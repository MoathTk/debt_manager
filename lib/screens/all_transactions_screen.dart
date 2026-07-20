import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../Providers/database_provider.dart';
import '../data/models/customer.dart';
import '../data/models/transaction.dart' as model;
import '../widgets/transaction_search_bar.dart';
import '../widgets/transaction_filter_bar.dart';
import '../widgets/sort_bottom_sheet.dart';
import '../widgets/all_transactions_tile.dart';

class AllTransactionsScreen extends ConsumerStatefulWidget {
  final int initialType;
  const AllTransactionsScreen({super.key, this.initialType = -1});
  @override
  ConsumerState<AllTransactionsScreen> createState() => _State();
}

class _State extends ConsumerState<AllTransactionsScreen> {
  final _ctrl = TextEditingController();
  String _query = '';
  late int _type = widget.initialType;
  SortMode _sort = SortMode.dateNewest;
  DateTimeRange? _range;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<model.Transaction> _apply(
    List<model.Transaction> txns,
    List<Customer> customers,
  ) {
    final names = {for (final c in customers) c.id: c.name};
    var list = txns;
    if (_type >= 0) list = list.where((t) => t.type == _type).toList();
    if (_range != null) {
      final s = _range!.start.toIso8601String().substring(0, 10);
      final e = _range!.end.toIso8601String().substring(0, 10);
      list = list.where((t) {
        final d = t.date.substring(0, 10);
        return d.compareTo(s) >= 0 && d.compareTo(e) <= 0;
      }).toList();
    }
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((t) {
        if (t.note?.toLowerCase().contains(q) == true) return true;
        if (names[t.customerId]?.toLowerCase().contains(q) == true) return true;
        final a = t.amount % 1 == 0
            ? t.amount.toStringAsFixed(0)
            : t.amount.toStringAsFixed(2);
        return a.contains(q);
      }).toList();
    }
    list.sort((a, b) {
      switch (_sort) {
        case SortMode.dateNewest:
          return b.date.compareTo(a.date);
        case SortMode.dateOldest:
          return a.date.compareTo(b.date);
        case SortMode.amountHighest:
          return b.amount.compareTo(a.amount);
        case SortMode.amountLowest:
          return a.amount.compareTo(b.amount);
      }
    });
    return list;
  }

  Widget _empty(String msg) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined, size: 56, color: cs.outlineVariant),
          const SizedBox(height: 16),
          Text(
            msg,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: cs.outline),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final txns = ref.watch(transactionsProvider);
    final custs = ref.watch(customersProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.allTransactions),backgroundColor: Colors.transparent,elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),),
      body: txns.when(
        data: (txns) {
          final f = _apply(txns, custs.valueOrNull ?? []);
          if (txns.isEmpty) return _empty(l10n.noTransactionsYet);
          return Column(
            children: [
              TransactionSearchBar(
                controller: _ctrl,
                onChanged: (v) => setState(() => _query = v),
              ),
              TransactionFilterBar(
                typeFilter: _type,
                sort: _sort,
                dateRange: _range,
                onTypeChanged: (v) => setState(() => _type = v),
                onSortChanged: (v) => setState(() => _sort = v),
                onDateRangeChanged: (v) => setState(() => _range = v),
                onClearDate: () => setState(() => _range = null),
              ),
              if (f.isEmpty)
                Expanded(child: _empty(l10n.noResults))
              else
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: f.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (_, i) =>
                        AllTransactionsTile(transaction: f[i]),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
