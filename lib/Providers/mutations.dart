import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_debt_management/features/debts/domain/entities/transaction.dart';
import '../utils/sync_id.dart';
import '../services/auth_service.dart';
import 'database_provider.dart';
import 'sync_provider.dart';

// ============================================================================
// DEBT WRITE ACTIONS
// ============================================================================
// The debt mutations (addDebt, recordPayment, updateTransaction,
// deleteTransaction, deleteDebt, settleDebt) now live in the debts feature —
// `lib/features/debts/presentation/providers/transaction_actions.dart`. They
// are re-exported here so legacy callers keep compiling unchanged.

export 'package:local_debt_management/features/debts/presentation/providers/transaction_actions.dart'
    show
        addDebt,
        recordPayment,
        updateTransaction,
        deleteTransaction,
        deleteDebt,
        settleDebt;

// ============================================================================
// DATA CLASSES
// ============================================================================

class DashboardStats {
  final int customerCount;
  final double totalDebts;
  final double totalPayments;
  final int pendingReminders;
  final List<Map<String, dynamic>> periodicData;
  final List<Map<String, dynamic>> topDebtors;

  double get collectionRate =>
      totalDebts > 0 ? totalPayments / totalDebts : 0.0;

  DashboardStats({
    required this.customerCount,
    required this.totalDebts,
    required this.totalPayments,
    required this.pendingReminders,
    this.periodicData = const [],
    this.topDebtors = const [],
  });
}

// ============================================================================
// INVALIDATION HELPLERS
// ============================================================================

void _invalidateReminders(ProviderContainer container) {
  container.invalidate(allRemindersProvider);
  container.invalidate(pendingRemindersProvider);
  container.invalidate(dueTodayProvider);
  container.invalidate(dashboardStatsProvider);
}

String _getOwnerId(ProviderContainer container) {
  return container.read(authServiceProvider).ownerId ?? '';
}

// ============================================================================
// REMINDER MUTATIONS
// ============================================================================

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
  await reminderRepo.markCompleted(id);
  _invalidateReminders(container);
  container.read(syncProvider.notifier).schedulePush();
}

Future<void> markReminderPending(ProviderContainer container, String id) async {
  final repo = container.read(debtReminderRepositoryProvider);
  await repo.markPending(id);
  _invalidateReminders(container);
  container.read(syncProvider.notifier).schedulePush();
}

Future<void> deleteReminder(ProviderContainer container, String id) async {
  final repo = container.read(debtReminderRepositoryProvider);
  await repo.delete(id);
  _invalidateReminders(container);
  container.read(syncProvider.notifier).schedulePush();
}

Future<void> deleteRemindersBatch(
  ProviderContainer container,
  List<String> ids,
) async {
  final repo = container.read(debtReminderRepositoryProvider);
  await repo.deleteBatch(ids);
  _invalidateReminders(container);
  container.read(syncProvider.notifier).schedulePush();
}
