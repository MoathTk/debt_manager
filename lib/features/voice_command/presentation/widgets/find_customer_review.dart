/// VOICE COMMAND FEATURE — PRESENTATION LAYER: FIND CUSTOMER REVIEW
///
/// Review screen for "find_customer" voice commands.
/// Shows matched customers and navigates to customer detail.
///
/// RULES: <80 lines, Theme.of(context), Semantics, l10n.
/// ---------------------------------------------------------------------------
library;

import 'package:flutter/material.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';
import 'package:local_debt_management/data/models/customer.dart';
import 'package:local_debt_management/screens/customer_detail_screen.dart';
import 'customer_match_chip.dart';

class FindCustomerReview extends StatelessWidget {
  final String customerName;
  final List<Customer> matchedCustomers;
  final Customer? selectedCustomer;
  final ValueChanged<Customer> onCustomerSelected;
  final VoidCallback onReRecord;
  const FindCustomerReview({
    super.key,
    required this.customerName,
    required this.matchedCustomers,
    this.selectedCustomer,
    required this.onCustomerSelected,
    required this.onReRecord,
  });

  void _navigateToDetail(BuildContext context, Customer customer) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CustomerDetailScreen(customerId: customer.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.secondary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _Header(l10n: l10n, cs: cs),
          const SizedBox(height: 8),
          CustomerMatchChip(
            customers: matchedCustomers,
            selected: selectedCustomer,
            onSelect: onCustomerSelected,
          ),
          if (selectedCustomer != null) ...[
            const SizedBox(height: 12),
            _ViewButton(
              l10n: l10n,
              cs: cs,
              customer: selectedCustomer!,
              onTap: () => _navigateToDetail(context, selectedCustomer!),
            ),
          ],
          if (matchedCustomers.isEmpty) ...[
            const SizedBox(height: 12),
            _EmptyState(l10n: l10n, cs: cs),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onReRecord,
              icon: const Icon(Icons.mic, size: 16),
              label: Text(l10n.reRecord),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final AppLocalizations l10n;
  final ColorScheme cs;
  const _Header({required this.l10n, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.person_search, size: 16, color: cs.secondary),
        const SizedBox(width: 6),
        Text(
          l10n.customerDetail,
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600, color: cs.secondary),
        ),
      ],
    );
  }
}

class _ViewButton extends StatelessWidget {
  final AppLocalizations l10n;
  final ColorScheme cs;
  final Customer customer;
  final VoidCallback onTap;
  const _ViewButton({
    required this.l10n,
    required this.cs,
    required this.customer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${l10n.customerDetail} ${customer.name}',
      button: true,
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.tonalIcon(
          onPressed: onTap,
          icon: const Icon(Icons.arrow_forward, size: 18),
          label: Text(customer.name),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations l10n;
  final ColorScheme cs;
  const _EmptyState({required this.l10n, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Text(
      l10n.noCustomersMessage,
      style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
    );
  }
}
