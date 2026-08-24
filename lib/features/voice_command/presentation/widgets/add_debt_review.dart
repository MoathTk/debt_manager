/// VOICE COMMAND FEATURE — PRESENTATION LAYER: ADD DEBT REVIEW
///
/// Review screen for "add_debt" voice commands.
/// Shows customer match, parsed items as cards, formatted total, and save actions.
///
/// RULES: <80 lines per class, Theme.of(context), Semantics, l10n.
/// ---------------------------------------------------------------------------
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';
import 'package:local_debt_management/data/models/customer.dart';
import 'package:local_debt_management/widgets/amount_input_formatter.dart';
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
  final ValueChanged<int> onRemoveItem;
  const AddDebtReview({
    super.key,
    required this.command,
    required this.matchedCustomers,
    this.selectedCustomer,
    required this.onCustomerSelected,
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
          _CustomerSection(
            l10n: l10n,
            cs: cs,
            customers: matchedCustomers,
            selected: selectedCustomer,
            onSelect: onCustomerSelected,
          ),
          const SizedBox(height: 10),
          _ItemsHeader(l10n: l10n, cs: cs, count: command.items.length),
          const SizedBox(height: 6),
          ...command.items.asMap().entries.map((e) => _ItemCard(
                index: e.key,
                item: e.value,
                cs: cs,
                l10n: l10n,
                onRemove: onRemoveItem,
              )),
          const SizedBox(height: 8),
          _TotalSection(l10n: l10n, cs: cs, total: command.totalAmount),
          if (command.dueDate != null) ...[
            const SizedBox(height: 6),
            _DueRow(l10n: l10n, cs: cs, date: command.dueDate!),
          ],
          const SizedBox(height: 12),
          _Actions(
            l10n: l10n,
            onReRecord: onReRecord,
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
        Text(
          l10n.customerName,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: cs.primary,
          ),
        ),
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
  final int count;
  const _ItemsHeader({
    required this.l10n,
    required this.cs,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.receipt_long_rounded, size: 14, color: Colors.amber.shade700),
        const SizedBox(width: 6),
        Text(
          '${l10n.parsedItems} ($count)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.amber.shade700,
          ),
        ),
      ],
    );
  }
}

class _ItemCard extends StatelessWidget {
  final int index;
  final VoiceCommandItem item;
  final ColorScheme cs;
  final AppLocalizations l10n;
  final ValueChanged<int> onRemove;
  const _ItemCard({
    required this.index,
    required this.item,
    required this.cs,
    required this.l10n,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('item_$index'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(index),
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.amber.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Icon(Icons.label_rounded, size: 16, color: Colors.amber.shade700),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface,
                ),
              ),
            ),
            Text(
              formatAmount(item.amount),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.amber.shade900,
              ),
            ),
            const SizedBox(width: 6),
            Semantics(
              label: l10n.deleteDebt,
              button: true,
              child: GestureDetector(
                onTap: () => onRemove(index),
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: Colors.red.shade400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalSection extends StatelessWidget {
  final AppLocalizations l10n;
  final ColorScheme cs;
  final double total;
  const _TotalSection({
    required this.l10n,
    required this.cs,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.total,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.red.shade700,
            ),
          ),
          Text(
            formatAmount(total),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.red.shade700,
            ),
          ),
        ],
      ),
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
    final locale = Localizations.localeOf(context);
    final formattedDate = DateFormat.yMMMd(locale.languageCode).format(date);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.teal.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.teal.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.teal.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.calendar_today_rounded, size: 16, color: Colors.teal.shade700),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.due.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.teal.shade700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback onReRecord;
  final VoidCallback onConfirm;
  const _Actions({
    required this.l10n,
    required this.onReRecord,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Semantics(
          label: l10n.reRecord,
          button: true,
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: onReRecord,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.mic_rounded, size: 18),
              label: Text(l10n.reRecord),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Semantics(
          label: l10n.acceptAndSave,
          button: true,
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: onConfirm,
              icon: const Icon(Icons.check_circle_rounded, size: 20),
              label: Text(l10n.acceptAndSave),
            ),
          ),
        ),
      ],
    );
  }
}
