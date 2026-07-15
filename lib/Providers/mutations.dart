import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/customer.dart';
import '../data/models/transaction.dart' as model;
import '../data/models/debt_reminder.dart';
import '../utils/sync_id.dart';
import '../services/auth_service.dart';
import 'database_provider.dart';
import 'sync_provider.dart';

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
// INVALIDATION HELPERS
// ============================================================================

void _invalidateCustomers(ProviderContainer container) {
  container.invalidate(customersProvider);
  container.invalidate(dashboardStatsProvider);
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

String _getOwnerId(ProviderContainer container) {
  return container.read(authServiceProvider).ownerId ?? '';
}

// ============================================================================
// REMINDER MUTATIONS
// ============================================================================

Future<void> markReminderCompleted(ProviderContainer container, String id,String note) async {
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
          model.Transaction(
            id: generateId(),
            customerId: debt.customerId,
            amount: remaining,
            type: model.Transaction.payment,
            note: note,
            date: now,
            debtId: reminder.debtId,
            ownerId: _getOwnerId(container),
            updatedAt: now,
          ),
        );
        _invalidateTransactions(container, debt.customerId);
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

Future<void> deleteRemindersBatch(ProviderContainer container, List<String> ids) async {
  final repo = container.read(debtReminderRepositoryProvider);
  await repo.deleteBatch(ids);
  _invalidateReminders(container);
  container.read(syncProvider.notifier).schedulePush();
}

// ============================================================================
// CUSTOMER MUTATIONS
// ============================================================================

Future<void> addCustomer(
  ProviderContainer container, {
  required String name,
  String? phone,
}) async {
  final repo = container.read(customerRepositoryProvider);
  final now = DateTime.now().toIso8601String();
  await repo.insert(
    Customer(
      id: generateId(),
      name: name,
      phone: phone,
      createdAt: now,
      ownerId: _getOwnerId(container),
      updatedAt: now,
    ),
  );
  _invalidateCustomers(container);
  container.read(syncProvider.notifier).schedulePush();
}

Future<void> updateCustomer(
  ProviderContainer container, {
  required Customer customer,
  required String name,
  String? phone,
}) async {
  final repo = container.read(customerRepositoryProvider);
  await repo.update(
    Customer(
      id: customer.id,
      name: name,
      phone: phone,
      createdAt: customer.createdAt,
      ownerId: customer.ownerId,
      updatedAt: DateTime.now().toIso8601String(),
    ),
  );
  container.invalidate(customersProvider);
  container.invalidate(customerByIdProvider(customer.id));
  container.invalidate(dashboardStatsProvider);
  container.read(syncProvider.notifier).schedulePush();
}

Future<void> deleteCustomer(ProviderContainer container, String customerId) async {
  final customerRepo = container.read(customerRepositoryProvider);
  final txRepo = container.read(transactionRepositoryProvider);
  final reminderRepo = container.read(debtReminderRepositoryProvider);
  await customerRepo.delete(customerId);
  await txRepo.deleteByCustomerId(customerId);
  await reminderRepo.deleteByCustomerId(customerId);
  _invalidateCustomers(container);
  _invalidateTransactions(container, customerId);
  _invalidateReminders(container);
  container.read(syncProvider.notifier).schedulePush();
}

// ============================================================================
// TRANSACTION MUTATIONS
// ============================================================================

Future<void> addDebt(
  ProviderContainer container, {
  required String customerId,
  required double amount,
  String? note,
  DateTime? reminderDate,
}) async {
  final repo = container.read(transactionRepositoryProvider);
  final now = DateTime.now().toIso8601String();
  final debtId = generateId();
  final ownerId = _getOwnerId(container);
  await repo.insert(
    model.Transaction(
      id: debtId,
      customerId: customerId,
      amount: amount,
      type: model.Transaction.debt,
      note: note,
      date: now,
      ownerId: ownerId,
      updatedAt: now,
    ),
  );
  if (reminderDate != null) {
    final reminderRepo = container.read(debtReminderRepositoryProvider);
    await reminderRepo.insert(
      DebtReminder(
        id: generateId(),
        customerId: customerId,
        debtId: debtId,
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
  final repo = container.read(transactionRepositoryProvider);
  final now = DateTime.now().toIso8601String();
  await repo.insert(
    model.Transaction(
      id: generateId(),
      customerId: customerId,
      amount: amount,
      type: model.Transaction.payment,
      note: note,
      date: now,
      debtId: debtId,
      ownerId: _getOwnerId(container),
      updatedAt: now,
    ),
  );
  _invalidateTransactions(container, customerId);
  container.read(syncProvider.notifier).schedulePush();
}

Future<void> deleteTransaction(
  ProviderContainer container,
  String transactionId,
  String customerId,
) async {
  final repo = container.read(transactionRepositoryProvider);
  await repo.delete(transactionId);
  _invalidateTransactions(container, customerId);
  container.read(syncProvider.notifier).schedulePush();
}

Future<void> updateTransaction(
  ProviderContainer container, {
  required model.Transaction transaction,
  required double amount,
  String? note,
}) async {
  final repo = container.read(transactionRepositoryProvider);
  await repo.update(
    model.Transaction(
      id: transaction.id,
      customerId: transaction.customerId,
      amount: amount,
      type: transaction.type,
      note: note,
      date: transaction.date,
      debtId: transaction.debtId,
      ownerId: transaction.ownerId,
      updatedAt: DateTime.now().toIso8601String(),
    ),
  );
  _invalidateTransactions(container, transaction.customerId);
  container.read(syncProvider.notifier).schedulePush();
}

Future<void> settleDebt(
  ProviderContainer container, {
  required String customerId,
  required String debtId,
  required double amount,
  String? note,
}) async {
  final repo = container.read(transactionRepositoryProvider);
  final now = DateTime.now().toIso8601String();
  await repo.insert(
    model.Transaction(
      id: generateId(),
      customerId: customerId,
      amount: amount,
      type: model.Transaction.payment,
      note: note ?? 'Settle',
      date: now,
      debtId: debtId,
      ownerId: _getOwnerId(container),
      updatedAt: now,
    ),
  );
  final reminderRepo = container.read(debtReminderRepositoryProvider);
  final reminders = await reminderRepo.getAll();
  for (final r in reminders) {
    if (r.debtId == debtId && !r.completed) {
      await reminderRepo.markCompleted(r.id);
    }
  }
  _invalidateTransactions(container, customerId);
  _invalidateReminders(container);
  container.read(syncProvider.notifier).schedulePush();
}
