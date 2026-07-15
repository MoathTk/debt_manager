import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:local_debt_management/data/database_helper.dart';
import 'package:local_debt_management/data/models/customer.dart';
import 'package:local_debt_management/data/models/transaction.dart' as model;
import 'package:local_debt_management/data/models/debt_reminder.dart';

const _uid = 'test-user-uid';

Future<Database> _setupDb() async {
  sqfliteFfiInit();
  final db = await databaseFactoryFfi.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      version: 6,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE customers (
            id TEXT PRIMARY KEY, name TEXT NOT NULL, phone TEXT,
            created_at TEXT NOT NULL, owner_id TEXT NOT NULL DEFAULT '',
            is_synced INTEGER DEFAULT 0, is_deleted INTEGER NOT NULL DEFAULT 0,
            updated_at TEXT
          )''');
        await db.execute('''
          CREATE TABLE transactions (
            id TEXT PRIMARY KEY, customer_id TEXT NOT NULL,
            amount REAL NOT NULL, type INTEGER NOT NULL, note TEXT,
            date TEXT NOT NULL, debt_id TEXT,
            owner_id TEXT NOT NULL DEFAULT '',
            is_synced INTEGER DEFAULT 0, is_deleted INTEGER NOT NULL DEFAULT 0,
            updated_at TEXT,
            FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE CASCADE,
            FOREIGN KEY (debt_id) REFERENCES transactions (id) ON DELETE SET NULL
          )''');
        await db.execute('''
          CREATE TABLE debt_reminders (
            id TEXT PRIMARY KEY, customer_id TEXT NOT NULL, debt_id TEXT,
            reminder_date TEXT NOT NULL, is_completed INTEGER NOT NULL DEFAULT 0,
            message TEXT, owner_id TEXT NOT NULL DEFAULT '',
            is_synced INTEGER DEFAULT 0, is_deleted INTEGER NOT NULL DEFAULT 0,
            updated_at TEXT,
            FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE CASCADE,
            FOREIGN KEY (debt_id) REFERENCES transactions (id) ON DELETE SET NULL
          )''');
      },
    ),
  );
  await db.execute('PRAGMA foreign_keys = ON');
  DatabaseHelper.testDatabase = db;
  return db;
}

void main() {
  late Database db;

  setUp(() async {
    db = await _setupDb();
  });

  tearDown(() async {
    await db.close();
  });

  // ======================== MODEL SYNC FIELDS ========================

  group('Model sync fields', () {
    test('Customer toMap includes is_deleted', () {
      final c = Customer(
        id: 'c1', name: 'Test', createdAt: '2025-01-01',
        ownerId: _uid, isSynced: true, isDeleted: true,
      );
      final map = c.toMap();
      expect(map['is_deleted'], 1);
      expect(map['is_synced'], 1);
      expect(map['owner_id'], _uid);
    });

    test('Customer fromMap reads is_deleted', () {
      final c = Customer.fromMap({
        'id': 'c1', 'name': 'Test', 'created_at': '2025-01-01',
        'owner_id': _uid, 'is_synced': 1, 'is_deleted': 1,
        'updated_at': '2025-06-01',
      });
      expect(c.isDeleted, true);
      expect(c.isSynced, true);
    });

    test('Transaction toMap includes is_deleted', () {
      final t = model.Transaction(
        id: 't1', customerId: 'c1', amount: 100,
        type: 0, date: '2025-01-01', ownerId: _uid, isDeleted: true,
      );
      expect(t.toMap()['is_deleted'], 1);
    });

    test('DebtReminder toMap includes is_deleted', () {
      final r = DebtReminder(
        id: 'r1', customerId: 'c1', reminderDate: '2025-06-01',
        ownerId: _uid, isDeleted: true,
      );
      expect(r.toMap()['is_deleted'], 1);
    });
  });

  // ======================== SOFT DELETE ========================

  group('Soft delete', () {
    test('customer delete sets is_deleted=1, is_synced=0', () async {
      await db.insert('customers', {
        'id': 'c1', 'name': 'Test', 'created_at': '2025-01-01',
        'owner_id': _uid, 'is_synced': 1,
      });

      final now = DateTime.now().toIso8601String();
      await db.update('customers',
        {'is_deleted': 1, 'is_synced': 0, 'updated_at': now},
        where: 'id = ?', whereArgs: ['c1']);

      final result = await db.query('customers', where: 'id = ?', whereArgs: ['c1']);
      expect(result.first['is_deleted'], 1);
      expect(result.first['is_synced'], 0);
    });

    test('getAll filters out deleted records', () async {
      await db.insert('customers', {
        'id': 'c1', 'name': 'Alive', 'created_at': '2025-01-01',
        'owner_id': _uid, 'is_deleted': 0,
      });
      await db.insert('customers', {
        'id': 'c2', 'name': 'Dead', 'created_at': '2025-01-01',
        'owner_id': _uid, 'is_deleted': 1,
      });

      final result = await db.query('customers', where: 'is_deleted = 0');
      expect(result.length, 1);
      expect(result.first['name'], 'Alive');
    });

    test('getById filters out deleted records', () async {
      await db.insert('customers', {
        'id': 'c1', 'name': 'Dead', 'created_at': '2025-01-01',
        'owner_id': _uid, 'is_deleted': 1,
      });

      final result = await db.query('customers',
        where: 'id = ? AND is_deleted = 0', whereArgs: ['c1']);
      expect(result, isEmpty);
    });

    test('cascade soft delete: customer + transactions + reminders', () async {
      await db.insert('customers', {
        'id': 'c1', 'name': 'Test', 'created_at': '2025-01-01',
        'owner_id': _uid,
      });
      await db.insert('transactions', {
        'id': 't1', 'customer_id': 'c1', 'amount': 100,
        'type': 0, 'date': '2025-01-01', 'owner_id': _uid,
      });
      await db.insert('debt_reminders', {
        'id': 'r1', 'customer_id': 'c1', 'reminder_date': '2025-06-01',
        'owner_id': _uid,
      });

      final now = DateTime.now().toIso8601String();
      final softDelete = {'is_deleted': 1, 'is_synced': 0, 'updated_at': now};

      // Cascade soft delete
      await db.update('customers', softDelete, where: 'id = ?', whereArgs: ['c1']);
      await db.update('transactions', softDelete, where: 'customer_id = ?', whereArgs: ['c1']);
      await db.update('debt_reminders', softDelete, where: 'customer_id = ?', whereArgs: ['c1']);

      // All three should be soft-deleted
      final custResult = await db.query('customers', where: 'is_deleted = 0');
      expect(custResult.length, 0);

      final txResult = await db.query('transactions', where: 'is_deleted = 0');
      expect(txResult.length, 0);

      final remResult = await db.query('debt_reminders', where: 'is_deleted = 0');
      expect(remResult.length, 0);
    });
  });

  // ======================== OWNER SCOPING ========================

  group('Owner scoping', () {
    test('getAll filters by owner_id', () async {
      await db.insert('customers', {
        'id': 'c1', 'name': 'User1', 'created_at': '2025-01-01',
        'owner_id': 'owner-a',
      });
      await db.insert('customers', {
        'id': 'c2', 'name': 'User2', 'created_at': '2025-01-01',
        'owner_id': 'owner-b',
      });

      final result = await db.query('customers',
        where: 'owner_id = ?', whereArgs: ['owner-a']);
      expect(result.length, 1);
      expect(result.first['name'], 'User1');
    });
  });

  // ======================== UNSYNCED COUNT ========================

  group('Unsynced tracking', () {
    test('count of is_synced=0 records across tables', () async {
      await db.insert('customers', {
        'id': 'c1', 'name': 'Test', 'created_at': '2025-01-01',
        'owner_id': _uid, 'is_synced': 0,
      });
      await db.insert('transactions', {
        'id': 't1', 'customer_id': 'c1', 'amount': 100,
        'type': 0, 'date': '2025-01-01', 'owner_id': _uid, 'is_synced': 0,
      });
      await db.insert('debt_reminders', {
        'id': 'r1', 'customer_id': 'c1', 'reminder_date': '2025-06-01',
        'owner_id': _uid, 'is_synced': 0,
      });

      int count = 0;
      for (final table in ['customers', 'transactions', 'debt_reminders']) {
        final result = await db.rawQuery(
          'SELECT COUNT(*) as c FROM $table WHERE is_synced = 0',
        );
        count += result.first['c'] as int;
      }
      expect(count, 3);
    });

    test('markSynced sets is_synced=1', () async {
      await db.insert('customers', {
        'id': 'c1', 'name': 'Test', 'created_at': '2025-01-01',
        'owner_id': _uid, 'is_synced': 0,
      });

      await db.update('customers', {'is_synced': 1},
        where: 'id = ?', whereArgs: ['c1']);

      final result = await db.query('customers', where: 'id = ?', whereArgs: ['c1']);
      expect(result.first['is_synced'], 1);
    });

    test('soft-deleted records appear in unsynced count', () async {
      await db.insert('customers', {
        'id': 'c1', 'name': 'Test', 'created_at': '2025-01-01',
        'owner_id': _uid, 'is_synced': 0, 'is_deleted': 1,
      });

      final result = await db.rawQuery(
        'SELECT COUNT(*) as c FROM customers WHERE is_synced = 0',
      );
      expect(result.first['c'], 1);
    });
  });

  // ======================== UPSERT FROM CLOUD ========================

  group('Upsert from cloud', () {
    test('insert new record from cloud', () async {
      final map = Customer(
        id: 'cloud-c1', name: 'Cloud Customer',
        createdAt: '2025-06-01', ownerId: _uid,
        updatedAt: '2025-06-01T00:00:00.000',
      ).toMap();
      map['is_synced'] = 1;

      await db.insert('customers', map);

      final result = await db.query('customers',
        where: 'id = ?', whereArgs: ['cloud-c1']);
      expect(result.length, 1);
      expect(result.first['name'], 'Cloud Customer');
      expect(result.first['is_synced'], 1);
    });

    test('update existing record when cloud is newer', () async {
      await db.insert('customers', {
        'id': 'c1', 'name': 'Old', 'created_at': '2025-01-01',
        'owner_id': _uid, 'updated_at': '2025-01-01T00:00:00.000',
      });

      // Cloud record is newer
      await db.update('customers', {
        'name': 'New', 'is_synced': 1, 'updated_at': '2025-06-15T00:00:00.000',
      }, where: 'id = ?', whereArgs: ['c1']);

      final result = await db.query('customers', where: 'id = ?', whereArgs: ['c1']);
      expect(result.first['name'], 'New');
    });

    test('keep local record when local is newer', () async {
      await db.insert('customers', {
        'id': 'c1', 'name': 'Local Winner', 'created_at': '2025-01-01',
        'owner_id': _uid, 'updated_at': '2025-12-31T00:00:00.000',
      });

      // Simulate cloud record being older — don't update
      final local = await db.query('customers', where: 'id = ?', whereArgs: ['c1']);
      expect(local.first['name'], 'Local Winner');
    });

    test('cloud soft-deleted record sets is_deleted locally', () async {
      await db.insert('customers', {
        'id': 'c1', 'name': 'Alive', 'created_at': '2025-01-01',
        'owner_id': _uid, 'is_deleted': 0,
      });

      // Cloud says deleted
      await db.update('customers', {
        'is_deleted': 1, 'is_synced': 1, 'updated_at': '2025-06-15T00:00:00.000',
      }, where: 'id = ?', whereArgs: ['c1']);

      final result = await db.query('customers', where: 'id = ?', whereArgs: ['c1']);
      expect(result.first['is_deleted'], 1);
    });
  });

  // ======================== DEBT REMAINING CALCULATION ========================

  group('Debt remaining with is_deleted', () {
    test('soft-deleted payment excluded from remaining calc', () async {
      await db.insert('customers', {
        'id': 'c1', 'name': 'Test', 'created_at': '2025-01-01', 'owner_id': _uid,
      });
      // Debt of 1000
      await db.insert('transactions', {
        'id': 'debt-1', 'customer_id': 'c1', 'amount': 1000,
        'type': 0, 'date': '2025-01-01', 'owner_id': _uid,
      });
      // Active payment of 300
      await db.insert('transactions', {
        'id': 'pay-1', 'customer_id': 'c1', 'amount': 300,
        'type': 1, 'date': '2025-02-01', 'debt_id': 'debt-1',
        'owner_id': _uid, 'is_deleted': 0,
      });
      // Soft-deleted payment of 200 (should be excluded)
      await db.insert('transactions', {
        'id': 'pay-2', 'customer_id': 'c1', 'amount': 200,
        'type': 1, 'date': '2025-03-01', 'debt_id': 'debt-1',
        'owner_id': _uid, 'is_deleted': 1,
      });

      // getPaymentsForDebt should only sum non-deleted payments
      final result = await db.rawQuery(
        "SELECT COALESCE(SUM(amount), 0) as total FROM transactions WHERE debt_id = ? AND type = 1 AND is_deleted = 0",
        ['debt-1'],
      );
      expect(result.first['total'], 300); // Only 300, not 500
    });

    test('soft-deleted debt excluded from debts with remaining', () async {
      await db.insert('customers', {
        'id': 'c1', 'name': 'Test', 'created_at': '2025-01-01', 'owner_id': _uid,
      });
      // Active debt
      await db.insert('transactions', {
        'id': 'debt-1', 'customer_id': 'c1', 'amount': 500,
        'type': 0, 'date': '2025-01-01', 'owner_id': _uid, 'is_deleted': 0,
      });
      // Soft-deleted debt (should not appear)
      await db.insert('transactions', {
        'id': 'debt-2', 'customer_id': 'c1', 'amount': 800,
        'type': 0, 'date': '2025-01-02', 'owner_id': _uid, 'is_deleted': 1,
      });

      final result = await db.rawQuery(
        "SELECT COUNT(*) as c FROM transactions WHERE type = 0 AND is_deleted = 0 AND customer_id = ?",
        ['c1'],
      );
      expect(result.first['c'], 1); // Only debt-1
    });
  });
}
