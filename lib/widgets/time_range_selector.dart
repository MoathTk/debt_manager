import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class TimeRangeSelector extends StatelessWidget {
  final bool isWeekly;
  final ValueChanged<bool> onChanged;
  const TimeRangeSelector({
    super.key,
    required this.isWeekly,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [_btn(l10n.weekly, true, cs), _btn(l10n.monthly, false, cs)],
      ),
    );
  }

  Widget _btn(String label, bool weekly, ColorScheme cs) {
    final selected = isWeekly == weekly;
    return GestureDetector(
      onTap: () => onChanged(weekly),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? cs.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? cs.onPrimary : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
