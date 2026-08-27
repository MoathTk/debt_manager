/// DEBTS FEATURE — DATA LAYER: REPOSITORY IMPLEMENTATION
///
/// Implements the [TransactionRepository] contract from the domain layer.
/// Bridges the pure domain entities with the SQLite datasource via
/// [TransactionModel]: every read converts model → entity, every write
/// converts entity → model.
///
/// The sync helpers (getUnsynced/markSynced/upsertFromCloud) intentionally
/// do NOT appear here — they belong to the datasource, which the cloud
/// sync service talks to directly.
/// ---------------------------------------------------------------------------
library;

import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDatasource _datasource;

  TransactionRepositoryImpl({TransactionLocalDatasource? datasource})
    : _datasource = datasource ?? TransactionLocalDatasource();

  @override
  Future<int> insert(Transaction transaction) async {
    return _datasource.insert(TransactionModel.fromEntity(transaction));
  }

  @override
  Future<int> update(Transaction transaction) async {
    return _datasource.update(TransactionModel.fromEntity(transaction));
  }

  @override
  Future<int> delete(String id) => _datasource.delete(id);

  @override
  Future<void> deletePaymentsByDebtId(String debtId) {
    return _datasource.deletePaymentsByDebtId(debtId);
  }

  @override
  Future<void> deleteByCustomerId(String customerId) {
    return _datasource.deleteByCustomerId(customerId);
  }

  @override
  Future<List<Transaction>> getAll({String? ownerId}) async {
    final models = await _datasource.getAll(ownerId: ownerId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Transaction?> getById(String id) async {
    final model = await _datasource.getById(id);
    return model?.toEntity();
  }

  @override
  Future<List<Transaction>> getByCustomer(String customerId) async {
    final models = await _datasource.getByCustomer(customerId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Transaction>> getByType(int type) async {
    final models = await _datasource.getByType(type);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Transaction>> getByDateRange(
    String startDate,
    String endDate,
  ) async {
    final models = await _datasource.getByDateRange(startDate, endDate);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<double> getCustomerBalance(String customerId) {
    return _datasource.getCustomerBalance(customerId);
  }

  @override
  Future<double> getTotalDebts({String? ownerId}) {
    return _datasource.getTotalDebts(ownerId: ownerId);
  }

  @override
  Future<double> getTotalPayments({String? ownerId}) {
    return _datasource.getTotalPayments(ownerId: ownerId);
  }

  @override
  Future<int> getTransactionCount({String? ownerId}) {
    return _datasource.getTransactionCount(ownerId: ownerId);
  }

  @override
  Future<List<Map<String, dynamic>>> getDebtsWithRemaining(String customerId) {
    return _datasource.getDebtsWithRemaining(customerId);
  }

  @override
  Future<double> getPaymentsForDebt(String debtId) {
    return _datasource.getPaymentsForDebt(debtId);
  }

  @override
  Future<List<Transaction>> getPaymentsByDebtId(String debtId) async {
    final models = await _datasource.getPaymentsByDebtId(debtId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Map<String, double>> getTotalsByDateRange(
    String startDate,
    String endDate,
  ) {
    return _datasource.getTotalsByDateRange(startDate, endDate);
  }

  @override
  Future<List<Map<String, dynamic>>> getPeriodicData({bool isWeekly = false}) {
    return _datasource.getPeriodicData(isWeekly: isWeekly);
  }

  @override
  Future<List<Map<String, dynamic>>> getTopDebtors(int limit) {
    return _datasource.getTopDebtors(limit);
  }
}
