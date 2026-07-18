import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/customer.dart';
import '../data/models/transaction.dart' as model;
import '../data/models/debt_reminder.dart';
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
      error: error,
    );
  }
}

class SyncNotifier extends StateNotifier<SyncState> {
  final Ref _ref;
  final _firestoreSync = FirestoreSync();
  final _connectivity = ConnectivityService();
  final _firestore = FirebaseFirestore.instance;

  StreamSubscription<bool>? _connectivitySub;
  StreamSubscription? _customersSub;
  StreamSubscription? _transactionsSub;
  StreamSubscription? _remindersSub;
  Timer? _debounce;
  Timer? _retryTimer;
  int _retryCount = 0;
  String? _currentUid;
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
  }

  void _startListeners(String uid) {
    _stopListeners();
    _currentUid = uid;
    _listenCustomers(uid);
    _listenTransactions(uid);
    _listenReminders(uid);
    print('[WS] listeners started for $uid');
  }

  void _listenCustomers(String uid) {
    _customersSub = _firestore
        .collection('users/$uid/customers')
        .snapshots()
        .listen(
      (snap) {
        final records = snap.docs.map((d) => Customer.fromMap(d.data())).toList();
        _firestoreSync.upsertCustomers(records);
        _ref.invalidate(customersProvider);
        _refreshUnsyncedCount();
      },
      onError: (e) => print('[WS] customers stream error: $e'),
    );
  }

  void _listenTransactions(String uid) {
    _transactionsSub = _firestore
        .collection('users/$uid/transactions')
        .snapshots()
        .listen(
      (snap) {
        final records = snap.docs.map((d) => model.Transaction.fromMap(d.data())).toList();
        _firestoreSync.upsertTransactions(records);
        _ref.invalidate(transactionsProvider);
        _refreshUnsyncedCount();
      },
      onError: (e) => print('[WS] transactions stream error: $e'),
    );
  }

  void _listenReminders(String uid) {
    _remindersSub = _firestore
        .collection('users/$uid/reminders')
        .snapshots()
        .listen(
      (snap) {
        final records = snap.docs.map((d) => DebtReminder.fromMap(d.data())).toList();
        _firestoreSync.upsertReminders(records);
        _ref.invalidate(allRemindersProvider);
        _ref.invalidate(pendingRemindersProvider);
        _ref.invalidate(dueTodayProvider);
        _refreshUnsyncedCount();
      },
      onError: (e) => print('[WS] reminders stream error: $e'),
    );
  }

  void _stopListeners() {
    _customersSub?.cancel();
    _transactionsSub?.cancel();
    _remindersSub?.cancel();
    _customersSub = null;
    _transactionsSub = null;
    _remindersSub = null;
  }

  void onAuthChanged(String? uid) {
    if (uid == null || uid.isEmpty) {
      _stopListeners();
      _currentUid = null;
      return;
    }
    if (uid != _currentUid) {
      _startListeners(uid);
      syncNow();
    }
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
    print('[SYNC] push started uid=$uid');
    state = state.copyWith(status: SyncStatus.syncing);
    try {
      await _firestoreSync.syncAll(uid);
      _retryCount = 0;
      _ref.invalidate(dashboardStatsProvider);
      final count = await _firestoreSync.getUnsyncedCount(uid);
      state = state.copyWith(
        status: SyncStatus.idle,
        unsyncedCount: count,
        lastSynced: DateTime.now().toIso8601String(),
      );
      print('[SYNC] push done — $count records still unsynced');
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
    _stopListeners();
    _debounce?.cancel();
    _retryTimer?.cancel();
    super.dispose();
  }
}

final syncProvider = StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  return SyncNotifier(ref);
});
