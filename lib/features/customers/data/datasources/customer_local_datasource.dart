/// CUSTOMERS FEATURE — DATA LAYER: LOCAL DATA SOURCE
///
/// Raw SQLite access to the `customers` table. This class is the only
/// one that knows query strings and column names; higher layers work
/// with [CustomerModel] and never touch SQL.
///
/// Soft deletes: rows are flagged `is_deleted = 1` and filtered out,
/// so synced devices can pull the tombstone instead of resurrecting
/// a deleted customer.
/// ---------------------------------------------------------------------------
library;

import '../../../../data/database_helper.dart';
import '../models/customer_model.dart';

class CustomerLocalDatasource {
  final DatabaseHelper _dbHelper;

  CustomerLocalDatasource({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<void> insert(CustomerModel customer) async {
    final db = await _dbHelper.database;
    await db.insert('customers', customer.toMap());
  }

  Future<void> update(CustomerModel customer) async {
    final db = await _dbHelper.database;
    await db.update(
      'customers',
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  /// Soft-delete a customer row.
  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();
    await db.update(
      'customers',
      {'is_deleted': 1, 'is_synced': 0, 'updated_at': now},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<CustomerModel>> getAll({String? ownerId}) async {
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
    return result.map(CustomerModel.fromMap).toList();
  }

  Future<CustomerModel?> getById(String id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'customers',
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return CustomerModel.fromMap(result.first);
  }

  Future<List<CustomerModel>> search(String query, {String? ownerId}) async {
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
    return result.map(CustomerModel.fromMap).toList();
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

  // ---- offline→online push helpers (mirror of the legacy repository) ----

  Future<List<CustomerModel>> getUnsynced() async {
    final db = await _dbHelper.database;
    final result = await db.query('customers', where: 'is_synced = 0');
    return result.map(CustomerModel.fromMap).toList();
  }

  Future<void> markSynced(List<String> ids) async {
    if (ids.isEmpty) return;
    final db = await _dbHelper.database;
    final placeholders = ids.map((_) => '?').join(',');
    await db.update(
      'customers',
      {'is_synced': 1},
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
  }

  /// Newest-wins upsert of cloud records; only applies when the incoming
  /// record is newer than what we already store locally.
  Future<void> upsertFromCloud(List<CustomerModel> records) async {
    final db = await _dbHelper.database;
    for (final c in records) {
      final existingResult = await db.query(
        'customers',
        where: 'id = ?',
        whereArgs: [c.id],
      );
      if (existingResult.isEmpty) {
        final map = c.toMap();
        map['is_synced'] = 1;
        await db.insert('customers', map);
      } else {
        final existing = CustomerModel.fromMap(existingResult.first);
        if (c.updatedAt.compareTo(existing.updatedAt) > 0) {
          final map = c.toMap();
          map['is_synced'] = 1;
          await db.update(
            'customers',
            map,
            where: 'id = ?',
            whereArgs: [c.id],
          );
        }
      }
    }
  }
}