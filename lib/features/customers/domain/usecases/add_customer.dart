/// CUSTOMERS FEATURE — DOMAIN LAYER: ADD CUSTOMER USE CASE
///
/// "AddCustomer" answers: "Create this customer for me."
///
/// It validates the input (a name is mandatory), assigns an id and
/// timestamps, and asks the repository to persist it. The returned
/// customer is the source of truth for what was actually saved.
///
/// TIMESTAMPS: generated here (moved from the presentation layer) so
/// the domain owns the "created at / updated at" business rule.
/// ---------------------------------------------------------------------------
library;

import 'package:local_debt_management/utils/sync_id.dart';
import '../entities/customer.dart';
import '../exceptions/customer_exception.dart';
import '../repositories/customer_repository.dart';

class AddCustomer {
  final CustomerRepository repo;
  final String Function() createId;
  final DateTime Function() now;

  AddCustomer(this.repo, {String Function()? createId, DateTime Function()? now})
    : createId = createId ?? generateId,
      now = now ?? DateTime.now;

  Future<Customer> call({
    required String name,
    String? phone,
    required String ownerId,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const CustomerValidationException('name must not be empty');
    }
    final timestamp = now().toIso8601String();
    final customer = Customer(
      id: createId(),
      name: trimmed,
      phone: phone?.trim().isEmpty == true ? null : phone?.trim(),
      createdAt: timestamp,
      ownerId: ownerId,
      updatedAt: timestamp,
    );
    await repo.insert(customer);
    return customer;
  }
}