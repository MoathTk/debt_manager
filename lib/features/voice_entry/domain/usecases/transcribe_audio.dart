/// VOICE ENTRY FEATURE — DOMAIN LAYER: TRANSCRIBE AUDIO USE CASE
///
/// Transcribes an audio file to text using OpenAI's transcription API.
/// ---------------------------------------------------------------------------
library;

import '../repositories/voice_entry_repository.dart';

class TranscribeAudio {
  final VoiceEntryRepository repo;

  TranscribeAudio(this.repo);

  /// Transcribe an audio file to text.
  ///
  /// [filePath] — path to the recorded audio file (.m4a).
  /// Returns the transcribed text.
  Future<String> call(String filePath) {
    return repo.transcribeAudio(filePath);
  }
}
