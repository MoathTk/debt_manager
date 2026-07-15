import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:local_debt_management/data/database_helper.dart';

/// Initializes sqflite_ffi for desktop testing and creates an in-memory
/// database with the full v6 schema. Assigns it to [DatabaseHelper.testDatabase].
Future<Database> setupTestDb() async {
  sqfliteFfiInit();
  final db = await databaseFactoryFfi.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      version: 6,
      onCreate: (db, version) async {
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
        await db.execute('CREATE INDEX idx_transactions_customer_id ON transactions (customer_id)');
        await db.execute('CREATE INDEX idx_transactions_type ON transactions (type)');
        await db.execute('CREATE INDEX idx_debt_reminders_customer_id ON debt_reminders (customer_id)');
        await db.execute('CREATE INDEX idx_debt_reminders_date ON debt_reminders (reminder_date)');
      },
    ),
  );
  await db.execute('PRAGMA foreign_keys = ON');
  DatabaseHelper.testDatabase = db;
  return db;
}
