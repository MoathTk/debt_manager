import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../data/models/transaction.dart' as model;
import '../Providers/database_provider.dart';
import '../data/models/debt_reminder.dart';
import 'reminder_detail_info.dart';
import 'reminder_detail_actions.dart';

void showReminderDetailSheet(
  BuildContext context,
  WidgetRef ref,
  DebtReminder reminder,
) {
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
    if (mounted) {
      setState(() {
        _debtTxn = txn;
        _debtPaid = paid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final r = widget.reminder;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: cs.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.reminderDetails,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          ReminderDetailInfo(
            reminder: r,
            debtTxn: _debtTxn,
            debtPaid: _debtPaid,
          ),
          const SizedBox(height: 20),
          _MarkCompletedButton(reminder: r, debtPaid: _debtPaid, debtTxn: _debtTxn),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () => confirmDelete(context, r, l10n),
              style: OutlinedButton.styleFrom(
                foregroundColor: cs.error,
                side: BorderSide(color: cs.error),
              ),
              child: Text(
                l10n.deleteReminder,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _MarkCompletedButton extends StatelessWidget {
  final DebtReminder reminder;
  final double debtPaid;
  final model.Transaction? debtTxn;

  const _MarkCompletedButton({
    required this.reminder,
    required this.debtPaid,
    required this.debtTxn,
  });

  bool get _isCompleted => reminder.completed;
  bool get _debtFullyPaid =>
      debtTxn != null && (debtTxn!.amount - debtPaid) <= 0;
  bool get _disabled => _isCompleted || _debtFullyPaid;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final disabled = _disabled;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: disabled ? null : () => confirmToggle(context, reminder, l10n),
        style: FilledButton.styleFrom(
          backgroundColor: disabled ? cs.surfaceContainerHighest : null,
          foregroundColor: disabled ? cs.onSurfaceVariant : null,
        ),
        child: Text(
          _debtFullyPaid ? l10n.settled : l10n.markCompleted,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
