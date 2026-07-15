import '../database_helper.dart';
import '../models/transaction.dart' as model;

class TransactionRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insert(model.Transaction transaction) async {
    final db = await _dbHelper.database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<int> update(model.Transaction transaction) async {
    final db = await _dbHelper.database;
    return await db.update(
      'transactions', transaction.toMap(),
      where: 'id = ?', whereArgs: [transaction.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await _dbHelper.database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<model.Transaction>> getAll({String? ownerId}) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'transactions',
      where: ownerId != null ? 'owner_id = ?' : null,
      whereArgs: ownerId != null ? [ownerId] : null,
      orderBy: 'date DESC',
    );
    return result.map((map) => model.Transaction.fromMap(map)).toList();
  }

  Future<model.Transaction?> getById(String id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'transactions', where: 'id = ?', whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return model.Transaction.fromMap(result.first);
  }

  Future<List<model.Transaction>> getByCustomer(String customerId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'transactions',
      where: 'customer_id = ?', whereArgs: [customerId],
      orderBy: 'date DESC',
    );
    return result.map((map) => model.Transaction.fromMap(map)).toList();
  }

  Future<List<model.Transaction>> getByType(int type) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'transactions', where: 'type = ?', whereArgs: [type],
      orderBy: 'date DESC',
    );
    return result.map((map) => model.Transaction.fromMap(map)).toList();
  }

  Future<List<model.Transaction>> getByDateRange(
    String startDate, String endDate,
  ) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'transactions',
      where: 'date BETWEEN ? AND ?', whereArgs: [startDate, endDate],
      orderBy: 'date DESC',
    );
    return result.map((map) => model.Transaction.fromMap(map)).toList();
  }

  Future<double> getCustomerBalance(String customerId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      '''SELECT
        COALESCE(SUM(CASE WHEN type = 0 THEN amount ELSE 0 END), 0) -
        COALESCE(SUM(CASE WHEN type = 1 THEN amount ELSE 0 END), 0) as balance
      FROM transactions WHERE customer_id = ?''',
      [customerId],
    );
    return (result.first['balance'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getTotalDebts({String? ownerId}) async {
    final db = await _dbHelper.database;
    final where = ownerId != null ? 'WHERE type = 0 AND owner_id = ?' : 'WHERE type = 0';
    final args = ownerId != null ? [ownerId] : <dynamic>[];
    final result = await db.rawQuery(
      "SELECT COALESCE(SUM(amount), 0) as total FROM transactions $where", args,
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getTotalPayments({String? ownerId}) async {
    final db = await _dbHelper.database;
    final where = ownerId != null ? 'WHERE type = 1 AND owner_id = ?' : 'WHERE type = 1';
    final args = ownerId != null ? [ownerId] : <dynamic>[];
    final result = await db.rawQuery(
      "SELECT COALESCE(SUM(amount), 0) as total FROM transactions $where", args,
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<int> getTransactionCount({String? ownerId}) async {
    final db = await _dbHelper.database;
    final result = ownerId != null
        ? await db.rawQuery(
            'SELECT COUNT(*) as count FROM transactions WHERE owner_id = ?', [ownerId])
        : await db.rawQuery('SELECT COUNT(*) as count FROM transactions');
    return result.first['count'] as int;
  }

  Future<List<Map<String, dynamic>>> getDebtsWithRemaining(
    String customerId,
  ) async {
    final db = await _dbHelper.database;
    return await db.rawQuery(
      '''SELECT * FROM (
        SELECT t.id, t.amount, t.note, t.date,
          t.amount - COALESCE(
            (SELECT SUM(p.amount) FROM transactions p WHERE p.debt_id = t.id), 0
          ) as remaining
        FROM transactions t
        WHERE t.customer_id = ? AND t.type = 0
      ) sub WHERE sub.remaining > 0 ORDER BY sub.date DESC''',
      [customerId],
    );
  }

  Future<double> getPaymentsForDebt(String debtId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM transactions WHERE debt_id = ? AND type = 1',
      [debtId],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<Map<String, double>> getTotalsByDateRange(
    String startDate, String endDate,
  ) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      '''SELECT
        COALESCE(SUM(CASE WHEN type = 0 THEN amount ELSE 0 END), 0) as debts,
        COALESCE(SUM(CASE WHEN type = 1 THEN amount ELSE 0 END), 0) as payments
      FROM transactions WHERE date BETWEEN ? AND ?''',
      [startDate, endDate],
    );
    return {
      'debts': (result.first['debts'] as num?)?.toDouble() ?? 0.0,
      'payments': (result.first['payments'] as num?)?.toDouble() ?? 0.0,
    };
  }

  Future<List<Map<String, dynamic>>> getPeriodicData({
    bool isWeekly = false,
  }) async {
    final db = await _dbHelper.database;
    final groupExpr = isWeekly
        ? "strftime('%Y-W%W', date)"
        : "strftime('%Y-%m', date)";
    final labelExpr = isWeekly
        ? "strftime('%W', date)"
        : "strftime('%m', date)";
    final result = await db.rawQuery(
      '''SELECT $groupExpr as period, $labelExpr as label,
        COALESCE(SUM(CASE WHEN type = 0 THEN amount ELSE 0 END), 0) as debts,
        COALESCE(SUM(CASE WHEN type = 1 THEN amount ELSE 0 END), 0) as payments
      FROM transactions GROUP BY period ORDER BY period DESC LIMIT 6''',
    );
    return result.reversed.toList();
  }

  Future<List<Map<String, dynamic>>> getTopDebtors(int limit) async {
    final db = await _dbHelper.database;
    return await db.rawQuery(
      '''SELECT t.customer_id, c.name,
        COALESCE(SUM(CASE WHEN t.type = 0 THEN t.amount ELSE 0 END), 0) -
        COALESCE(SUM(CASE WHEN t.type = 1 THEN t.amount ELSE 0 END), 0) as outstanding
      FROM transactions t JOIN customers c ON c.id = t.customer_id
      GROUP BY t.customer_id HAVING outstanding > 0
      ORDER BY outstanding DESC LIMIT ?''',
      [limit],
    );
  }

  Future<List<model.Transaction>> getUnsynced() async {
    final db = await _dbHelper.database;
    final result = await db.query('transactions', where: 'is_synced = 0');
    return result.map((map) => model.Transaction.fromMap(map)).toList();
  }

  Future<void> markSynced(List<String> ids) async {
    if (ids.isEmpty) return;
    final db = await _dbHelper.database;
    final placeholders = ids.map((_) => '?').join(',');
    await db.update(
      'transactions', {'is_synced': 1},
      where: 'id IN ($placeholders)', whereArgs: ids,
    );
  }

  Future<void> upsertFromCloud(List<model.Transaction> records) async {
    final db = await _dbHelper.database;
    for (final t in records) {
      final existing = await getById(t.id!);
      if (existing == null) {
        await db.insert('transactions', t.toMap());
      } else if (t.updatedAt.compareTo(existing.updatedAt) > 0) {
        await db.update(
          'transactions', t.toMap(),
          where: 'id = ?', whereArgs: [t.id],
        );
      }
    }
  }
}
