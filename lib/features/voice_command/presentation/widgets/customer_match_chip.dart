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
import 'package:local_debt_management/features/customers/domain/entities/customer.dart';

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
      runSpacing: 6,
      children: customers.map((c) {
        final isSelected = selected?.id == c.id;
        return Semantics(
          label: c.name,
          selected: isSelected,
          button: true,
          child: GestureDetector(
            onTap: () => onSelect(c),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? cs.primaryContainer
                    : cs.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? cs.primary.withValues(alpha: 0.6)
                      : cs.outlineVariant.withValues(alpha: 0.4),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Avatar(name: c.name, cs: cs, isSelected: isSelected),
                  const SizedBox(width: 8),
                  Text(
                    c.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? cs.onPrimaryContainer
                          : cs.onSurface,
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 6),
                    Icon(Icons.check_circle_rounded, size: 16, color: cs.primary),
                  ],
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final ColorScheme cs;
  final bool isSelected;
  const _Avatar({
    required this.name,
    required this.cs,
    required this.isSelected,
  });

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Color get _bgColor {
    final hash = name.hashCode;
    final hue = (hash % 360).abs().toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.55, 0.65).toColor();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? cs.primary.withValues(alpha: 0.2) : _bgColor.withValues(alpha: 0.2),
      ),
      child: Center(
        child: Text(
          _initials,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? cs.primary : _bgColor,
          ),
        ),
      ),
    );
  }
}
