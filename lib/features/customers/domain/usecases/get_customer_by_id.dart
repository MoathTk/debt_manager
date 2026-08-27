/// CUSTOMERS FEATURE — DOMAIN LAYER: GET CUSTOMER BY ID USE CASE
///
/// "GetCustomerById" answers: "Who is this specific customer?"
/// Returns null when no (non-deleted) customer carries that id.
/// ---------------------------------------------------------------------------
library;

import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class GetCustomerById {
  final CustomerRepository repo;

  GetCustomerById(this.repo);

  Future<Customer?> call(String id) => repo.getById(id);
}