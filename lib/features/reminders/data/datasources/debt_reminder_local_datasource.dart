/// REMINDERS FEATURE — DATA LAYER: LOCAL DATA SOURCE
///
/// Raw SQLite access to the `debt_reminders` table. This class is the only
/// one that knows query strings and column names; higher layers work
/// with [DebtReminderModel] and never touch SQL.
///
/// Soft deletes: rows are flagged `is_deleted = 1` and filtered out,
/// so synced devices can pull the tombstone instead of resurrecting
/// a deleted reminder.
///
/// The offline→online sync helpers live here too — the cloud sync
/// service talks to the datasource directly, not through the domain
/// repository interface.
/// ---------------------------------------------------------------------------
library;

import '../../../../data/database_helper.dart';
import '../models/debt_reminder_model.dart';

class DebtReminderLocalDatasource {
  final DatabaseHelper _dbHelper;

  DebtReminderLocalDatasource({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<int> insert(DebtReminderModel reminder) async {
    final db = await _dbHelper.database;
    return await db.insert('debt_reminders', reminder.toMap());
  }

  Future<int> update(DebtReminderModel reminder) async {
    final db = await _dbHelper.database;
    return await db.update(
      'debt_reminders', reminder.toMap(),
      where: 'id = ?', whereArgs: [reminder.id],
    );
  }

  /// Soft-delete a reminder row.
  Future<int> delete(String id) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();
    return await db.update(
      'debt_reminders',
      {'is_deleted': 1, 'is_synced': 0, 'updated_at': now},
      where: 'id = ?', whereArgs: [id],
    );
  }

  /// Soft-delete several reminder rows.
  Future<void> deleteBatch(List<String> ids) async {
    if (ids.isEmpty) return;
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();
    final placeholders = ids.map((_) => '?').join(',');
    await db.update(
      'debt_reminders',
      {'is_deleted': 1, 'is_synced': 0, 'updated_at': now},
      where: 'id IN ($placeholders)', whereArgs: ids,
    );
  }

  /// Soft-delete every reminder attached to a debt.
  Future<void> deleteByDebtId(String debtId) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();
    await db.update(
      'debt_reminders',
      {'is_deleted': 1, 'is_synced': 0, 'updated_at': now},
      where: 'debt_id = ?', whereArgs: [debtId],
    );
  }

