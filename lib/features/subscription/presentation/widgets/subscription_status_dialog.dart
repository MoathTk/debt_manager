import 'dart:async';
import 'package:flutter/material.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';
import '../../domain/entities/subscription.dart';
import 'subscription_status_header.dart';

class SubscriptionStatusDialog extends StatefulWidget {
  final Subscription subscription;
  const SubscriptionStatusDialog({super.key, required this.subscription});
  @override
  State<SubscriptionStatusDialog> createState() => _State();
}

class _State extends State<SubscriptionStatusDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Timer _dismiss;
  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _dismiss = Timer(const Duration(seconds: 2), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    _pulse.dispose();
    _dismiss.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final sub = widget.subscription;
    final color = dotColor(sub);
    final diff = sub.expiresAt.difference(DateTime.now());
    final expired = diff.isNegative;
    final timeStr = expired
        ? l10n.expiredLabel
        : diff.inDays > 0
        ? '${diff.inDays}d ${diff.inHours % 24}h'
        : '${diff.inHours}h ${diff.inMinutes % 60}m';
    final expiry =
        '${sub.expiresAt.day}/${sub.expiresAt.month}/${sub.expiresAt.year}';
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      contentPadding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SubscriptionStatusHeader(color: color, pulse: _pulse),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Column(
              children: [
                Text(
                  sub.planLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                _InfoRow(l10n.planName, sub.planLabel, cs),
                _InfoRow(l10n.expiresOnLabel, expiry, cs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.timeRemainingLabel,
                      style: TextStyle(
                        fontSize: 14,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    StatusBadge(timeStr, color),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Color dotColor(Subscription sub) => switch (sub.status) {
  SubscriptionStatus.active => Colors.green,
  SubscriptionStatus.expiring => Colors.orange,
  SubscriptionStatus.grace => Colors.red,
  SubscriptionStatus.blocked => Colors.red.shade900,
  SubscriptionStatus.noData => Colors.blue,
};

class _InfoRow extends StatelessWidget {
  final String label, value;
  final ColorScheme cs;
  const _InfoRow(this.label, this.value, this.cs);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant)),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}
