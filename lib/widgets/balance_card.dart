import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../l10n/app_localizations.dart';

/// Prominent balance card showing the customer's net balance with status color.
///
/// When [onTap] is provided the card becomes tappable (e.g. to reveal the
/// breakdown of the customer's unpaid debts).
class BalanceCard extends StatelessWidget {
  final double balance;
  final VoidCallback? onTap;
  const BalanceCard({super.key, required this.balance, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isOwed = balance > 0;
    final isOverpaid = balance < 0;
    final statusLabel = isOwed
        ? l10n.owes
        : isOverpaid
        ? l10n.overpaid
        : l10n.settled;
    final appColors = AppColors.of(context);
    final color = isOwed
        ? appColors.debt
        : isOverpaid
        ? appColors.payment
        : theme.colorScheme.onSurfaceVariant;
    final bgColor = isOwed
        ? appColors.debtBg
        : isOverpaid
        ? appColors.paymentBg
        : theme.colorScheme.surfaceContainerHighest;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: color.withValues(alpha: 0.15)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.balance.toUpperCase(),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: color.withValues(alpha: 0.7),
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _fmt(balance.abs()),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: color,
                          letterSpacing: -1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusLabel.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: color,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _fmt(double n) {
    final s = n % 1 == 0 ? n.toStringAsFixed(0) : n.toStringAsFixed(2);
    return s.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}
