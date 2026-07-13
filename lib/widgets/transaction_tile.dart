import 'package:flutter/material.dart';
import '../data/models/transaction.dart' as model;
import '../l10n/app_localizations.dart';

/// Single transaction row with type icon, amount, date, and optional note.
String _fmt(double n) {
  final s = n % 1 == 0 ? n.toStringAsFixed(0) : n.toStringAsFixed(2);
  return s.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}

class TransactionTile extends StatelessWidget {
  final model.Transaction transaction;
  final double? remaining;
  const TransactionTile({super.key, required this.transaction, this.remaining});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDebt = transaction.isDebt;
    final color = isDebt ? theme.colorScheme.error : const Color(0xFF2E7D32);
    final bg = isDebt ? theme.colorScheme.errorContainer : const Color(0xFFE8F5E9);
    final formatted = _fmt(transaction.amount);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3))),
          child: Row(children: [
            _Icon(isDebt: isDebt, color: color, bg: bg),
            const SizedBox(width: 14),
            Expanded(child: _Info(txn: transaction, isDebt: isDebt, remaining: remaining)),
            _Amt(formatted: formatted, isDebt: isDebt, color: color, date: transaction.date),
        ]),
      ),
    );
  }
}

class _Icon extends StatelessWidget {
  final bool isDebt;
  final Color color, bg;
  const _Icon({required this.isDebt, required this.color, required this.bg});
  @override
  Widget build(BuildContext context) {
    return Container(width: 42, height: 42,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Icon(isDebt ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, color: color, size: 22));
  }
}

class _Info extends StatelessWidget {
  final model.Transaction txn;
  final bool isDebt;
  final double? remaining;
  const _Info({required this.txn, required this.isDebt, this.remaining});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final fullyPaid = isDebt && remaining != null && remaining! <= 0;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(isDebt ? l10n.debt : l10n.payment, style: TextStyle(
          fontSize: 15, fontWeight: FontWeight.w700,
          color: fullyPaid ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.error)),
        if (fullyPaid) ...[const SizedBox(width: 6),
          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(4)),
            child: Text(l10n.fullyPaid, style: const TextStyle(
              fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF2E7D32))))],
      ]),
      if (isDebt && remaining != null && !fullyPaid)
        Padding(padding: const EdgeInsets.only(top: 2),
          child: Text('${l10n.remaining}: ${_fmt(remaining!)}',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.error))),
      if (!isDebt && txn.debtId != null)
        Padding(padding: const EdgeInsets.only(top: 2),
          child: Text('${l10n.paidTo} #${txn.debtId}',
            style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant))),
      if (txn.note?.isNotEmpty == true)
        Padding(padding: const EdgeInsets.only(top: 2),
          child: Text(txn.note!, style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
            maxLines: 1, overflow: TextOverflow.ellipsis)),
    ]);
  }
}

class _Amt extends StatelessWidget {
  final String formatted;
  final bool isDebt;
  final Color color;
  final String date;
  const _Amt({required this.formatted, required this.isDebt, required this.color, required this.date});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Text('${isDebt ? '+' : '-'}$formatted',
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: color, letterSpacing: -0.3)),
      Text(date.substring(0, 10),
        style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7))),
    ]);
  }
}