  /// Soft-delete every reminder attached to a customer.
  Future<void> deleteByCustomerId(String customerId) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();
    await db.update(
      'debt_reminders',
      {'is_deleted': 1, 'is_synced': 0, 'updated_at': now},
      where: 'customer_id = ?', whereArgs: [customerId],
    );
  }

  Future<List<DebtReminderModel>> getAll({String? ownerId}) async {
    final db = await _dbHelper.database;
    final conditions = ['is_deleted = 0'];
    final args = <dynamic>[];
    if (ownerId != null) {
      conditions.add('owner_id = ?');
      args.add(ownerId);
    }
    final result = await db.query(
      'debt_reminders',
      where: conditions.join(' AND '),
      whereArgs: args,
      orderBy: 'reminder_date ASC',
    );
    return result.map((map) => DebtReminderModel.fromMap(map)).toList();
  }

  Future<DebtReminderModel?> getById(String id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'debt_reminders', where: 'id = ? AND is_deleted = 0', whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return DebtReminderModel.fromMap(result.first);
  }

  Future<List<DebtReminderModel>> getByCustomer(String customerId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'debt_reminders',
      where: 'customer_id = ? AND is_deleted = 0', whereArgs: [customerId],
      orderBy: 'reminder_date ASC',
    );
    return result.map((map) => DebtReminderModel.fromMap(map)).toList();
  }

  Future<List<DebtReminderModel>> getPending({String? ownerId}) async {
    final db = await _dbHelper.database;
    final conditions = ['is_completed = 0', 'is_deleted = 0'];
    final args = <dynamic>[];
    if (ownerId != null) {
      conditions.add('owner_id = ?');
      args.add(ownerId);
    }
    final result = await db.query(
      'debt_reminders',
      where: conditions.join(' AND '),
      whereArgs: args,
      orderBy: 'reminder_date ASC',
    );
    return result.map((map) => DebtReminderModel.fromMap(map)).toList();
  }

  Future<List<DebtReminderModel>> getCompleted({String? ownerId}) async {
    final db = await _dbHelper.database;
    final conditions = ['is_completed = 1', 'is_deleted = 0'];
    final args = <dynamic>[];
    if (ownerId != null) {
      conditions.add('owner_id = ?');
      args.add(ownerId);
    }
    final result = await db.query(
      'debt_reminders',
      where: conditions.join(' AND '),
      whereArgs: args,
      orderBy: 'reminder_date DESC',
    );
    return result.map((map) => DebtReminderModel.fromMap(map)).toList();
  }

  Future<int> markCompleted(String id) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();
    return await db.update(
      'debt_reminders',
      {'is_completed': 1, 'is_synced': 0, 'updated_at': now},
      where: 'id = ?', whereArgs: [id],
    );
  }

  Future<int> markPending(String id) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();
    return await db.update(
      'debt_reminders',
      {'is_completed': 0, 'is_synced': 0, 'updated_at': now},
      where: 'id = ?', whereArgs: [id],
    );
  }

  Future<List<DebtReminderModel>> getDueToday({String? date}) async {
    final db = await _dbHelper.database;
    final now = (date ?? DateTime.now().toIso8601String().substring(0, 10));
    final result = await db.query(
      'debt_reminders',
      where: 'is_completed = 0 AND is_deleted = 0 AND reminder_date <= ?',
      whereArgs: [now],
      orderBy: 'reminder_date ASC',
    );
    return result.map((map) => DebtReminderModel.fromMap(map)).toList();
  }

  Future<int> getPendingCount({String? ownerId}) async {
    final db = await _dbHelper.database;
    final conditions = ['is_completed = 0', 'is_deleted = 0'];
    final args = <dynamic>[];
    if (ownerId != null) {
      conditions.add('owner_id = ?');
      args.add(ownerId);
    }
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM debt_reminders WHERE ${conditions.join(' AND ')}',
      args,
    );
    return result.first['count'] as int;
  }

  // ======================== SYNC HELPERS ========================

  Future<List<DebtReminderModel>> getUnsynced() async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'debt_reminders', where: 'is_synced = 0',
    );
    return result.map((map) => DebtReminderModel.fromMap(map)).toList();
  }

  Future<void> markSynced(List<String> ids) async {
    if (ids.isEmpty) return;
    final db = await _dbHelper.database;
    final placeholders = ids.map((_) => '?').join(',');
    await db.update(
      'debt_reminders', {'is_synced': 1},
      where: 'id IN ($placeholders)', whereArgs: ids,
    );
  }

  Future<void> upsertFromCloud(List<DebtReminderModel> records) async {
    final db = await _dbHelper.database;
    for (final r in records) {
      final existing = await _getByIdIncludingDeleted(r.id);
      if (existing == null) {
        final map = r.toMap();
        map['is_synced'] = 1;
        await db.insert('debt_reminders', map);
      } else if (r.updatedAt.compareTo(existing.updatedAt) > 0) {
        final map = r.toMap();
        map['is_synced'] = 1;
        await db.update(
          'debt_reminders', map,
          where: 'id = ?', whereArgs: [r.id],
        );
      }
    }
  }

  /// Raw by-id lookup used only by cloud upserts: soft-deleted rows are
  /// deliberately included so a stale cloud record cannot resurrect a
  /// locally deleted reminder.
  Future<DebtReminderModel?> _getByIdIncludingDeleted(String id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'debt_reminders',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return DebtReminderModel.fromMap(result.first);
  }
}