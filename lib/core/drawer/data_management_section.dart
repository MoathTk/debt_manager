import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_debt_management/core/sharedProviders/database_provider.dart';
import 'package:local_debt_management/core/sharedProviders/sync_provider.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';
import 'package:local_debt_management/core/utils/seed_database.dart';
import 'package:local_debt_management/core/services/auth_service.dart';
import 'package:local_debt_management/core/services/firestore_sync.dart';
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

    Future<void> seedStress(BuildContext context, int count) async {
      if (MutationGuard.checkBlocked(context, ref)) return;
      final uid = ref.read(authServiceProvider).ownerId;
      final ok = await confirm(
        'Seed stress data',
        'This clears ALL local data, then inserts $count customers, '
        '~${count * 6} transactions, ~${(count * 2.4).round()} reminders '
        'and subscription rows. Proceed?',
      );
      if (ok != true || !context.mounted) return;

      final navigator = Navigator.of(context, rootNavigator: true);
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Dialog(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
                SizedBox(width: 16),
                Flexible(child: Text('Seeding data…')),
              ],
            ),
          ),
        ),
      );

      try {
        final result = await SeedDatabase.seedStressData(
          ownerId: uid,
          customerCount: count,
        );
        navigator.pop();
        if (!context.mounted) return;
        invalidateAll();
        _showSeedResult(context, result);
      } catch (e) {
        navigator.pop();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Seed failed: $e'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.dataManagement,
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
              FilledButton.tonalIcon(
                onPressed: () async {
                  if (MutationGuard.checkBlocked(context, ref)) return;
                  await SeedDatabase.seedDemoData();
                  ref.invalidate(dashboardStatsProvider);
                  ref.invalidate(customersProvider);
                  ref.invalidate(transactionsProvider);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.demoDataSeeded),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.dataset_outlined),
                label: Center(child: Text(l10n.seedDemoData)),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.centerLeft,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: () => seedStress(context, 500),
                icon: const Icon(Icons.storage_rounded),
                label: const Center(child: Text('Seed 500 stress records')),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.centerLeft,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: () => seedStress(context, 2000),
                icon: const Icon(Icons.data_usage_rounded),
                label: const Center(child: Text('Seed 2,000 stress records')),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.centerLeft,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  if (MutationGuard.checkBlocked(context, ref)) return;
                  final ok = await confirm(
                    l10n.clearDemoData,
                    l10n.confirmDelete,
                  );
                  if (ok == true) {
                    await SeedDatabase.clearDemoData();
                    invalidateAll();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.demoDataCleared),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.delete_outline),
                label: Center(child: Text(l10n.clearDemoData)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.centerLeft,
                  foregroundColor: cs.error,
                  side: BorderSide(color: cs.error.withValues(alpha: 0.5)),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  if (MutationGuard.checkBlocked(context, ref)) return;
                  final ok = await confirm(
                    'Reset Sync',
                    'Force a full re-sync from cloud? This will re-download all your data.',
                  );
                  if (ok == true) {
                    final uid = ref.read(authServiceProvider).ownerId;
                    if (uid != null) {
                      try {
                        await FirestoreSync().deleteLastSyncMetadata(uid);
                      } catch (_) {}
                    }
                    invalidateAll();
                    ref.read(syncProvider.notifier).syncNow();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Sync reset — pulling all data from cloud',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.cloud_download_outlined),
                label: Center(child: const Text('Reset Sync')),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.centerLeft,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  //if (MutationGuard.checkBlocked(context, ref)) return;
                  final ok = await confirm(
                    l10n.deleteLocalDatabase,
                    l10n.confirmDeleteLocalDatabase,
                  );
                  if (ok == true) {
                    await SeedDatabase.clearDemoData();
                    final uid = ref.read(authServiceProvider).ownerId;
                    if (uid != null) {
                      try {
                        await FirestoreSync().deleteLastSyncMetadata(uid);
                      } catch (_) {}
                    }
                    invalidateAll();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.demoDataCleared),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.storage_outlined),
                label: Center(child: Text(l10n.deleteLocalDatabase)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.centerLeft,
                  foregroundColor: cs.error,
                  side: BorderSide(color: cs.error.withValues(alpha: 0.5)),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final ok = await confirm(
                    l10n.wipeAllData,
                    l10n.confirmWipeAll,
                  );
                  if (ok == true) {
                    await SeedDatabase.clearDemoData();
                    final uid = ref.read(authServiceProvider).ownerId;
                    if (uid != null) {
                      try {
                        await FirestoreSync().deleteAllFirestoreData(uid);
                      } catch (_) {}
                    }
                    invalidateAll();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.wipeAllSuccess),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.delete_forever_outlined),
                label: Center(child: Text(l10n.wipeAllData)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.centerLeft,
                  foregroundColor: cs.error,
                  side: BorderSide(color: cs.error),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showSeedResult(BuildContext context, SeedResult r) {
    final sb = StringBuffer()
      ..writeln('Inserted in ${r.insertMs} ms:')
      ..writeln('• customers: ${r.customerCount}')
      ..writeln('• transactions: ${r.transactionCount}')
      ..writeln('• reminders: ${r.reminderCount}')
      ..writeln('• subscriptions: ${r.subscriptionCount}')
      ..writeln()
      ..writeln(
        'Verification (${r.checks['verify_ms'] ?? '?'} ms):',
      );
    r.checks.forEach((key, value) {
      if (key != 'verify_ms') sb.writeln('• $key: $value');
    });
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Stress seed complete'),
        content: SingleChildScrollView(child: Text(sb.toString())),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
