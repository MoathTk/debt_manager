import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_debt_management/services/auth_service.dart';

class _FakeGoogleSignIn implements GoogleSignIn {
  @override
  Future<GoogleSignInAccount?> signIn() async => null;
  @override
  Future<GoogleSignInAccount?> signOut() async => null;
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  group('AuthService', () {
    group('ownerId', () {
      test('returns null when not logged in', () {
        final auth = MockFirebaseAuth();
        final service = AuthService(auth: auth);
        expect(service.ownerId, null);
      });

      test('returns uid when logged in', () {
        final mockUser = MockUser(uid: 'test-uid-123');
        final auth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
        final service = AuthService(auth: auth);
        expect(service.ownerId, 'test-uid-123');
      });
    });

    group('currentUser', () {
      test('returns null when not logged in', () {
        final auth = MockFirebaseAuth();
        final service = AuthService(auth: auth);
        expect(service.currentUser, null);
      });

      test('returns user when signed in', () {
        final mockUser = MockUser(uid: 'uid-1', email: 'test@test.com');
        final auth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
        final service = AuthService(auth: auth);
        expect(service.currentUser, isNotNull);
        expect(service.currentUser!.uid, 'uid-1');
        expect(service.currentUser!.email, 'test@test.com');
      });
    });

    group('authStateChanges', () {
      test('emits null when not logged in', () async {
        final auth = MockFirebaseAuth();
        final service = AuthService(auth: auth);
        expect(service.authStateChanges, emits(null));
      });

      test('emits user when logged in', () async {
        final mockUser = MockUser(uid: 'uid-2');
        final auth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
        final service = AuthService(auth: auth);
        final user = await service.authStateChanges.first;
        expect(user, isNotNull);
        expect(user!.uid, 'uid-2');
      });
    });

    group('signInWithGoogle', () {
      test('returns null when Google sign-in is cancelled', () async {
        final google = _FakeGoogleSignIn();
        final mockUser = MockUser(uid: 'google-uid', email: 'g@g.com');
        final auth = MockFirebaseAuth(mockUser: mockUser);
        final service = AuthService(auth: auth, google: google);
        final result = await service.signInWithGoogle();
        expect(result, null);
      });
    });

    group('signOut', () {
      test('clears current user', () async {
        final mockUser = MockUser(uid: 'uid-3');
        final auth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
        final service = AuthService(auth: auth, google: _FakeGoogleSignIn());

        expect(service.currentUser, isNotNull);
        await service.signOut();
        expect(service.currentUser, null);
      });

      test('ownerId is null after sign out', () async {
        final mockUser = MockUser(uid: 'uid-4');
        final auth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
        final service = AuthService(auth: auth, google: _FakeGoogleSignIn());

        await service.signOut();
        expect(service.ownerId, null);
      });
    });
  });
}
