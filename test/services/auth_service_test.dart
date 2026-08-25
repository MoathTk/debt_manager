import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:local_debt_management/services/auth_service.dart';

/// In-memory fake for the flutter_secure_storage platform channel.
/// The plugin talks to Android Keystore / iOS Keychain via a method channel,
/// which does not exist in the test environment. This mock stores values in a
/// plain map so ClockIntegrityService.clear()/init() can run during tests.
final Map<String, String> _secureStorage = {};

void _mockSecureStorageChannel() {
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  TestWidgetsFlutterBinding.ensureInitialized();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async {
    switch (call.method) {
      case 'read':
        return _secureStorage[call.arguments['key']];
      case 'write':
        _secureStorage[call.arguments['key']] = call.arguments['value'];
        return true;
      case 'delete':
        _secureStorage.remove(call.arguments['key']);
        return true;
      case 'deleteAll':
        _secureStorage.clear();
        return true;
      case 'containsKey':
        return _secureStorage.containsKey(call.arguments['key']);
      case 'readAll':
        return Map<String, String>.from(_secureStorage);
      default:
        return null;
    }
  });
}

void main() {
  setUp(() {
    _secureStorage.clear();
    _mockSecureStorageChannel();
  });

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

    group('signOut', () {
      test('clears current user', () async {
        final mockUser = MockUser(uid: 'uid-3');
        final auth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
        final service = AuthService(auth: auth);

        expect(service.currentUser, isNotNull);
        await service.signOut();
        expect(service.currentUser, null);
      });

      test('ownerId is null after sign out', () async {
        final mockUser = MockUser(uid: 'uid-4');
        final auth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
        final service = AuthService(auth: auth);

        await service.signOut();
        expect(service.ownerId, null);
      });
    });
  });
}
