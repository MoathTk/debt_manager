/// CUSTOMERS FEATURE — PRESENTATION LAYER: PROVIDERS
///
/// Riverpod wiring for the customers feature. Exposes the repository
/// (so the app can construct it once) plus:
///   - [customersProvider]      → full list (owner-scoped when signed in)
///   - [customerByIdProvider]   → single customer (ownership-checked)
///   - the use cases as providers, so widgets and actions depend on
///     behaviour, never on the concrete repository/SQLite.
///
/// OWNERSHIP: when a user is signed in, lists are filtered to that
/// owner's records and cross-owner reads return null/empty. This is the
/// exact behaviour that lived in the global database_provider before the
/// feature extraction.
/// ---------------------------------------------------------------------------
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_debt_management/core/services/auth_service.dart';
import '../../../../utils/sync_id.dart';
import '../../data/repositories/customer_repository_impl.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../domain/usecases/add_customer.dart';
import '../../domain/usecases/delete_customer.dart';
import '../../domain/usecases/get_customer_by_id.dart';
import '../../domain/usecases/get_customers.dart';
import '../../domain/usecases/search_customers.dart';
import '../../domain/usecases/update_customer.dart';

/// Single entry point to the customers data source.
final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepositoryImpl();
});

final _ownerIdProvider = Provider<String>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  return user?.uid ?? '';
});

/// All non-deleted customers, newest first.
final customersProvider = FutureProvider<List<Customer>>((ref) async {
  final repo = ref.watch(customerRepositoryProvider);
  final ownerId = ref.watch(_ownerIdProvider);
  return repo.getAll(ownerId: ownerId.isEmpty ? null : ownerId);
});

/// A single customer; returns null when not found or owned by someone else.
final customerByIdProvider = FutureProvider.family<Customer?, String>((
  ref,
  id,
) async {
  final repo = ref.watch(customerRepositoryProvider);
  final ownerId = ref.watch(_ownerIdProvider);
  final customer = await repo.getById(id);
  if (customer != null && ownerId.isNotEmpty && customer.ownerId != ownerId) {
    return null;
  }
  return customer;
});

// ---- USE CASES ----

final getCustomersUseCaseProvider = Provider<GetCustomers>((ref) {
  return GetCustomers(ref.watch(customerRepositoryProvider));
});

final getCustomerByIdUseCaseProvider = Provider<GetCustomerById>((ref) {
  return GetCustomerById(ref.watch(customerRepositoryProvider));
});

final searchCustomersUseCaseProvider = Provider<SearchCustomers>((ref) {
  return SearchCustomers(ref.watch(customerRepositoryProvider));
});

final addCustomerUseCaseProvider = Provider<AddCustomer>((ref) {
  return AddCustomer(
    ref.watch(customerRepositoryProvider),
    createId: generateId,
  );
});

final updateCustomerUseCaseProvider = Provider<UpdateCustomer>((ref) {
  return UpdateCustomer(ref.watch(customerRepositoryProvider));
});

final deleteCustomerUseCaseProvider = Provider<DeleteCustomer>((ref) {
  return DeleteCustomer(ref.watch(customerRepositoryProvider));
});
