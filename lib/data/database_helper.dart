import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Singleton helper class for managing the SQLite database.
///
/// This class handles:
/// - Database initialization and creation
/// - Table creation with proper schema
/// - Index creation for query performance
/// - Database lifecycle management (open/close)
///
/// Uses singleton pattern to ensure only one database connection exists.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// Returns the database instance, creating it if necessary.
  /// This is the main entry point for all database operations.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('debt_management.db');
    return _database!;
  }

  /// Initializes the database file and sets up the schema.
  /// The [onCreate] callback is called only when the database is first created.
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  /// Creates all database tables and indexes.
  /// This is called automatically when the database file is first created.
  ///
  /// Tables created:
  /// - customers: Stores customer information
  /// - transactions: Logs all financial movements (debts and payments)
  /// - debt_reminders: Schedules debt collection follow-ups
  ///
  /// Foreign keys use CASCADE DELETE to maintain referential integrity.
  /// Deleting a customer automatically removes all their transactions and reminders.
  Future<void> _createDB(Database db, int version) async {
    // Create customers table
    // - id: Auto-incrementing primary key
    // - name: Customer's full name (required)
    // - phone: Customer's phone number (optional, can be null)
    // - created_at: Timestamp when customer was added (ISO 8601 format)
    // - firebase_id: Reserved for future cloud sync with Firebase
    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        created_at TEXT NOT NULL,
        firebase_id TEXT
      )
    ''');

    // Create transactions table
    // - id: Auto-incrementing primary key
    // - customer_id: Foreign key to customers table (cascade delete)
    // - amount: Transaction amount (always positive)
    // - type: 0 = Debt (money owed), 1 = Payment (money received)
    // - note: Optional description of the transaction
    // - date: Transaction date (ISO 8601 format)
    // - firebase_id: Reserved for future cloud sync with Firebase
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

    // Create debt_reminders table
    // - id: Auto-incrementing primary key
    // - customer_id: Foreign key to customers table (cascade delete)
    // - reminder_date: When the reminder is due (ISO 8601 format)
    // - is_completed: 0 = pending, 1 = completed
    // - message: Optional reminder message/description
    await db.execute('''
      CREATE TABLE debt_reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL,
        reminder_date TEXT NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        message TEXT,
        FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for performance optimization
    // These speed up queries that filter by customer_id or type/date
    await db.execute('''
      CREATE INDEX idx_transactions_customer_id ON transactions (customer_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_transactions_type ON transactions (type)
    ''');

    await db.execute('''
      CREATE INDEX idx_debt_reminders_customer_id ON debt_reminders (customer_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_debt_reminders_date ON debt_reminders (reminder_date)
    ''');
  }

  /// Closes the database connection and resets the singleton.
  /// Should be called when the app is shutting down or when testing.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE transactions ADD COLUMN debt_id INTEGER');
    }
  }

  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }
}
