/// VOICE COMMAND FEATURE — PRESENTATION LAYER: VIEW BALANCE REVIEW
///
/// Review screen for "view_balance" voice commands.
/// Shows customer match chips, balance card, outstanding debts, and navigation.
/// Debts are directly tappable for inline payment (amount input + confirm).
///
/// RULES: <80 lines per class, Theme.of(context), Semantics, l10n.
/// ---------------------------------------------------------------------------
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_debt_management/core/theme/app_colors.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';
import 'package:local_debt_management/features/customers/domain/entities/customer.dart';
import 'package:local_debt_management/features/customers/presentation/screens/customer_detail_screen.dart';
import 'package:local_debt_management/features/debts/presentation/widgets/balance_card.dart';
import 'package:local_debt_management/features/debts/presentation/widgets/debt_selector_tile.dart';
import 'package:local_debt_management/features/debts/presentation/widgets/amount_input_formatter.dart';
import 'customer_match_chip.dart';

class ViewBalanceReview extends StatefulWidget {
  final String customerName;
  final List<Customer> matchedCustomers;
  final Customer? selectedCustomer;
  final ValueChanged<Customer> onCustomerSelected;
  final VoidCallback onReRecord;
  final VoidCallback onConfirmPayment;
  final double? customerBalance;
  final List<Map<String, dynamic>>? remainingDebts;
  final String? selectedDebtId;
  final String? paymentWarning;
  final double? maxPayment;
  final void Function(String, double)? onDebtSelected;
  final ValueChanged<double>? onAmountChanged;
  final double paymentAmount;

  const ViewBalanceReview({
    super.key,
    required this.customerName,
    required this.matchedCustomers,
    this.selectedCustomer,
    required this.onCustomerSelected,
    required this.onReRecord,
    required this.onConfirmPayment,
    this.customerBalance,
    this.remainingDebts,
    this.selectedDebtId,
    this.paymentWarning,
    this.maxPayment,
    this.onDebtSelected,
    this.onAmountChanged,
    this.paymentAmount = 0,
  });

  @override
  State<ViewBalanceReview> createState() => _ViewBalanceReviewState();
}

class _ViewBalanceReviewState extends State<ViewBalanceReview> {
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
            customers: widget.matchedCustomers,
            selected: widget.selectedCustomer,
            onSelect: widget.onCustomerSelected,
          ),
          if (widget.selectedCustomer != null) ...[
            const SizedBox(height: 12),
            _BalanceSection(
              customer: widget.selectedCustomer!,
              balance: widget.customerBalance,
              debts: widget.remainingDebts,
              selectedId: widget.selectedDebtId,
              onDebtSelected: widget.onDebtSelected,
              l10n: l10n,
            ),
            if (widget.selectedDebtId != null) ...[
              const SizedBox(height: 10),
              _InlinePayment(
                l10n: l10n,
                cs: cs,
                amount: widget.paymentAmount,
                maxPayment: widget.maxPayment,
                warning: widget.paymentWarning,
                onAmountChanged: widget.onAmountChanged,
                onConfirm: widget.onConfirmPayment,
              ),
            ],
            const SizedBox(height: 12),
            _ViewDetailButton(
              l10n: l10n,
              customer: widget.selectedCustomer!,
              onTap: () => _navigateToDetail(context, widget.selectedCustomer!),
            ),
          ],
          if (widget.matchedCustomers.isEmpty) ...[
            const SizedBox(height: 12),
            _EmptyState(l10n: l10n),
          ],
          const SizedBox(height: 12),
          _ReRecordButton(l10n: l10n, onPressed: widget.onReRecord),
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
        Icon(Icons.account_balance_wallet, size: 16, color: cs.secondary),
        const SizedBox(width: 6),
        Text(
          l10n.balance,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: cs.secondary,
          ),
        ),
      ],
    );
  }
}

