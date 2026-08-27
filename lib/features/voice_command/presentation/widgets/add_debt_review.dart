/// VOICE COMMAND FEATURE — PRESENTATION LAYER: ADD DEBT REVIEW
///
/// Review screen for "add_debt" voice commands.
/// Shows customer match, parsed items as cards, formatted total, and save actions.
///
/// RULES: <80 lines per class, Theme.of(context), Semantics, l10n.
/// ---------------------------------------------------------------------------
library;

import 'package:flutter/material.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';
import 'package:local_debt_management/features/customers/domain/entities/customer.dart';
import '../../domain/entities/voice_command.dart';
import 'add_debt_customer_section.dart';
import 'review_items_header.dart';
import 'review_total_due.dart';
import 'review_actions.dart';

class AddDebtReview extends StatelessWidget {
  final VoiceCommand command;
  final List<Customer> matchedCustomers;
  final List<Customer> allCustomers;
  final Customer? selectedCustomer;
  final ValueChanged<Customer> onCustomerSelected;
  final VoidCallback onAddCustomer;
  final ValueChanged<VoiceCommand> onConfirm;
  final VoidCallback onRetry;
  final VoidCallback onReRecord;
  final ValueChanged<int> onRemoveItem;
  const AddDebtReview({
    super.key,
    required this.command,
    required this.matchedCustomers,
    required this.allCustomers,
    this.selectedCustomer,
    required this.onCustomerSelected,
    required this.onAddCustomer,
    required this.onConfirm,
    required this.onRetry,
    required this.onReRecord,
    required this.onRemoveItem,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomerSection(
            l10n: l10n,
            cs: cs,
            customers: matchedCustomers,
            allCustomers: allCustomers,
            selected: selectedCustomer,
            onSelect: onCustomerSelected,
            onAddCustomer: onAddCustomer,
          ),
          const SizedBox(height: 10),
          ItemsHeader(l10n: l10n, cs: cs, count: command.items.length),
          const SizedBox(height: 6),
          ...command.items.asMap().entries.map((e) => ItemCard(
                index: e.key,
                item: e.value,
                cs: cs,
                l10n: l10n,
                onRemove: onRemoveItem,
              )),
          const SizedBox(height: 8),
          TotalSection(l10n: l10n, cs: cs, total: command.totalAmount),
          if (command.dueDate != null) ...[
            const SizedBox(height: 6),
            DueRow(l10n: l10n, cs: cs, date: command.dueDate!),
          ],
          const SizedBox(height: 12),
          ReviewActions(
            l10n: l10n,
            onReRecord: onReRecord,
            onConfirm: () => onConfirm(command),
          ),
        ],
      ),
    );
  }
}
