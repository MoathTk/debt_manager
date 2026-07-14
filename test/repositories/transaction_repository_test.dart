import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:local_debt_management/data/database_helper.dart';
import 'package:local_debt_management/data/models/transaction.dart' as model;
import 'package:local_debt_management/data/repositories/transaction_repository.dart';

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

Future<int> _addCustomer(var repo) async {
  _cid++;
  final custRepo = (await DatabaseHelper.instance.database);
  await custRepo.insert('customers', {
    'name': 'Customer$_cid',
    'created_at': '2025-01-01',
  });
  return _cid;
}

void main() {
  late TransactionRepository repo;

  setUp(() async {
    _cid = 0;
    await _setupDb();
    repo = TransactionRepository();
  });

  tearDown(() async {
    final db = await DatabaseHelper.instance.database;
    await db.close();
  });

  Future<int> insertDebt(int custId, double amount, {String date = '2025-06-01'}) =>
      repo.insert(model.Transaction(
        customerId: custId, amount: amount, type: model.Transaction.debt, date: date,
      ));

  Future<int> insertPayment(int custId, double amount, {int? debtId, String date = '2025-06-01'}) =>
      repo.insert(model.Transaction(
        customerId: custId, amount: amount, type: model.Transaction.payment, date: date, debtId: debtId,
      ));

  group('insert & getById', () {
    test('insert returns valid id', () async {
      final cid = await _addCustomer(repo);
      final id = await insertDebt(cid, 500);
      expect(id, greaterThan(0));
    });

    test('getById returns correct transaction', () async {
      final cid = await _addCustomer(repo);
      final id = await insertDebt(cid, 100);
      final t = await repo.getById(id);
      expect(t, isNotNull);
      expect(t!.amount, 100);
      expect(t.isDebt, true);
    });

    test('getById returns null for nonexistent', () async {
      expect(await repo.getById(9999), null);
    });
  });

  group('getByCustomer', () {
    test('returns transactions for specific customer', () async {
      final cid1 = await _addCustomer(repo);
      final cid2 = await _addCustomer(repo);
      await insertDebt(cid1, 100);
      await insertDebt(cid1, 200);
      await insertDebt(cid2, 300);
      final results = await repo.getByCustomer(cid1);
      expect(results.length, 2);
    });
  });

  group('getByType', () {
    test('returns only debts', () async {
      final cid = await _addCustomer(repo);
      await insertDebt(cid, 100);
      await insertPayment(cid, 50);
      final debts = await repo.getByType(model.Transaction.debt);
      expect(debts.length, 1);
      expect(debts.first.isDebt, true);
    });

    test('returns only payments', () async {
      final cid = await _addCustomer(repo);
      await insertDebt(cid, 100);
      await insertPayment(cid, 50);
      final payments = await repo.getByType(model.Transaction.payment);
      expect(payments.length, 1);
      expect(payments.first.isPayment, true);
    });
  });

  group('getCustomerBalance', () {
    test('calculates balance = debts - payments', () async {
      final cid = await _addCustomer(repo);
      await insertDebt(cid, 500);
      await insertDebt(cid, 300);
      await insertPayment(cid, 200);
      final balance = await repo.getCustomerBalance(cid);
      expect(balance, 600);
    });

    test('returns 0 for no transactions', () async {
      final cid = await _addCustomer(repo);
      expect(await repo.getCustomerBalance(cid), 0.0);
    });
  });

  group('getTotalDebts & getTotalPayments', () {
    test('sums correctly across customers', () async {
      final cid1 = await _addCustomer(repo);
      final cid2 = await _addCustomer(repo);
      await insertDebt(cid1, 100);
      await insertDebt(cid2, 250);
      await insertPayment(cid1, 50);
      await insertPayment(cid2, 75);
      expect(await repo.getTotalDebts(), 350);
      expect(await repo.getTotalPayments(), 125);
    });
  });

  group('getDebtsWithRemaining', () {
    test('returns debts with remaining > 0', () async {
      final cid = await _addCustomer(repo);
      final debtId = await insertDebt(cid, 500);
      await insertPayment(cid, 200, debtId: debtId);
      final remaining = await repo.getDebtsWithRemaining(cid);
      expect(remaining.length, 1);
      expect(remaining.first['remaining'], 300);
    });

    test('excludes fully paid debts', () async {
      final cid = await _addCustomer(repo);
      final debtId = await insertDebt(cid, 100);
      await insertPayment(cid, 100, debtId: debtId);
      final remaining = await repo.getDebtsWithRemaining(cid);
      expect(remaining, isEmpty);
    });

    test('multiple debts with different payment status', () async {
      final cid = await _addCustomer(repo);
      final d1 = await insertDebt(cid, 500, date: '2025-06-01');
      final d2 = await insertDebt(cid, 300, date: '2025-06-02');
      await insertPayment(cid, 500, debtId: d1);
      await insertPayment(cid, 100, debtId: d2);
      final remaining = await repo.getDebtsWithRemaining(cid);
      expect(remaining.length, 1);
      expect(remaining.first['id'], d2);
      expect(remaining.first['remaining'], 200);
    });
  });

  group('getPaymentsForDebt', () {
    test('sums payments linked to a debt', () async {
      final cid = await _addCustomer(repo);
      final debtId = await insertDebt(cid, 500);
      await insertPayment(cid, 100, debtId: debtId, date: '2025-06-01');
      await insertPayment(cid, 200, debtId: debtId, date: '2025-06-02');
      final total = await repo.getPaymentsForDebt(debtId);
      expect(total, 300);
    });

    test('returns 0 for no payments', () async {
      expect(await repo.getPaymentsForDebt(999), 0.0);
    });
  });

  group('getTotalsByDateRange', () {
    test('returns debts and payments in range', () async {
      final cid = await _addCustomer(repo);
      await insertDebt(cid, 100, date: '2025-06-01');
      await insertDebt(cid, 200, date: '2025-07-01');
      await insertPayment(cid, 50, date: '2025-06-15');
      final totals = await repo.getTotalsByDateRange('2025-06-01', '2025-06-30');
      expect(totals['debts'], 100);
      expect(totals['payments'], 50);
    });

    test('returns 0 for empty range', () async {
      final totals = await repo.getTotalsByDateRange('2030-01-01', '2030-12-31');
      expect(totals['debts'], 0.0);
      expect(totals['payments'], 0.0);
    });
  });

  group('getTopDebtors', () {
    test('returns top debtors by outstanding', () async {
      final cid1 = await _addCustomer(repo);
      final cid2 = await _addCustomer(repo);
      await insertDebt(cid1, 500);
      await insertDebt(cid2, 1000);
      final top = await repo.getTopDebtors(5);
      expect(top.length, 2);
      expect(top.first['name'], 'Customer2');
      expect(top.first['outstanding'], 1000);
    });

    test('respects limit', () async {
      final c1 = await _addCustomer(repo);
      final c2 = await _addCustomer(repo);
      final c3 = await _addCustomer(repo);
      await insertDebt(c1, 100);
      await insertDebt(c2, 200);
      await insertDebt(c3, 300);
      final top = await repo.getTopDebtors(2);
      expect(top.length, 2);
    });
  });

  group('delete', () {
    test('removes transaction', () async {
      final cid = await _addCustomer(repo);
      final id = await insertDebt(cid, 100);
      await repo.delete(id);
      expect(await repo.getById(id), null);
    });
  });

  group('getAll', () {
    test('returns all transactions ordered by date DESC', () async {
      final cid = await _addCustomer(repo);
      await insertDebt(cid, 100, date: '2025-06-01');
      await insertDebt(cid, 200, date: '2025-07-01');
      final all = await repo.getAll();
      expect(all.length, 2);
      expect(all.first.date, '2025-07-01');
    });
  });
}
