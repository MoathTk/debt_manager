/// CUSTOMER SEARCH PICKER — SearchSheet, SheetHandle, SheetHeader
///
/// RULES: <80 lines per class, Theme.of(context), Semantics, l10n.
library;

import 'package:flutter/material.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';
import 'package:local_debt_management/features/customers/domain/entities/customer.dart';
import 'package:local_debt_management/data/repositories/transaction_repository.dart';
import 'customer_tile.dart';
import 'search_field.dart';

class SearchSheet extends StatefulWidget {
  final AppLocalizations l10n;
  final List<Customer> customers;
  final Customer? selected;
  final ValueChanged<Customer> onSelect;
  const SearchSheet({
    super.key,
    required this.l10n,
    required this.customers,
    this.selected,
    required this.onSelect,
  });

  @override
  State<SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<SearchSheet> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  List<Customer> _filtered = [];
  Map<String, int> _debtCounts = {};
  Map<String, double> _balances = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _filtered = widget.customers;
    _focus.requestFocus();
    _loadDebtInfo();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _loadDebtInfo() async {
    try {
      final txRepo = TransactionRepository();
      final allTx = await txRepo.getAll();
      final counts = <String, int>{};
      final bals = <String, double>{};
      for (final tx in allTx) {
        counts[tx.customerId] = (counts[tx.customerId] ?? 0) + 1;
        bals[tx.customerId] = (bals[tx.customerId] ?? 0) +
            (tx.isDebt ? tx.amount : -tx.amount);
      }
      if (mounted) {
        setState(() {
          _debtCounts = counts;
          _balances = bals;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyFilter(String q) {
    final query = q.trim().toLowerCase();
    setState(() {
      _filtered = query.isEmpty
          ? widget.customers
          : widget.customers.where((c) {
              return c.name.toLowerCase().contains(query) ||
                  (c.phone != null && c.phone!.contains(query));
            }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      margin: EdgeInsets.only(bottom: bottom),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        children: [
          SheetHandle(cs: cs),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: SearchField(
              l10n: widget.l10n,
              cs: cs,
              ctrl: _ctrl,
              focus: _focus,
              onChanged: _applyFilter,
            ),
          ),
          SheetHeader(
            l10n: widget.l10n,
            cs: cs,
            count: _filtered.length,
            total: widget.customers.length,
          ),
          const SizedBox(height: 4),
          Expanded(
            child: _loading
                ? Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: cs.primary,
                      ),
                    ),
                  )
                : _filtered.isEmpty
                    ? _EmptyState(l10n: widget.l10n, cs: cs)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) => CustomerTile(
                          customer: _filtered[i],
                          cs: cs,
                          isSelected: widget.selected?.id == _filtered[i].id,
                          debtCount: _debtCounts[_filtered[i].id] ?? 0,
                          balance: _balances[_filtered[i].id] ?? 0,
                          isLoading: _loading,
                          onTap: () => widget.onSelect(_filtered[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class SheetHandle extends StatelessWidget {
  final ColorScheme cs;
  const SheetHandle({super.key, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(top: 12, bottom: 4),
        decoration: BoxDecoration(
          color: cs.onSurfaceVariant.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class SheetHeader extends StatelessWidget {
  final AppLocalizations l10n;
  final ColorScheme cs;
  final int count;
  final int total;
  const SheetHeader({
    super.key,
    required this.l10n,
    required this.cs,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            l10n.customerName,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count == total ? '$total' : '$count/$total',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: cs.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations l10n;
  final ColorScheme cs;
  const _EmptyState({required this.l10n, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: cs.onSurfaceVariant.withValues(alpha: 0.3)),
          const SizedBox(height: 10),
          Text(
            l10n.noMatchFound,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.addNewCustomer,
            style: TextStyle(
              fontSize: 12,
              color: cs.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
