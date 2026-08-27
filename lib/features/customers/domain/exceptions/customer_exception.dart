/// CUSTOMERS FEATURE — DOMAIN LAYER: EXCEPTIONS
///
/// Custom exceptions that the customers feature can throw.
/// These live in the domain layer so both data and presentation
/// layers can reference them without circular dependencies.
///
/// HIERARCHY:
/// - CustomerException (base)
///   ├── CustomerNotFoundException — looked up but missing
///   ├── CustomerValidationException — invalid input
///   └── CustomerStorageException — local DB read/write failed
/// ---------------------------------------------------------------------------
library;

/// Base exception for all customer-related errors.
abstract class CustomerException implements Exception {
  final String message;
  final Object? cause;
  const CustomerException(this.message, [this.cause]);
}

/// Thrown when a customer that was expected to exist is missing.
class CustomerNotFoundException extends CustomerException {
  const CustomerNotFoundException(String id)
    : super('Customer not found: $id');
}

/// Thrown when customer input fails validation (e.g., empty name).
class CustomerValidationException extends CustomerException {
  const CustomerValidationException(String detail)
    : super('Invalid customer data: $detail');
}

/// Thrown when a local database operation fails (read, write, or delete).
class CustomerStorageException extends CustomerException {
  const CustomerStorageException(String detail, [Object? cause])
    : super('Local database error: $detail', cause);
}