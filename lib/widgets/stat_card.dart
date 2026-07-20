import 'package:flutter/material.dart';
import 'animated_counter.dart';
import '../utils/number_formatter.dart';
import '../l10n/app_localizations.dart';

/// Premium stat card for the dashboard grid.
///
/// When [compact] is true, the number is displayed as simplified text
/// (e.g. "1.25 مليون") without animation — for large currency values.
class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final double numValue;
  final Color color;
  final bool compact;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.numValue,
    required this.color,
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final compactFn = compact
      ? (double v) => NumberFormatter.compact(v,
          billion: l10n!.billion, million: l10n.million, thousand: l10n.thousand)
      : null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          margin: EdgeInsets.all(3),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color.withValues(alpha: 0.7)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _IconBadge(icon: icon),
                const Spacer(),
                FittedBox(
                  child: AnimatedCounter(
                    targetValue: numValue,
                    formatter: compactFn,
                    style: TextStyle(
                      fontSize: compact ? 22 : 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Circular icon badge with a translucent white background.
class _IconBadge extends StatelessWidget {
  final IconData icon;

  const _IconBadge({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }
}
