import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../Providers/database_provider.dart';
import '../Providers/sync_provider.dart';
import '../data/models/transaction.dart' as model;
import '../data/models/debt_reminder.dart';

void confirmToggle(BuildContext ctx, DebtReminder r, AppLocalizations l10n) {
  final msg = r.completed ? l10n.confirmMarkPending : l10n.confirmMarkCompleted;
  final container = ProviderScope.containerOf(ctx);
  final reminderRepo = container.read(debtReminderRepositoryProvider);
  final txnRepo = container.read(transactionRepositoryProvider);
  final parentCtx = Navigator.of(ctx).context;
  Navigator.pop(ctx);
  showDialog(
    context: parentCtx,
    builder: (_) => AlertDialog(
      title: Text(l10n.markCompleted),
      content: Text(msg),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(parentCtx),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(parentCtx);
            await reminderRepo.markCompleted(r.id!);
            if (r.debtId != null) {
              final debt = await txnRepo.getById(r.debtId!);
              if (debt != null) {
                final paid = await txnRepo.getPaymentsForDebt(r.debtId!);
                final remaining = debt.amount - paid;
                if (remaining > 0) {
                  await txnRepo.insert(
                    model.Transaction(
                      customerId: debt.customerId,
                      amount: remaining,
                      type: model.Transaction.payment,
                      debtId: r.debtId,
                      date: DateTime.now().toIso8601String(),
                      note: l10n.autoSettledViaReminder,
                    ),
                  );
                }
              }
            }
            if (parentCtx.mounted) _invalidate(parentCtx);
          },
          child: Text(l10n.yes),
        ),
      ],
    ),
  );
}

void confirmDelete(BuildContext ctx, DebtReminder r, AppLocalizations l10n) {
  final container = ProviderScope.containerOf(ctx);
  final reminderRepo = container.read(debtReminderRepositoryProvider);
  final parentCtx = Navigator.of(ctx).context;
  Navigator.pop(ctx);
  showDialog(
    context: parentCtx,
    builder: (_) => AlertDialog(
      title: Text(l10n.deleteReminder),
      content: Text(l10n.confirmDeleteReminder),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(parentCtx),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(parentCtx);
            await reminderRepo.delete(r.id!);
            if (parentCtx.mounted) {
              ProviderScope.containerOf(
                parentCtx,
              ).read(syncProvider.notifier).schedulePush();
            }
            if (parentCtx.mounted) _invalidate(parentCtx);
          },
          child: Text(
            l10n.yes,
            style: TextStyle(color: Theme.of(parentCtx).colorScheme.error),
          ),
        ),
      ],
    ),
  );
}

void _invalidate(BuildContext ctx) {
  if (!ctx.mounted) return;
  final c = ProviderScope.containerOf(ctx);
  c.invalidate(allRemindersProvider);
  c.invalidate(pendingRemindersProvider);
  c.invalidate(dueTodayProvider);
  c.invalidate(dashboardStatsProvider);
  c.invalidate(transactionsProvider);
}
