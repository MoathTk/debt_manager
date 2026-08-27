/// CUSTOMERS FEATURE — PRESENTATION LAYER: ACTIONS
///
/// The write path for customers. These free functions take a
/// [ProviderContainer] so they can be invoked from any widget/sheet/
/// voice-command flow, exactly like the legacy global mutations.
/// Each action: runs the domain use case → invalidates affected
/// providers → schedules a cloud push.
/// ---------------------------------------------------------------------------
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_debt_management/core/sharedProviders/database_provider.dart';
import 'package:local_debt_management/core/sharedProviders/sync_provider.dart';
import 'package:local_debt_management/core/services/auth_service.dart';
import '../../domain/entities/customer.dart';
import 'customer_providers.dart';

String _getOwnerId(ProviderContainer container) {
  return container.read(authServiceProvider).ownerId ?? '';
}

void _invalidateCustomers(ProviderContainer container) {
  container.invalidate(customersProvider);
  container.invalidate(dashboardStatsProvider);
}

Future<void> addCustomer(
  ProviderContainer container, {
  required String name,
  String? phone,
}) async {
  final useCase = container.read(addCustomerUseCaseProvider);
  await useCase.call(name: name, phone: phone, ownerId: _getOwnerId(container));
  _invalidateCustomers(container);
  container.read(syncProvider.notifier).schedulePush();
}

Future<void> updateCustomer(
  ProviderContainer container, {
  required Customer customer,
  required String name,
  String? phone,
}) async {
  final useCase = container.read(updateCustomerUseCaseProvider);
  await useCase.call(customer: customer, name: name, phone: phone);
  container.invalidate(customersProvider);
  container.invalidate(customerByIdProvider(customer.id));
  container.invalidate(dashboardStatsProvider);
  container.read(syncProvider.notifier).schedulePush();
}

/// Soft-deletes the customer and cascades the delete to every
/// transaction and reminder attached to them.
Future<void> deleteCustomer(
  ProviderContainer container,
  String customerId,
) async {
  await container.read(deleteCustomerUseCaseProvider).call(customerId);
  final txRepo = container.read(transactionRepositoryProvider);
  final reminderRepo = container.read(debtReminderRepositoryProvider);
  await txRepo.deleteByCustomerId(customerId);
  await reminderRepo.deleteByCustomerId(customerId);
  _invalidateCustomers(container);
  container.invalidate(transactionsProvider);
  container.invalidate(transactionsByCustomerProvider(customerId));
  container.invalidate(customerBalanceProvider(customerId));
  container.invalidate(debtsWithRemainingProvider(customerId));
  container.invalidate(allRemindersProvider);
  container.invalidate(pendingRemindersProvider);
  container.invalidate(dueTodayProvider);
  container.read(syncProvider.notifier).schedulePush();
}
