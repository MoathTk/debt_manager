/// AUTHENTICATION FEATURE — DOMAIN LAYER: USE CASE
///
/// Checks whether a user already has a PIN configured.
///
/// CLEAN ARCHITECTURE:
/// - Depends ONLY on domain repository interface
/// - No knowledge of SecureStorage, Firestore, or UI frameworks
/// - Single responsibility: check PIN existence
/// ---------------------------------------------------------------------------
library;

import '../repositories/pin_repository.dart';

class CheckHasPin {
  final PinRepository _repository;

  const CheckHasPin(this._repository);

  Future<bool> call(String uid) {
    return _repository.hasPin(uid);
  }
}
