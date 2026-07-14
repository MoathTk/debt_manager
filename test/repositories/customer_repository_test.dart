import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:local_debt_management/data/database_helper.dart';
import 'package:local_debt_management/data/models/customer.dart';
import 'package:local_debt_management/data/repositories/customer_repository.dart';

Future<void> _setupDb() async {
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
}

void main() {
  late CustomerRepository repo;

  setUp(() async {
    await _setupDb();
    repo = CustomerRepository();
  });

  tearDown(() async {
    final db = await DatabaseHelper.instance.database;
    await db.close();
  });

  group('insert & getById', () {
    test('insert returns valid id', () async {
      final id = await repo.insert(
        Customer(name: 'Ahmed', createdAt: '2025-01-01'),
      );
      expect(id, greaterThan(0));
    });

    test('getById returns correct customer', () async {
      final id = await repo.insert(
        Customer(name: 'Sara', phone: '07801234567', createdAt: '2025-06-15'),
      );
      final c = await repo.getById(id);
      expect(c, isNotNull);
      expect(c!.name, 'Sara');
      expect(c.phone, '07801234567');
    });

    test('getById returns null for nonexistent id', () async {
      expect(await repo.getById(9999), null);
    });
  });

  group('getAll', () {
    test('returns all customers ordered by created_at DESC', () async {
      await repo.insert(Customer(name: 'Oldest', createdAt: '2025-01-01'));
      await repo.insert(Customer(name: 'Newest', createdAt: '2025-06-15'));
      final all = await repo.getAll();
      expect(all.length, 2);
      expect(all.first.name, 'Newest');
    });
  });

  group('update', () {
    test('updates customer fields', () async {
      final id = await repo.insert(
        Customer(name: 'OldName', createdAt: '2025-01-01'),
      );
      await repo.update(Customer(id: id, name: 'NewName', createdAt: '2025-01-01'));
      final c = await repo.getById(id);
      expect(c!.name, 'NewName');
    });
  });

  group('delete', () {
    test('removes customer', () async {
      final id = await repo.insert(
        Customer(name: 'ToDelete', createdAt: '2025-01-01'),
      );
      await repo.delete(id);
      expect(await repo.getById(id), null);
    });
  });

  group('search', () {
    test('finds by name substring', () async {
      await repo.insert(Customer(name: 'Ahmed Ali', createdAt: '2025-01-01'));
      await repo.insert(Customer(name: 'Sara Mohammed', createdAt: '2025-01-01'));
      final results = await repo.search('Ahmed');
      expect(results.length, 1);
      expect(results.first.name, 'Ahmed Ali');
    });

    test('finds by phone substring', () async {
      await repo.insert(Customer(name: 'Test', phone: '07801234567', createdAt: '2025-01-01'));
      final results = await repo.search('1234');
      expect(results.length, 1);
    });

    test('returns empty for no match', () async {
      await repo.insert(Customer(name: 'Ali', createdAt: '2025-01-01'));
      expect(await repo.search('zzz'), isEmpty);
    });

    test('LIKE wildcard chars are escaped — no false positives', () async {
      await repo.insert(Customer(name: 'A', createdAt: '2025-01-01'));
      await repo.insert(Customer(name: 'AB', createdAt: '2025-01-01'));
      // Search for literal '%' should not match everything
      final results = await repo.search('%');
      expect(results, isEmpty);
    });

    test('underscore is escaped', () async {
      await repo.insert(Customer(name: 'A_B', createdAt: '2025-01-01'));
      await repo.insert(Customer(name: 'AXB', createdAt: '2025-01-01'));
      final results = await repo.search('_');
      expect(results.length, 1);
      expect(results.first.name, 'A_B');
    });
  });

  group('getCustomerCount', () {
    test('returns correct count', () async {
      expect(await repo.getCustomerCount(), 0);
      await repo.insert(Customer(name: 'A', createdAt: '2025-01-01'));
      await repo.insert(Customer(name: 'B', createdAt: '2025-01-01'));
      expect(await repo.getCustomerCount(), 2);
    });
  });
}
