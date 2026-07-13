import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

enum SortMode { dateNewest, dateOldest, amountHighest, amountLowest }

void showSortSheet(
  BuildContext ctx, {
  required SortMode current,
  required ValueChanged<SortMode> onSelected,
}) {
  final l10n = AppLocalizations.of(ctx)!;
  final cs = Theme.of(ctx).colorScheme;
  final options = [
    (SortMode.dateNewest, l10n.dateNewest),
    (SortMode.dateOldest, l10n.dateOldest),
    (SortMode.amountHighest, l10n.amountHighest),
    (SortMode.amountLowest, l10n.amountLowest),
  ];
  showModalBottomSheet(
    context: ctx,
    builder: (_) => SafeArea(child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(l10n.sortBy,
            style: Theme.of(ctx).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        ),
        for (final (mode, label) in options)
          ListTile(
            leading: Icon(
              current == mode ? Icons.radio_button_checked : Icons.radio_button_off,
              color: current == mode ? cs.primary : null,
            ),
            title: Text(label),
            onTap: () { onSelected(mode); Navigator.pop(ctx); },
          ),
        const SizedBox(height: 8),
      ],
    )),
  );
}

Future<void> pickDateRange(
  BuildContext ctx, {
  DateTimeRange? initial,
  required ValueChanged<DateTimeRange> onPicked,
}) async {
  final picked = await showDateRangePicker(
    context: ctx, firstDate: DateTime(2020), lastDate: DateTime.now(),
    initialDateRange: initial,
  );
  if (picked != null) onPicked(picked);
}
