/// VOICE ENTRY FEATURE — DOMAIN LAYER: EXCEPTIONS
///
/// Custom exceptions that the voice entry feature can throw.
/// These live in the domain layer so both data and presentation
/// layers can reference them without circular dependencies.
///
/// HIERARCHY:
/// - VoiceEntryException (base)
///   ├── SpeechRecognitionException — speech-to-text failed
///   ├── AiParsingException — GPT-4o mini API call failed
///   └── NoInternetForVoiceException — offline, can't parse
/// ---------------------------------------------------------------------------
library;

/// Base exception for all voice entry errors.
abstract class VoiceEntryException implements Exception {
  final String message;
  final Object? cause;
  const VoiceEntryException(this.message, [this.cause]);
}

/// Thrown when speech recognition fails (permission denied, device error, etc.).
class SpeechRecognitionException extends VoiceEntryException {
  const SpeechRecognitionException(String detail, [Object? cause])
    : super('Speech recognition failed: $detail', cause);
}

class NotUnderstoodException extends VoiceEntryException {
  const NotUnderstoodException(String detail, [Object? cause])
    : super('not understood: $detail', cause);
}

/// Thrown when the AI API call fails (network, invalid response, rate limit).
class AiParsingException extends VoiceEntryException {
  const AiParsingException(String detail, [Object? cause])
    : super('AI parsing failed: $detail', cause);
}

/// Thrown when the device is offline and voice parsing requires internet.
class NoInternetForVoiceException extends VoiceEntryException {
  const NoInternetForVoiceException()
    : super('Voice input requires internet connection');
}
