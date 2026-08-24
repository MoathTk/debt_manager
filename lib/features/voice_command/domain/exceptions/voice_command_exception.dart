/// VOICE COMMAND FEATURE — DOMAIN LAYER: EXCEPTIONS
///
/// Typed exceptions specific to the voice command feature.
/// All exceptions inherit from [VoiceCommandException] for easy catching.
///
/// ARCHITECTURE RULE: Only the domain and data layers throw these.
/// The presentation layer catches them and maps to user-friendly messages.
/// ---------------------------------------------------------------------------
library;

/// Base exception for all voice command errors.
class VoiceCommandException implements Exception {
  final String message;
  final Object? cause;

  const VoiceCommandException(this.message, [this.cause]);

  @override
  String toString() => 'VoiceCommandException: $message';
}

/// API key is missing or invalid.
class ApiKeyNotConfiguredException extends VoiceCommandException {
  const ApiKeyNotConfiguredException([
    super.message = 'API key not configured',
  ]);
}

/// No internet connection available.
class NoInternetException extends VoiceCommandException {
  const NoInternetException([
    super.message = 'No internet connection',
  ]);
}

/// Transcription returned empty or no speech was detected.
class NoSpeechDetectedException extends VoiceCommandException {
  const NoSpeechDetectedException([
    super.message = 'No speech detected in recording',
  ]);
}

/// AI could not determine the action from the command.
class UnknownActionException extends VoiceCommandException {
  const UnknownActionException([
    super.message = 'Could not understand the command',
  ]);
}
