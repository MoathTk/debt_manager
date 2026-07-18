import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_debt_management/Providers/database_provider.dart';
import 'package:local_debt_management/Providers/sync_provider.dart';
import 'package:local_debt_management/features/subscription/presentation/providers/subscription_provider.dart';
import '../data/database_helper.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.read(authServiceProvider).authStateChanges;
});

class AuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _google;

  AuthService({FirebaseAuth? auth, GoogleSignIn? google})
    : _auth = auth ?? FirebaseAuth.instance,
      _google = google ?? GoogleSignIn(scopes: ['email']);

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  String? get ownerId => _auth.currentUser?.uid;

  Future<UserCredential?> signInWithGoogle() async {
    final googleUser = await _google.signIn();
    if (googleUser == null) return null;
    final auth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );
    return await _auth.signInWithCredential(credential);
  }

  Future<void> signOut([WidgetRef? ref]) async {
    await DatabaseHelper.instance.close();
    if (ref != null) {
      ref.invalidate(customersProvider);
      ref.invalidate(transactionsProvider);
      ref.invalidate(pendingRemindersProvider);
      ref.invalidate(allRemindersProvider);
      ref.invalidate(dueTodayProvider);
      ref.invalidate(dashboardStatsProvider);
      ref.invalidate(syncProvider);
      ref.invalidate(subscriptionProvider);
    }
    await Future.wait([_google.signOut(), _auth.signOut()]);
  }
}
