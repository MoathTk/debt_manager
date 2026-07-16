import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/firestore_sync.dart';
import '../services/connectivity_service.dart';
import 'database_provider.dart';

enum SyncStatus { idle, syncing, error, offline }

class SyncState {
  final SyncStatus status;
  final int unsyncedCount;
  final String? lastSynced;
  final String? error;

  const SyncState({
    this.status = SyncStatus.idle,
    this.unsyncedCount = 0,
    this.lastSynced,
    this.error,
  });

  SyncState copyWith({
    SyncStatus? status,
    int? unsyncedCount,
    String? lastSynced,
    String? error,
  }) {
    return SyncState(
      status: status ?? this.status,
      unsyncedCount: unsyncedCount ?? this.unsyncedCount,
      lastSynced: lastSynced ?? this.lastSynced,
      error: error ?? this.error,
    );
  }
}

class SyncNotifier extends StateNotifier<SyncState> {
  final Ref _ref;
  final _firestoreSync = FirestoreSync();
  final _connectivity = ConnectivityService();
  StreamSubscription<bool>? _connectivitySub;
  Timer? _debounce;
  Timer? _retryTimer;
  Timer? _periodicTimer;
  int _retryCount = 0;
  static const _maxRetries = 3;
  static const _retryDelays = [
    Duration(seconds: 30),
    Duration(seconds: 60),
    Duration(seconds: 120),
  ];

  SyncNotifier(this._ref) : super(const SyncState()) {
    _connectivity.init();
    _init();
  }

  void _init() {
    _connectivitySub = _connectivity.isConnected.listen((connected) {
      if (connected && state.status == SyncStatus.offline) {
        syncNow();
      } else if (!connected) {
        state = state.copyWith(status: SyncStatus.offline);
      }
    });
    _refreshUnsyncedCount();
    _periodicTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        if (state.status != SyncStatus.syncing) syncNow();
      },
    );
  }

  Future<void> syncNow() async {
    final uid = _ref.read(authServiceProvider).ownerId;
    if (uid == null || uid.isEmpty) {
      print('[SYNC] skipped — uid is null or empty');
      return;
    }
    final online = await _connectivity.checkConnection();
    if (!online) {
      print('[SYNC] skipped — offline');
      state = state.copyWith(status: SyncStatus.offline);
      return;
    }
    print('[SYNC] syncNow started uid=$uid');
    state = state.copyWith(status: SyncStatus.syncing);
    try {
      await _firestoreSync.syncAll(uid);
      _retryCount = 0;
      _ref.invalidate(customersProvider);
      _ref.invalidate(transactionsProvider);
      _ref.invalidate(allRemindersProvider);
      _ref.invalidate(pendingRemindersProvider);
      _ref.invalidate(dueTodayProvider);
      _ref.invalidate(dashboardStatsProvider);
      final count = await _firestoreSync.getUnsyncedCount(uid);
      state = state.copyWith(
        status: SyncStatus.idle,
        unsyncedCount: count,
        lastSynced: DateTime.now().toIso8601String(),
      );
      print('[SYNC] completed — $count records still unsynced');
    } catch (e) {
      print('[SYNC] FAILED: $e');
      _scheduleRetry(e.toString());
    }
  }

  void _scheduleRetry(String error) {
    if (_retryCount < _maxRetries) {
      final delay = _retryDelays[_retryCount];
      _retryCount++;
      state = state.copyWith(
        status: SyncStatus.error,
        error: 'Retry $_retryCount/$_maxRetries in ${delay.inSeconds}s',
      );
      _retryTimer?.cancel();
      _retryTimer = Timer(delay, () => syncNow());
    } else {
      state = state.copyWith(
        status: SyncStatus.error,
        error: error,
      );
    }
  }

  void schedulePush() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 2), () => syncNow());
  }

  Future<void> _refreshUnsyncedCount() async {
    final uid = _ref.read(authServiceProvider).ownerId;
    if (uid == null || uid.isEmpty) return;
    final count = await _firestoreSync.getUnsyncedCount(uid);
    state = state.copyWith(unsyncedCount: count);
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    _debounce?.cancel();
    _retryTimer?.cancel();
    _periodicTimer?.cancel();
    super.dispose();
  }
}

final syncProvider = StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  return SyncNotifier(ref);
});
