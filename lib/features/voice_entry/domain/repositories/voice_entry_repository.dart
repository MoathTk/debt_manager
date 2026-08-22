/// VOICE ENTRY FEATURE — DOMAIN LAYER: REPOSITORY INTERFACE
///
/// This is the "contract" that the data layer must implement.
/// The domain layer says: "I need to parse voice transcripts into
/// structured debt data, but I don't care HOW — GPT? Gemini? Local ML?"
///
/// This is the Dependency Inversion Principle (D):
/// - Domain defines the interface
/// - Data layer implements it
/// - Use cases depend on the interface, not the implementation
///
/// ARCHITECTURE RULE: This file must never import from data/ or presentation/.
/// ---------------------------------------------------------------------------
library;

import '../entities/voice_parsed_debt.dart';

abstract class VoiceEntryRepository {
  /// Parse a voice transcript into structured debt data.
  ///
  /// Takes a raw transcript string (from speech-to-text) and returns
  /// a [VoiceParsedDebt] containing extracted items, total amount,
  /// and optional due date.
  ///
  /// Throws [AiParsingException] if the AI API call fails.
  /// Throws [NoInternetForVoiceException] if offline.
  Future<VoiceParsedDebt> parseTranscript(String transcript);
}
