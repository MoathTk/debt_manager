import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_debt_management/Providers/admin_provider.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';
import '../providers/subscribers_provider.dart';
import '../widgets/subscriber_tile.dart';

class SubscribersDashboardScreen extends ConsumerWidget {
  const SubscribersDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isAdmin = ref.watch(isAdminProvider).valueOrNull ?? false;

    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.subscribersDashboard)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(l10n.accessDenied, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );
    }

    final asyncSubs = ref.watch(subscribersStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.subscribersDashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(subscribersStreamProvider),
          ),
        ],
      ),
      body: asyncSubs.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noSubscribers,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            );
          }
          list.sort((a, b) => a.expiresAt.compareTo(b.expiresAt));
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (_, i) => SubscriberTile(sub: list[i]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
