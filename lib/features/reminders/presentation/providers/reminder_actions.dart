/// REMINDERS FEATURE — PRESENTATION LAYER: ACTIONS
///
/// The write path for reminders. These free functions take a
/// [ProviderContainer] so they can be invoked from any widget/sheet,
/// exactly like the legacy global mutations.
/// Each action: runs the domain use case (or composes cross-feature
/// writes) → invalidates affected providers → schedules a cloud push.
///
/// Debt coordination (creating a payment when a reminder is completed
/// against a still-outstanding debt) is composed here against the debts
/// feature — the same relationship the debts feature has with reminders
/// in transaction_actions.dart.
/// ---------------------------------------------------------------------------
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_debt_management/core/sharedProviders/database_provider.dart';
import 'package:local_debt_management/core/sharedProviders/sync_provider.dart';
import 'package:local_debt_management/features/debts/domain/entities/transaction.dart';
import 'package:local_debt_management/features/debts/presentation/providers/transaction_providers.dart';
import 'package:local_debt_management/core/services/auth_service.dart';
import 'package:local_debt_management/core/utils/sync_id.dart';
import 'debt_reminder_providers.dart';

String _getOwnerId(ProviderContainer container) {
  return container.read(authServiceProvider).ownerId ?? '';
}

void _invalidateReminders(ProviderContainer container) {
  container.invalidate(allRemindersProvider);
  container.invalidate(pendingRemindersProvider);
  container.invalidate(dueTodayProvider);
  container.invalidate(dashboardStatsProvider);
}

Future<void> markReminderCompleted(
  ProviderContainer container,
  String id,
  String note,
) async {
  final reminderRepo = container.read(debtReminderRepositoryProvider);
  final reminder = await reminderRepo.getById(id);
  if (reminder != null && reminder.debtId != null) {
    final txRepo = container.read(transactionRepositoryProvider);
    final debt = await txRepo.getById(reminder.debtId!);
    if (debt != null) {
      final paid = await txRepo.getPaymentsForDebt(reminder.debtId!);
      final remaining = debt.amount - paid;
      if (remaining > 0) {
        final now = DateTime.now().toIso8601String();
        await txRepo.insert(
          Transaction(
            id: generateId(),
            customerId: debt.customerId,
            amount: remaining,
            type: Transaction.payment,
            note: note,
            date: now,
            debtId: reminder.debtId,
            ownerId: _getOwnerId(container),
            updatedAt: now,
          ),
        );
        container.invalidate(transactionsProvider);
        container.invalidate(transactionsByCustomerProvider(debt.customerId));
        container.invalidate(customerBalanceProvider(debt.customerId));
        container.invalidate(debtsWithRemainingProvider(debt.customerId));
        container.invalidate(dashboardStatsProvider);
        container.invalidate(paymentsByDebtProvider(reminder.debtId!));
      }
    }
  }
  await container.read(markCompletedUseCaseProvider).call(id);
  _invalidateReminders(container);
  container.read(syncProvider.notifier).schedulePush();
}

Future<void> markReminderPending(ProviderContainer container, String id) async {
  await container.read(markPendingUseCaseProvider).call(id);
  _invalidateReminders(container);
  container.read(syncProvider.notifier).schedulePush();
}

Future<void> deleteReminder(ProviderContainer container, String id) async {
  await container.read(deleteReminderUseCaseProvider).call(id);
  _invalidateReminders(container);
  container.read(syncProvider.notifier).schedulePush();
}

Future<void> deleteRemindersBatch(
  ProviderContainer container,
  List<String> ids,
) async {
  await container.read(deleteRemindersBatchUseCaseProvider).call(ids);
  _invalidateReminders(container);
  container.read(syncProvider.notifier).schedulePush();
}
