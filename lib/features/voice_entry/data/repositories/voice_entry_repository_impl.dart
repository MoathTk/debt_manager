/// VOICE ENTRY FEATURE — DATA LAYER: REPOSITORY IMPLEMENTATION
///
/// Implements the abstract [VoiceEntryRepository] interface from the domain layer.
/// Delegates to [AiParsingDatasource] for the actual AI API communication.
///
/// ARCHITECTURE RULE: This is the ONLY place that knows about the AI API.
/// The domain layer and presentation layer never see this implementation.
/// ---------------------------------------------------------------------------
library;

import '../../domain/entities/voice_parsed_debt.dart';
import '../../domain/exceptions/voice_entry_exception.dart';
import '../../domain/repositories/voice_entry_repository.dart';
import '../datasources/ai_parsing_datasource.dart';

class VoiceEntryRepositoryImpl implements VoiceEntryRepository {
  final AiParsingDatasource _aiDatasource;

  VoiceEntryRepositoryImpl(this._aiDatasource);

  @override
  Future<String> transcribeAudio(String filePath) async {
    return _aiDatasource.transcribeAudio(filePath);
  }

  @override
  Future<VoiceParsedDebt> parseTranscript(String transcript) async {
    if (transcript.trim().isEmpty) {
      throw const AiParsingException('Empty transcript');
    }
    return _aiDatasource.parse(transcript);
  }
}
