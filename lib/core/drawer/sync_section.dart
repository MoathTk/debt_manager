import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_debt_management/Providers/sync_provider.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';

class SyncSection extends ConsumerWidget {
  const SyncSection({super.key, required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final syncState = ref.watch(syncProvider);

    IconData statusIcon;
    String statusText;
    switch (syncState.status) {
      case SyncStatus.offline:
        statusIcon = Icons.cloud_off;
        statusText = l10n.syncStatusOffline;
      case SyncStatus.syncing:
        statusIcon = Icons.sync;
        statusText = l10n.syncStatusSyncing;
      case SyncStatus.error:
        statusIcon = Icons.cloud_off;
        statusText = l10n.syncStatusError;
      case SyncStatus.idle:
        statusIcon = Icons.cloud_done;
        statusText = l10n.syncStatusConnected;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.cloudSync,
          style: tt.labelSmall?.copyWith(
            color: cs.primary,
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                Icon(statusIcon, size: 20, color: cs.onSurfaceVariant),
                const SizedBox(width: 12),
                Expanded(child: Text(statusText, style: tt.titleMedium)),
              ]),
              const SizedBox(height: 8),
              if (syncState.unsyncedCount > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '${syncState.unsyncedCount} ${l10n.pendingSync}',
                    style: tt.bodySmall?.copyWith(color: cs.error),
                  ),
                ),
              FilledButton.tonalIcon(
                onPressed: () {
                  ref.read(syncProvider.notifier).syncNow();
                  onClose();
                },
                icon: const Icon(Icons.sync),
                label: Center(child: Text(l10n.syncNow)),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.centerLeft,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
