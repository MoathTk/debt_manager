import '../database_helper.dart';
import '../models/debt_reminder.dart';

class DebtReminderRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insert(DebtReminder reminder) async {
    final db = await _dbHelper.database;
    return await db.insert('debt_reminders', reminder.toMap());
  }

  Future<int> update(DebtReminder reminder) async {
    final db = await _dbHelper.database;
    return await db.update(
      'debt_reminders', reminder.toMap(),
      where: 'id = ?', whereArgs: [reminder.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();
    return await db.update(
      'debt_reminders',
      {'is_deleted': 1, 'is_synced': 0, 'updated_at': now},
      where: 'id = ?', whereArgs: [id],
    );
  }

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

  Future<void> deleteByDebtId(String debtId) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();
    await db.update(
      'debt_reminders',
      {'is_deleted': 1, 'is_synced': 0, 'updated_at': now},
      where: 'debt_id = ?', whereArgs: [debtId],
    );
  }

  Future<void> deleteByCustomerId(String customerId) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();
    await db.update(
      'debt_reminders',
      {'is_deleted': 1, 'is_synced': 0, 'updated_at': now},
      where: 'customer_id = ?', whereArgs: [customerId],
    );
  }

  Future<List<DebtReminder>> getAll({String? ownerId}) async {
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
    return result.map((map) => DebtReminder.fromMap(map)).toList();
  }

  Future<DebtReminder?> getById(String id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'debt_reminders', where: 'id = ? AND is_deleted = 0', whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return DebtReminder.fromMap(result.first);
  }

  Future<List<DebtReminder>> getByCustomer(String customerId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'debt_reminders',
      where: 'customer_id = ? AND is_deleted = 0', whereArgs: [customerId],
      orderBy: 'reminder_date ASC',
    );
    return result.map((map) => DebtReminder.fromMap(map)).toList();
  }

  Future<List<DebtReminder>> getPending({String? ownerId}) async {
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
    return result.map((map) => DebtReminder.fromMap(map)).toList();
  }

  Future<List<DebtReminder>> getCompleted({String? ownerId}) async {
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
    return result.map((map) => DebtReminder.fromMap(map)).toList();
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

  Future<List<DebtReminder>> getDueToday({String? date}) async {
    final db = await _dbHelper.database;
    final now = (date ?? DateTime.now().toIso8601String().substring(0, 10));
    final result = await db.query(
      'debt_reminders',
      where: 'is_completed = 0 AND is_deleted = 0 AND reminder_date <= ?',
      whereArgs: [now],
      orderBy: 'reminder_date ASC',
    );
    return result.map((map) => DebtReminder.fromMap(map)).toList();
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

  Future<List<DebtReminder>> getUnsynced() async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'debt_reminders', where: 'is_synced = 0',
    );
    return result.map((map) => DebtReminder.fromMap(map)).toList();
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

  Future<void> upsertFromCloud(List<DebtReminder> records) async {
    final db = await _dbHelper.database;
    for (final r in records) {
      final existingResult = await db.query(
        'debt_reminders', where: 'id = ?', whereArgs: [r.id],
      );
      if (existingResult.isEmpty) {
        final map = r.toMap();
        map['is_synced'] = 1;
        await db.insert('debt_reminders', map);
      } else {
        final existing = DebtReminder.fromMap(existingResult.first);
        if (r.updatedAt.compareTo(existing.updatedAt) > 0) {
          final map = r.toMap();
          map['is_synced'] = 1;
          await db.update(
            'debt_reminders', map,
            where: 'id = ?', whereArgs: [r.id],
          );
        }
      }
    }
  }
}
