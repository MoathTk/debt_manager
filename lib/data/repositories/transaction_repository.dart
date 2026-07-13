import '../database_helper.dart';
import '../models/transaction.dart' as model;

/// Repository class for Transaction CRUD operations and financial queries.
///
/// Handles all database interactions related to financial transactions.
/// Uses [DatabaseHelper] singleton to access the SQLite database.
///
/// **Important**: The Transaction model is imported as 'model' to avoid
/// name collision with sqflite's internal Transaction class.
///
/// Transaction types:
/// - 0 (debt): Money owed by customer
/// - 1 (payment): Money paid by customer
class TransactionRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Inserts a new transaction into the database.
  /// Returns the auto-generated ID of the newly created transaction.
  Future<int> insert(model.Transaction transaction) async {
    final db = await _dbHelper.database;
    return await db.insert('transactions', transaction.toMap());
  }

  /// Updates an existing transaction in the database.
  /// Matches by transaction.id and returns the number of affected rows.
  Future<int> update(model.Transaction transaction) async {
    final db = await _dbHelper.database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  /// Deletes a transaction from the database by ID.
  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Retrieves all transactions from the database.
  /// Results are ordered by date (newest first).
  Future<List<model.Transaction>> getAll() async {
    final db = await _dbHelper.database;
    final result = await db.query('transactions', orderBy: 'date DESC');
    return result.map((map) => model.Transaction.fromMap(map)).toList();
  }

  /// Retrieves a single transaction by its ID.
  /// Returns null if no transaction is found.
  Future<model.Transaction?> getById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return model.Transaction.fromMap(result.first);
  }

  /// Retrieves all transactions for a specific customer.
  /// Results are ordered by date (newest first).
  Future<List<model.Transaction>> getByCustomer(int customerId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'transactions',
      where: 'customer_id = ?',
      whereArgs: [customerId],
      orderBy: 'date DESC',
    );
    return result.map((map) => model.Transaction.fromMap(map)).toList();
  }

  /// Retrieves transactions filtered by type.
  /// Use [model.Transaction.debt] (0) or [model.Transaction.payment] (1).
  Future<List<model.Transaction>> getByType(int type) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'transactions',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'date DESC',
    );
    return result.map((map) => model.Transaction.fromMap(map)).toList();
  }

  /// Retrieves transactions within a date range (inclusive).
  /// Both dates should be in ISO 8601 format (YYYY-MM-DD).
  Future<List<model.Transaction>> getByDateRange(String startDate, String endDate) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'transactions',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
      orderBy: 'date DESC',
    );
    return result.map((map) => model.Transaction.fromMap(map)).toList();
  }

  /// Calculates the net balance for a specific customer.
  /// Balance = Total Debts - Total Payments
  /// Positive balance means customer owes money.
  /// Negative balance means customer has overpaid.
  Future<double> getCustomerBalance(int customerId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT 
        COALESCE(SUM(CASE WHEN type = 0 THEN amount ELSE 0 END), 0) - 
        COALESCE(SUM(CASE WHEN type = 1 THEN amount ELSE 0 END), 0) as balance
      FROM transactions 
      WHERE customer_id = ?
    ''', [customerId]);
    return (result.first['balance'] as num?)?.toDouble() ?? 0.0;
  }

  /// Calculates the sum of all debt transactions across all customers.
  /// Used for dashboard statistics.
  Future<double> getTotalDebts() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total 
      FROM transactions 
      WHERE type = 0
    ''');
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Calculates the sum of all payment transactions across all customers.
  /// Used for dashboard statistics.
  Future<double> getTotalPayments() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total 
      FROM transactions 
      WHERE type = 1
    ''');
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Returns the total number of transactions in the database.
  /// Useful for dashboard statistics.
  Future<int> getTransactionCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM transactions');
    return result.first['count'] as int;
  }

  /// Returns each debt for a customer with its remaining balance.
  /// Remaining = debt amount - sum of payments linked to that debt.
  /// Only returns debts with remaining > 0 (unpaid/partially paid).
  Future<List<Map<String, dynamic>>> getDebtsWithRemaining(int customerId) async {
    final db = await _dbHelper.database;
    return await db.rawQuery('''
      SELECT * FROM (
        SELECT
          t.id, t.amount, t.note, t.date,
          t.amount - COALESCE(
            (SELECT SUM(p.amount) FROM transactions p WHERE p.debt_id = t.id), 0
          ) as remaining
        FROM transactions t
        WHERE t.customer_id = ? AND t.type = 0
      ) sub
      WHERE sub.remaining > 0
      ORDER BY sub.date DESC
    ''', [customerId]);
  }

  /// Returns the total amount of payments linked to a specific debt.
  Future<double> getPaymentsForDebt(int debtId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total
      FROM transactions
      WHERE debt_id = ? AND type = 1
    ''', [debtId]);
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }
}
