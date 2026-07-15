import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database_helper.dart';
import '../data/repositories/customer_repository.dart';
import '../data/repositories/transaction_repository.dart';
import '../data/repositories/debt_reminder_repository.dart';
import '../data/models/customer.dart';
import '../data/models/transaction.dart' as model;
import '../data/models/debt_reminder.dart';
import '../services/auth_service.dart';
import 'mutations.dart';

final databaseProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepository();
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

final debtReminderRepositoryProvider = Provider<DebtReminderRepository>((ref) {
  return DebtReminderRepository();
});

final _ownerIdProvider = Provider<String>((ref) {
  return ref.watch(authServiceProvider).ownerId ?? '';
});

final customersProvider = FutureProvider<List<Customer>>((ref) async {
  final repo = ref.watch(customerRepositoryProvider);
  final ownerId = ref.watch(_ownerIdProvider);
  return repo.getAll(ownerId: ownerId.isEmpty ? null : ownerId);
});

final customerByIdProvider =
    FutureProvider.family<Customer?, String>((ref, id) async {
  final repo = ref.watch(customerRepositoryProvider);
  final ownerId = ref.watch(_ownerIdProvider);
  final customer = await repo.getById(id);
  if (customer != null && ownerId.isNotEmpty && customer.ownerId != ownerId) {
    return null;
  }
  return customer;
});

final transactionsProvider = FutureProvider<List<model.Transaction>>((
  ref,
) async {
  final repo = ref.watch(transactionRepositoryProvider);
  final ownerId = ref.watch(_ownerIdProvider);
  return repo.getAll(ownerId: ownerId.isEmpty ? null : ownerId);
});

final transactionsByCustomerProvider =
    FutureProvider.family<List<model.Transaction>, String>((
      ref,
      customerId,
    ) async {
      final repo = ref.watch(transactionRepositoryProvider);
      final customerRepo = ref.watch(customerRepositoryProvider);
      final ownerId = ref.watch(_ownerIdProvider);
      if (ownerId.isNotEmpty) {
        final customer = await customerRepo.getById(customerId);
        if (customer == null || customer.ownerId != ownerId) {
          return [];
        }
      }
      return repo.getByCustomer(customerId);
    });

final customerBalanceProvider = FutureProvider.family<double, String>((
  ref,
  customerId,
) async {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getCustomerBalance(customerId);
});

final debtsWithRemainingProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      customerId,
    ) async {
      final repo = ref.watch(transactionRepositoryProvider);
      return repo.getDebtsWithRemaining(customerId);
    });

final pendingRemindersProvider = FutureProvider<List<DebtReminder>>((
  ref,
) async {
  final repo = ref.watch(debtReminderRepositoryProvider);
  final ownerId = ref.watch(_ownerIdProvider);
  return repo.getPending(ownerId: ownerId.isEmpty ? null : ownerId);
});

final dueTodayProvider = FutureProvider<List<DebtReminder>>((ref) async {
  final repo = ref.watch(debtReminderRepositoryProvider);
  return repo.getDueToday();
});

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final customerRepo = ref.watch(customerRepositoryProvider);
  final transactionRepo = ref.watch(transactionRepositoryProvider);
  final reminderRepo = ref.watch(debtReminderRepositoryProvider);
  final ownerId = ref.watch(_ownerIdProvider);
  final ownerFilter = ownerId.isEmpty ? null : ownerId;
  final customerCount = await customerRepo.getCustomerCount(ownerId: ownerFilter);
  final totalDebts = await transactionRepo.getTotalDebts(ownerId: ownerFilter);
  final totalPayments = await transactionRepo.getTotalPayments(ownerId: ownerFilter);
  final pendingReminders = await reminderRepo.getPendingCount(ownerId: ownerFilter);
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

final periodicDataProvider =
    FutureProvider.family<List<Map<String, dynamic>>, bool>((
      ref,
      isWeekly,
    ) async {
      final repo = ref.watch(transactionRepositoryProvider);
      return repo.getPeriodicData(isWeekly: isWeekly);
    });

final topDebtorsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  ref.watch(dashboardStatsProvider);
  final repo = ref.read(transactionRepositoryProvider);
  return repo.getTopDebtors(5);
});

final totalsByDateRangeProvider =
    FutureProvider.family<Map<String, double>, String>((ref, key) async {
      ref.watch(dashboardStatsProvider);
      final parts = key.split('|');
      if (parts.length != 2 || parts[0].isEmpty || parts[1].isEmpty) {
        throw ArgumentError(
          'Invalid date range key: "$key" (expected "startIso|endIso")',
        );
      }
      final repo = ref.read(transactionRepositoryProvider);
      return repo.getTotalsByDateRange(parts[0], parts[1]);
    });

final allRemindersProvider = FutureProvider<List<DebtReminder>>((ref) async {
  final repo = ref.watch(debtReminderRepositoryProvider);
  final ownerId = ref.watch(_ownerIdProvider);
  return repo.getAll(ownerId: ownerId.isEmpty ? null : ownerId);
});
