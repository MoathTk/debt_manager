/// CUSTOMERS FEATURE — DOMAIN LAYER: REPOSITORY INTERFACE
///
/// This is the "contract" that the data layer must implement.
/// The domain layer says: "I need to read/write customers, but I don't
/// care HOW — SQLite? Firestore? HTTP? I don't know."
///
/// This is the Dependency Inversion Principle (D):
/// - Domain defines the interface
/// - Data layer implements it
/// - Use cases depend on the interface, not the implementation
///
/// ARCHITECTURE RULE: This file must never import from data/ or presentation/.
/// ---------------------------------------------------------------------------
library;

import '../entities/customer.dart';

abstract class CustomerRepository {
  /// Persist a new customer.
  Future<void> insert(Customer customer);

  /// Update an existing customer's fields.
  Future<void> update(Customer customer);

  /// Soft-delete a customer by id.
  Future<void> delete(String id);

  /// All non-deleted customers, newest first. Optionally scoped to an owner.
  Future<List<Customer>> getAll({String? ownerId});

  /// Look up a single non-deleted customer by id, null if not found.
  Future<Customer?> getById(String id);

  /// Case-insensitive search over name and phone. Optionally scoped to an owner.
  Future<List<Customer>> search(String query, {String? ownerId});

  /// Count non-deleted customers. Optionally scoped to an owner.
  Future<int> getCustomerCount({String? ownerId});
}