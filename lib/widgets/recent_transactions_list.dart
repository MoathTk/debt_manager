import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../Providers/database_provider.dart';
import '../data/models/transaction.dart' as model;
import 'add_debt_sheet.dart';
import 'record_payment_sheet.dart';
import 'records_list_sheet.dart';

String _fmt(double n) {
  final s = n % 1 == 0 ? n.toStringAsFixed(0) : n.toStringAsFixed(2);
  return s.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}

/// Displays the 5 most recent transactions on the dashboard.
///
/// Each tile shows a color-coded icon, amount, type, and date.
/// Shows a friendly empty state when no transactions exist.
class RecentTransactionsList extends ConsumerWidget {
  const RecentTransactionsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final l10n = AppLocalizations.of(context)!;

    return transactionsAsync.when(
      data: (transactions) {
        if (transactions.isEmpty) {
          return _EmptyTransactions(l10n: l10n);
        }
        final recent = transactions.take(5).toList();
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            children: recent.asMap().entries.map((entry) {
              final txn = entry.value;
              final isLast = entry.key == recent.length - 1;
              return _TransactionTile(
                transaction: txn,
                l10n: l10n,
                showDivider: !isLast,
                onTap: () => _showTransactionActions(
                  context, ref, txn.customerId,
                ),
              );
            }).toList(),
          ),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  void _showTransactionActions(
    BuildContext context,
    WidgetRef ref,
    String customerId,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            _ActionOption(
              icon: Icons.add_rounded,
              label: l10n.debt,
              color: theme.colorScheme.error,
              onTap: () {
                Navigator.pop(context);
                showAddDebtSheet(context, ref, customerId);
              },
            ),
            const SizedBox(height: 8),
            _ActionOption(
              icon: Icons.payments_rounded,
              label: l10n.payment,
              color: theme.colorScheme.primary,
              onTap: () {
                Navigator.pop(context);
                showRecordPaymentSheet(context, ref, customerId);
              },
            ),
            const SizedBox(height: 8),
            _ActionOption(
              icon: Icons.edit_rounded,
              label: l10n.editRecords,
              color: theme.colorScheme.tertiary,
              onTap: () {
                Navigator.pop(context);
                showRecordsListSheet(context, ref, customerId);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state for when there are no transactions yet.
class _EmptyTransactions extends StatelessWidget {
  final AppLocalizations l10n;

  const _EmptyTransactions({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.noTransactionsYet,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

/// Single transaction row with icon, label, and date.
class _TransactionTile extends StatelessWidget {
  final model.Transaction transaction;
  final AppLocalizations l10n;
  final bool showDivider;
  final VoidCallback onTap;

  const _TransactionTile({
    required this.transaction,
    required this.l10n,
    required this.showDivider,
    required this.onTap,
  });

  bool get _isDebt => transaction.isDebt;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 2,
          ),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _isDebt
                  ? const Color(0xFFFFEBEE)
                  : const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _isDebt
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              color: _isDebt
                  ? const Color(0xFFE53935)
                  : const Color(0xFF43A047),
              size: 20,
            ),
          ),
          title: Text(
            '${_fmt(transaction.amount)} ${_isDebt ? l10n.debt : l10n.payment}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _isDebt
                  ? const Color(0xFFE53935)
                  : const Color(0xFF43A047),
            ),
          ),
          subtitle: (transaction.note != null && transaction.note!.isNotEmpty)
              ? Text(
                  transaction.note!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          trailing: Text(
            transaction.date.length >= 10
                ? transaction.date.substring(0, 10)
                : transaction.date,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 56,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
      ],
    );
  }
}

class _ActionOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.1),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: Icon(Icons.chevron_right_rounded, color: color),
    );
  }
}
