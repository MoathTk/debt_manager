import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/customer.dart';
import '../data/models/transaction.dart' as model;
import '../data/models/debt_reminder.dart';
import '../utils/sync_id.dart';
import '../services/auth_service.dart';
import 'database_provider.dart';

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

void _invalidateCustomers(WidgetRef ref) {
  ref.invalidate(customersProvider);
  ref.invalidate(dashboardStatsProvider);
}

void _invalidateTransactions(WidgetRef ref, String customerId) {
  ref.invalidate(transactionsProvider);
  ref.invalidate(transactionsByCustomerProvider(customerId));
  ref.invalidate(customerBalanceProvider(customerId));
  ref.invalidate(debtsWithRemainingProvider(customerId));
  ref.invalidate(dashboardStatsProvider);
}

void _invalidateReminders(WidgetRef ref) {
  ref.invalidate(allRemindersProvider);
  ref.invalidate(pendingRemindersProvider);
  ref.invalidate(dueTodayProvider);
  ref.invalidate(dashboardStatsProvider);
}

// ============================================================================
// REMINDER MUTATIONS
// ============================================================================

Future<void> markReminderCompleted(WidgetRef ref, String id) async {
  final repo = ref.read(debtReminderRepositoryProvider);
  await repo.markCompleted(id);
  _invalidateReminders(ref);
}

Future<void> markReminderPending(WidgetRef ref, String id) async {
  final repo = ref.read(debtReminderRepositoryProvider);
  await repo.markPending(id);
  _invalidateReminders(ref);
}

Future<void> deleteReminder(WidgetRef ref, String id) async {
  final repo = ref.read(debtReminderRepositoryProvider);
  await repo.delete(id);
  _invalidateReminders(ref);
}

Future<void> deleteRemindersBatch(WidgetRef ref, List<String> ids) async {
  final repo = ref.read(debtReminderRepositoryProvider);
  await repo.deleteBatch(ids);
  _invalidateReminders(ref);
}

// ============================================================================
// CUSTOMER MUTATIONS
// ============================================================================

String _getOwnerId(WidgetRef ref) {
  return ref.read(authServiceProvider).ownerId ?? '';
}

Future<void> addCustomer(
  WidgetRef ref, {
  required String name,
  String? phone,
}) async {
  final repo = ref.read(customerRepositoryProvider);
  final now = DateTime.now().toIso8601String();
  await repo.insert(
    Customer(
      id: generateId(),
      name: name,
      phone: phone,
      createdAt: now,
      ownerId: _getOwnerId(ref),
      updatedAt: now,
    ),
  );
  _invalidateCustomers(ref);
}

Future<void> updateCustomer(
  WidgetRef ref, {
  required Customer customer,
  required String name,
  String? phone,
}) async {
  final repo = ref.read(customerRepositoryProvider);
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
  ref.invalidate(customersProvider);
  ref.invalidate(customerByIdProvider(customer.id!));
  ref.invalidate(dashboardStatsProvider);
}

// ============================================================================
// TRANSACTION MUTATIONS
// ============================================================================

Future<void> addDebt(
  WidgetRef ref, {
  required String customerId,
  required double amount,
  String? note,
}) async {
  final repo = ref.read(transactionRepositoryProvider);
  final now = DateTime.now().toIso8601String();
  final debtId = generateId();
  final ownerId = _getOwnerId(ref);
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
  final reminderRepo = ref.read(debtReminderRepositoryProvider);
  await reminderRepo.insert(
    DebtReminder(
      id: generateId(),
      customerId: customerId,
      debtId: debtId,
      reminderDate: now.substring(0, 10),
      message: note,
      ownerId: ownerId,
      updatedAt: now,
    ),
  );
  _invalidateTransactions(ref, customerId);
  _invalidateReminders(ref);
}

Future<void> recordPayment(
  WidgetRef ref, {
  required String customerId,
  required double amount,
  String? note,
  String? debtId,
}) async {
  final repo = ref.read(transactionRepositoryProvider);
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
      ownerId: _getOwnerId(ref),
      updatedAt: now,
    ),
  );
  _invalidateTransactions(ref, customerId);
}

Future<void> deleteTransaction(
  WidgetRef ref,
  String transactionId,
  String customerId,
) async {
  final repo = ref.read(transactionRepositoryProvider);
  await repo.delete(transactionId);
  _invalidateTransactions(ref, customerId);
}

Future<void> updateTransaction(
  WidgetRef ref, {
  required model.Transaction transaction,
  required double amount,
  String? note,
}) async {
  final repo = ref.read(transactionRepositoryProvider);
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
  _invalidateTransactions(ref, transaction.customerId);
}

Future<void> settleDebt(
  WidgetRef ref, {
  required String customerId,
  required String debtId,
  required double amount,
  String? note,
}) async {
  final repo = ref.read(transactionRepositoryProvider);
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
      ownerId: _getOwnerId(ref),
      updatedAt: now,
    ),
  );
  final reminderRepo = ref.read(debtReminderRepositoryProvider);
  final reminders = await reminderRepo.getAll();
  for (final r in reminders) {
    if (r.debtId == debtId && !r.completed) {
      await reminderRepo.markCompleted(r.id!);
    }
  }
  _invalidateTransactions(ref, customerId);
  _invalidateReminders(ref);
}
