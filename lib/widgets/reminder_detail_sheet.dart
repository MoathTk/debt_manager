import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../data/models/transaction.dart' as model;
import '../Providers/database_provider.dart';
import '../data/models/debt_reminder.dart';
import 'info_row.dart';

String _fmt(double n) {
  final s = n % 1 == 0 ? n.toStringAsFixed(0) : n.toStringAsFixed(2);
  return s.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}

void showReminderDetailSheet(
    BuildContext context, WidgetRef ref, DebtReminder reminder) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _ReminderDetailBody(reminder: reminder),
  );
}

class _ReminderDetailBody extends ConsumerStatefulWidget {
  final DebtReminder reminder;
  const _ReminderDetailBody({required this.reminder});
  @override
  ConsumerState<_ReminderDetailBody> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_ReminderDetailBody> {
  model.Transaction? _debtTxn;
  double _debtPaid = 0;

  @override
  void initState() {
    super.initState();
    _loadDebt();
  }

  Future<void> _loadDebt() async {
    if (widget.reminder.debtId == null) return;
    final repo = ref.read(transactionRepositoryProvider);
    final txn = await repo.getById(widget.reminder.debtId!);
    final paid = await repo.getPaymentsForDebt(widget.reminder.debtId!);
    if (mounted) setState(() { _debtTxn = txn; _debtPaid = paid; });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final r = widget.reminder;
    final nameAsync = ref.watch(customerByIdProvider(r.customerId));
    final rd = DateTime.parse(r.reminderDate);
    final dateStr = '${rd.day}/${rd.month}/${rd.year}';
    final remaining = _debtTxn != null ? _debtTxn!.amount - _debtPaid : 0.0;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4,
          decoration: BoxDecoration(
            color: cs.onSurfaceVariant.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),
        Text(l10n.reminderDetails, style: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w800, color: cs.onSurface)),
        const SizedBox(height: 20),
        InfoRow(label: l10n.customerName, child: nameAsync.when(
          data: (c) => Text(c?.name ?? '—', style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w600, color: cs.onSurface)),
          loading: () => const CircularProgressIndicator(strokeWidth: 2),
          error: (_, __) => const Text('—'),
        )),
        if (_debtTxn != null) ...[
          InfoRow(label: l10n.amount, child: Text(_fmt(_debtTxn!.amount),
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
              color: cs.onSurface))),
          if (remaining > 0)
            InfoRow(label: l10n.remaining, child: Text(_fmt(remaining),
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                color: cs.error))),
        ],
        InfoRow(label: l10n.reminderDate, child: Text(dateStr,
          style: TextStyle(fontSize: 15, color: cs.onSurface))),
        if (r.message != null)
          InfoRow(label: l10n.note, child: Text(r.message!,
            style: TextStyle(fontSize: 15, color: cs.onSurface))),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity, height: 52,
          child: FilledButton(onPressed: () => _confirmToggle(context, ref, l10n),
            child: Text(l10n.markCompleted,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          )),
        const SizedBox(height: 10),
        SizedBox(width: double.infinity, height: 52,
          child: OutlinedButton(onPressed: () => _confirmDelete(context, ref, l10n),
            style: OutlinedButton.styleFrom(
              foregroundColor: cs.error, side: BorderSide(color: cs.error)),
            child: Text(l10n.deleteReminder,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          )),
        const SizedBox(height: 8),
      ]),
    );
  }

  void _confirmToggle(BuildContext ctx, WidgetRef ref, AppLocalizations l10n) {
    final r = widget.reminder;
    final msg = r.completed ? l10n.confirmMarkPending : l10n.confirmMarkCompleted;
    Navigator.pop(ctx);
    showDialog(context: ctx, builder: (_) => AlertDialog(
      title: Text(l10n.markCompleted), content: Text(msg),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
        TextButton(onPressed: () { Navigator.pop(ctx);
          r.completed
            ? markReminderPending(ref, r.id!)
            : markReminderCompleted(ref, r.id!);
        }, child: Text(l10n.yes)),
      ],
    ));
  }

  void _confirmDelete(BuildContext ctx, WidgetRef ref, AppLocalizations l10n) {
    final r = widget.reminder;
    Navigator.pop(ctx);
    showDialog(context: ctx, builder: (_) => AlertDialog(
      title: Text(l10n.deleteReminder), content: Text(l10n.confirmDeleteReminder),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
        TextButton(onPressed: () { Navigator.pop(ctx); deleteReminder(ref, r.id!); },
          child: Text(l10n.yes, style: TextStyle(color: Theme.of(ctx).colorScheme.error))),
      ],
    ));
  }
}
