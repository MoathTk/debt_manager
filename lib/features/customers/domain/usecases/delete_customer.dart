/// CUSTOMERS FEATURE — DOMAIN LAYER: DELETE CUSTOMER USE CASE
///
/// "DeleteCustomer" answers: "Remove this customer and everything
/// attached to them (transactions + reminders)."
///
/// The repository's `delete` is a soft delete; cascading the dependent
/// records is delegated to the data layer so the domain keeps the rule
/// ("a deleted customer has no transactions or reminders") in one place.
/// ---------------------------------------------------------------------------
library;

import '../repositories/customer_repository.dart';

class DeleteCustomer {
  final CustomerRepository repo;

  DeleteCustomer(this.repo);

  Future<void> call(String id) => repo.delete(id);
}