import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database_helper.dart';
import '../data/repositories/customer_repository.dart';
import '../data/repositories/transaction_repository.dart';
import '../data/repositories/debt_reminder_repository.dart';
import '../data/models/customer.dart';
import '../data/models/transaction.dart' as model;
import '../data/models/debt_reminder.dart';

// ============================================================================
// INFRASTRUCTURE PROVIDERS
// These providers give access to the database and repository instances.
// ============================================================================

/// Provider for the DatabaseHelper singleton.
/// All database operations go through this instance.
final databaseProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

/// Provider for CustomerRepository.
/// Handles all customer-related database operations.
final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepository();
});

/// Provider for TransactionRepository.
/// Handles all transaction-related database operations.
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

/// Provider for DebtReminderRepository.
/// Handles all debt reminder-related database operations.
final debtReminderRepositoryProvider = Provider<DebtReminderRepository>((ref) {
  return DebtReminderRepository();
});

// ============================================================================
// DATA PROVIDERS (FutureProvider)
// These providers fetch and cache data from the database.
// They automatically re-fetch when their dependencies change.
// ============================================================================

/// Fetches all customers from the database.
/// Returns a list ordered by creation date (newest first).
final customersProvider = FutureProvider<List<Customer>>((ref) async {
  final repo = ref.watch(customerRepositoryProvider);
  return repo.getAll();
});

/// Fetches a single customer by ID.
/// Uses Riverpod's family feature to cache per-customer results.
/// Returns null if the customer doesn't exist.
final customerByIdProvider = FutureProvider.family<Customer?, int>((
  ref,
  id,
) async {
  final repo = ref.watch(customerRepositoryProvider);
  return repo.getById(id);
});

/// Fetches all transactions from the database.
/// Returns a list ordered by date (newest first).
final transactionsProvider = FutureProvider<List<model.Transaction>>((
  ref,
) async {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getAll();
});

/// Fetches all transactions for a specific customer.
/// Uses Riverpod's family feature to cache per-customer results.
final transactionsByCustomerProvider =
    FutureProvider.family<List<model.Transaction>, int>((
      ref,
      customerId,
    ) async {
      final repo = ref.watch(transactionRepositoryProvider);
      return repo.getByCustomer(customerId);
    });

/// Calculates the net balance for a specific customer.
/// Balance = Total Debts - Total Payments
/// Positive = customer owes money, Negative = customer has overpaid.
final customerBalanceProvider = FutureProvider.family<double, int>((
  ref,
  customerId,
) async {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getCustomerBalance(customerId);
});

/// Returns debts with their remaining balances for a specific customer.
/// Each entry has: id, amount, note, date, remaining.
/// Only includes debts with remaining > 0.
final debtsWithRemainingProvider =
    FutureProvider.family<List<Map<String, dynamic>>, int>((
      ref,
      customerId,
    ) async {
      final repo = ref.watch(transactionRepositoryProvider);
      return repo.getDebtsWithRemaining(customerId);
    });

/// Fetches all pending (uncompleted) debt reminders.
/// Results are ordered by reminder date (earliest first).
final pendingRemindersProvider = FutureProvider<List<DebtReminder>>((
  ref,
) async {
  final repo = ref.watch(debtReminderRepositoryProvider);
  return repo.getPending();
});

/// Fetches all reminders due today or earlier.
/// Only includes pending (uncompleted) reminders.
final dueTodayProvider = FutureProvider<List<DebtReminder>>((ref) async {
  final repo = ref.watch(debtReminderRepositoryProvider);
  return repo.getDueToday();
});

/// Fetches aggregated dashboard statistics.
/// Combines data from all three repositories into a single stats object.
/// Includes: customer count, total debts, total payments, pending reminders.
final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final customerRepo = ref.watch(customerRepositoryProvider);
  final transactionRepo = ref.watch(transactionRepositoryProvider);
  final reminderRepo = ref.watch(debtReminderRepositoryProvider);

  final customerCount = await customerRepo.getCustomerCount();
  final totalDebts = await transactionRepo.getTotalDebts();
  final totalPayments = await transactionRepo.getTotalPayments();
  final pendingReminders = await reminderRepo.getPendingCount();
  final periodic = await transactionRepo.getPeriodicData();
  final topDebtors = await transactionRepo.getTopDebtors(5);

  return DashboardStats(
    customerCount: customerCount,
    totalDebts: totalDebts,
    totalPayments: totalPayments,
    pendingReminders: pendingReminders,
    periodicData: periodic,
    topDebtors: topDebtors,
  );
});

