import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';
import 'package:local_debt_management/data/database_helper.dart';
import 'package:local_debt_management/data/models/debt_reminder.dart';
import 'package:local_debt_management/data/repositories/debt_reminder_repository.dart';

const _uuid = Uuid();

Future<void> _setupDb() async {
  sqfliteFfiInit();
  final db = await databaseFactoryFfi.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE customers (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL, phone TEXT,
            created_at TEXT NOT NULL,
            owner_id TEXT NOT NULL DEFAULT '',
            is_synced INTEGER DEFAULT 0, updated_at TEXT
          )''');
        await db.execute('''
          CREATE TABLE transactions (
            id TEXT PRIMARY KEY,
            customer_id TEXT NOT NULL, amount REAL NOT NULL,
            type INTEGER NOT NULL, note TEXT, date TEXT NOT NULL,
            debt_id TEXT,
            owner_id TEXT NOT NULL DEFAULT '',
            is_synced INTEGER DEFAULT 0, updated_at TEXT,
            FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE CASCADE,
            FOREIGN KEY (debt_id) REFERENCES transactions (id) ON DELETE SET NULL
          )''');
        await db.execute('''
          CREATE TABLE debt_reminders (
            id TEXT PRIMARY KEY,
            customer_id TEXT NOT NULL, debt_id TEXT,
            reminder_date TEXT NOT NULL, is_completed INTEGER NOT NULL DEFAULT 0,
            message TEXT,
            owner_id TEXT NOT NULL DEFAULT '',
            is_synced INTEGER DEFAULT 0, updated_at TEXT,
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

Future<String> _addCustomer() async {
  _cid++;
  final id = _uuid.v4();
  final db = await DatabaseHelper.instance.database;
  await db.insert('customers', {'id': id, 'name': 'C$_cid', 'created_at': '2025-01-01'});
  return id;
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
        DebtReminder(id: _uuid.v4(), customerId: cid, reminderDate: '2025-06-01'),
      );
      expect(id, greaterThan(0));
    });

    test('getById returns correct reminder', () async {
      final cid = await _addCustomer();
      final uuid = _uuid.v4();
      await repo.insert(
        DebtReminder(id: uuid, customerId: cid, reminderDate: '2025-06-01', message: 'test'),
      );
      final r = await repo.getById(uuid);
      expect(r, isNotNull);
      expect(r!.message, 'test');
      expect(r.completed, false);
    });

    test('getById returns null for nonexistent', () async {
      expect(await repo.getById(_uuid.v4()), null);
    });
  });

  group('getAll', () {
    test('returns all ordered by reminder_date ASC', () async {
      final cid = await _addCustomer();
      await repo.insert(DebtReminder(id: _uuid.v4(), customerId: cid, reminderDate: '2025-07-01'));
      await repo.insert(DebtReminder(id: _uuid.v4(), customerId: cid, reminderDate: '2025-06-01'));
      final all = await repo.getAll();
      expect(all.length, 2);
      expect(all.first.reminderDate, '2025-06-01');
    });
  });

  group('getByCustomer', () {
    test('returns only reminders for given customer', () async {
      final cid1 = await _addCustomer();
      final cid2 = await _addCustomer();
      await repo.insert(DebtReminder(id: _uuid.v4(), customerId: cid1, reminderDate: '2025-06-01'));
      await repo.insert(DebtReminder(id: _uuid.v4(), customerId: cid2, reminderDate: '2025-06-01'));
      final results = await repo.getByCustomer(cid1);
      expect(results.length, 1);
    });
  });

  group('getPending & getCompleted', () {
    test('getPending returns only uncompleted', () async {
      final cid = await _addCustomer();
      await repo.insert(DebtReminder(id: _uuid.v4(), customerId: cid, reminderDate: '2025-06-01', isCompleted: 0));
      await repo.insert(DebtReminder(id: _uuid.v4(), customerId: cid, reminderDate: '2025-06-02', isCompleted: 1));
      final pending = await repo.getPending();
      expect(pending.length, 1);
    });

    test('getCompleted returns only completed', () async {
      final cid = await _addCustomer();
      await repo.insert(DebtReminder(id: _uuid.v4(), customerId: cid, reminderDate: '2025-06-01', isCompleted: 0));
      await repo.insert(DebtReminder(id: _uuid.v4(), customerId: cid, reminderDate: '2025-06-02', isCompleted: 1));
      final completed = await repo.getCompleted();
      expect(completed.length, 1);
    });
  });

  group('markCompleted & markPending', () {
    test('markCompleted sets is_completed=1', () async {
      final cid = await _addCustomer();
      final uuid = _uuid.v4();
      await repo.insert(
        DebtReminder(id: uuid, customerId: cid, reminderDate: '2025-06-01'),
      );
      await repo.markCompleted(uuid);
      final r = await repo.getById(uuid);
      expect(r!.completed, true);
    });

    test('markPending sets is_completed=0', () async {
      final cid = await _addCustomer();
      final uuid = _uuid.v4();
      await repo.insert(
        DebtReminder(id: uuid, customerId: cid, reminderDate: '2025-06-01', isCompleted: 1),
      );
      await repo.markPending(uuid);
      final r = await repo.getById(uuid);
      expect(r!.completed, false);
    });
  });

  group('getDueToday', () {
    test('returns reminders due on or before the given date', () async {
      final cid = await _addCustomer();
      await repo.insert(DebtReminder(id: _uuid.v4(), customerId: cid, reminderDate: '2025-06-01'));
      await repo.insert(DebtReminder(id: _uuid.v4(), customerId: cid, reminderDate: '2025-06-15'));
      await repo.insert(DebtReminder(id: _uuid.v4(), customerId: cid, reminderDate: '2025-06-30'));
      final due = await repo.getDueToday(date: '2025-06-15');
      expect(due.length, 2);
    });

    test('excludes completed reminders', () async {
      final cid = await _addCustomer();
      await repo.insert(DebtReminder(id: _uuid.v4(), customerId: cid, reminderDate: '2025-06-01'));
      await repo.insert(DebtReminder(id: _uuid.v4(), customerId: cid, reminderDate: '2025-06-01', isCompleted: 1));
      final due = await repo.getDueToday(date: '2025-06-15');
      expect(due.length, 1);
    });

    test('returns empty when no reminders due', () async {
      final cid = await _addCustomer();
      await repo.insert(DebtReminder(id: _uuid.v4(), customerId: cid, reminderDate: '2025-12-31'));
      final due = await repo.getDueToday(date: '2025-06-01');
      expect(due, isEmpty);
    });
  });

  group('getPendingCount', () {
    test('counts only pending', () async {
      final cid = await _addCustomer();
      await repo.insert(DebtReminder(id: _uuid.v4(), customerId: cid, reminderDate: '2025-06-01'));
      await repo.insert(DebtReminder(id: _uuid.v4(), customerId: cid, reminderDate: '2025-06-01', isCompleted: 1));
      expect(await repo.getPendingCount(), 1);
    });
  });

  group('deleteBatch', () {
    test('deletes multiple by ids', () async {
      final cid = await _addCustomer();
      final id1 = _uuid.v4();
      final id2 = _uuid.v4();
      await repo.insert(DebtReminder(id: id1, customerId: cid, reminderDate: '2025-06-01'));
      await repo.insert(DebtReminder(id: id2, customerId: cid, reminderDate: '2025-06-02'));
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
      final txId1 = _uuid.v4();
      final txId2 = _uuid.v4();
      await db.insert('transactions', {
        'id': txId1,
        'customer_id': cid, 'amount': 100, 'type': 0, 'date': '2025-06-01',
      });
      await db.insert('transactions', {
        'id': txId2,
        'customer_id': cid, 'amount': 200, 'type': 0, 'date': '2025-06-02',
      });
      await repo.insert(DebtReminder(id: _uuid.v4(), customerId: cid, debtId: txId1, reminderDate: '2025-06-01'));
      await repo.insert(DebtReminder(id: _uuid.v4(), customerId: cid, debtId: txId1, reminderDate: '2025-07-01'));
      await repo.insert(DebtReminder(id: _uuid.v4(), customerId: cid, debtId: txId2, reminderDate: '2025-06-01'));
      await repo.deleteByDebtId(txId1);
      final remaining = await repo.getAll();
      expect(remaining.length, 1);
      expect(remaining.first.debtId, txId2);
    });
  });

  group('update', () {
    test('updates reminder fields', () async {
      final cid = await _addCustomer();
      final uuid = _uuid.v4();
      await repo.insert(
        DebtReminder(id: uuid, customerId: cid, reminderDate: '2025-06-01'),
      );
      final existing = (await repo.getById(uuid))!;
      await repo.update(existing.copyWith(message: 'updated'));
      final updated = await repo.getById(uuid);
      expect(updated!.message, 'updated');
    });
  });
}
