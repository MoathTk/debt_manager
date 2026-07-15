import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../data/models/transaction.dart' as model;
import '../Providers/database_provider.dart';
import '../Providers/mutations.dart';
import '../Providers/sync_provider.dart';
import 'amount_input_formatter.dart';
import 'app_snackbar.dart';

/// Bottom sheet for editing or deleting an existing debt.
void showEditDebtSheet(
  BuildContext context,
  WidgetRef ref,
  model.Transaction debt,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _EditDebtBody(debt: debt),
  );
}

class _EditDebtBody extends ConsumerStatefulWidget {
  final model.Transaction debt;
  const _EditDebtBody({required this.debt});
  @override
  ConsumerState<_EditDebtBody> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_EditDebtBody> {
  late final TextEditingController _amount;
  late final TextEditingController _note;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _amount = TextEditingController(
      text: formatAmount(widget.debt.amount),
    );
    _note = TextEditingController(text: widget.debt.note ?? '');
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final val = parseAmount(_amount.text.trim());
    if (val == null || val <= 0) return;

    final totalPaid = await ref
        .read(transactionRepositoryProvider)
        .getPaymentsForDebt(widget.debt.id);
    if (val < totalPaid) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        showErrorSnackBar(context, l10n.amountCannotExceedRemaining);
      }
      return;
    }

    setState(() => _saving = true);
    await updateTransaction(
      ref,
      transaction: widget.debt,
      amount: val,
      note: _note.text.trim().isEmpty ? null : _note.text.trim(),
    );
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    setState(() => _saving = true);
    final reminderRepo = ref.read(debtReminderRepositoryProvider);
    await reminderRepo.deleteByDebtId(widget.debt.id);
    final repo = ref.read(transactionRepositoryProvider);
    await repo.delete(widget.debt.id);
    ref.read(syncProvider.notifier).schedulePush();
    _invalidate(ref);
    ref.invalidate(allRemindersProvider);
    ref.invalidate(pendingRemindersProvider);
    ref.invalidate(dueTodayProvider);
    if (mounted) Navigator.pop(context);
  }

  void _invalidate(WidgetRef ref) {
    ref.invalidate(transactionsByCustomerProvider(widget.debt.customerId));
    ref.invalidate(customerBalanceProvider(widget.debt.customerId));
    ref.invalidate(debtsWithRemainingProvider(widget.debt.customerId));
    ref.invalidate(transactionsProvider);
    ref.invalidate(dashboardStatsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _handle(theme),
          const SizedBox(height: 20),
          Text(
            l10n.editDebt,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 24),
          _Field(ctrl: _amount, label: l10n.amount, decimal: true, autofocus: true,
            formatters: [ThousandsSeparatorInputFormatter()]),
          const SizedBox(height: 16),
          _Field(ctrl: _note, label: l10n.noteOptional),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : Text(
                      l10n.save,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: _saving ? null : _delete,
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error),
              ),
              child: Text(
                l10n.deleteDebt,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _handle(ThemeData theme) => Container(
    width: 40,
    height: 4,
    decoration: BoxDecoration(
      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(2),
    ),
  );
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final bool decimal;
  final bool autofocus;
  final List<TextInputFormatter>? formatters;
  const _Field({required this.ctrl, required this.label, this.decimal = false, this.autofocus = false, this.formatters});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      autofocus: autofocus,
      keyboardType: decimal
          ? const TextInputType.numberWithOptions(decimal: true)
          : null,
      inputFormatters: formatters,
      style: const TextStyle(fontSize: 18),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
