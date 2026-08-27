/// DEBTS FEATURE — PRESENTATION LAYER: PROVIDERS
///
/// Riverpod wiring for the debts feature. Exposes the repository
/// (so the app can construct it once) plus:
///   - [transactionRepositoryProvider] → single entry point to the feature
///   - the read providers the UI watches (all transactions, per customer,
///     balances, unsettled debts, per-debt payments)
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
import '../../../../features/customers/presentation/providers/customer_providers.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/usecases/add_debt.dart';
import '../../domain/usecases/delete_debt.dart';
import '../../domain/usecases/delete_transaction.dart';
import '../../domain/usecases/record_payment.dart';
import '../../domain/usecases/settle_debt.dart';
import '../../domain/usecases/update_transaction.dart';

/// Single entry point to the debts data source.
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepositoryImpl();
});

final _ownerIdProvider = Provider<String>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  return user?.uid ?? '';
});

/// All non-deleted transactions, newest first (owner-scoped when signed in).
final transactionsProvider = FutureProvider<List<Transaction>>((ref) async {
  final repo = ref.watch(transactionRepositoryProvider);
  final ownerId = ref.watch(_ownerIdProvider);
  return repo.getAll(ownerId: ownerId.isEmpty ? null : ownerId);
});

/// A single customer's transactions; empty when not owned by the user.
final transactionsByCustomerProvider = FutureProvider.autoDispose
    .family<List<Transaction>, String>((ref, customerId) async {
      final repo = ref.watch(transactionRepositoryProvider);
      final customerRepo = ref.watch(customerRepositoryProvider);
      final ownerId = ref.watch(_ownerIdProvider);
      if (ownerId.isNotEmpty) {
        final customer = await customerRepo.getById(customerId);
        if (customer == null || customer.ownerId != ownerId) {
          return [];
        }
      }
      return repo.getByCustomer(customerId);
    });

/// Net balance (debts − payments) for a customer.
final customerBalanceProvider = FutureProvider.family<double, String>((
  ref,
  customerId,
) async {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getCustomerBalance(customerId);
});

/// Unsettled debts (id, amount, note, date, remaining) for a customer.
final debtsWithRemainingProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, customerId) async {
      final repo = ref.watch(transactionRepositoryProvider);
      return repo.getDebtsWithRemaining(customerId);
    });

/// All payments recorded against a single debt.
final paymentsByDebtProvider = FutureProvider.autoDispose
    .family<List<Transaction>, String>((ref, debtId) async {
      final repo = ref.watch(transactionRepositoryProvider);
      return repo.getPaymentsByDebtId(debtId);
    });

// ---- USE CASES ----

final addDebtUseCaseProvider = Provider<AddDebt>((ref) {
  return AddDebt(ref.watch(transactionRepositoryProvider));
});

final recordPaymentUseCaseProvider = Provider<RecordPayment>((ref) {
  return RecordPayment(ref.watch(transactionRepositoryProvider));
});

final updateTransactionUseCaseProvider = Provider<UpdateTransaction>((ref) {
  return UpdateTransaction(ref.watch(transactionRepositoryProvider));
});

final deleteTransactionUseCaseProvider = Provider<DeleteTransaction>((ref) {
  return DeleteTransaction(ref.watch(transactionRepositoryProvider));
});

final deleteDebtUseCaseProvider = Provider<DeleteDebt>((ref) {
  return DeleteDebt(ref.watch(transactionRepositoryProvider));
});

final settleDebtUseCaseProvider = Provider<SettleDebt>((ref) {
  return SettleDebt(ref.watch(transactionRepositoryProvider));
});
