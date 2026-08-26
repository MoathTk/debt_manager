/// ADD CUSTOMER BUTTONS — AddCustomerButton, AddCustomerOnly
///
/// RULES: <80 lines per class, Theme.of(context), Semantics, l10n.
library;

import 'package:flutter/material.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';

class AddCustomerButton extends StatelessWidget {
  final AppLocalizations l10n;
  final ColorScheme cs;
  final VoidCallback onTap;
  const AddCustomerButton({
    super.key,
    required this.l10n,
    required this.cs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: l10n.addNewCustomer,
      button: true,
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.person_add_rounded, size: 18),
          label: Text(l10n.addNewCustomer),
        ),
      ),
    );
  }
}

class AddCustomerOnly extends StatelessWidget {
  final AppLocalizations l10n;
  final ColorScheme cs;
  final VoidCallback onAddCustomer;
  const AddCustomerOnly({
    super.key,
    required this.l10n,
    required this.cs,
    required this.onAddCustomer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.noCustomersYet,
          style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        AddCustomerButton(l10n: l10n, cs: cs, onTap: onAddCustomer),
      ],
    );
  }
}