/// Provider for periodic data with week/month toggle.
final periodicDataProvider =
    FutureProvider.family<List<Map<String, dynamic>>, bool>((
      ref,
      isWeekly,
    ) async {
      final repo = ref.watch(transactionRepositoryProvider);
      return repo.getPeriodicData(isWeekly: isWeekly);
    });

/// Provider for top debtors.
final topDebtorsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  ref.watch(dashboardStatsProvider);
  final repo = ref.read(transactionRepositoryProvider);
  return repo.getTopDebtors(5);
});

/// Provider for total debts/payments in a date range.
/// Family key is "startIso|endIso".
final totalsByDateRangeProvider =
    FutureProvider.family<Map<String, double>, String>((ref, key) async {
      ref.watch(dashboardStatsProvider);
      final parts = key.split('|');
      final repo = ref.read(transactionRepositoryProvider);
      return repo.getTotalsByDateRange(parts[0], parts[1]);
    });

/// Provider for all reminders (for grouping in reminders screen).
final allRemindersProvider = FutureProvider<List<DebtReminder>>((ref) async {
  final repo = ref.watch(debtReminderRepositoryProvider);
  return repo.getAll();
});

/// Helper to invalidate all reminder-related providers.
void _invalidateReminders(WidgetRef ref) {
  ref.invalidate(allRemindersProvider);
  ref.invalidate(pendingRemindersProvider);
  ref.invalidate(dueTodayProvider);
  ref.invalidate(dashboardStatsProvider);
}

/// Marks a reminder as completed.
Future<void> markReminderCompleted(WidgetRef ref, int id) async {
  final repo = ref.read(debtReminderRepositoryProvider);
  await repo.markCompleted(id);
  _invalidateReminders(ref);
}

/// Reopens a completed reminder back to pending.
Future<void> markReminderPending(WidgetRef ref, int id) async {
  final repo = ref.read(debtReminderRepositoryProvider);
  await repo.markPending(id);
  _invalidateReminders(ref);
}

/// Deletes a reminder and refreshes all related providers.
Future<void> deleteReminder(WidgetRef ref, int id) async {
  final repo = ref.read(debtReminderRepositoryProvider);
  await repo.delete(id);
  _invalidateReminders(ref);
}

/// Deletes multiple reminders by IDs and refreshes all related providers.
Future<void> deleteRemindersBatch(WidgetRef ref, List<int> ids) async {
  final repo = ref.read(debtReminderRepositoryProvider);
  await repo.deleteBatch(ids);
  _invalidateReminders(ref);
}

// ============================================================================
// DATA CLASSES
// ============================================================================

/// Aggregated statistics for the dashboard.
/// Contains summary data from all three database tables.
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
// MUTATION HELPERS
// These functions perform database writes and invalidate affected providers.
// ============================================================================

/// Adds a new customer and refreshes all related providers.
///
/// Creates a new [Customer] with the given [name] and optional [phone],
/// inserts it into the database, then invalidates the customer list
/// and dashboard stats so the UI automatically refreshes.
Future<void> addCustomer(
  WidgetRef ref, {
  required String name,
  String? phone,
}) async {
  final repo = ref.read(customerRepositoryProvider);
  await repo.insert(
    Customer(
      name: name,
      phone: phone,
      createdAt: DateTime.now().toIso8601String(),
    ),
  );
  ref.invalidate(customersProvider);
  ref.invalidate(dashboardStatsProvider);
}

/// Updates an existing customer and refreshes all related providers.
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
      firebaseId: customer.firebaseId,
    ),
  );
  ref.invalidate(customersProvider);
  ref.invalidate(customerByIdProvider(customer.id!));
  ref.invalidate(dashboardStatsProvider);
}
