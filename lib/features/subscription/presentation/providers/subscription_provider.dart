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
import '../../data/models/subscription_model.dart';
import '../../data/repositories/subscription_repository_impl.dart';
import 'subscription_state.dart';

final subscriptionRepositoryProvider = Provider<SubscriptionRepositoryImpl>((
  _,
) {
  return SubscriptionRepositoryImpl(
    SubscriptionLocalDatasource(DatabaseHelper.instance),
    SubscriptionRemoteDatasource(FirebaseFirestore.instance),
  );
});

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final CheckSubscription _check;
  final ActivateTrial _activateTrial;
  final AuthService _auth;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<DocumentSnapshot>? _userSub;
  StreamSubscription<DocumentSnapshot>? _adminSub;

  SubscriptionNotifier(this._check, this._activateTrial, this._auth)
    : super(const SubscriptionState()) {
    _init();
  }

  void _init() async {
    await load();
    if (!mounted) return;
    final uid = _auth.ownerId;
    if (uid != null) _listenToFirestore(uid);
  }

  void _listenToFirestore(String uid) {
    _userSub?.cancel();
    _adminSub?.cancel();

    _userSub = _firestore
        .collection('users')
        .doc(uid)
        .collection('subscription')
        .doc('status')
        .snapshots()
        .listen((doc) {
          if (!doc.exists || doc.data() == null) {
            state = state.copyWith(isLoading: false, clearSubscription: true);
            return;
          }
          final sub = SubscriptionModel.fromFirestore(doc.data()!);
          state = state.copyWith(isLoading: false, subscription: sub);
        }, onError: (e) => print('[SUB] User doc stream error: $e'));

    _adminSub = _firestore
        .collection('subscriptions')
        .doc(uid)
        .snapshots()
        .listen((doc) {
          if (!doc.exists || doc.data() == null) {
            state = state.copyWith(isLoading: false, clearSubscription: true);
            return;
          }
          final sub = SubscriptionModel.fromFirestore(doc.data()!);
          state = state.copyWith(isLoading: false, subscription: sub);
        }, onError: (e) => print('[SUB] Admin doc stream error: $e'));
  }

  @override
  void dispose() {
    _userSub?.cancel();
    _adminSub?.cancel();
    super.dispose();
  }

  Future<void> load() async {
    final uid = _auth.ownerId;
    if (uid == null) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final sub = await _check(uid);
      if (!mounted) return;
      if (sub != null) {
        state = state.copyWith(isLoading: false, subscription: sub);
      } else {
        state = state.copyWith(isLoading: false, clearSubscription: true);
      }
    } catch (e) {
      if (!mounted) return;
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
      if (!mounted) return;
      state = state.copyWith(isLoading: false, subscription: sub);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  bool get isBlocked {
    return state.subscription?.status == SubscriptionStatus.blocked;
  }
}

final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
      ref.watch(authStateProvider);
      final auth = ref.watch(authServiceProvider);
      final repo = ref.watch(subscriptionRepositoryProvider);
      final check = CheckSubscription(repo, ConnectivityService());
      final activateTrial = ActivateTrial(repo);
      return SubscriptionNotifier(check, activateTrial, auth);
    });
