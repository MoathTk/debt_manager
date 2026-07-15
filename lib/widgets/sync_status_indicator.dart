import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Providers/sync_provider.dart';

class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncProvider);
    final theme = Theme.of(context);

    IconData icon;
    Color color;
    String tooltip;

    switch (syncState.status) {
      case SyncStatus.syncing:
        icon = Icons.sync;
        color = theme.colorScheme.primary;
        tooltip = 'Syncing...';
      case SyncStatus.error:
        icon = Icons.sync_problem;
        color = theme.colorScheme.error;
        tooltip = 'Sync error';
      case SyncStatus.offline:
        icon = Icons.cloud_off;
        color = theme.colorScheme.outline;
        tooltip = 'Offline';
      case SyncStatus.idle:
        icon = Icons.cloud_done;
        color = theme.colorScheme.primary;
        tooltip = 'Synced';
    }

    return Tooltip(
      message: tooltip,
      child: Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            icon: Icon(icon, color: color, size: 24),
            onPressed: () => ref.read(syncProvider.notifier).syncNow(),
          ),
          if (syncState.unsyncedCount > 0)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${syncState.unsyncedCount}',
                  style: const TextStyle(
                    fontSize: 8,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
