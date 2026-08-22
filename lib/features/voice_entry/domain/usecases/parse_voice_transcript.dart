/// VOICE ENTRY FEATURE — DOMAIN LAYER: PARSE VOICE TRANSCRIPT USE CASE
///
/// A use case encapsulates a single business action.
/// "ParseVoiceTranscript" answers: "What debt items did the shopkeeper say?"
///
/// USE CASE RULES:
/// - Each use case does ONE thing (Single Responsibility)
/// - It calls the repository (abstract interface) — never touches
///   the AI API directly
/// - Business logic lives here; UI and data details do NOT
/// ---------------------------------------------------------------------------
library;

import '../entities/voice_parsed_debt.dart';
import '../repositories/voice_entry_repository.dart';

class ParseVoiceTranscript {
  final VoiceEntryRepository repo;

  ParseVoiceTranscript(this.repo);

  /// Parse a raw transcript into structured debt data.
  ///
  /// [transcript] — the text output from speech-to-text.
  /// Returns [VoiceParsedDebt] with items, total, and optional due date.
  Future<VoiceParsedDebt> call(String transcript) {
    return repo.parseTranscript(transcript);
  }
}
