import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_debt_management/Providers/database_provider.dart';
import 'package:local_debt_management/features/subscription/presentation/providers/subscription_provider.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';
import '../../domain/entities/debt_reminder.dart';
import '../providers/reminder_actions.dart';

void confirmToggle(
  BuildContext ctx,
  DebtReminder r,
  AppLocalizations l10n,
) {
  final container = ProviderScope.containerOf(ctx);
  final state = container.read(subscriptionProvider);
  if (state.isBlocked) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(content: Text(l10n.subExpiredReadonly), behavior: SnackBarBehavior.floating),
    );
    return;
  }
  final msg = r.completed ? l10n.confirmMarkPending : l10n.confirmMarkCompleted;
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
            r.completed
                ? await markReminderPending(container, r.id)
                : await markReminderCompleted(container, r.id,l10n.autoSettledViaReminder);
          },
          child: Text(l10n.yes),
        ),
      ],
    ),
  );
}

void confirmDelete(BuildContext ctx, DebtReminder r, AppLocalizations l10n) {
  final container = ProviderScope.containerOf(ctx);
  final state = container.read(subscriptionProvider);
  if (state.isBlocked) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(content: Text(l10n.subExpiredReadonly), behavior: SnackBarBehavior.floating),
    );
    return;
  }
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
            await deleteReminder(container, r.id);
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
