/// VOICE ENTRY FEATURE — PRESENTATION LAYER: PROVIDER
///
/// Manages the voice recording → transcription → AI parsing flow.
/// Uses speech_to_text for on-device speech recognition and
/// ParseVoiceTranscript use case for AI parsing.
/// ---------------------------------------------------------------------------
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:local_debt_management/services/connectivity_service.dart';
import '../../domain/exceptions/voice_entry_exception.dart';
import '../../domain/usecases/parse_voice_transcript.dart';
import '../../data/datasources/ai_parsing_datasource.dart';
import '../../data/repositories/voice_entry_repository_impl.dart';
import 'voice_entry_state.dart';

/// Provider for the voice entry notifier.
///
/// Uses a compile-time environment variable for the API key.
/// Pass --dart-define=OPENAI_API_KEY=your_key at build time.
/// The provider is autoDispose since voice entry is session-based.
final voiceEntryProvider =
    StateNotifierProvider.autoDispose<VoiceEntryNotifier, VoiceEntryState>((
      ref,
    ) {
      final parseTranscript = ParseVoiceTranscript(
        VoiceEntryRepositoryImpl(
          AiParsingDatasource(
            apiKey: const String.fromEnvironment('GEMINI_API_KEY'),
          ),
        ),
      );
      return VoiceEntryNotifier(parseTranscript);
    });

class VoiceEntryNotifier extends StateNotifier<VoiceEntryState> {
  final ParseVoiceTranscript _parseTranscript;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechInitialized = false;
  bool _processing = false;
  String _localeId = 'ar-IQ';
  String _committedTranscript = '';

  VoiceEntryNotifier(this._parseTranscript) : super(const VoiceEntryState());

  Future<void> _initSpeech() async {
    if (_speechInitialized) return;
    final available = await _speech.initialize(
      onError: (error) {
        if (mounted && !state.isRecording) {
          state = state.copyWith(
            status: VoiceEntryStatus.error,
            error: error.errorMsg,
          );
        }
      },
    );
    if (!available) {
      throw const SpeechRecognitionException(
        'Speech recognition not available on this device',
      );
    }
    _speechInitialized = true;
  }

  void _onSpeechResult(dynamic result) {
    if (!mounted || !state.isRecording) return;
    final words = result.recognizedWords as String? ?? '';
    if (words.isEmpty) return;
    final isFinal = result.finalResult as bool? ?? false;
    final currentTranscript = state.transcript ?? '';

    // Detect new session: the engine reset and gave us fresh words
    // that don't include what we already have
    final isOldSessionDone =
        currentTranscript.isNotEmpty &&
        words != currentTranscript &&
        !words.startsWith(currentTranscript);
    if (isOldSessionDone) {
      _committedTranscript = currentTranscript;
    }

    final full = _committedTranscript.isEmpty
        ? words
        : '$_committedTranscript $words';

    state = state.copyWith(transcript: full);

    if (isFinal) {
      _committedTranscript = full;
    }
  }

  static const _arabicLocalePriority = [
    'ar-IQ',
    'ar-SA',
    'ar-AE',
    'ar-EG',
    'ar-MA',
    'ar-TN',
    'ar',
  ];

  Future<String> _detectArabicLocale() async {
    try {
      final locales = await _speech.locales();
      for (final preferred in _arabicLocalePriority) {
        if (locales.any((l) => l.localeId == preferred)) {
          return preferred;
        }
      }
      if (locales.any((l) => l.localeId.startsWith('ar'))) {
        return 'ar';
      }
    } catch (_) {}
    return 'ar-IQ';
  }

  Future<void> startRecording() async {
    try {
      await _initSpeech();
      _processing = false;
      _committedTranscript = '';

      _localeId = await _detectArabicLocale();

      state = state.copyWith(
        status: VoiceEntryStatus.recording,
        clearError: true,
        clearParsedDebt: true,
        clearTranscript: true,
      );

      await _speech.listen(
        onResult: _onSpeechResult,
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.deviceDefault,
          cancelOnError: true,
          partialResults: true,
          localeId: _localeId,
          pauseFor: const Duration(minutes: 5),
          listenFor: const Duration(minutes: 5),
        ),
      );
    } on VoiceEntryException {
      rethrow;
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          status: VoiceEntryStatus.error,
          error: e.toString(),
        );
      }
    }
  }

  Future<void> stopRecording() async {
    // Stop speech first — this may trigger a final onResult callback
    try {
      await _speech.stop().timeout(const Duration(seconds: 2));
    } catch (_) {}

    // Small delay to let any pending onResult callback update state.transcript
    await Future.delayed(const Duration(milliseconds: 400));

    final transcript = state.transcript;

    // Force UI out of "Listening..."
    if (mounted) {
      state = state.copyWith(status: VoiceEntryStatus.idle);
    }

    if (_processing) return;
    if (transcript != null && transcript.isNotEmpty) {
      await _processTranscript(transcript);
    } else if (mounted) {
      state = state.copyWith(
        status: VoiceEntryStatus.error,
        error: 'No speech detected. Please try again.',
      );
    }
  }

  Future<void> _processTranscript(String transcript) async {
    if (!mounted || _processing) return;
    _processing = true;
    state = state.copyWith(
      status: VoiceEntryStatus.transcribing,
      transcript: transcript,
    );

    if (!await ConnectivityService().checkConnection()) {
      if (mounted) {
        state = state.copyWith(
          status: VoiceEntryStatus.error,
          error: 'Requires internet connection',
        );
      }
      return;
    }

    if (mounted) {
      state = state.copyWith(status: VoiceEntryStatus.parsing);
    }

    try {
      final result = await _parseTranscript(transcript);
      if (mounted) {
        state = state.copyWith(
          status: VoiceEntryStatus.ready,
          parsedDebt: result,
        );
      }
    } on VoiceEntryException catch (e) {
      if (mounted) {
        state = state.copyWith(
          status: VoiceEntryStatus.error,
          error: e.message,
        );
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          status: VoiceEntryStatus.error,
          error: e.toString(),
        );
      }
    }
  }

  void reset() {
    _committedTranscript = '';
    state = const VoiceEntryState();
  }

  @override
  void dispose() {
    _speech.cancel();
    super.dispose();
  }
}
