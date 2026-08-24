/// VOICE COMMAND FEATURE — PRESENTATION LAYER: ADD DEBT REVIEW
///
/// Review screen for "add_debt" voice commands.
/// Shows customer match, editable items, total, and save/retry actions.
///
/// RULES: <80 lines per class, Theme.of(context), Semantics, l10n.
/// ---------------------------------------------------------------------------
library;

import 'package:flutter/material.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';
import 'package:local_debt_management/data/models/customer.dart';
import '../../domain/entities/voice_command.dart';
import 'customer_match_chip.dart';

class AddDebtReview extends StatelessWidget {
  final VoiceCommand command;
  final List<Customer> matchedCustomers;
  final Customer? selectedCustomer;
  final ValueChanged<Customer> onCustomerSelected;
  final ValueChanged<VoiceCommand> onConfirm;
  final VoidCallback onRetry;
  final VoidCallback onReRecord;
  const AddDebtReview({
    super.key,
    required this.command,
    required this.matchedCustomers,
    this.selectedCustomer,
    required this.onCustomerSelected,
    required this.onConfirm,
    required this.onRetry,
    required this.onReRecord,
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
          _CustomerSection(
            l10n: l10n,
            cs: cs,
            customers: matchedCustomers,
            selected: selectedCustomer,
            onSelect: onCustomerSelected,
          ),
          const SizedBox(height: 10),
          _ItemsHeader(l10n: l10n, cs: cs),
          const SizedBox(height: 6),
          ...command.items.asMap().entries.map((e) =>
              _ItemRow(item: e.value, cs: cs)),
          const SizedBox(height: 6),
          _TotalRow(l10n: l10n, cs: cs, total: command.totalAmount),
          if (command.dueDate != null) ...[
            const SizedBox(height: 4),
            _DueRow(l10n: l10n, cs: cs, date: command.dueDate!),
          ],
          const SizedBox(height: 12),
          _Actions(
            l10n: l10n,
            onReRecord: onReRecord,
            onRetry: onRetry,
            onConfirm: () => onConfirm(command),
          ),
        ],
      ),
    );
  }
}

class _CustomerSection extends StatelessWidget {
  final AppLocalizations l10n;
  final ColorScheme cs;
  final List<Customer> customers;
  final Customer? selected;
  final ValueChanged<Customer> onSelect;
  const _CustomerSection({
    required this.l10n,
    required this.cs,
    required this.customers,
    this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.customerName,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: cs.primary)),
        const SizedBox(height: 4),
        CustomerMatchChip(
          customers: customers,
          selected: selected,
          onSelect: onSelect,
        ),
      ],
    );
  }
}

class _ItemsHeader extends StatelessWidget {
  final AppLocalizations l10n;
  final ColorScheme cs;
  const _ItemsHeader({required this.l10n, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.check_circle_outline, size: 14, color: cs.primary),
        const SizedBox(width: 4),
        Text(l10n.parsedItems,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: cs.primary)),
      ],
    );
  }
}

class _ItemRow extends StatelessWidget {
  final VoiceCommandItem item;
  final ColorScheme cs;
  const _ItemRow({required this.item, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(item.name, style: const TextStyle(fontSize: 14))),
          Text('${item.amount.toInt()}',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface)),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final AppLocalizations l10n;
  final ColorScheme cs;
  final double total;
  const _TotalRow({required this.l10n, required this.cs, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(l10n.total,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        Text('${total.toInt()}',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w800, color: cs.primary)),
      ],
    );
  }
}

class _DueRow extends StatelessWidget {
  final AppLocalizations l10n;
  final ColorScheme cs;
  final DateTime date;
  const _DueRow({required this.l10n, required this.cs, required this.date});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.calendar_today, size: 13, color: cs.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          '${l10n.due}: ${date.day}/${date.month}/${date.year}',
          style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback onReRecord;
  final VoidCallback onRetry;
  final VoidCallback onConfirm;
  const _Actions({
    required this.l10n,
    required this.onReRecord,
    required this.onRetry,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onReRecord,
                icon: const Icon(Icons.mic, size: 16),
                label: Text(l10n.reRecord),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 16),
                label: Text(l10n.retryParsing),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onConfirm,
            icon: const Icon(Icons.check, size: 18),
            label: Text(l10n.acceptAndSave),
          ),
        ),
      ],
    );
  }
}
