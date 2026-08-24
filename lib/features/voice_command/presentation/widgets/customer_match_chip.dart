/// VOICE COMMAND FEATURE — PRESENTATION LAYER: CUSTOMER MATCH CHIP
///
/// Displays a selectable customer chip for 2-3 match results.
/// Single matches auto-select. Zero matches show a message.
///
/// RULES: <80 lines, Theme.of(context), Semantics, no hardcoded strings.
/// ---------------------------------------------------------------------------
library;

import 'package:flutter/material.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';
import 'package:local_debt_management/data/models/customer.dart';

class CustomerMatchChip extends StatelessWidget {
  final List<Customer> customers;
  final Customer? selected;
  final ValueChanged<Customer> onSelect;
  const CustomerMatchChip({
    super.key,
    required this.customers,
    this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    if (customers.isEmpty) {
      return Semantics(
        label: l10n.noCustomersYet,
        child: Text(
          l10n.noCustomersYet,
          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: customers.map((c) {
        final isSelected = selected?.id == c.id;
        return Semantics(
          label: c.name,
          selected: isSelected,
          button: true,
          child: ChoiceChip(
            label: Text(c.name, style: const TextStyle(fontSize: 13)),
            selected: isSelected,
            selectedColor: cs.primaryContainer,
            onSelected: (_) => onSelect(c),
          ),
        );
      }).toList(),
    );
  }
}
