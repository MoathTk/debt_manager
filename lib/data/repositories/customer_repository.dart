import '../database_helper.dart';
import '../models/customer.dart';

/// Repository class for Customer CRUD operations.
///
/// Handles all database interactions related to customers.
/// Uses [DatabaseHelper] singleton to access the SQLite database.
/// 
/// All methods are async and return Future-based results.
class CustomerRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Inserts a new customer into the database.
  /// Returns the auto-generated ID of the newly created customer.
  Future<int> insert(Customer customer) async {
    final db = await _dbHelper.database;
    return await db.insert('customers', customer.toMap());
  }

  /// Updates an existing customer in the database.
  /// Matches by customer.id and returns the number of affected rows.
  Future<int> update(Customer customer) async {
    final db = await _dbHelper.database;
    return await db.update(
      'customers',
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  /// Deletes a customer from the database by ID.
  /// Due to CASCADE DELETE, this also removes all associated
  /// transactions and debt reminders for this customer.
  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Retrieves all customers from the database.
  /// Results are ordered by creation date (newest first).
  Future<List<Customer>> getAll() async {
    final db = await _dbHelper.database;
    final result = await db.query('customers', orderBy: 'created_at DESC');
    return result.map((map) => Customer.fromMap(map)).toList();
  }

  /// Retrieves a single customer by their ID.
  /// Returns null if no customer is found with the given ID.
  Future<Customer?> getById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Customer.fromMap(result.first);
  }

  /// Searches customers by name or phone number.
  /// Uses LIKE for partial matching (case-insensitive on most systems).
  /// Handles null phone values safely with NULL check.
  /// Escapes LIKE wildcards in user input to prevent unintended matches.
  Future<List<Customer>> search(String query) async {
    final db = await _dbHelper.database;
    final escaped = query.replaceAll('%', '\\%').replaceAll('_', '\\_');
    final result = await db.query(
      'customers',
      where: 'name LIKE ? ESCAPE \'\\\' OR (phone IS NOT NULL AND phone LIKE ? ESCAPE \'\\\')',
      whereArgs: ['%$escaped%', '%$escaped%'],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Customer.fromMap(map)).toList();
  }

  /// Returns the total number of customers in the database.
  /// Useful for dashboard statistics.
  Future<int> getCustomerCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM customers');
    return result.first['count'] as int;
  }
}
