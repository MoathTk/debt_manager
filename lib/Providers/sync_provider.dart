import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/firestore_sync.dart';
import '../services/connectivity_service.dart';

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
  Timer? _debounce;

  SyncNotifier(this._ref) : super(const SyncState()) {
    _init();
  }

  void _init() {
    _connectivity.isConnected.listen((connected) {
      if (connected && state.status == SyncStatus.offline) {
        syncNow();
      } else if (!connected) {
        state = state.copyWith(status: SyncStatus.offline);
      }
    });
    _refreshUnsyncedCount();
  }

  Future<void> syncNow() async {
    final uid = _ref.read(authServiceProvider).ownerId;
    if (uid == null || uid.isEmpty) return;
    final online = await _connectivity.checkConnection();
    if (!online) {
      state = state.copyWith(status: SyncStatus.offline);
      return;
    }
    state = state.copyWith(status: SyncStatus.syncing);
    try {
      await _firestoreSync.syncAll(uid);
      state = state.copyWith(
        status: SyncStatus.idle,
        unsyncedCount: 0,
        lastSynced: DateTime.now().toIso8601String(),
      );
    } catch (e) {
      state = state.copyWith(status: SyncStatus.error, error: e.toString());
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
    _debounce?.cancel();
    _connectivity.dispose();
    super.dispose();
  }
}

final syncProvider = StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  return SyncNotifier(ref);
});
