/// AUTHENTICATION FEATURE — DOMAIN LAYER: USE CASE
///
/// Creates a new PIN for a user (hash + salt + Firestore profile).
///
/// CLEAN ARCHITECTURE:
/// - Depends ONLY on domain repository interface
/// - No knowledge of SecureStorage, Firestore, or UI frameworks
/// - Single responsibility: save PIN and user profile
/// ---------------------------------------------------------------------------
library;

import '../repositories/pin_repository.dart';

class SetUpPin {
  final PinRepository _repository;

  const SetUpPin(this._repository);

  Future<void> call({
    required String uid,
    required String pin,
    required String name,
    required String phone,
  }) {
    return _repository.savePin(
      uid: uid,
      pin: pin,
      name: name,
      phone: phone,
    );
  }
}
