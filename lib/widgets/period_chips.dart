import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

enum PeriodType { day, week, month, year }

class PeriodChips extends StatelessWidget {
  final PeriodType selected;
  final ValueChanged<PeriodType> onChanged;
  const PeriodChips({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = [
      (PeriodType.day, l10n.day),
      (PeriodType.week, l10n.week),
      (PeriodType.month, l10n.month),
      (PeriodType.year, l10n.year),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.map((e) {
          final active = e.$1 == selected;
          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: ChoiceChip(
              label: Text(
                e.$2,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              selected: active,
              onSelected: (_) => onChanged(e.$1),
            ),
          );
        }).toList(),
      ),
    );
  }
}
