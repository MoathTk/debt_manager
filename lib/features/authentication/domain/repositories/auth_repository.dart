/// AUTHENTICATION FEATURE — DOMAIN LAYER: REPOSITORY INTERFACE
///
/// Contract for Firebase phone authentication operations.
///
/// ARCHITECTURE RULE: This file must never import from data/ or presentation/.
/// ---------------------------------------------------------------------------
library;

import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  User? get currentUser;

  Stream<User?> get authStateChanges;

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(PhoneAuthCredential credential) verificationCompleted,
    required void Function(FirebaseAuthException error) verificationFailed,
    required void Function(String verificationId, int? resendToken) codeSent,
    required void Function(String verificationId) codeAutoRetrievalTimeout,
    int? resendToken,
  });

  Future<UserCredential> verifySmsCode({
    required String verificationId,
    required String smsCode,
  });

  Future<void> signOut();
}
