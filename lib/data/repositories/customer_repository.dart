import '../database_helper.dart';
import '../models/customer.dart';

class CustomerRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insert(Customer customer) async {
    final db = await _dbHelper.database;
    return await db.insert('customers', customer.toMap());
  }

  Future<int> update(Customer customer) async {
    final db = await _dbHelper.database;
    return await db.update(
      'customers',
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Customer>> getAll() async {
    final db = await _dbHelper.database;
    final result = await db.query('customers', orderBy: 'created_at DESC');
    return result.map((map) => Customer.fromMap(map)).toList();
  }

  Future<Customer?> getById(String id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Customer.fromMap(result.first);
  }

  Future<List<Customer>> search(String query) async {
    final db = await _dbHelper.database;
    final escaped = query.replaceAll('%', '\\%').replaceAll('_', '\\_');
    final result = await db.query(
      'customers',
      where:
          'name LIKE ? ESCAPE \'\\\' OR (phone IS NOT NULL AND phone LIKE ? ESCAPE \'\\\')',
      whereArgs: ['%$escaped%', '%$escaped%'],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Customer.fromMap(map)).toList();
  }

  Future<int> getCustomerCount() async {
    final db = await _dbHelper.database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM customers');
    return result.first['count'] as int;
  }
}
