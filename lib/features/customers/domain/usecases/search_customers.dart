/// CUSTOMERS FEATURE — DOMAIN LAYER: SEARCH CUSTOMERS USE CASE
///
/// "SearchCustomers" answers: "Which customers match this text?"
/// Used by the list search bar and the voice-command matcher.
/// Delegates the escaping of LIKE wildcards to the data layer.
/// ---------------------------------------------------------------------------
library;

import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class SearchCustomers {
  final CustomerRepository repo;

  SearchCustomers(this.repo);

  Future<List<Customer>> call(String query, {String? ownerId}) {
    return repo.search(query, ownerId: ownerId);
  }
}