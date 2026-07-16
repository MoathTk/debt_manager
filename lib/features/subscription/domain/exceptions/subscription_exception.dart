/// SUBSCRIPTION FEATURE — DOMAIN LAYER: EXCEPTIONS
///
/// Custom exceptions that the subscription feature can throw.
/// These live in the domain layer so both data and presentation
/// layers can reference them without circular dependencies.
///
/// WHY CUSTOM EXCEPTIONS?
/// - Generic exceptions hide the cause (was it network? DB? parsing?)
/// - Custom exceptions let callers handle each failure mode specifically
/// - They carry context (e.g., which operation failed, what the error was)
///
/// HIERARCHY:
/// - SubscriptionException (base)
///   ├── RequiresInternetException — offline + no cache
///   ├── SubscriptionLocalException — SQLite read/write failed
///   ├── SubscriptionRemoteException — Firestore read/write failed
///   └── SubscriptionParsingException — data format invalid
/// ---------------------------------------------------------------------------
library;

/// Base exception for all subscription-related errors.
abstract class SubscriptionException implements Exception {
  final String message;
  final Object? cause;
  const SubscriptionException(this.message, [this.cause]);
}

/// Thrown when the app cannot verify subscription:
/// user is offline AND has no local cache.
class RequiresInternetException extends SubscriptionException {
  const RequiresInternetException()
      : super('Connect to internet to verify subscription');
}

/// Thrown when a SQLite operation fails (read, write, or delete).
class SubscriptionLocalException extends SubscriptionException {
  const SubscriptionLocalException(String detail, [Object? cause])
      : super('Local database error: $detail', cause);
}

/// Thrown when a Firestore operation fails (read or write).
class SubscriptionRemoteException extends SubscriptionException {
  const SubscriptionRemoteException(String detail, [Object? cause])
      : super('Cloud sync error: $detail', cause);
}

/// Thrown when stored data cannot be parsed (corrupted or format changed).
class SubscriptionParsingException extends SubscriptionException {
  const SubscriptionParsingException(String detail, [Object? cause])
      : super('Data format error: $detail', cause);
}
