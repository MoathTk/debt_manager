import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_debt_management/Providers/database_provider.dart';
import 'package:local_debt_management/Providers/locale_provider.dart';
import 'package:local_debt_management/Providers/sync_provider.dart';
import 'package:local_debt_management/Providers/theme_provider.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';
import 'package:local_debt_management/utils/seed_database.dart';
import 'package:local_debt_management/services/auth_service.dart';
import 'package:local_debt_management/services/firestore_sync.dart';

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({
    super.key,
    required this.l10n,
    required this.ref,
    required this.onClose,
  });
  final AppLocalizations l10n;
  final WidgetRef ref;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    final currentTheme = ref.watch(themeProvider);
    final syncState = ref.watch(syncProvider);
    final user = ref.watch(authServiceProvider).currentUser;

    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Drawer(
      width: screenWidth * 0.85,
      backgroundColor: colorScheme.surface,
      elevation: 1,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    child: user?.photoURL != null
                        ? ClipOval(
                            child: Image.network(
                              user!.photoURL!,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Text(
                                (user.displayName ?? 'U')[0].toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                            ),
                          )
                        : Text(
                            (user?.displayName ?? 'U')[0].toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.displayName ?? 'User',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user?.email ?? '',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Divider(indent: 24, endIndent: 24),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                children: [
                  Text(
                    l10n.cloudSync,
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(
                              syncState.status == SyncStatus.offline
                                  ? Icons.cloud_off
                                  : syncState.status == SyncStatus.syncing
                                      ? Icons.sync
                                      : Icons.cloud_done,
                              size: 20,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                syncState.status == SyncStatus.offline
                                    ? l10n.syncStatusOffline
                                    : syncState.status == SyncStatus.syncing
                                        ? l10n.syncStatusSyncing
                                        : syncState.status ==
                                                SyncStatus.error
                                            ? l10n.syncStatusError
                                            : l10n.syncStatusConnected,
                                style: textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (syncState.unsyncedCount > 0)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              '${syncState.unsyncedCount} ${l10n.pendingSync}',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.error,
                              ),
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
                  const SizedBox(height: 24),
                  Text(
                    l10n.preferences,
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.language,
                              size: 20,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 12),
                            Text(l10n.language, style: textTheme.titleMedium),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(
                                value: 'ar',
                                label: Text('العربية'),
                              ),
                              ButtonSegment(
                                value: 'en',
                                label: Text('English'),
                              ),
                            ],
                            selected: {currentLocale.languageCode},
                            onSelectionChanged: (selected) {
                              final code = selected.first;
                              if (code == 'ar') {
                                ref.read(localeProvider.notifier).setArabic();
                              } else {
                                ref.read(localeProvider.notifier).setEnglish();
                              }
                              onClose();
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Icon(
                              Icons.palette_outlined,
                              size: 20,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 12),
                            Text(l10n.theme, style: textTheme.titleMedium),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<ThemeMode>(
                            segments: const [
                              ButtonSegment(
                                value: ThemeMode.light,
                                label: Icon(Icons.light_mode),
                              ),
                              ButtonSegment(
                                value: ThemeMode.dark,
                                label: Icon(Icons.dark_mode),
                              ),
                            ],
                            selected: {currentTheme},
                            onSelectionChanged: (selected) {
                              ref
                                  .read(themeProvider.notifier)
                                  .setTheme(selected.first);
                              onClose();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    l10n.dataManagement,
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FilledButton.tonalIcon(
                          onPressed: () async {
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
                        OutlinedButton.icon(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text(l10n.clearDemoData),
                                content: Text(l10n.confirmDelete),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: Text(l10n.cancel),
                                  ),
                                  FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: colorScheme.error,
                                      foregroundColor: colorScheme.onError,
                                    ),
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: Text(l10n.save),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await SeedDatabase.clearDemoData();
                              ref.invalidate(dashboardStatsProvider);
                              ref.invalidate(customersProvider);
                              ref.invalidate(transactionsProvider);
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
                            foregroundColor: colorScheme.error,
                            side: BorderSide(
                              color:
                                  colorScheme.error.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text(l10n.deleteLocalDatabase),
                                content:
                                    Text(l10n.confirmDeleteLocalDatabase),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: Text(l10n.cancel),
                                  ),
                                  FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: colorScheme.error,
                                      foregroundColor: colorScheme.onError,
                                    ),
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child:
                                        Text(l10n.deleteLocalDatabase),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await SeedDatabase.clearDemoData();
                              final uid =
                                  ref.read(authServiceProvider).ownerId;
                              if (uid != null) {
                                try {
                                  await FirestoreSync()
                                      .deleteLastSyncMetadata(uid);
                                } catch (_) {}
                              }
                              ref.invalidate(dashboardStatsProvider);
                              ref.invalidate(customersProvider);
                              ref.invalidate(transactionsProvider);
                              ref.invalidate(allRemindersProvider);
                              ref.invalidate(pendingRemindersProvider);
                              ref.invalidate(dueTodayProvider);
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
                          label: Center(
                            child: Text(l10n.deleteLocalDatabase),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                            alignment: Alignment.centerLeft,
                            foregroundColor: colorScheme.error,
                            side: BorderSide(
                              color:
                                  colorScheme.error.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: OutlinedButton.icon(
                onPressed: () async {
                  await ref.read(authServiceProvider).signOut();
                  if (context.mounted) onClose();
                },
                icon: const Icon(Icons.logout),
                label: Center(child: Text(l10n.signOut)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.centerLeft,
                  foregroundColor: colorScheme.error,
                  side: BorderSide(
                    color: colorScheme.error.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  'v1.0.0',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
