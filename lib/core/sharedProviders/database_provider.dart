// ============================================================================
// LEGACY PROVIDER BARREL
// ============================================================================
// The customers, debts and reminders features now own their providers under
// `lib/features/<feature>/presentation/providers/`. This file re-exports
// them (so legacy callers keep compiling unchanged) and still hosts the
// cross-feature dashboard stats that aggregate all three.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_debt_management/features/customers/presentation/providers/customer_providers.dart';
import 'package:local_debt_management/features/debts/presentation/providers/transaction_providers.dart';
import 'package:local_debt_management/features/reminders/presentation/providers/debt_reminder_providers.dart';
import '../../data/database_helper.dart';
import '../services/auth_service.dart';
import 'mutations.dart';

export 'package:local_debt_management/features/customers/presentation/providers/customer_providers.dart'
    show customerRepositoryProvider, customersProvider, customerByIdProvider;

export 'package:local_debt_management/features/debts/presentation/providers/transaction_providers.dart'
    show
        transactionRepositoryProvider,
        transactionsProvider,
        transactionsByCustomerProvider,
        customerBalanceProvider,
        debtsWithRemainingProvider,
        paymentsByDebtProvider;

export 'package:local_debt_management/features/reminders/presentation/providers/debt_reminder_providers.dart'
    show
        debtReminderRepositoryProvider,
        allRemindersProvider,
        pendingRemindersProvider,
        dueTodayProvider,
        remindersByCustomerProvider;

final databaseProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

final _ownerIdProvider = Provider<String>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  return user?.uid ?? '';
});

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final customerRepo = ref.watch(customerRepositoryProvider);
  final transactionRepo = ref.watch(transactionRepositoryProvider);
  final reminderRepo = ref.watch(debtReminderRepositoryProvider);
  final ownerId = ref.watch(_ownerIdProvider);
  final ownerFilter = ownerId.isEmpty ? null : ownerId;
  final customerCount = await customerRepo.getCustomerCount(
    ownerId: ownerFilter,
  );
  final totalDebts = await transactionRepo.getTotalDebts(ownerId: ownerFilter);
  final totalPayments = await transactionRepo.getTotalPayments(
    ownerId: ownerFilter,
  );
  final pendingReminders = await reminderRepo.getPendingCount(
    ownerId: ownerFilter,
  );
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

final topDebtorsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      ref.watch(dashboardStatsProvider);
      final repo = ref.read(transactionRepositoryProvider);
      return repo.getTopDebtors(5);
    });

final totalsByDateRangeProvider = FutureProvider.autoDispose
    .family<Map<String, double>, String>((ref, key) async {
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
