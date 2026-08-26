/// Barrel file — re-exports auth providers and repositories from the
/// authentication feature, plus a legacy [AuthService] wrapper for backward
/// compatibility with existing consumer code.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_debt_management/Providers/database_provider.dart';
import 'package:local_debt_management/Providers/sync_provider.dart';
import 'package:local_debt_management/features/subscription/presentation/providers/subscription_provider.dart';
import 'package:local_debt_management/data/database_helper.dart';
import 'package:local_debt_management/services/clock_integrity_service.dart';
import 'package:local_debt_management/services/online_status_service.dart';
import 'package:local_debt_management/features/authentication/data/repositories/pin_repository_impl.dart';

export 'package:local_debt_management/features/authentication/data/providers/auth_providers.dart'
    show authUserProvider;

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.read(authServiceProvider).authStateChanges;
});

class AuthService {
  final FirebaseAuth _auth;

  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  String? get ownerId => _auth.currentUser?.uid;

  Future<void> signOut([WidgetRef? ref]) async {
    final uid = _auth.currentUser?.uid;
    OnlineStatusService.instance.dispose();
    if (uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'isOnline': false,
        'lastSeen': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    await DatabaseHelper.instance.close();
    await ClockIntegrityService.clear();
    if (uid != null) await PinRepositoryImpl().clearPin(uid);
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
    await _auth.signOut();
  }
}
