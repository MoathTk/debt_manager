/// VOICE ENTRY FEATURE — PRESENTATION LAYER: PROVIDER
///
/// Manages the record → transcribe → parse flow.
/// Uses record package for audio capture and OpenAI for transcription + parsing.
/// ---------------------------------------------------------------------------
library;

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:local_debt_management/services/connectivity_service.dart';
import '../../domain/exceptions/voice_entry_exception.dart';
import '../../domain/usecases/transcribe_audio.dart';
import '../../domain/usecases/parse_voice_transcript.dart';
import '../../data/datasources/ai_parsing_datasource.dart';
import '../../data/repositories/voice_entry_repository_impl.dart';
import 'voice_entry_state.dart';
import '../../domain/entities/voice_parsed_debt.dart';

final voiceEntryProvider =
    StateNotifierProvider.autoDispose<VoiceEntryNotifier, VoiceEntryState>((
      ref,
    ) {
      final datasource = AiParsingDatasource(
        apiKey: const String.fromEnvironment('OPENAI_API_KEY'),
      );
      final repo = VoiceEntryRepositoryImpl(datasource);
      return VoiceEntryNotifier(
        TranscribeAudio(repo),
        ParseVoiceTranscript(repo),
      );
    });

class VoiceEntryNotifier extends StateNotifier<VoiceEntryState> {
  final TranscribeAudio _transcribeAudio;
  final ParseVoiceTranscript _parseTranscript;
  final AudioRecorder _recorder = AudioRecorder();
  StreamSubscription<Amplitude>? _ampSub;

  VoiceEntryNotifier(this._transcribeAudio, this._parseTranscript)
    : super(const VoiceEntryState());

  Future<void> startRecording() async {
    const apiKey = String.fromEnvironment('OPENAI_API_KEY');
    if (apiKey.isEmpty) {
      state = state.copyWith(
        status: VoiceEntryStatus.error,
        error: 'api_key_not_configured',
      );
      return;
    }

    try {
      if (!await _recorder.hasPermission()) {
        state = state.copyWith(
          status: VoiceEntryStatus.error,
          error: 'no_speech_detected',
        );
        return;
      }
    } catch (e) {
      state = state.copyWith(
        status: VoiceEntryStatus.error,
        error: 'no_speech_detected',
      );
      return;
    }

    final tempDir = Directory.systemTemp;
    final path =
        '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

    try {
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
          numChannels: 1,
        ),
        path: path,
      );
    } catch (e) {
      state = state.copyWith(
        status: VoiceEntryStatus.error,
        error: 'no_speech_detected',
      );
      return;
    }

    state = state.copyWith(
      status: VoiceEntryStatus.recording,
      clearError: true,
      clearParsedDebt: true,
      clearTranscript: true,
      recordingStarted: DateTime.now(),
      soundLevel: 0.0,
      recordedFilePath: path,
    );

    _ampSub = _recorder
        .onAmplitudeChanged(const Duration(milliseconds: 200))
        .listen((amp) {
      if (!mounted || !state.isRecording) return;
      final normalized = pow(10, amp.current / 20).clamp(0.0, 1.0);
      state = state.copyWith(soundLevel: normalized.toDouble());
    });
  }

  Future<void> stopRecording() async {
    await _ampSub?.cancel();
    _ampSub = null;

    String? path;
    try {
      path = await _recorder.stop();
    } catch (_) {}

    if (!mounted) return;

    if (path == null || path.isEmpty) {
      state = state.copyWith(
        status: VoiceEntryStatus.error,
        error: 'no_speech_detected',
        clearRecordingStarted: true,
        soundLevel: 0.0,
      );
      return;
    }

    await _processAudio(path);
  }

  Future<void> retryParsing() async {
    final transcript = state.transcript;
    if (transcript == null || transcript.isEmpty) return;
    await _runParsing(transcript);
  }

  void updateParsedDebt(VoiceParsedDebt updated) {
    if (mounted) {
      state = state.copyWith(parsedDebt: updated);
    }
  }

  void reRecord() {
    reset();
    startRecording();
  }

  Future<void> _processAudio(String filePath) async {
    if (!mounted) return;

    state = state.copyWith(
      status: VoiceEntryStatus.transcribing,
      clearRecordingStarted: true,
      soundLevel: 0.0,
    );

    if (!await ConnectivityService().checkConnection()) {
      if (mounted) {
        state = state.copyWith(
          status: VoiceEntryStatus.error,
          error: 'no_internet',
        );
      }
      return;
    }

    try {
      final transcript = await _transcribeAudio(filePath);
      if (!mounted) return;
      state = state.copyWith(transcript: transcript);
      await _runParsing(transcript);
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

  Future<void> _runParsing(String transcript) async {
    if (!mounted) return;

    state = state.copyWith(status: VoiceEntryStatus.parsing);

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
    _ampSub?.cancel();
    _ampSub = null;
    _recorder.stop();
    state = const VoiceEntryState();
  }

  @override
  void dispose() {
    _ampSub?.cancel();
    _recorder.dispose();
    super.dispose();
  }
}
