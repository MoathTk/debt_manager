import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:local_debt_management/data/database_helper.dart';
import 'package:local_debt_management/data/models/debt_reminder.dart';
import 'package:local_debt_management/data/repositories/debt_reminder_repository.dart';

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
            name TEXT NOT NULL, phone TEXT,
            created_at TEXT NOT NULL, firebase_id TEXT
          )''');
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            customer_id INTEGER NOT NULL, amount REAL NOT NULL,
            type INTEGER NOT NULL, note TEXT, date TEXT NOT NULL,
            debt_id INTEGER, firebase_id TEXT,
            FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE CASCADE,
            FOREIGN KEY (debt_id) REFERENCES transactions (id) ON DELETE SET NULL
          )''');
        await db.execute('''
          CREATE TABLE debt_reminders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            customer_id INTEGER NOT NULL, debt_id INTEGER,
            reminder_date TEXT NOT NULL, is_completed INTEGER NOT NULL DEFAULT 0,
            message TEXT,
            FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE CASCADE,
            FOREIGN KEY (debt_id) REFERENCES transactions (id) ON DELETE SET NULL
          )''');
      },
    ),
  );
  await db.execute('PRAGMA foreign_keys = ON');
  DatabaseHelper.testDatabase = db;
}

int _cid = 0;

Future<int> _addCustomer() async {
  _cid++;
  final db = await DatabaseHelper.instance.database;
  await db.insert('customers', {'name': 'C$_cid', 'created_at': '2025-01-01'});
  return _cid;
}

