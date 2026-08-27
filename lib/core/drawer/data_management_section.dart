import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_debt_management/Providers/database_provider.dart';
import 'package:local_debt_management/Providers/sync_provider.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';
import 'package:local_debt_management/utils/seed_database.dart';
import 'package:local_debt_management/services/auth_service.dart';
import 'package:local_debt_management/services/firestore_sync.dart';
import 'package:local_debt_management/features/subscription/presentation/widgets/mutation_guard.dart';

class DataManagementSection extends ConsumerWidget {
  const DataManagementSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    Future<bool?> confirm(String title, String content) => showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    void invalidateAll() {
      ref.invalidate(dashboardStatsProvider);
      ref.invalidate(customersProvider);
      ref.invalidate(transactionsProvider);
      ref.invalidate(allRemindersProvider);
      ref.invalidate(pendingRemindersProvider);
      ref.invalidate(dueTodayProvider);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.dataManagement, style: tt.labelSmall?.copyWith(
          color: cs.primary, letterSpacing: 1.2, fontWeight: FontWeight.bold,
        )),
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
              FilledButton.tonalIcon(
                onPressed: () async {
                  if (MutationGuard.checkBlocked(context, ref)) return;
                  await SeedDatabase.seedDemoData();
                  ref.invalidate(dashboardStatsProvider);
                  ref.invalidate(customersProvider);
                  ref.invalidate(transactionsProvider);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.demoDataSeeded), behavior: SnackBarBehavior.floating),
                    );
                  }
                },
                icon: const Icon(Icons.dataset_outlined),
                label: Center(child: Text(l10n.seedDemoData)),
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), alignment: Alignment.centerLeft),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  if (MutationGuard.checkBlocked(context, ref)) return;
                  final ok = await confirm(l10n.clearDemoData, l10n.confirmDelete);
                  if (ok == true) {
                    await SeedDatabase.clearDemoData();
                    invalidateAll();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.demoDataCleared), behavior: SnackBarBehavior.floating),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.delete_outline),
                label: Center(child: Text(l10n.clearDemoData)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12), alignment: Alignment.centerLeft,
                  foregroundColor: cs.error, side: BorderSide(color: cs.error.withValues(alpha: 0.5)),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  if (MutationGuard.checkBlocked(context, ref)) return;
                  final ok = await confirm('Reset Sync', 'Force a full re-sync from cloud? This will re-download all your data.');
                  if (ok == true) {
                    final uid = ref.read(authServiceProvider).ownerId;
                    if (uid != null) {
                      try { await FirestoreSync().deleteLastSyncMetadata(uid); } catch (_) {}
                    }
                    invalidateAll();
                    ref.read(syncProvider.notifier).syncNow();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: const Text('Sync reset — pulling all data from cloud'), behavior: SnackBarBehavior.floating),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.cloud_download_outlined),
                label: Center(child: const Text('Reset Sync')),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12), alignment: Alignment.centerLeft,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  //if (MutationGuard.checkBlocked(context, ref)) return;
                  final ok = await confirm(l10n.deleteLocalDatabase, l10n.confirmDeleteLocalDatabase);
                  if (ok == true) {
                    await SeedDatabase.clearDemoData();
                    final uid = ref.read(authServiceProvider).ownerId;
                    if (uid != null) {
                      try { await FirestoreSync().deleteLastSyncMetadata(uid); } catch (_) {}
                    }
                    invalidateAll();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.demoDataCleared), behavior: SnackBarBehavior.floating),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.storage_outlined),
                label: Center(child: Text(l10n.deleteLocalDatabase)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12), alignment: Alignment.centerLeft,
                  foregroundColor: cs.error, side: BorderSide(color: cs.error.withValues(alpha: 0.5)),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final ok = await confirm(l10n.wipeAllData, l10n.confirmWipeAll);
                  if (ok == true) {
                    await SeedDatabase.clearDemoData();
                    final uid = ref.read(authServiceProvider).ownerId;
                    if (uid != null) {
                      try { await FirestoreSync().deleteAllFirestoreData(uid); } catch (_) {}
                    }
                    invalidateAll();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.wipeAllSuccess), behavior: SnackBarBehavior.floating),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.delete_forever_outlined),
                label: Center(child: Text(l10n.wipeAllData)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12), alignment: Alignment.centerLeft,
                  foregroundColor: cs.error, side: BorderSide(color: cs.error),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
