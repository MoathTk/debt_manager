/// CUSTOMERS FEATURE — DOMAIN LAYER: UPDATE CUSTOMER USE CASE
///
/// "UpdateCustomer" answers: "Refresh this customer's details."
/// Preserves identity and ownership; only name and phone change from
/// the outside, and the updated-at timestamp is bumped.
/// ---------------------------------------------------------------------------
library;

import '../entities/customer.dart';
import '../exceptions/customer_exception.dart';
import '../repositories/customer_repository.dart';

class UpdateCustomer {
  final CustomerRepository repo;
  final DateTime Function() now;

  UpdateCustomer(this.repo, {DateTime Function()? now})
    : now = now ?? DateTime.now;

  Future<Customer> call({
    required Customer customer,
    required String name,
    String? phone,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const CustomerValidationException('name must not be empty');
    }
    final updated = customer.copyWith(
      name: trimmed,
      phone: phone?.trim().isEmpty == true ? null : phone?.trim(),
      updatedAt: now().toIso8601String(),
    );
    await repo.update(updated);
    return updated;
  }
}