/// VOICE COMMAND FEATURE — DOMAIN LAYER: USE CASE
///
/// Orchestrates the voice command flow: transcribe audio → parse command.
/// Customer matching happens in the provider layer (presentation).
///
/// CLEAN ARCHITECTURE:
/// - Depends ONLY on domain entities and repository interface
/// - No knowledge of OpenAI, SQLite, or UI frameworks
/// - Single responsibility: coordinate transcription + command parsing
/// ---------------------------------------------------------------------------
library;

import '../entities/voice_command.dart';
import '../repositories/voice_command_repository.dart';

/// Processes an audio file into a structured [VoiceCommand].
///
/// Usage: `final command = await ProcessVoiceCommand(repo)(audioPath);`
class ProcessVoiceCommand {
  final VoiceCommandRepository _repository;

  const ProcessVoiceCommand(this._repository);

  /// Execute the voice command processing pipeline.
  ///
  /// 1. Transcribe the audio file to text
  /// 2. Parse the text into a structured command (action + details)
  ///
  /// Throws [VoiceCommandException] on failure.
  Future<VoiceCommand> call(String audioFilePath) async {
    final transcript = await _repository.transcribeAudio(audioFilePath);
    if (transcript.trim().isEmpty) {
      throw const EmptyTranscriptException();
    }
    return _repository.parseVoiceCommand(transcript);
  }
}

/// Thrown when transcription returns empty text.
class EmptyTranscriptException implements Exception {
  const EmptyTranscriptException();
  @override
  String toString() => 'EmptyTranscriptException: No speech detected';
}
