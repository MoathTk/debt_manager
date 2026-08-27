// ============================================================================
// LEGACY MUTATIONS BARREL
// ============================================================================
// The debt mutations (addDebt, recordPayment, …) live in the debts feature —
// `lib/features/debts/presentation/providers/transaction_actions.dart`. The
// reminder mutations (markReminderCompleted, …) live in the reminders feature
// — `lib/features/reminders/presentation/providers/reminder_actions.dart`.
// Both are re-exported here so legacy callers keep compiling unchanged.

export 'package:local_debt_management/features/debts/presentation/providers/transaction_actions.dart'
    show
        addDebt,
        recordPayment,
        updateTransaction,
        deleteTransaction,
        deleteDebt,
        settleDebt;

export 'package:local_debt_management/features/reminders/presentation/providers/reminder_actions.dart'
    show
        markReminderCompleted,
        markReminderPending,
        deleteReminder,
        deleteRemindersBatch;

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