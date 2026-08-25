/// AUTHENTICATION FEATURE — DOMAIN LAYER: USE CASE
///
/// Fetches the user's profile (name, phone) from storage.
///
/// CLEAN ARCHITECTURE:
/// - Depends ONLY on domain repository interface
/// - No knowledge of SecureStorage, Firestore, or UI frameworks
/// - Single responsibility: retrieve user profile data
/// ---------------------------------------------------------------------------
library;

import '../repositories/pin_repository.dart';

class GetUserProfile {
  final PinRepository _repository;

  const GetUserProfile(this._repository);

  Future<Map<String, String>?> call(String uid) {
    return _repository.getUserProfile(uid);
  }
}
