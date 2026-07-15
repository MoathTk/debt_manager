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
      'customers', customer.toMap(),
      where: 'id = ?', whereArgs: [customer.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();
    return await db.update(
      'customers',
      {'is_deleted': 1, 'is_synced': 0, 'updated_at': now},
      where: 'id = ?', whereArgs: [id],
    );
  }

  Future<List<Customer>> getAll({String? ownerId}) async {
    final db = await _dbHelper.database;
    final conditions = ['is_deleted = 0'];
    final args = <dynamic>[];
    if (ownerId != null) {
      conditions.add('owner_id = ?');
      args.add(ownerId);
    }
    final result = await db.query(
      'customers',
      where: conditions.join(' AND '),
      whereArgs: args,
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Customer.fromMap(map)).toList();
  }

  Future<Customer?> getById(String id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'customers', where: 'id = ? AND is_deleted = 0', whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Customer.fromMap(result.first);
  }

  Future<List<Customer>> search(String query, {String? ownerId}) async {
    final db = await _dbHelper.database;
    final escaped = query.replaceAll('%', '\\%').replaceAll('_', '\\_');
    final conditions = [
      "(name LIKE ? ESCAPE '\\' OR (phone IS NOT NULL AND phone LIKE ? ESCAPE '\\'))",
      'is_deleted = 0',
    ];
    final args = ['%$escaped%', '%$escaped%'];
    if (ownerId != null) {
      conditions.add('owner_id = ?');
      args.add(ownerId);
    }
    final result = await db.query(
      'customers',
      where: conditions.join(' AND '),
      whereArgs: args,
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Customer.fromMap(map)).toList();
  }

  Future<int> getCustomerCount({String? ownerId}) async {
    final db = await _dbHelper.database;
    final conditions = ['is_deleted = 0'];
    final args = <dynamic>[];
    if (ownerId != null) {
      conditions.add('owner_id = ?');
      args.add(ownerId);
    }
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM customers WHERE ${conditions.join(' AND ')}',
      args,
    );
    return result.first['count'] as int;
  }

  Future<List<Customer>> getUnsynced() async {
    final db = await _dbHelper.database;
    final result = await db.query('customers', where: 'is_synced = 0');
    return result.map((map) => Customer.fromMap(map)).toList();
  }

  Future<void> markSynced(List<String> ids) async {
    if (ids.isEmpty) return;
    final db = await _dbHelper.database;
    final placeholders = ids.map((_) => '?').join(',');
    await db.update(
      'customers', {'is_synced': 1},
      where: 'id IN ($placeholders)', whereArgs: ids,
    );
  }

  Future<void> upsertFromCloud(List<Customer> records) async {
    final db = await _dbHelper.database;
    for (final c in records) {
      final existingResult = await db.query(
        'customers', where: 'id = ?', whereArgs: [c.id],
      );
      if (existingResult.isEmpty) {
        final map = c.toMap();
        map['is_synced'] = 1;
        await db.insert('customers', map);
      } else {
        final existing = Customer.fromMap(existingResult.first);
        if (c.updatedAt.compareTo(existing.updatedAt) > 0) {
          final map = c.toMap();
          map['is_synced'] = 1;
          await db.update(
            'customers', map,
            where: 'id = ?', whereArgs: [c.id],
          );
        }
      }
    }
  }
}
