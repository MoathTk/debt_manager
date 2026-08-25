/// AUTHENTICATION FEATURE — DOMAIN LAYER: USE CASE
///
/// Orchestrates phone number verification initiation.
///
/// CLEAN ARCHITECTURE:
/// - Depends ONLY on domain entities and repository interface
/// - No knowledge of Firebase, Firestore, or UI frameworks
/// - Single responsibility: delegate phone verification to the repository
/// ---------------------------------------------------------------------------
library;

import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';

class SendOtp {
  final AuthRepository _repository;

  const SendOtp(this._repository);

  Future<void> call({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) codeSent,
    required void Function(String error) verificationFailed,
    required void Function(PhoneAuthCredential credential) autoVerify,
    required void Function(String verificationId) timeout,
    int? resendToken,
  }) {
    return _repository.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: autoVerify,
      verificationFailed: (e) => verificationFailed(
        e.message ?? 'Verification failed',
      ),
      codeSent: codeSent,
      codeAutoRetrievalTimeout: timeout,
      resendToken: resendToken,
    );
  }
}
