/// VOICE COMMAND FEATURE — PRESENTATION LAYER: RECORD PAYMENT REVIEW
///
/// Review screen for "record_payment" voice commands.
/// Shows customer match, outstanding debts, editable amount, and confirm actions.
///
/// RULES: <80 lines per class, Theme.of(context), Semantics, l10n.
/// ---------------------------------------------------------------------------
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';
import 'package:local_debt_management/data/models/customer.dart';
import 'package:local_debt_management/widgets/debt_selector_tile.dart';
import 'package:local_debt_management/widgets/amount_input_formatter.dart';
import '../../domain/entities/voice_command.dart';
import '../providers/voice_command_provider.dart';
import 'customer_match_chip.dart';

class RecordPaymentReview extends StatelessWidget {
  final VoiceCommand command;
  final List<Customer> matchedCustomers;
  final Customer? selectedCustomer;
  final List<Map<String, dynamic>>? remainingDebts;
  final String? selectedDebtId;
  final String? paymentWarning;
  final double? maxPayment;
  final ValueChanged<Customer> onCustomerSelected;
  final void Function(String debtId, double max) onDebtSelected;
  final ValueChanged<double> onAmountChanged;
  final VoidCallback onConfirm;
  final VoidCallback onReRecord;
  const RecordPaymentReview({
    super.key,
    required this.command,
    required this.matchedCustomers,
    this.selectedCustomer,
    this.remainingDebts,
    this.selectedDebtId,
    this.paymentWarning,
    this.maxPayment,
    required this.onCustomerSelected,
    required this.onDebtSelected,
    required this.onAmountChanged,
    required this.onConfirm,
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
        color: cs.tertiaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.tertiary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _Header(l10n: l10n, cs: cs),
          const SizedBox(height: 10),
          _CustomerSection(
            l10n: l10n,
            cs: cs,
            customers: matchedCustomers,
            selected: selectedCustomer,
            onSelect: onCustomerSelected,
          ),
          if (selectedCustomer != null) ...[
            const SizedBox(height: 10),
            _DebtSection(
              l10n: l10n,
              cs: cs,
              debts: remainingDebts,
              selectedId: selectedDebtId,
              onSelect: onDebtSelected,
            ),
          ],
          if (selectedDebtId != null) ...[
            const SizedBox(height: 10),
            _AmountRow(l10n: l10n, cs: cs, amount: command.totalAmount, maxAmount: maxPayment, onChanged: onAmountChanged),
            if (paymentWarning != null) ...[
              const SizedBox(height: 8),
              _PaymentWarning(l10n: l10n, cs: cs, maxAmount: maxPayment),
            ],
          ],
          const SizedBox(height: 12),
          _Actions(l10n: l10n, onReRecord: onReRecord, onConfirm: onConfirm, enabled: selectedDebtId != null && command.totalAmount > 0),
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
        Icon(Icons.payments_outlined, size: 16, color: cs.tertiary),
        const SizedBox(width: 6),
        Text(
          l10n.recordPayment,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: cs.tertiary,
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

class _DebtSection extends StatelessWidget {
  final AppLocalizations l10n;
  final ColorScheme cs;
  final List<Map<String, dynamic>>? debts;
  final String? selectedId;
  final void Function(String, double) onSelect;
  const _DebtSection({
    required this.l10n,
    required this.cs,
    this.debts,
    this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (debts == null) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    if (debts!.isEmpty) {
      return Text(
        l10n.noOutstandingDebts,
        style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.outstandingDebts,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: cs.primary,
          ),
        ),
        const SizedBox(height: 4),
        ...debts!.map((d) {
          final id = d['id'] as String;
          final remaining = (d['remaining'] as num).toDouble();
          final amount = (d['amount'] as num).toDouble();
          final note = d['note'] as String?;
          return DebtSelectorTile(
            id: id,
            amount: amount,
            remaining: remaining,
            note: note,
            isSelected: selectedId == id,
            onTap: () => onSelect(id, remaining),
          );
        }),
      ],
    );
  }
}

class _AmountRow extends ConsumerStatefulWidget {
  final AppLocalizations l10n;
  final ColorScheme cs;
  final double amount;
  final double? maxAmount;
  final ValueChanged<double> onChanged;
  const _AmountRow({
    required this.l10n,
    required this.cs,
    required this.amount,
    this.maxAmount,
    required this.onChanged,
  });

  @override
  ConsumerState<_AmountRow> createState() => _AmountRowState();
}

class _AmountRowState extends ConsumerState<_AmountRow> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.amount > 0 ? formatAmount(widget.amount) : '',
    );
    ref.listenManual(voiceCommandProvider, (prev, next) {
      final amt = next.command?.totalAmount;
      if (amt != null) {
        final text = amt > 0 ? formatAmount(amt) : '';
        if (_controller.text != text) {
          _controller.text = text;
          _controller.selection = TextSelection.collapsed(offset: text.length);
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextField(
      controller: _controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [ThousandsSeparatorInputFormatter()],
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: widget.l10n.paymentAmount,
        prefixIcon: const Icon(Icons.payments_outlined),
        suffixIcon: widget.maxAmount != null
            ? Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Text('${widget.l10n.remaining}: ${widget.maxAmount!.toInt()}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)),
              )
            : null,
        suffixIconConstraints: const BoxConstraints(maxWidth: 120),
        filled: true,
        fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.4),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: cs.primary, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      ),
      onChanged: (v) => widget.onChanged(parseAmount(v) ?? 0),
    );
  }
}

class _PaymentWarning extends StatelessWidget {
  final AppLocalizations l10n;
  final ColorScheme cs;
  final double? maxAmount;
  const _PaymentWarning({required this.l10n, required this.cs, this.maxAmount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              maxAmount != null
                  ? l10n.maxPaymentIs(maxAmount!.toInt().toString())
                  : l10n.amountExceedsRemaining,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.orange.shade800,
              ),
            ),
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
  final bool enabled;
  const _Actions({
    required this.l10n,
    required this.onReRecord,
    required this.onConfirm,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: onReRecord,
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              side: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
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
              backgroundColor: enabled
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest,
              foregroundColor: enabled
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurfaceVariant,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: enabled ? 2 : 0,
              shadowColor: enabled ? theme.colorScheme.primary.withValues(alpha: 0.4) : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 22,
                  color: enabled ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.confirmPayment,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    color: enabled ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
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
