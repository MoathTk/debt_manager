/// AUTHENTICATION FEATURE — DOMAIN LAYER: USE CASE
///
/// Orchestrates SMS code verification and Firebase sign-in.
///
/// CLEAN ARCHITECTURE:
/// - Depends ONLY on domain entities and repository interface
/// - No knowledge of Firebase, Firestore, or UI frameworks
/// - Single responsibility: verify OTP and return credential result
/// ---------------------------------------------------------------------------
library;

import 'package:firebase_auth/firebase_auth.dart' show UserCredential;
import '../repositories/auth_repository.dart';

class VerifyOtp {
  final AuthRepository _repository;

  const VerifyOtp(this._repository);

  Future<UserCredential> call({
    required String verificationId,
    required String smsCode,
  }) {
    return _repository.verifySmsCode(
      verificationId: verificationId,
      smsCode: smsCode,
    );
  }
}
