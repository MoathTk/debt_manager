library;

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_debt_management/data/database_helper.dart';
import 'package:local_debt_management/services/auth_service.dart';
import 'package:local_debt_management/services/connectivity_service.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/usecases/check_subscription.dart';
import '../../domain/usecases/activate_trial.dart';
import '../../data/datasources/subscription_local_datasource.dart';
import '../../data/datasources/subscription_remote_datasource.dart';
import '../../data/repositories/subscription_repository_impl.dart';
import 'subscription_state.dart';

final subscriptionRepositoryProvider =
    Provider<SubscriptionRepositoryImpl>((_) {
  return SubscriptionRepositoryImpl(
    SubscriptionLocalDatasource(DatabaseHelper.instance),
    SubscriptionRemoteDatasource(FirebaseFirestore.instance),
  );
});

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final CheckSubscription _check;
  final ActivateTrial _activateTrial;
  final AuthService _auth;
  Timer? _retryTimer;

  SubscriptionNotifier(this._check, this._activateTrial, this._auth)
      : super(const SubscriptionState()) {
    load();
    _retryTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => load(),
    );
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  Future<void> load() async {
    final uid = _auth.ownerId;
    if (uid == null) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final sub = await _check(uid);
      state = state.copyWith(isLoading: false, subscription: sub);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> activateTrial() async {
    final uid = _auth.ownerId;
    if (uid == null) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = _auth.currentUser;
      final sub = await _activateTrial(
        uid,
        userName: user?.displayName ?? '',
        userEmail: user?.email ?? '',
      );
      state = state.copyWith(isLoading: false, subscription: sub);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  bool get isBlocked {
    return state.subscription?.status == SubscriptionStatus.blocked;
  }
}

final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  final auth = ref.watch(authServiceProvider);
  final repo = ref.watch(subscriptionRepositoryProvider);
  final check = CheckSubscription(repo, ConnectivityService());
  final activateTrial = ActivateTrial(repo);
  return SubscriptionNotifier(check, activateTrial, auth);
});
