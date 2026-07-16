import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/number_formatter.dart';

/// Semantic balance badge that adapts to dark/light modes.
class BalanceBadge extends StatelessWidget {
  final double balance;
  final AppLocalizations l10n;

  const BalanceBadge({super.key, required this.balance, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final textColor = _getTextColor(isDark, theme);
    final bgColor = _getBgColor(isDark, theme);

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

  Color _getTextColor(bool isDark, ThemeData theme) {
    if (balance > 0) {
      return isDark ? const Color(0xFFFFB4AB) : theme.colorScheme.error;
    }
    if (balance < 0) {
      return isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32);
    }
    return theme.colorScheme.onSurfaceVariant;
  }

  Color _getBgColor(bool isDark, ThemeData theme) {
    if (balance > 0) {
      return isDark
          ? const Color(0xFF93000A).withValues(alpha: 0.3)
          : theme.colorScheme.errorContainer;
    }
    if (balance < 0) {
      return isDark
          ? const Color(0xFF005313).withValues(alpha: 0.3)
          : const Color(0xFFE8F5E9);
    }
    return theme.colorScheme.surfaceContainerHighest;
  }

  String _getLabel() {
    if (balance > 0) return l10n.owes;
    if (balance < 0) return l10n.overpaid;
    return l10n.settled;
  }
}