class _BalanceSection extends StatelessWidget {
  final Customer customer;
  final double? balance;
  final List<Map<String, dynamic>>? debts;
  final String? selectedId;
  final void Function(String, double)? onDebtSelected;
  final AppLocalizations l10n;
  const _BalanceSection({
    required this.customer,
    this.balance,
    this.debts,
    this.selectedId,
    this.onDebtSelected,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (balance != null) BalanceCard(balance: balance!),
        if (debts != null && debts!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            l10n.outstandingDebts.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: cs.onSurfaceVariant,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          ...debts!.map((d) {
            final id = d['id'] as String;
            final remaining = (d['remaining'] as num).toDouble();
            return DebtSelectorTile(
              id: id,
              amount: (d['amount'] as num).toDouble(),
              remaining: remaining,
              note: d['note'] as String?,
              date: d['date'] as String?,
              isSelected: selectedId == id,
              onTap: onDebtSelected != null
                  ? () => onDebtSelected!(id, remaining)
                  : () {},
            );
          }),
        ],
        if (debts != null && debts!.isEmpty) ...[
          const SizedBox(height: 8),
          Text(
            l10n.noOutstandingDebts,
            style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}

class _InlinePayment extends ConsumerStatefulWidget {
  final AppLocalizations l10n;
  final ColorScheme cs;
  final double amount;
  final double? maxPayment;
  final String? warning;
  final ValueChanged<double>? onAmountChanged;
  final VoidCallback onConfirm;
  const _InlinePayment({
    required this.l10n,
    required this.cs,
    required this.amount,
    this.maxPayment,
    this.warning,
    this.onAmountChanged,
    required this.onConfirm,
  });

  @override
  ConsumerState<_InlinePayment> createState() => _InlinePaymentState();
}

class _InlinePaymentState extends ConsumerState<_InlinePayment> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.amount > 0 ? formatAmount(widget.amount) : '',
    );
  }

  @override
  void didUpdateWidget(covariant _InlinePayment oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.maxPayment != oldWidget.maxPayment &&
        widget.maxPayment != null) {
      final text = formatAmount(widget.maxPayment!);
      _controller.text = text;
      _controller.selection = TextSelection.collapsed(offset: text.length);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.amount > 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [ThousandsSeparatorInputFormatter()],
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            labelText: widget.l10n.paymentAmount,
            prefixIcon: const Icon(Icons.payments_outlined),
            suffixIcon: widget.maxPayment != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Text(
                      '${widget.l10n.remaining}: ${formatAmount(widget.maxPayment!)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: widget.cs.onSurfaceVariant,
                      ),
                    ),
                  )
                : null,
            suffixIconConstraints: const BoxConstraints(maxWidth: 120),
            filled: true,
            fillColor: widget.cs.surfaceContainerHighest.withValues(alpha: 0.4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: widget.cs.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 18,
            ),
          ),
          onChanged: (v) => widget.onAmountChanged?.call(parseAmount(v) ?? 0),
        ),
        if (widget.warning != null) ...[
          const SizedBox(height: 8),
          _PaymentWarning(
            l10n: widget.l10n,
            cs: widget.cs,
            maxAmount: widget.maxPayment,
          ),
        ],
        const SizedBox(height: 10),
        Semantics(
          label: widget.l10n.confirmPayment,
          button: true,
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: enabled ? widget.onConfirm : null,
              icon: const Icon(Icons.check_circle_rounded, size: 20),
              label: Text(widget.l10n.confirmPayment),
            ),
          ),
        ),
      ],
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
    final appColors = AppColors.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: appColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: appColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: appColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              maxAmount != null
                  ? l10n.maxPaymentIs(maxAmount!.toInt().toString())
                  : l10n.amountExceedsRemaining,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: appColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewDetailButton extends StatelessWidget {
  final AppLocalizations l10n;
  final Customer customer;
  final VoidCallback onTap;
  const _ViewDetailButton({
    required this.l10n,
    required this.customer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${l10n.viewCustomer} ${customer.name}',
      button: true,
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.tonalIcon(
          onPressed: onTap,
          icon: const Icon(Icons.arrow_forward, size: 18),
          label: Text(l10n.viewCustomer),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations l10n;
  const _EmptyState({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Text(
      l10n.noCustomersMessage,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontSize: 13,
      ),
    );
  }
}

class _ReRecordButton extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback onPressed;
  const _ReRecordButton({required this.l10n, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.mic, size: 16),
        label: Text(l10n.reRecord),
      ),
    );
  }
}
