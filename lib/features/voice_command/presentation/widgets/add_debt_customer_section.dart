/// CUSTOMER SECTION WIDGETS — CustomerSection, NoMatchFallback
///
/// RULES: <80 lines per class, Theme.of(context), Semantics, l10n.
library;

import 'package:flutter/material.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';
import 'package:local_debt_management/features/customers/domain/entities/customer.dart';
import 'customer_match_chip.dart';
import 'customer_dropdown.dart';
import 'add_customer_buttons.dart';

class CustomerSection extends StatelessWidget {
  final AppLocalizations l10n;
  final ColorScheme cs;
  final List<Customer> customers;
  final List<Customer> allCustomers;
  final Customer? selected;
  final ValueChanged<Customer> onSelect;
  final VoidCallback onAddCustomer;
  const CustomerSection({
    super.key,
    required this.l10n,
    required this.cs,
    required this.customers,
    required this.allCustomers,
    this.selected,
    required this.onSelect,
    required this.onAddCustomer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.customerName,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: cs.primary,
          ),
        ),
        const SizedBox(height: 4),
        if (customers.isNotEmpty)
          CustomerMatchChip(
            customers: customers,
            selected: selected,
            onSelect: onSelect,
          )
        else if (allCustomers.isNotEmpty)
          NoMatchFallback(
            l10n: l10n,
            cs: cs,
            allCustomers: allCustomers,
            selected: selected,
            onSelect: onSelect,
            onAddCustomer: onAddCustomer,
          )
        else
          AddCustomerOnly(l10n: l10n, cs: cs, onAddCustomer: onAddCustomer),
      ],
    );
  }
}

class NoMatchFallback extends StatelessWidget {
  final AppLocalizations l10n;
  final ColorScheme cs;
  final List<Customer> allCustomers;
  final Customer? selected;
  final ValueChanged<Customer> onSelect;
  final VoidCallback onAddCustomer;
  const NoMatchFallback({
    super.key,
    required this.l10n,
    required this.cs,
    required this.allCustomers,
    this.selected,
    required this.onSelect,
    required this.onAddCustomer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.noMatchFound,
          style: TextStyle(fontSize: 12, color: cs.error),
        ),
        const SizedBox(height: 8),
        CustomerDropdown(
          l10n: l10n,
          cs: cs,
          customers: allCustomers,
          selected: selected,
          onSelect: onSelect,
        ),
        const SizedBox(height: 8),
        AddCustomerButton(l10n: l10n, cs: cs, onTap: onAddCustomer),
      ],
    );
  }
}
