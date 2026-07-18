import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_debt_management/Providers/admin_provider.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';
import '../../data/models/subscriber_model.dart';
import '../providers/subscribers_provider.dart';
import '../widgets/subscriber_stats_row.dart';
import '../widgets/subscriber_tile.dart';

class SubscribersDashboardScreen extends ConsumerWidget {
  const SubscribersDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isAdmin = ref.watch(isAdminProvider).valueOrNull ?? false;

    if (!isAdmin) return _accessDenied(context, l10n);

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
        data: (list) => _body(context, ref, l10n, list),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.subLoadError)),
      ),
    );
  }

  Widget _accessDenied(BuildContext context, AppLocalizations l10n) {
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

  Widget _body(BuildContext ctx, WidgetRef ref, AppLocalizations l10n,
      List<SubscriberModel> list) {
    if (list.isEmpty) return _empty(ctx, l10n);
    list.sort((a, b) => a.expiresAt.compareTo(b.expiresAt));
    final active = list.where((s) => !s.isExpired && s.daysRemaining > 1).length;
    final expiring = list.where((s) => !s.isExpired && s.daysRemaining <= 1).length;
    final expired = list.where((s) => s.isExpired).length;
    return Column(
      children: [
        SubscriberStatsRow(total: list.length, active: active,
            expiring: expiring, expired: expired),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (_, i) => SubscriberTile(sub: list[i]),
          ),
        ),
      ],
    );
  }

  Widget _empty(BuildContext ctx, AppLocalizations l10n) {
    final cs = Theme.of(ctx).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline, size: 64, color: cs.outline),
          const SizedBox(height: 16),
          Text(l10n.noSubscribers,
              style: TextStyle(fontSize: 16, color: cs.outline)),
          const SizedBox(height: 8),
          Text(l10n.noSubscribersMessage,
              style: TextStyle(fontSize: 13, color: cs.outline),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
