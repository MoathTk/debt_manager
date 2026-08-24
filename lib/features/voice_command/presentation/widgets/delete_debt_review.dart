/// VOICE COMMAND FEATURE — PRESENTATION LAYER: DELETE DEBT REVIEW
///
/// Review screen for "delete_debt" voice commands.
/// Shows customer match, debt selector, and danger-styled confirm actions.
///
/// RULES: <80 lines per class, Theme.of(context), Semantics, l10n.
/// ---------------------------------------------------------------------------
library;

import 'package:flutter/material.dart';
import 'package:local_debt_management/data/models/customer.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';
import 'package:local_debt_management/widgets/debt_selector_tile.dart';
import 'customer_match_chip.dart';
import '../../domain/entities/voice_command.dart';

class DeleteDebtReview extends StatelessWidget {
  final VoiceCommand command;
  final List<Customer> matchedCustomers;
  final Customer? selectedCustomer;
  final ValueChanged<Customer> onSelectCustomer;
  final List<Map<String, dynamic>> remainingDebts;
  final String? selectedDebtId;
  final ValueChanged<String> onSelectDebt;
  final VoidCallback onConfirm;
  final VoidCallback onReRecord;
  final bool isSaving;
  const DeleteDebtReview({
    super.key,
    required this.command,
    required this.matchedCustomers,
    this.selectedCustomer,
    required this.onSelectCustomer,
    required this.remainingDebts,
    this.selectedDebtId,
    required this.onSelectDebt,
    required this.onConfirm,
    required this.onReRecord,
    this.isSaving = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final hasMultiple = matchedCustomers.length > 1;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.errorContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.error.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _Header(l10n: l10n, cs: cs),
          const SizedBox(height: 10),
          if (hasMultiple)
            _CustomerSection(
              l10n: l10n,
              cs: cs,
              customers: matchedCustomers,
              selected: selectedCustomer,
              onSelect: onSelectCustomer,
            )
          else if (selectedCustomer != null)
            _CustomerBadge(customer: selectedCustomer!, cs: cs),
          if (selectedCustomer != null) ...[
            const SizedBox(height: 12),
            _DebtSectionHeader(
              l10n: l10n,
              cs: cs,
              count: remainingDebts.length,
            ),
            const SizedBox(height: 6),
            _DebtList(
              debts: remainingDebts,
              selectedDebtId: selectedDebtId,
              onSelectDebt: onSelectDebt,
              l10n: l10n,
            ),
          ],
          const SizedBox(height: 14),
          _Actions(
            l10n: l10n,
            cs: cs,
            onReRecord: onReRecord,
            onConfirm: onConfirm,
            canConfirm: selectedDebtId != null,
            isSaving: isSaving,
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
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: cs.error.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.delete_forever_rounded, size: 16, color: cs.error),
        ),
        const SizedBox(width: 10),
        Text(
          l10n.deleteDebtAction,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: cs.error,
          ),
        ),
      ],
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
          l10n.customerName.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: cs.onSurfaceVariant,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        CustomerMatchChip(
          customers: customers,
          selected: selected,
          onSelect: onSelect,
        ),
      ],
    );
  }
}

class _CustomerBadge extends StatelessWidget {
  final Customer customer;
  final ColorScheme cs;
  const _CustomerBadge({required this.customer, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cs.errorContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.error.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: cs.error.withValues(alpha: 0.15),
            child: Text(
              customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: cs.error,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            customer.name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: cs.onErrorContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _DebtSectionHeader extends StatelessWidget {
  final AppLocalizations l10n;
  final ColorScheme cs;
  final int count;
  const _DebtSectionHeader({
    required this.l10n,
    required this.cs,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.receipt_long_rounded, size: 14, color: cs.error),
        const SizedBox(width: 6),
        Text(
          '${l10n.outstandingDebts} ($count)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: cs.error,
          ),
        ),
      ],
    );
  }
}

class _DebtList extends StatelessWidget {
  final List<Map<String, dynamic>> debts;
  final String? selectedDebtId;
  final ValueChanged<String> onSelectDebt;
  final AppLocalizations l10n;
  const _DebtList({
    required this.debts,
    this.selectedDebtId,
    required this.onSelectDebt,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    if (debts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            l10n.noDebtsFound,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }
    return Column(
      children: debts
          .map(
            (d) => DebtSelectorTile(
              id: d['id'] as String,
              amount: (d['amount'] as num).toDouble(),
              remaining: (d['remaining'] as num).toDouble(),
              note: d['note'] as String?,
              date: d['date'] as String?,
              isSelected: d['id'] == selectedDebtId,
              onTap: () => onSelectDebt(d['id'] as String),
            ),
          )
          .toList(),
    );
  }
}

class _Actions extends StatelessWidget {
  final AppLocalizations l10n;
  final ColorScheme cs;
  final VoidCallback onReRecord;
  final VoidCallback onConfirm;
  final bool canConfirm;
  final bool isSaving;
  const _Actions({
    required this.l10n,
    required this.cs,
    required this.onReRecord,
    required this.onConfirm,
    required this.canConfirm,
    this.isSaving = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = canConfirm && !isSaving;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: isSaving ? null : onReRecord,
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              side: BorderSide(
                color: cs.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            icon: const Icon(Icons.mic_rounded, size: 20),
            label: Text(
              l10n.reRecord,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            onPressed: enabled ? onConfirm : null,
            style: FilledButton.styleFrom(
              backgroundColor: enabled ? cs.error : cs.surfaceContainerHighest,
              foregroundColor: enabled ? cs.onError : cs.onSurfaceVariant,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: enabled ? 2 : 0,
              shadowColor: enabled ? cs.error.withValues(alpha: 0.4) : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSaving)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                  )
                else
                  Icon(
                    Icons.delete_forever_rounded,
                    size: 22,
                    color: enabled ? cs.onError : cs.onSurfaceVariant,
                  ),
                const SizedBox(width: 8),
                Text(
                  l10n.confirmDeleteVoice,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    color: enabled ? cs.onError : cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
