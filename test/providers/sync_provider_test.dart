import 'package:flutter_test/flutter_test.dart';
import 'package:local_debt_management/Providers/sync_provider.dart';

void main() {
  group('SyncState', () {
    test('default state is idle with 0 unsynced', () {
      const state = SyncState();
      expect(state.status, SyncStatus.idle);
      expect(state.unsyncedCount, 0);
      expect(state.lastSynced, null);
      expect(state.error, null);
    });

    test('copyWith preserves unchanged fields', () {
      const state = SyncState(
        status: SyncStatus.syncing,
        unsyncedCount: 5,
        lastSynced: '2025-01-01',
        error: 'some error',
      );
      final updated = state.copyWith(status: SyncStatus.idle);
      expect(updated.status, SyncStatus.idle);
      expect(updated.unsyncedCount, 5);
      expect(updated.lastSynced, '2025-01-01');
      expect(updated.error, null);
    });

    test('copyWith updates specified fields', () {
      const state = SyncState();
      final updated = state.copyWith(
        status: SyncStatus.error,
        unsyncedCount: 10,
        lastSynced: '2025-06-15',
        error: 'Network timeout',
      );
      expect(updated.status, SyncStatus.error);
      expect(updated.unsyncedCount, 10);
      expect(updated.lastSynced, '2025-06-15');
      expect(updated.error, 'Network timeout');
    });

    test('copyWith partial update preserves others', () {
      const state = SyncState(
        status: SyncStatus.error,
        unsyncedCount: 3,
        error: 'old error',
      );
      final updated = state.copyWith(unsyncedCount: 0);
      expect(updated.status, SyncStatus.error);
      expect(updated.unsyncedCount, 0);
      expect(updated.error, null);
    });
  });

  group('SyncStatus enum', () {
    test('has all expected values', () {
      expect(SyncStatus.values.length, 4);
      expect(SyncStatus.idle, isNotNull);
      expect(SyncStatus.syncing, isNotNull);
      expect(SyncStatus.error, isNotNull);
      expect(SyncStatus.offline, isNotNull);
    });
  });

  group('SyncState transitions (conceptual)', () {
    test('idle -> syncing', () {
      const state = SyncState(status: SyncStatus.idle);
      final syncing = state.copyWith(status: SyncStatus.syncing);
      expect(syncing.status, SyncStatus.syncing);
    });

    test('syncing -> idle (success)', () {
      const state = SyncState(status: SyncStatus.syncing);
      final idle = state.copyWith(
        status: SyncStatus.idle,
        unsyncedCount: 0,
        lastSynced: '2025-06-15T00:00:00.000',
      );
      expect(idle.status, SyncStatus.idle);
      expect(idle.unsyncedCount, 0);
    });

    test('syncing -> error (failure)', () {
      const state = SyncState(status: SyncStatus.syncing);
      final error = state.copyWith(
        status: SyncStatus.error,
        error: 'Retry 1/3 in 30s',
      );
      expect(error.status, SyncStatus.error);
      expect(error.error, contains('Retry'));
    });

    test('error -> idle (retry success)', () {
      const errorState = SyncState(
        status: SyncStatus.error,
        error: 'Retry 1/3 in 30s',
      );
      expect(errorState.status, SyncStatus.error);

      const idleState = SyncState();
      expect(idleState.status, SyncStatus.idle);
      expect(idleState.error, null);
    });

    test('idle -> offline (connectivity lost)', () {
      const state = SyncState(status: SyncStatus.idle);
      final offline = state.copyWith(status: SyncStatus.offline);
      expect(offline.status, SyncStatus.offline);
    });

    test('offline -> syncing (reconnected)', () {
      const state = SyncState(status: SyncStatus.offline);
      final syncing = state.copyWith(status: SyncStatus.syncing);
      expect(syncing.status, SyncStatus.syncing);
    });
  });
}
