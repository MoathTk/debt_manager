import 'package:flutter/material.dart';
import 'package:local_debt_management/core/theme/app_colors.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';
import 'package:local_debt_management/utils/number_formatter.dart';

/// Semantic balance badge that adapts to dark/light modes.
class BalanceBadge extends StatelessWidget {
  final double balance;
  final AppLocalizations l10n;

  const BalanceBadge({super.key, required this.balance, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    final theme = Theme.of(context);
    final textColor = _getTextColor(appColors, theme);
    final bgColor = _getBgColor(appColors, theme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              NumberFormatter.formatForCard(balance.abs()),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: textColor,
                letterSpacing: -0.3,
              ),
            ),
          ),
          Text(
            _getLabel().toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: textColor.withValues(alpha: 0.8),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTextColor(AppColors appColors, ThemeData theme) {
    if (balance > 0) return appColors.debt;
    if (balance < 0) return appColors.payment;
    return theme.colorScheme.onSurfaceVariant;
  }

  Color _getBgColor(AppColors appColors, ThemeData theme) {
    if (balance > 0) return appColors.debtBg;
    if (balance < 0) return appColors.paymentBg;
    return theme.colorScheme.surfaceContainerHighest;
  }

  String _getLabel() {
    if (balance > 0) return l10n.owes;
    if (balance < 0) return l10n.overpaid;
    return l10n.settled;
  }
}
