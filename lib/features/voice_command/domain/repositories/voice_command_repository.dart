/// VOICE COMMAND FEATURE — DOMAIN LAYER: REPOSITORY INTERFACE
///
/// Contract for the voice command data layer.
/// The domain layer says: "I need to transcribe audio and parse it into a
/// command action, but I don't care HOW."
///
/// ARCHITECTURE RULE: This file must never import from data/ or presentation/.
/// ---------------------------------------------------------------------------
library;

import '../entities/voice_command.dart';

abstract class VoiceCommandRepository {
  /// Transcribe an audio file to text (supports Arabic/Iraqi dialect).
  Future<String> transcribeAudio(String filePath);

  /// Parse a transcript into a structured [VoiceCommand] with detected action.
  Future<VoiceCommand> parseVoiceCommand(String transcript);
}
