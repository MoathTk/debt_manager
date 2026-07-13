import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class CollectionProgressRing extends StatelessWidget {
  final double rate;
  const CollectionProgressRing({super.key, required this.rate});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final pct = (rate * 100).clamp(0, 100);
    final color = rate >= 0.7
        ? const Color(0xFF43A047)
        : rate >= 0.4
        ? const Color(0xFFF9A825)
        : const Color(0xFFE53935);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: rate.clamp(0.0, 1.0),
                    strokeWidth: 8,
                    backgroundColor: cs.outlineVariant.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation(color),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text(
                  '${pct.toInt()}%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.collectionRate,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${pct.toInt()}% ${l10n.ofTotalDebts}',
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
