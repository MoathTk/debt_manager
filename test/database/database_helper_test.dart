import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:local_debt_management/data/database_helper.dart';

Future<Database> _setupDb() async {
  sqfliteFfiInit();
  final db = await databaseFactoryFfi.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE customers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            phone TEXT,
            created_at TEXT NOT NULL,
            firebase_id TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            customer_id INTEGER NOT NULL,
            amount REAL NOT NULL,
            type INTEGER NOT NULL,
            note TEXT,
            date TEXT NOT NULL,
            debt_id INTEGER,
            firebase_id TEXT,
            FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE CASCADE,
            FOREIGN KEY (debt_id) REFERENCES transactions (id) ON DELETE SET NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE debt_reminders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            customer_id INTEGER NOT NULL,
            debt_id INTEGER,
            reminder_date TEXT NOT NULL,
            is_completed INTEGER NOT NULL DEFAULT 0,
            message TEXT,
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
      expect(names, containsAll(['id', 'name', 'phone', 'created_at', 'firebase_id']));
    });

    test('transactions table has debt_id column', () async {
      final cols = await db.rawQuery('PRAGMA table_info(transactions)');
      final names = cols.map((c) => c['name'] as String).toSet();
      expect(names, contains('debt_id'));
    });

    test('debt_reminders table has debt_id column (CRITICAL fix regression)', () async {
      final cols = await db.rawQuery('PRAGMA table_info(debt_reminders)');
      final names = cols.map((c) => c['name'] as String).toSet();
      expect(names, contains('debt_id'),
        reason: 'debt_reminders must have debt_id column — fresh installs were missing it');
    });

    test('debt_reminders.debt_id is nullable INTEGER', () async {
      final cols = await db.rawQuery('PRAGMA table_info(debt_reminders)');
      final debtIdCol = cols.firstWhere((c) => c['name'] == 'debt_id');
      expect(debtIdCol['type'], 'INTEGER');
      expect(debtIdCol['notnull'], 0);
    });

    test('foreign keys enforce cascade on delete', () async {
      await db.insert('customers', {'name': 'Test', 'created_at': '2025-01-01'});
      await db.insert('transactions', {
        'customer_id': 1,
        'amount': 100,
        'type': 0,
        'date': '2025-01-01',
      });
      await db.insert('debt_reminders', {
        'customer_id': 1,
        'reminder_date': '2025-06-01',
      });
      await db.delete('customers', where: 'id = ?', whereArgs: [1]);
      final rem = await db.query('debt_reminders');
      expect(rem, isEmpty);
    });

    test('inserting reminder with debt_id succeeds', () async {
      await db.insert('customers', {'name': 'Test', 'created_at': '2025-01-01'});
      await db.insert('transactions', {
        'customer_id': 1,
        'amount': 100,
        'type': 0,
        'date': '2025-01-01',
      });
      final id = await db.insert('debt_reminders', {
        'customer_id': 1,
        'debt_id': 1,
        'reminder_date': '2025-06-01',
      });
      expect(id, greaterThan(0));
      final rows = await db.query('debt_reminders', where: 'debt_id = ?', whereArgs: [1]);
      expect(rows.length, 1);
    });

    test('inserting reminder without debt_id (null) succeeds', () async {
      await db.insert('customers', {'name': 'Test', 'created_at': '2025-01-01'});
      final id = await db.insert('debt_reminders', {
        'customer_id': 1,
        'reminder_date': '2025-06-01',
      });
      expect(id, greaterThan(0));
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
