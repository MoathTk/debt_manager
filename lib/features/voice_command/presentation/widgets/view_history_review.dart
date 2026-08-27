/// VOICE COMMAND FEATURE — PRESENTATION LAYER: VIEW HISTORY REVIEW
///
/// Review screen for "view_history" voice commands.
/// Shows customer match, balance card, and transaction history list.
///
/// RULES: <80 lines per class, Theme.of(context), Semantics, l10n.
/// ---------------------------------------------------------------------------
library;

import 'package:flutter/material.dart';
import 'package:local_debt_management/core/theme/app_colors.dart';
import 'package:local_debt_management/features/customers/domain/entities/customer.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';
import 'package:local_debt_management/features/debts/domain/entities/transaction.dart';
import 'package:local_debt_management/features/debts/presentation/widgets/balance_card.dart';
import 'customer_match_chip.dart';
import '../../domain/entities/voice_command.dart';

class ViewHistoryReview extends StatelessWidget {
  final VoiceCommand command;
  final List<Customer> matchedCustomers;
  final Customer? selectedCustomer;
  final ValueChanged<Customer> onSelectCustomer;
  final double? balance;
  final List<Transaction> transactions;
  const ViewHistoryReview({
    super.key,
    required this.command,
    required this.matchedCustomers,
    this.selectedCustomer,
    required this.onSelectCustomer,
    this.balance,
    required this.transactions,
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
        color: cs.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary.withValues(alpha: 0.15)),
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
            if (balance != null) ...[
              const SizedBox(height: 12),
              BalanceCard(balance: balance!),
            ],
            const SizedBox(height: 12),
            _HistorySection(l10n: l10n, cs: cs, transactions: transactions),
          ],
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
            color: cs.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.history_rounded, size: 16, color: cs.primary),
        ),
        const SizedBox(width: 10),
        Text(
          l10n.transactionHistory,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: cs.primary,
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
        color: cs.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: cs.primary.withValues(alpha: 0.15),
            child: Text(
              customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: cs.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            customer.name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: cs.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistorySection extends StatelessWidget {
  final AppLocalizations l10n;
  final ColorScheme cs;
  final List<Transaction> transactions;
  const _HistorySection({
    required this.l10n,
    required this.cs,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.receipt_long_rounded, size: 14, color: cs.primary),
            const SizedBox(width: 6),
            Text(
              '${l10n.transactionHistory} (${transactions.length})',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: cs.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (transactions.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                l10n.noTransactionHistory,
                style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
              ),
            ),
          )
        else
          ...transactions
              .take(10)
              .map((tx) => _TransactionTile(tx: tx, cs: cs)),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction tx;
  final ColorScheme cs;
  const _TransactionTile({required this.tx, required this.cs});

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    final isDebt = tx.isDebt;
    final color = isDebt ? cs.error : appColors.payment;
    final bgColor = isDebt ? cs.errorContainer : appColors.paymentBg;
    final icon = isDebt
        ? Icons.arrow_upward_rounded
        : Icons.arrow_downward_rounded;
    final label = isDebt ? 'DEBT' : 'PAID';
    final formatted = _fmt(tx.amount);
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatted,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                if (tx.note?.isNotEmpty == true)
                  Text(
                    tx.note!,
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tx.date,
                style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(double n) {
    final s = n % 1 == 0 ? n.toStringAsFixed(0) : n.toStringAsFixed(2);
    return s.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}