void main() {
  late DebtReminderRepository repo;

  setUp(() async {
    _cid = 0;
    await _setupDb();
    repo = DebtReminderRepository();
  });

  tearDown(() async {
    final db = await DatabaseHelper.instance.database;
    await db.close();
  });

  group('insert & getById', () {
    test('insert returns valid id', () async {
      final cid = await _addCustomer();
      final id = await repo.insert(
        DebtReminder(customerId: cid, reminderDate: '2025-06-01'),
      );
      expect(id, greaterThan(0));
    });

    test('getById returns correct reminder', () async {
      final cid = await _addCustomer();
      final id = await repo.insert(
        DebtReminder(customerId: cid, reminderDate: '2025-06-01', message: 'test'),
      );
      final r = await repo.getById(id);
      expect(r, isNotNull);
      expect(r!.message, 'test');
      expect(r.completed, false);
    });

    test('getById returns null for nonexistent', () async {
      expect(await repo.getById(9999), null);
    });
  });

  group('getAll', () {
    test('returns all ordered by reminder_date ASC', () async {
      final cid = await _addCustomer();
      await repo.insert(DebtReminder(customerId: cid, reminderDate: '2025-07-01'));
      await repo.insert(DebtReminder(customerId: cid, reminderDate: '2025-06-01'));
      final all = await repo.getAll();
      expect(all.length, 2);
      expect(all.first.reminderDate, '2025-06-01');
    });
  });

  group('getByCustomer', () {
    test('returns only reminders for given customer', () async {
      final cid1 = await _addCustomer();
      final cid2 = await _addCustomer();
      await repo.insert(DebtReminder(customerId: cid1, reminderDate: '2025-06-01'));
      await repo.insert(DebtReminder(customerId: cid2, reminderDate: '2025-06-01'));
      final results = await repo.getByCustomer(cid1);
      expect(results.length, 1);
    });
  });

  group('getPending & getCompleted', () {
    test('getPending returns only uncompleted', () async {
      final cid = await _addCustomer();
      await repo.insert(DebtReminder(customerId: cid, reminderDate: '2025-06-01', isCompleted: 0));
      await repo.insert(DebtReminder(customerId: cid, reminderDate: '2025-06-02', isCompleted: 1));
      final pending = await repo.getPending();
      expect(pending.length, 1);
    });

    test('getCompleted returns only completed', () async {
      final cid = await _addCustomer();
      await repo.insert(DebtReminder(customerId: cid, reminderDate: '2025-06-01', isCompleted: 0));
      await repo.insert(DebtReminder(customerId: cid, reminderDate: '2025-06-02', isCompleted: 1));
      final completed = await repo.getCompleted();
      expect(completed.length, 1);
    });
  });

  group('markCompleted & markPending', () {
    test('markCompleted sets is_completed=1', () async {
      final cid = await _addCustomer();
      final id = await repo.insert(
        DebtReminder(customerId: cid, reminderDate: '2025-06-01'),
      );
      await repo.markCompleted(id);
      final r = await repo.getById(id);
      expect(r!.completed, true);
    });

    test('markPending sets is_completed=0', () async {
      final cid = await _addCustomer();
      final id = await repo.insert(
        DebtReminder(customerId: cid, reminderDate: '2025-06-01', isCompleted: 1),
      );
      await repo.markPending(id);
      final r = await repo.getById(id);
      expect(r!.completed, false);
    });
  });

  group('getDueToday', () {
    test('returns reminders due on or before the given date', () async {
      final cid = await _addCustomer();
      await repo.insert(DebtReminder(customerId: cid, reminderDate: '2025-06-01'));
      await repo.insert(DebtReminder(customerId: cid, reminderDate: '2025-06-15'));
      await repo.insert(DebtReminder(customerId: cid, reminderDate: '2025-06-30'));
      final due = await repo.getDueToday(date: '2025-06-15');
      expect(due.length, 2);
    });

    test('excludes completed reminders', () async {
      final cid = await _addCustomer();
      await repo.insert(DebtReminder(customerId: cid, reminderDate: '2025-06-01'));
      await repo.insert(DebtReminder(customerId: cid, reminderDate: '2025-06-01', isCompleted: 1));
      final due = await repo.getDueToday(date: '2025-06-15');
      expect(due.length, 1);
    });

    test('returns empty when no reminders due', () async {
      final cid = await _addCustomer();
      await repo.insert(DebtReminder(customerId: cid, reminderDate: '2025-12-31'));
      final due = await repo.getDueToday(date: '2025-06-01');
      expect(due, isEmpty);
    });
  });

  group('getPendingCount', () {
    test('counts only pending', () async {
      final cid = await _addCustomer();
      await repo.insert(DebtReminder(customerId: cid, reminderDate: '2025-06-01'));
      await repo.insert(DebtReminder(customerId: cid, reminderDate: '2025-06-01', isCompleted: 1));
      expect(await repo.getPendingCount(), 1);
    });
  });

  group('deleteBatch', () {
    test('deletes multiple by ids', () async {
      final cid = await _addCustomer();
      final id1 = await repo.insert(DebtReminder(customerId: cid, reminderDate: '2025-06-01'));
      final id2 = await repo.insert(DebtReminder(customerId: cid, reminderDate: '2025-06-02'));
      await repo.deleteBatch([id1, id2]);
      expect(await repo.getById(id1), null);
      expect(await repo.getById(id2), null);
    });

    test('empty list is no-op', () async {
      await repo.deleteBatch([]);
    });
  });

  group('deleteByDebtId', () {
    test('deletes all reminders linked to a debt', () async {
      final cid = await _addCustomer();
      final db = await DatabaseHelper.instance.database;
      await db.insert('transactions', {
        'customer_id': cid, 'amount': 100, 'type': 0, 'date': '2025-06-01',
      });
      await db.insert('transactions', {
        'customer_id': cid, 'amount': 200, 'type': 0, 'date': '2025-06-02',
      });
      await repo.insert(DebtReminder(customerId: cid, debtId: 1, reminderDate: '2025-06-01'));
      await repo.insert(DebtReminder(customerId: cid, debtId: 1, reminderDate: '2025-07-01'));
      await repo.insert(DebtReminder(customerId: cid, debtId: 2, reminderDate: '2025-06-01'));
      await repo.deleteByDebtId(1);
      final remaining = await repo.getAll();
      expect(remaining.length, 1);
      expect(remaining.first.debtId, 2);
    });
  });

  group('update', () {
    test('updates reminder fields', () async {
      final cid = await _addCustomer();
      final id = await repo.insert(
        DebtReminder(customerId: cid, reminderDate: '2025-06-01'),
      );
      final existing = (await repo.getById(id))!;
      await repo.update(existing.copyWith(message: 'updated'));
      final updated = await repo.getById(id);
      expect(updated!.message, 'updated');
    });
  });
}
