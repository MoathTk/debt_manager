/// CUSTOMERS FEATURE — DOMAIN LAYER: GET CUSTOMERS USE CASE
///
/// "GetCustomers" answers: "Give me all customers I can see."
/// Optionally scoped to an owner id so multi-account installs never
/// leak one account's customers into another.
/// ---------------------------------------------------------------------------
library;

import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class GetCustomers {
  final CustomerRepository repo;

  GetCustomers(this.repo);

  Future<List<Customer>> call({String? ownerId}) {
    return repo.getAll(ownerId: ownerId);
  }
}