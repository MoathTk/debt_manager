import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Optional date picker with quick-select chips for setting a debt reminder date.
class ReminderDatePicker extends StatelessWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onDateChanged;
  const ReminderDatePicker({
    super.key,
    this.selectedDate,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final today = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.reminderDateOptional,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _QuickChip(label: l10n.today, onTap: () => onDateChanged(today)),
            const SizedBox(width: 8),
            _QuickChip(
              label: l10n.afterOneWeek,
              onTap: () => onDateChanged(today.add(const Duration(days: 7))),
            ),
            const SizedBox(width: 8),
            _QuickChip(
              label: l10n.afterOneMonth,
              onTap: () => onDateChanged(
                DateTime(today.year, today.month + 1, today.day),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? today,
              firstDate: today,
              lastDate: DateTime(today.year + 2),
            );
            if (picked != null) onDateChanged(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 20, color: cs.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedDate != null ? _fmt(selectedDate!) : l10n.pickDate,
                    style: TextStyle(
                      fontSize: 16,
                      color: selectedDate != null
                          ? cs.onSurface
                          : cs.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                if (selectedDate != null)
                  GestureDetector(
                    onTap: () => onDateChanged(null),
                    child: Icon(Icons.close_rounded, size: 18, color: cs.error),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

class _QuickChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QuickChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: cs.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}
