import 'package:flutter/material.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';

class SubscriberStatsRow extends StatelessWidget {
  final int total;
  final int active;
  final int expiring;
  final int expired;

  const SubscriberStatsRow({
    super.key,
    required this.total,
    required this.active,
    required this.expiring,
    required this.expired,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          _card(l10n.totalSubscribers, total, cs.primary, cs),
          const SizedBox(width: 8),
          _card(l10n.activeSubscribers, active, Colors.green, cs),
          const SizedBox(width: 8),
          _card(l10n.expiringSubscribers, expiring, Colors.orange, cs),
          const SizedBox(width: 8),
          _card(l10n.expiredSubscribers, expired, Colors.red, cs),
        ],
      ),
    );
  }

  Widget _card(String label, int count, Color color, ColorScheme cs) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text('$count',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color.withValues(alpha: 0.8)),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
