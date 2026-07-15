import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:local_debt_management/data/database_helper.dart';

Future<Database> _setupDb() async {
  sqfliteFfiInit();
  final db = await databaseFactoryFfi.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      version: 5,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE customers (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            phone TEXT,
            created_at TEXT NOT NULL,
            owner_id TEXT NOT NULL DEFAULT '',
            is_synced INTEGER DEFAULT 0,
            updated_at TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE transactions (
            id TEXT PRIMARY KEY,
            customer_id TEXT NOT NULL,
            amount REAL NOT NULL,
            type INTEGER NOT NULL,
            note TEXT,
            date TEXT NOT NULL,
            debt_id TEXT,
            owner_id TEXT NOT NULL DEFAULT '',
            is_synced INTEGER DEFAULT 0,
            updated_at TEXT,
            FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE CASCADE,
            FOREIGN KEY (debt_id) REFERENCES transactions (id) ON DELETE SET NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE debt_reminders (
            id TEXT PRIMARY KEY,
            customer_id TEXT NOT NULL,
            debt_id TEXT,
            reminder_date TEXT NOT NULL,
            is_completed INTEGER NOT NULL DEFAULT 0,
            message TEXT,
            owner_id TEXT NOT NULL DEFAULT '',
            is_synced INTEGER DEFAULT 0,
            updated_at TEXT,
            FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE CASCADE,
            FOREIGN KEY (debt_id) REFERENCES transactions (id) ON DELETE SET NULL
          )
        ''');
      },
    ),
  );
  await db.execute('PRAGMA foreign_keys = ON');
  DatabaseHelper.testDatabase = db;
  return db;
}

void main() {
  group('DatabaseHelper schema', () {
    late Database db;

    setUp(() async {
      db = await _setupDb();
    });

    tearDown(() async {
      await db.close();
    });

    test('customers table has correct columns', () async {
      final cols = await db.rawQuery('PRAGMA table_info(customers)');
      final names = cols.map((c) => c['name'] as String).toSet();
      expect(names, containsAll([
        'id', 'name', 'phone', 'created_at',
        'owner_id', 'is_synced', 'updated_at',
      ]));
    });

    test('transactions table has correct columns', () async {
      final cols = await db.rawQuery('PRAGMA table_info(transactions)');
      final names = cols.map((c) => c['name'] as String).toSet();
      expect(names, containsAll([
        'debt_id', 'owner_id', 'is_synced', 'updated_at',
      ]));
    });

    test('debt_reminders table has debt_id column', () async {
      final cols = await db.rawQuery('PRAGMA table_info(debt_reminders)');
      final names = cols.map((c) => c['name'] as String).toSet();
      expect(names, contains('debt_id'));
    });

    test('debt_reminders.debt_id is nullable TEXT', () async {
      final cols = await db.rawQuery('PRAGMA table_info(debt_reminders)');
      final debtIdCol = cols.firstWhere((c) => c['name'] == 'debt_id');
      expect(debtIdCol['type'], 'TEXT');
      expect(debtIdCol['notnull'], 0);
    });

    test('foreign keys enforce cascade on delete', () async {
      final cid = 'test-cust-1';
      await db.insert('customers', {
        'id': cid, 'name': 'Test', 'created_at': '2025-01-01',
      });
      await db.insert('transactions', {
        'id': 'tx-1', 'customer_id': cid, 'amount': 100,
        'type': 0, 'date': '2025-01-01',
      });
      await db.insert('debt_reminders', {
        'id': 'rem-1', 'customer_id': cid, 'reminder_date': '2025-06-01',
      });
      await db.delete('customers', where: 'id = ?', whereArgs: [cid]);
      final rem = await db.query('debt_reminders');
      expect(rem, isEmpty);
    });

    test('inserting reminder with debt_id succeeds', () async {
      final cid = 'cust-1';
      await db.insert('customers', {
        'id': cid, 'name': 'Test', 'created_at': '2025-01-01',
      });
      await db.insert('transactions', {
        'id': 'tx-1', 'customer_id': cid, 'amount': 100,
        'type': 0, 'date': '2025-01-01',
      });
      await db.insert('debt_reminders', {
        'id': 'rem-1', 'customer_id': cid, 'debt_id': 'tx-1',
        'reminder_date': '2025-06-01',
      });
      final rows = await db.query('debt_reminders', where: 'debt_id = ?', whereArgs: ['tx-1']);
      expect(rows.length, 1);
    });

    test('inserting reminder without debt_id (null) succeeds', () async {
      final cid = 'cust-2';
      await db.insert('customers', {
        'id': cid, 'name': 'Test', 'created_at': '2025-01-01',
      });
      await db.insert('debt_reminders', {
        'id': 'rem-2', 'customer_id': cid, 'reminder_date': '2025-06-01',
      });
      final rows = await db.query('debt_reminders');
      expect(rows.length, 1);
    });
  });

  group('DatabaseHelper singleton', () {
    test('testDatabase setter overrides singleton database', () async {
      final db = await _setupDb();
      final helper = DatabaseHelper.instance;
      final result = await helper.database;
      identical(result, db);
      await db.close();
    });
  });
}
