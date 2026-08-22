/// VOICE ENTRY FEATURE — PRESENTATION LAYER: STATE
///
/// Immutable state class for the voice entry feature.
/// Managed by [VoiceEntryNotifier] via Riverpod's StateNotifier.
/// ---------------------------------------------------------------------------
library;

import '../../domain/entities/voice_parsed_debt.dart';

enum VoiceEntryStatus { idle, recording, transcribing, parsing, ready, error }

class VoiceEntryState {
  final VoiceEntryStatus status;
  final String? transcript;
  final VoiceParsedDebt? parsedDebt;
  final String? error;

  const VoiceEntryState({
    this.status = VoiceEntryStatus.idle,
    this.transcript,
    this.parsedDebt,
    this.error,
  });

  VoiceEntryState copyWith({
    VoiceEntryStatus? status,
    bool clearTranscript = false,
    String? transcript,
    bool clearParsedDebt = false,
    VoiceParsedDebt? parsedDebt,
    bool clearError = false,
    String? error,
  }) {
    return VoiceEntryState(
      status: status ?? this.status,
      transcript: clearTranscript ? null : (transcript ?? this.transcript),
      parsedDebt: clearParsedDebt ? null : (parsedDebt ?? this.parsedDebt),
      error: clearError ? null : (error ?? this.error),
    );
  }

  bool get isIdle => status == VoiceEntryStatus.idle;
  bool get isRecording => status == VoiceEntryStatus.recording;
  bool get isTranscribing => status == VoiceEntryStatus.transcribing;
  bool get isParsing => status == VoiceEntryStatus.parsing;
  bool get isReady => status == VoiceEntryStatus.ready;
  bool get isError => status == VoiceEntryStatus.error;
  bool get isProcessing => isTranscribing || isParsing;
}
