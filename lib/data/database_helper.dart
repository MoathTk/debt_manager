import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../utils/sync_id.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  String? _currentUid;

  DatabaseHelper._init();

  static set testDatabase(Database db) => _database = db;

  Future<Database> get database async {
    if (_database != null) return _database!;
    return _openDb(_currentUid ?? 'default');
  }

  /// Opens the database for [uid].
  /// Each user gets their own file: debt_management_{uid}.db
  Future<void> init(String uid) async {
    if (_currentUid == uid && _database != null) return;
    await close();
    _currentUid = uid;
    _database = await _openDb(uid);
    await _migrateFromSharedDb(_database!);
    await _cleanupOrphanRecords(_database!);
  }

  Future<Database> _openDb(String uid) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'debt_management_$uid.db');
    return openDatabase(
      path,
      version: 8,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  /// Closes the current database. Called on sign-out.
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    _currentUid = null;
  }

  Future<void> _createDB(Database db, int version) async {
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

    await db.execute(
      'CREATE INDEX idx_transactions_customer_id ON transactions (customer_id)',
    );
    await db.execute(
      'CREATE INDEX idx_transactions_type ON transactions (type)',
    );
    await db.execute(
      'CREATE INDEX idx_debt_reminders_customer_id ON debt_reminders (customer_id)',
    );
    await db.execute(
      'CREATE INDEX idx_debt_reminders_date ON debt_reminders (reminder_date)',
    );

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

  Future<void> _onUpgrade(
    Database db, int oldVersion, int newVersion,
  ) async {
    if (oldVersion < 4) {
      final customers = await db.query('customers');
      final transactions = await db.query('transactions');
      final reminders = await db.query('debt_reminders');

      final customerMap = <int, String>{};
      final debtMap = <int, String>{};

      await db.execute('DROP TABLE IF EXISTS debt_reminders');
      await db.execute('DROP TABLE IF EXISTS transactions');
      await db.execute('DROP TABLE IF EXISTS customers');

      await _createDB(db, 6);

      for (final c in customers) {
        final newId = generateId();
        customerMap[c['id'] as int] = newId;
        await db.insert('customers', {
          'id': newId,
          'name': c['name'],
          'phone': c['phone'],
          'created_at': c['created_at'],
          'is_synced': 0,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

      for (final t in transactions) {
        final newId = generateId();
        final oldId = t['id'] as int;
        final newCustId = customerMap[t['customer_id'] as int] ?? '';
        final oldDebtId = t['debt_id'] as int?;
        final newDebtId = oldDebtId != null ? debtMap[oldDebtId] : null;
        debtMap[oldId] = newId;

        await db.insert('transactions', {
          'id': newId,
          'customer_id': newCustId,
          'amount': t['amount'],
          'type': t['type'],
          'note': t['note'],
          'date': t['date'],
          'debt_id': newDebtId,
          'is_synced': 0,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

      for (final r in reminders) {
        final newId = generateId();
        final newCustId = customerMap[r['customer_id'] as int] ?? '';
        final oldDebtId = r['debt_id'] as int?;
        final newDebtId = oldDebtId != null ? debtMap[oldDebtId] : null;

        await db.insert('debt_reminders', {
          'id': newId,
          'customer_id': newCustId,
          'debt_id': newDebtId,
          'reminder_date': r['reminder_date'],
          'is_completed': r['is_completed'],
          'message': r['message'],
          'is_synced': 0,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    }

    if (oldVersion < 5) {
      await db.execute(
        "ALTER TABLE customers ADD COLUMN owner_id TEXT NOT NULL DEFAULT ''",
      );
      await db.execute(
        "ALTER TABLE transactions ADD COLUMN owner_id TEXT NOT NULL DEFAULT ''",
      );
      await db.execute(
        "ALTER TABLE debt_reminders ADD COLUMN owner_id TEXT NOT NULL DEFAULT ''",
      );
    }

    if (oldVersion < 6) {
      await db.execute(
        "ALTER TABLE customers ADD COLUMN is_deleted INTEGER NOT NULL DEFAULT 0",
      );
      await db.execute(
        "ALTER TABLE transactions ADD COLUMN is_deleted INTEGER NOT NULL DEFAULT 0",
      );
      await db.execute(
        "ALTER TABLE debt_reminders ADD COLUMN is_deleted INTEGER NOT NULL DEFAULT 0",
      );
    }

    if (oldVersion < 7) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS user_subscription (
          user_id TEXT PRIMARY KEY,
          plan TEXT NOT NULL,
          expires_at TEXT NOT NULL,
          activated_at TEXT NOT NULL,
          is_active INTEGER NOT NULL DEFAULT 1
        )
      ''');
    }
  }

  Future<void> _cleanupOrphanRecords(Database db) async {
    await db.delete('customers', where: 'id IS NULL');
    await db.delete('transactions', where: 'id IS NULL');
    await db.delete('debt_reminders', where: 'id IS NULL');
  }

  /// One-time migration: copies data from the old shared debt_management.db
  /// to the current per-user database, then deletes the old file.
  Future<void> _migrateFromSharedDb(Database targetDb) async {
    final dbPath = await getDatabasesPath();
    final sharedPath = join(dbPath, 'debt_management.db');
    if (!await File(sharedPath).exists()) return;

    Database? sharedDb;
    try {
      sharedDb = await openDatabase(sharedPath, version: 8);
      final db = sharedDb;
      final customers = await db.query('customers');
      if (customers.isEmpty) return;

      final txnCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM transactions'),
      );
      if (txnCount == null || txnCount == 0) return;

      await targetDb.transaction((txn) async {
        for (final c in customers) {
          await txn.insert('customers', c, conflictAlgorithm: ConflictAlgorithm.replace);
        }
        final transactions = await db.query('transactions');
        for (final t in transactions) {
          await txn.insert('transactions', t, conflictAlgorithm: ConflictAlgorithm.replace);
        }
        final reminders = await db.query('debt_reminders');
        for (final r in reminders) {
          await txn.insert('debt_reminders', r, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      });
    } catch (_) {
      return;
    } finally {
      await sharedDb?.close();
      try {
        await File(sharedPath).delete();
      } catch (_) {}
    }
  }
}
