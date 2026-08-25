/// AUTHENTICATION FEATURE — DOMAIN LAYER: USE CASE
///
/// Validates a PIN against the stored hash.
///
/// CLEAN ARCHITECTURE:
/// - Depends ONLY on domain repository interface
/// - No knowledge of SecureStorage, Firestore, or UI frameworks
/// - Single responsibility: verify PIN correctness
/// ---------------------------------------------------------------------------
library;

import '../repositories/pin_repository.dart';

class ValidatePin {
  final PinRepository _repository;

  const ValidatePin(this._repository);

  Future<bool> call({
    required String uid,
    required String pin,
  }) {
    return _repository.validatePin(uid: uid, pin: pin);
  }
}
