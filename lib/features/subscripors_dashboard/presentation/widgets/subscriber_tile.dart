import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_debt_management/features/subscription/presentation/providers/subscription_provider.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';
import '../../data/models/subscriber_model.dart';
import '../providers/subscribers_provider.dart';
import 'update_expiry_sheet.dart';

class SubscriberTile extends ConsumerWidget {
  final SubscriberModel sub;
  const SubscriberTile({super.key, required this.sub});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final color = sub.isExpired ? Colors.red : sub.daysRemaining <= 1 ? Colors.orange : Colors.green;
    final label = sub.isExpired ? l10n.expiredSubscribers : sub.daysRemaining <= 1 ? l10n.expiringSubscribers : l10n.activeSubscribers;
    final days = sub.isExpired ? l10n.daysAgo(sub.daysRemaining.abs()) : sub.daysRemaining == 0 ? l10n.subToday : l10n.daysLeft(sub.daysRemaining);
    final name = sub.userName.isNotEmpty ? sub.userName : sub.uid.substring(0, 8);
    final subtext = sub.userEmail.isNotEmpty ? sub.userEmail : _planLabel(sub.plan, l10n);
    final icon = sub.plan == 'weekly' ? Icons.view_week_rounded : sub.plan == 'monthly' ? Icons.calendar_month_rounded : Icons.science_rounded;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(subtext, style: TextStyle(fontSize: 12, color: cs.outline), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          )),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
            ),
            const SizedBox(height: 4),
            Text(days, style: TextStyle(fontSize: 11, color: cs.outline, fontWeight: FontWeight.w500)),
          ]),
          const SizedBox(width: 4),
          IconButton(
            icon: Icon(Icons.edit_calendar_rounded, size: 20, color: cs.primary),
            onPressed: () => showModalBottomSheet(
              context: context, isScrollControlled: true,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
              builder: (_) => UpdateExpirySheet(sub: sub),
            ),
          ),
          IconButton(
            icon: Icon(Icons.block_rounded, size: 20, color: Colors.red),
            onPressed: sub.isExpired ? null : () => _confirmExpire(context, ref, l10n, name),
          ),
        ]),
      ),
    );
  }

  Future<void> _confirmExpire(BuildContext context, WidgetRef ref, AppLocalizations l10n, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 32),
        title: Text(l10n.confirmExpire),
        content: Text(l10n.confirmExpireMsg(name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.expireNow),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await ref.read(subscribersProvider.notifier).expireNow(sub.uid);
      ref.read(subscriptionProvider.notifier).load();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.subscriptionExpired)));
      }
    }
  }

  String _planLabel(String plan, AppLocalizations l10n) => switch (plan) {
    'weekly' => l10n.planWeekly, 'monthly' => l10n.planMonthly, _ => l10n.planTrial,
  };
}
