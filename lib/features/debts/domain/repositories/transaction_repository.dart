/// DEBTS FEATURE — DOMAIN LAYER: REPOSITORY INTERFACE
///
/// This is the "contract" that the data layer must implement.
/// The domain layer says: "I need to read/write transactions, but I don't
/// care HOW — SQLite? Firestore? HTTP? I don't know."
///
/// This is the Dependency Inversion Principle (D):
/// - Domain defines the interface
/// - Data layer implements it
/// - Use cases depend on the interface, not the implementation
///
/// ARCHITECTURE RULE: This file must never import from data/ or presentation/.
///
/// The offline→online sync helpers (getUnsynced/markSynced/upsertFromCloud)
/// intentionally do NOT appear here — they belong to the datasource, which
/// the cloud sync service talks to directly.
/// ---------------------------------------------------------------------------
library;

import '../entities/transaction.dart';

abstract class TransactionRepository {
  /// Persist a new transaction (debt or payment).
  Future<int> insert(Transaction transaction);

  /// Update an existing transaction's fields.
  Future<int> update(Transaction transaction);

  /// Soft-delete a transaction by id.
  Future<int> delete(String id);

  /// Soft-delete every payment attached to a debt.
  Future<void> deletePaymentsByDebtId(String debtId);

  /// Soft-delete every transaction attached to a customer.
  Future<void> deleteByCustomerId(String customerId);

  /// All non-deleted transactions, newest first. Optionally scoped to an owner.
  Future<List<Transaction>> getAll({String? ownerId});

  /// Look up a single non-deleted transaction by id, null if not found.
  Future<Transaction?> getById(String id);

  /// All non-deleted transactions for a customer, newest first.
  Future<List<Transaction>> getByCustomer(String customerId);

  /// All non-deleted transactions of a given type (debt/payment).
  Future<List<Transaction>> getByType(int type);

  /// All non-deleted transactions whose date is within a range.
  Future<List<Transaction>> getByDateRange(String startDate, String endDate);

  /// Net balance for a customer: total debts minus total payments.
  Future<double> getCustomerBalance(String customerId);

  /// Sum of all debt amounts. Optionally scoped to an owner.
  Future<double> getTotalDebts({String? ownerId});

  /// Sum of all payment amounts. Optionally scoped to an owner.
  Future<double> getTotalPayments({String? ownerId});

  /// Count of non-deleted transactions. Optionally scoped to an owner.
  Future<int> getTransactionCount({String? ownerId});

  /// Unsettled debts for a customer (amount, note, date, remaining).
  Future<List<Map<String, dynamic>>> getDebtsWithRemaining(String customerId);

  /// Total paid so far for a single debt.
  Future<double> getPaymentsForDebt(String debtId);

  /// All payments recorded against a debt, oldest first.
  Future<List<Transaction>> getPaymentsByDebtId(String debtId);

  /// Debts/payments totals over a date range.
  Future<Map<String, double>> getTotalsByDateRange(
    String startDate,
    String endDate,
  );

  /// Monthly (or weekly) debts/payments aggregates for charting.
  Future<List<Map<String, dynamic>>> getPeriodicData({bool isWeekly = false});

  /// Customers with the largest outstanding balance.
  Future<List<Map<String, dynamic>>> getTopDebtors(int limit);
}
