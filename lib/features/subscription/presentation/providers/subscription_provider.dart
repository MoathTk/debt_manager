library;

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_debt_management/data/database_helper.dart';
import 'package:local_debt_management/services/auth_service.dart';
import 'package:local_debt_management/services/clock_integrity_service.dart';
import 'package:local_debt_management/services/connectivity_service.dart';
import 'package:local_debt_management/services/trusted_time.dart';
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

    _userSub = _firestore
        .collection('users')
        .doc(uid)
        .collection('subscription')
        .doc('status')
        .snapshots()
        .listen((doc) async {
          if (!doc.exists || doc.data() == null) {
            state = state.copyWith(isLoading: false, clearSubscription: true);
            return;
          }
          final sub = SubscriptionModel.fromFirestore(doc.data()!);

          // Cross-check: fetch fresh trusted time from the best available
          // ONLINE source (NTP → Firestore server timestamp → HTTPS Date header).
          // We never depend on the device clock here — see trusted_time.dart.
          final trustedNow = await fetchTrustedTime();
          // Track whether we need to override isActive due to expiry.
          bool expiredByTrustedTime = false;
          if (trustedNow != null) {
            // Store the anchor so isClockIntactSync() stays accurate.
            await ClockIntegrityService.markTrustedTime(
              trustedNow: trustedNow,
              expiresAt: sub.expiresAt,
            );
            // If subscription is expired in trusted time, override isActive.
            // This prevents the listener from showing an expired sub as active.
            if (trustedNow.isAfter(sub.expiresAt)) {
              expiredByTrustedTime = true;
            }
          } else if (!await ClockIntegrityService.hasAnchor()) {
            // Every online source failed AND no previous anchor exists
            // (fresh install / first activation). Last resort: device time.
            await ClockIntegrityService.markTrustedTime(
              trustedNow: DateTime.now(),
              expiresAt: sub.expiresAt,
            );
          }
          // If all sources failed but an old anchor exists, keep the old
          // anchor — never overwrite a good (real-time) anchor with device time.

          if (!mounted) return;
          final entity = Subscription(
            plan: sub.plan,
            expiresAt: sub.expiresAt,
            activatedAt: sub.activatedAt,
            isActive: expiredByTrustedTime ? false : sub.isActive,
          );
          state = state.copyWith(isLoading: false, subscription: entity);
        }, onError: (e) => print('[SUB] User doc stream error: $e'));
  }

  @override
  void dispose() {
    _userSub?.cancel();
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
      final sub = await _activateTrial(uid);
      if (!mounted) return;
      state = state.copyWith(isLoading: false, subscription: sub);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
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
