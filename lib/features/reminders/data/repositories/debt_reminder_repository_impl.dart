/// REMINDERS FEATURE — DATA LAYER: REPOSITORY IMPLEMENTATION
///
/// Implements the [DebtReminderRepository] contract from the domain layer.
/// Bridges the pure domain entities with the SQLite datasource via
/// [DebtReminderModel]: every read converts model → entity, every write
/// converts entity → model.
///
/// The sync helpers (getUnsynced/markSynced/upsertFromCloud) intentionally
/// do NOT appear here — they belong to the datasource, which the cloud
/// sync service talks to directly.
/// ---------------------------------------------------------------------------
library;

import '../../domain/entities/debt_reminder.dart';
import '../../domain/repositories/debt_reminder_repository.dart';
import '../datasources/debt_reminder_local_datasource.dart';
import '../models/debt_reminder_model.dart';

class DebtReminderRepositoryImpl implements DebtReminderRepository {
  final DebtReminderLocalDatasource _datasource;

  DebtReminderRepositoryImpl({DebtReminderLocalDatasource? datasource})
    : _datasource = datasource ?? DebtReminderLocalDatasource();

  @override
  Future<int> insert(DebtReminder reminder) async {
    return _datasource.insert(DebtReminderModel.fromEntity(reminder));
  }

  @override
  Future<int> update(DebtReminder reminder) async {
    return _datasource.update(DebtReminderModel.fromEntity(reminder));
  }

  @override
  Future<int> delete(String id) => _datasource.delete(id);

  @override
  Future<void> deleteBatch(List<String> ids) => _datasource.deleteBatch(ids);

  @override
  Future<void> deleteByDebtId(String debtId) {
    return _datasource.deleteByDebtId(debtId);
  }

  @override
  Future<void> deleteByCustomerId(String customerId) {
    return _datasource.deleteByCustomerId(customerId);
  }

  @override
  Future<List<DebtReminder>> getAll({String? ownerId}) async {
    final models = await _datasource.getAll(ownerId: ownerId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<DebtReminder?> getById(String id) async {
    final model = await _datasource.getById(id);
    return model?.toEntity();
  }

  @override
  Future<List<DebtReminder>> getByCustomer(String customerId) async {
    final models = await _datasource.getByCustomer(customerId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<DebtReminder>> getPending({String? ownerId}) async {
    final models = await _datasource.getPending(ownerId: ownerId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<DebtReminder>> getCompleted({String? ownerId}) async {
    final models = await _datasource.getCompleted(ownerId: ownerId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<int> markCompleted(String id) => _datasource.markCompleted(id);

  @override
  Future<int> markPending(String id) => _datasource.markPending(id);

  @override
  Future<List<DebtReminder>> getDueToday({String? date}) async {
    final models = await _datasource.getDueToday(date: date);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<int> getPendingCount({String? ownerId}) {
    return _datasource.getPendingCount(ownerId: ownerId);
  }
}