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
      'debt_reminders',
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'debt_reminders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteBatch(List<String> ids) async {
    if (ids.isEmpty) return;
    final db = await _dbHelper.database;
    final placeholders = ids.map((_) => '?').join(',');
    await db.delete(
      'debt_reminders',
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
  }

  Future<void> deleteByDebtId(String debtId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'debt_reminders',
      where: 'debt_id = ?',
      whereArgs: [debtId],
    );
  }

  Future<List<DebtReminder>> getAll() async {
    final db = await _dbHelper.database;
    final result =
        await db.query('debt_reminders', orderBy: 'reminder_date ASC');
    return result.map((map) => DebtReminder.fromMap(map)).toList();
  }

  Future<DebtReminder?> getById(String id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'debt_reminders',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return DebtReminder.fromMap(result.first);
  }

  Future<List<DebtReminder>> getByCustomer(String customerId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'debt_reminders',
      where: 'customer_id = ?',
      whereArgs: [customerId],
      orderBy: 'reminder_date ASC',
    );
    return result.map((map) => DebtReminder.fromMap(map)).toList();
  }

  Future<List<DebtReminder>> getPending() async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'debt_reminders',
      where: 'is_completed = 0',
      orderBy: 'reminder_date ASC',
    );
    return result.map((map) => DebtReminder.fromMap(map)).toList();
  }

  Future<List<DebtReminder>> getCompleted() async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'debt_reminders',
      where: 'is_completed = 1',
      orderBy: 'reminder_date DESC',
    );
    return result.map((map) => DebtReminder.fromMap(map)).toList();
  }

  Future<int> markCompleted(String id) async {
    final db = await _dbHelper.database;
    return await db.update(
      'debt_reminders',
      {'is_completed': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> markPending(String id) async {
    final db = await _dbHelper.database;
    return await db.update(
      'debt_reminders',
      {'is_completed': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<DebtReminder>> getDueToday({String? date}) async {
    final db = await _dbHelper.database;
    final now =
        (date ?? DateTime.now().toIso8601String().substring(0, 10));
    final result = await db.query(
      'debt_reminders',
      where: 'is_completed = 0 AND reminder_date <= ?',
      whereArgs: [now],
      orderBy: 'reminder_date ASC',
    );
    return result.map((map) => DebtReminder.fromMap(map)).toList();
  }

  Future<int> getPendingCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM debt_reminders WHERE is_completed = 0',
    );
    return result.first['count'] as int;
  }
}
