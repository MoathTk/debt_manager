/// VOICE COMMAND FEATURE — DATA LAYER: REPOSITORY IMPLEMENTATION
///
/// Implements [VoiceCommandRepository] using the shared [AiParsingDatasource].
/// Reuses the same OpenAI API client for transcription and command parsing.
///
/// ARCHITECTURE RULE: This is the ONLY place that knows about the AI API.
/// The domain layer never sees this implementation.
/// ---------------------------------------------------------------------------
library;

import '../../domain/exceptions/voice_command_exception.dart';
import '../../domain/repositories/voice_command_repository.dart';
import '../../../voice_entry/data/datasources/ai_parsing_datasource.dart';
import '../../domain/entities/voice_command.dart';

class VoiceCommandRepositoryImpl implements VoiceCommandRepository {
  final AiParsingDatasource _aiDatasource;

  VoiceCommandRepositoryImpl(this._aiDatasource);

  @override
  Future<String> transcribeAudio(String filePath) async {
    return _aiDatasource.transcribeAudio(filePath);
  }

  @override
  Future<VoiceCommand> parseVoiceCommand(String transcript) async {
    if (transcript.trim().isEmpty) {
      throw const VoiceCommandException('Empty transcript');
    }
    return _aiDatasource.parseVoiceCommand(transcript);
  }
}
