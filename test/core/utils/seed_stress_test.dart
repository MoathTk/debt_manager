import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:local_debt_management/data/database_helper.dart';
import 'package:local_debt_management/core/utils/seed_database.dart';

/// Verifies [SeedDatabase.seedStressData] inserts the expected volume and
/// leaves the database internally consistent (foreign keys, variety flags).
void main() {
  test('seedStressData seeds volume + variety across all tables', () async {
    sqfliteFfiInit();
    final db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(version: 1, onCreate: _createSchema),
    );
    await db.execute('PRAGMA foreign_keys = ON');
    DatabaseHelper.testDatabase = db;

    final res = await SeedDatabase.seedStressData(
      ownerId: 'u1',
      customerCount: 100,
      randomSeed: 42,
    );

    expect(res.customerCount, 100);
    expect(res.transactionCount, greaterThanOrEqualTo(150));
    expect(res.reminderCount, (100 * 2.4).round());
    expect(res.subscriptionCount, 3);

    final customers = await db.query('customers');
    final txns = await db.query('transactions');
    final reminders = await db.query('debt_reminders');
    final subs = await db.query('user_subscription');

    expect(customers.length, 100);
    expect(txns.length, res.transactionCount);
    expect(reminders.length, res.reminderCount);
    expect(subs.length, 3);

    expect(customers.where((c) => c['is_deleted'] == 1).length,
        greaterThan(0),
        reason: 'deleted-customer subset should exist');
    expect(customers.where((c) => c['phone'] == null).length, greaterThan(0),
        reason: 'missing phone subset should exist');
    expect(customers.where((c) => c['is_synced'] == 0).length, greaterThan(0),
        reason: 'unsynced subset should exist');

    expect(txns.where((t) => t['type'] == 1 && t['debt_id'] != null).length,
        greaterThan(0),
        reason: 'some payments should link to a debt');
    expect(txns.where((t) => t['type'] == 1 && t['debt_id'] == null).length,
        greaterThan(0),
        reason: 'some payments should be unlinked');

    expect(reminders.where((r) => r['is_completed'] == 1).length,
        greaterThan(0),
        reason: 'completed reminders subset should exist');
    expect(reminders.where((r) => r['debt_id'] == null).length, greaterThan(0),
        reason: 'customer-level reminders should exist');

    final active =
        subs.singleWhere((s) => s['user_id'] == 'u1');
    expect(active['plan'], 'monthly');
    expect(active['is_active'], 1);
    expect(res.checks['owed_customers'], isNotNull);
    expect(res.checks['settled_customers'], isNotNull);
    expect(res.checks['overpaid_customers'], isNotNull);

    await db.close();
  });
}

Future<void> _createSchema(Database db, int version) async {
  await db.execute('''
    CREATE TABLE customers (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      phone TEXT,
      created_at TEXT NOT NULL,
      owner_id TEXT NOT NULL DEFAULT '',
      is_synced INTEGER DEFAULT 0,
      is_deleted INTEGER NOT NULL DEFAULT 0,
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
      is_deleted INTEGER NOT NULL DEFAULT 0,
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
      is_deleted INTEGER NOT NULL DEFAULT 0,
      updated_at TEXT,
      FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE CASCADE,
      FOREIGN KEY (debt_id) REFERENCES transactions (id) ON DELETE SET NULL
    )
  ''');
  await db.execute('''
    CREATE TABLE user_subscription (
      user_id TEXT PRIMARY KEY,
      plan TEXT NOT NULL,
      expires_at TEXT NOT NULL,
      activated_at TEXT NOT NULL,
      is_active INTEGER NOT NULL DEFAULT 1
    )
  ''');
}