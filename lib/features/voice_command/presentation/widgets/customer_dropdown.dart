/// CUSTOMER SEARCH PICKER — CustomerDropdown
///
/// RULES: <80 lines per class, Theme.of(context), Semantics, l10n.
library;

import 'package:flutter/material.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';
import 'package:local_debt_management/features/customers/domain/entities/customer.dart';
import 'customer_search_sheet.dart';

class CustomerDropdown extends StatelessWidget {
  final AppLocalizations l10n;
  final ColorScheme cs;
  final List<Customer> customers;
  final Customer? selected;
  final ValueChanged<Customer> onSelect;
  const CustomerDropdown({
    super.key,
    required this.l10n,
    required this.cs,
    required this.customers,
    this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSearchSheet(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.person_search_rounded, size: 18, color: cs.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selected?.name ?? l10n.customerName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected != null ? FontWeight.w600 : FontWeight.w400,
                  color: selected != null ? cs.onSurface : cs.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.arrow_drop_down_rounded, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  void _showSearchSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SearchSheet(
        l10n: l10n,
        customers: customers,
        selected: selected,
        onSelect: (c) {
          Navigator.of(context).pop();
          onSelect(c);
        },
      ),
    );
  }
}
