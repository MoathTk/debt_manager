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

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'debt_reminders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<DebtReminder>> getAll() async {
    final db = await _dbHelper.database;
    final result = await db.query('debt_reminders', orderBy: 'reminder_date ASC');
    return result.map((map) => DebtReminder.fromMap(map)).toList();
  }

  Future<DebtReminder?> getById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'debt_reminders',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return DebtReminder.fromMap(result.first);
  }

  Future<List<DebtReminder>> getByCustomer(int customerId) async {
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

  Future<int> markCompleted(int id) async {
    final db = await _dbHelper.database;
    return await db.update(
      'debt_reminders',
      {'is_completed': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> markPending(int id) async {
    final db = await _dbHelper.database;
    return await db.update(
      'debt_reminders',
      {'is_completed': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<DebtReminder>> getDueToday() async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String().substring(0, 10);
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
