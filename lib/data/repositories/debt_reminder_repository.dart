import '../database_helper.dart';
import '../models/debt_reminder.dart';

/// Repository class for DebtReminder CRUD operations and query helpers.
///
/// Handles all database interactions related to debt collection reminders.
/// Uses [DatabaseHelper] singleton to access the SQLite database.
///
/// Reminders help merchants track when to follow up on outstanding debts.
/// Each reminder can be marked as completed once the follow-up is done.
class DebtReminderRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Inserts a new debt reminder into the database.
  /// Returns the auto-generated ID of the newly created reminder.
  Future<int> insert(DebtReminder reminder) async {
    final db = await _dbHelper.database;
    return await db.insert('debt_reminders', reminder.toMap());
  }

  /// Updates an existing debt reminder in the database.
  /// Matches by reminder.id and returns the number of affected rows.
  Future<int> update(DebtReminder reminder) async {
    final db = await _dbHelper.database;
    return await db.update(
      'debt_reminders',
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  /// Deletes a debt reminder from the database by ID.
  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'debt_reminders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Retrieves all debt reminders from the database.
  /// Results are ordered by reminder date (earliest first).
  Future<List<DebtReminder>> getAll() async {
    final db = await _dbHelper.database;
    final result = await db.query('debt_reminders', orderBy: 'reminder_date ASC');
    return result.map((map) => DebtReminder.fromMap(map)).toList();
  }

  /// Retrieves a single debt reminder by its ID.
  /// Returns null if no reminder is found.
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

  /// Retrieves all reminders for a specific customer.
  /// Results are ordered by reminder date (earliest first).
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

  /// Retrieves all pending (uncompleted) reminders.
  /// Results are ordered by reminder date (earliest first).
  Future<List<DebtReminder>> getPending() async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'debt_reminders',
      where: 'is_completed = 0',
      orderBy: 'reminder_date ASC',
    );
    return result.map((map) => DebtReminder.fromMap(map)).toList();
  }

  /// Retrieves all completed reminders.
  /// Results are ordered by reminder date (most recent first).
  Future<List<DebtReminder>> getCompleted() async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'debt_reminders',
      where: 'is_completed = 1',
      orderBy: 'reminder_date DESC',
    );
    return result.map((map) => DebtReminder.fromMap(map)).toList();
  }

  /// Marks a reminder as completed (is_completed = 1).
  /// Returns the number of affected rows.
  Future<int> markCompleted(int id) async {
    final db = await _dbHelper.database;
    return await db.update(
      'debt_reminders',
      {'is_completed': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Marks a reminder as pending (is_completed = 0).
  /// Useful for reopening a completed reminder.
  Future<int> markPending(int id) async {
    final db = await _dbHelper.database;
    return await db.update(
      'debt_reminders',
      {'is_completed': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Retrieves all pending reminders that are due today or earlier.
  /// Uses today's date (YYYY-MM-DD) for comparison.
  /// Results are ordered by reminder date (earliest first).
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

  /// Returns the total number of pending (uncompleted) reminders.
  /// Useful for dashboard statistics.
  Future<int> getPendingCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM debt_reminders WHERE is_completed = 0',
    );
    return result.first['count'] as int;
  }
}
