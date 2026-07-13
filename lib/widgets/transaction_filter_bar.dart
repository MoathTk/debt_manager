import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'sort_bottom_sheet.dart';

class TransactionFilterBar extends StatelessWidget {
  final int typeFilter;
  final SortMode sort;
  final DateTimeRange? dateRange;
  final ValueChanged<int> onTypeChanged;
  final ValueChanged<SortMode> onSortChanged;
  final ValueChanged<DateTimeRange?> onDateRangeChanged;
  final VoidCallback onClearDate;

  const TransactionFilterBar({
    super.key,
    required this.typeFilter,
    required this.sort,
    required this.dateRange,
    required this.onTypeChanged,
    required this.onSortChanged,
    required this.onDateRangeChanged,
    required this.onClearDate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final types = [(l10n.all, -1), (l10n.debts, 0), (l10n.payments, 1)];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final (label, value) in types)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(label),
                            selected: typeFilter == value,
                            onSelected: (_) => onTypeChanged(value),
                            selectedColor: cs.primary,
                            labelStyle: TextStyle(
                              color: typeFilter == value
                                  ? cs.onPrimary
                                  : cs.onSurface,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => showSortSheet(
                  context,
                  current: sort,
                  onSelected: onSortChanged,
                ),
                icon: Icon(Icons.sort, size: 20, color: cs.primary),
                tooltip: l10n.sortBy,
                style: IconButton.styleFrom(
                  backgroundColor: cs.primaryContainer.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ActionChip(
                avatar: Icon(
                  Icons.date_range,
                  size: 16,
                  color: dateRange != null ? cs.primary : cs.onSurfaceVariant,
                ),
                label: Text(
                  dateRange != null
                      ? '${dateRange!.start.month}/${dateRange!.start.day} - ${dateRange!.end.month}/${dateRange!.end.day}'
                      : l10n.dateRange,
                  style: TextStyle(
                    fontSize: 12,
                    color: dateRange != null ? cs.primary : cs.onSurfaceVariant,
                  ),
                ),
                onPressed: () => pickDateRange(
                  context,
                  initial: dateRange,
                  onPicked: onDateRangeChanged,
                ),
                backgroundColor: dateRange != null
                    ? cs.primaryContainer.withValues(alpha: 0.3)
                    : cs.surfaceContainerHighest.withValues(alpha: 0.3),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              if (dateRange != null) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onClearDate,
                  child: Icon(Icons.close, size: 16, color: cs.error),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
