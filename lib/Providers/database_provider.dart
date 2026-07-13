import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database_helper.dart';
import '../data/repositories/customer_repository.dart';
import '../data/repositories/transaction_repository.dart';
import '../data/repositories/debt_reminder_repository.dart';
import '../data/models/customer.dart';
import '../data/models/transaction.dart' as model;
import '../data/models/debt_reminder.dart';

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

final customersProvider = FutureProvider<List<Customer>>((ref) async {
  final repo = ref.watch(customerRepositoryProvider);
  return repo.getAll();
});

final customerByIdProvider = FutureProvider.family<Customer?, int>((ref, id) async {
  final repo = ref.watch(customerRepositoryProvider);
  return repo.getById(id);
});

final transactionsProvider = FutureProvider<List<model.Transaction>>((ref) async {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getAll();
});

final transactionsByCustomerProvider = FutureProvider.family<List<model.Transaction>, int>((ref, customerId) async {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getByCustomer(customerId);
});

final customerBalanceProvider = FutureProvider.family<double, int>((ref, customerId) async {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getCustomerBalance(customerId);
});

final pendingRemindersProvider = FutureProvider<List<DebtReminder>>((ref) async {
  final repo = ref.watch(debtReminderRepositoryProvider);
  return repo.getPending();
});

final dueTodayProvider = FutureProvider<List<DebtReminder>>((ref) async {
  final repo = ref.watch(debtReminderRepositoryProvider);
  return repo.getDueToday();
});

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final customerRepo = ref.watch(customerRepositoryProvider);
  final transactionRepo = ref.watch(transactionRepositoryProvider);
  final reminderRepo = ref.watch(debtReminderRepositoryProvider);

  final customerCount = await customerRepo.getCustomerCount();
  final totalDebts = await transactionRepo.getTotalDebts();
  final totalPayments = await transactionRepo.getTotalPayments();
  final pendingReminders = await reminderRepo.getPendingCount();

  return DashboardStats(
    customerCount: customerCount,
    totalDebts: totalDebts,
    totalPayments: totalPayments,
    pendingReminders: pendingReminders,
  );
});

class DashboardStats {
  final int customerCount;
  final double totalDebts;
  final double totalPayments;
  final int pendingReminders;

  DashboardStats({
    required this.customerCount,
    required this.totalDebts,
    required this.totalPayments,
    required this.pendingReminders,
  });
}
