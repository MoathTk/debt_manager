library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';
import '../../domain/entities/subscription.dart';
import '../providers/subscription_provider.dart';

class SubscriptionBanner extends ConsumerWidget {
  const SubscriptionBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sub = ref.watch(subscriptionProvider).subscription;
    if (sub == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final (color, icon) = _style(sub.status);
    final label = _label(sub.status, l10n);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border(bottom: BorderSide(color: color.withValues(alpha: 0.3))),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${sub.planLabel} — $label',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          Text(
            _timeRemaining(sub.expiresAt),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _timeRemaining(DateTime expiresAt) {
    final diff = expiresAt.difference(DateTime.now());
    if (diff.isNegative) return 'Expired';
    final d = diff.inDays;
    final h = diff.inHours % 24;
    final m = diff.inMinutes % 60;
    if (d > 0) return '${d}d ${h}h';
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  (Color, IconData) _style(SubscriptionStatus s) => switch (s) {
        SubscriptionStatus.active =>
          (Colors.green, Icons.check_circle_outline),
        SubscriptionStatus.expiring =>
          (Colors.orange, Icons.warning_amber_rounded),
        SubscriptionStatus.grace =>
          (Colors.red, Icons.error_outline),
        SubscriptionStatus.blocked =>
          (Colors.red.shade900, Icons.block),
        SubscriptionStatus.noData =>
          (Colors.blue, Icons.info_outline),
      };

  String _label(SubscriptionStatus s, AppLocalizations l10n) => switch (s) {
        SubscriptionStatus.active => l10n.subActive,
        SubscriptionStatus.expiring => l10n.subExpiring,
        SubscriptionStatus.grace => l10n.subGrace,
        SubscriptionStatus.blocked => l10n.subBlocked,
        SubscriptionStatus.noData => l10n.subNoData,
      };
}
