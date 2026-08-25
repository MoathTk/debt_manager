/// AUTHENTICATION FEATURE — DOMAIN LAYER: REPOSITORY INTERFACE
///
/// Contract for PIN management operations (hash, store, validate).
/// The domain layer says: "I need to save and verify PINs,
/// but I don't care HOW they're stored."
///
/// ARCHITECTURE RULE: This file must never import from data/ or presentation/.
/// ---------------------------------------------------------------------------
library;

abstract class PinRepository {
  Future<void> savePin({
    required String uid,
    required String pin,
    required String name,
    required String phone,
  });

  Future<bool> hasPin(String uid);

  Future<bool> validatePin({
    required String uid,
    required String pin,
  });

  Future<Map<String, String>?> getUserProfile(String uid);

  Future<void> clearPin(String uid);
}
