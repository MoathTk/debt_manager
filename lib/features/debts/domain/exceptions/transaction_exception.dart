/// DEBTS FEATURE — DOMAIN LAYER: EXCEPTIONS
///
/// Custom exceptions that the debts feature can throw.
/// These live in the domain layer so both data and presentation
/// layers can reference them without circular dependencies.
///
/// HIERARCHY:
/// - TransactionException (base)
///   ├── TransactionNotFoundException — looked up but missing
///   ├── TransactionValidationException — invalid input
///   └── TransactionStorageException — local DB read/write failed
/// ---------------------------------------------------------------------------
library;

/// Base exception for all transaction-related errors.
abstract class TransactionException implements Exception {
  final String message;
  final Object? cause;
  const TransactionException(this.message, [this.cause]);
}

/// Thrown when a transaction that was expected to exist is missing.
class TransactionNotFoundException extends TransactionException {
  const TransactionNotFoundException(String id)
    : super('Transaction not found: $id');
}

/// Thrown when transaction input fails validation (e.g., amount <= 0).
class TransactionValidationException extends TransactionException {
  const TransactionValidationException(String detail)
    : super('Invalid transaction data: $detail');
}

/// Thrown when a local database operation fails (read, write, or delete).
class TransactionStorageException extends TransactionException {
  const TransactionStorageException(String detail, [Object? cause])
    : super('Local database error: $detail', cause);
}
