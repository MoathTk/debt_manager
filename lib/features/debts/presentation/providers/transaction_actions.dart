/// DEBTS FEATURE — PRESENTATION LAYER: ACTIONS
///
/// The write path for debts. These free functions take a
/// [ProviderContainer] so they can be invoked from any widget/sheet/
/// voice-command flow, exactly like the legacy global mutations.
/// Each action: runs the domain use case → invalidates affected
/// providers → schedules a cloud push.
///
/// Reminder coordination (creating one with a debt, auto-completing one
/// when a debt is settled) is composed here against the reminders feature's
/// repository until the cross-feature actions are unified.
/// ---------------------------------------------------------------------------
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_debt_management/Providers/database_provider.dart';
import 'package:local_debt_management/Providers/sync_provider.dart';
import 'package:local_debt_management/features/reminders/domain/entities/debt_reminder.dart';
import 'package:local_debt_management/services/auth_service.dart';
import 'package:local_debt_management/utils/sync_id.dart';
import '../../domain/entities/transaction.dart';
import 'transaction_providers.dart';

String _getOwnerId(ProviderContainer container) {
  return container.read(authServiceProvider).ownerId ?? '';
}

void _invalidateTransactions(ProviderContainer container, String customerId) {
  container.invalidate(transactionsProvider);
  container.invalidate(transactionsByCustomerProvider(customerId));
  container.invalidate(customerBalanceProvider(customerId));
  container.invalidate(debtsWithRemainingProvider(customerId));
  container.invalidate(dashboardStatsProvider);
}

void _invalidateReminders(ProviderContainer container) {
  container.invalidate(allRemindersProvider);
  container.invalidate(pendingRemindersProvider);
  container.invalidate(dueTodayProvider);
  container.invalidate(dashboardStatsProvider);
}

Future<void> addDebt(
  ProviderContainer container, {
  required String customerId,
  required double amount,
  String? note,
  DateTime? reminderDate,
}) async {
  final ownerId = _getOwnerId(container);
  final debt = await container
      .read(addDebtUseCaseProvider)
      .call(
        customerId: customerId,
        amount: amount,
        note: note,
        ownerId: ownerId,
      );
  if (reminderDate != null) {
    final now = DateTime.now().toIso8601String();
    final reminderRepo = container.read(debtReminderRepositoryProvider);
    await reminderRepo.insert(
      DebtReminder(
        id: generateId(),
        customerId: customerId,
        debtId: debt.id,
        reminderDate: reminderDate.toIso8601String().substring(0, 10),
        message: note,
        ownerId: ownerId,
        updatedAt: now,
      ),
    );
    _invalidateReminders(container);
  }
  _invalidateTransactions(container, customerId);
  container.read(syncProvider.notifier).schedulePush();
}

Future<void> recordPayment(
  ProviderContainer container, {
  required String customerId,
  required double amount,
  String? note,
  String? debtId,
}) async {
  await container
      .read(recordPaymentUseCaseProvider)
      .call(
        customerId: customerId,
        amount: amount,
        note: note,
        debtId: debtId,
        ownerId: _getOwnerId(container),
      );
  _invalidateTransactions(container, customerId);
  if (debtId != null) {
    container.invalidate(paymentsByDebtProvider(debtId));
    await _autoCompleteRemindersIfSettled(container, debtId);
  }
  container.read(syncProvider.notifier).schedulePush();
}

Future<void> deleteTransaction(
  ProviderContainer container,
  String transactionId,
  String customerId,
) async {
  final txn = await container
      .read(deleteTransactionUseCaseProvider)
      .call(transactionId);
  _invalidateTransactions(container, customerId);
  if (txn != null && txn.isPayment && txn.debtId != null) {
    container.invalidate(paymentsByDebtProvider(txn.debtId!));
  }
  container.read(syncProvider.notifier).schedulePush();
}

/// Cascade-deletes a debt and all its associated payments and reminders.
Future<void> deleteDebt(
  ProviderContainer container,
  String debtId,
  String customerId,
) async {
  await container.read(deleteDebtUseCaseProvider).call(debtId);
  final reminderRepo = container.read(debtReminderRepositoryProvider);
  await reminderRepo.deleteByDebtId(debtId);
  _invalidateTransactions(container, customerId);
  _invalidateReminders(container);
  container.invalidate(paymentsByDebtProvider(debtId));
  container.read(syncProvider.notifier).schedulePush();
}

Future<void> updateTransaction(
  ProviderContainer container, {
  required Transaction transaction,
  required double amount,
  String? note,
}) async {
  await container
      .read(updateTransactionUseCaseProvider)
      .call(transaction: transaction, amount: amount, note: note);
  _invalidateTransactions(container, transaction.customerId);
  if (transaction.isPayment && transaction.debtId != null) {
    await _autoCompleteRemindersIfSettled(container, transaction.debtId!);
  }
  container.read(syncProvider.notifier).schedulePush();
}

Future<void> settleDebt(
  ProviderContainer container, {
  required String customerId,
  required String debtId,
  required double amount,
  String? note,
}) async {
  await container
      .read(settleDebtUseCaseProvider)
      .call(
        customerId: customerId,
        amount: amount,
        note: note,
        debtId: debtId,
        ownerId: _getOwnerId(container),
      );
  await _autoCompleteRemindersIfSettled(container, debtId);
  _invalidateTransactions(container, customerId);
  container.invalidate(paymentsByDebtProvider(debtId));
  container.read(syncProvider.notifier).schedulePush();
}

Future<void> _autoCompleteRemindersIfSettled(
  ProviderContainer container,
  String debtId,
) async {
  final txRepo = container.read(transactionRepositoryProvider);
  final debt = await txRepo.getById(debtId);
  if (debt == null) return;
  final paid = await txRepo.getPaymentsForDebt(debtId);
  if ((debt.amount - paid) > 0) return;
  final reminderRepo = container.read(debtReminderRepositoryProvider);
  final reminders = await reminderRepo.getAll();
  var changed = false;
  for (final r in reminders) {
    if (r.debtId == debtId && !r.completed) {
      await reminderRepo.markCompleted(r.id);
      changed = true;
    }
  }
  if (changed) _invalidateReminders(container);
}
