import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../Providers/database_provider.dart';
import '../data/models/transaction.dart' as model;

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
              final isLast = entry.key == recent.length - 1;
              return _TransactionTile(
                transaction: entry.value,
                l10n: l10n,
                showDivider: !isLast,
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

  const _TransactionTile({
    required this.transaction,
    required this.l10n,
    required this.showDivider,
  });

  bool get _isDebt => transaction.isDebt;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
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
            '${transaction.amount.toStringAsFixed(0)} ${_isDebt ? l10n.debt : l10n.payment}',
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
