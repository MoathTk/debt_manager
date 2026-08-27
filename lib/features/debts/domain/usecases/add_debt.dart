/// DEBTS FEATURE — DOMAIN LAYER: ADD DEBT USE CASE
///
/// "AddDebt" answers: "Record a new debt owed by a customer."
///
/// It assigns an id, timestamps and persists a debt-type [Transaction].
/// The returned transaction is the source of truth for what was saved.
///
/// A companion reminder (if the caller asks for one) is composed at the
/// presentation layer — it lives in the reminders feature.
/// ---------------------------------------------------------------------------
library;

import 'package:local_debt_management/utils/sync_id.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class AddDebt {
  final TransactionRepository repo;
  final String Function() createId;
  final DateTime Function() now;

  AddDebt(this.repo, {String Function()? createId, DateTime Function()? now})
    : createId = createId ?? generateId,
      now = now ?? DateTime.now;

  Future<Transaction> call({
    required String customerId,
    required double amount,
    String? note,
    required String ownerId,
  }) async {
    final timestamp = now().toIso8601String();
    final transaction = Transaction(
      id: createId(),
      customerId: customerId,
      amount: amount,
      type: Transaction.debt,
      note: note,
      date: timestamp,
      ownerId: ownerId,
      updatedAt: timestamp,
    );
    await repo.insert(transaction);
    return transaction;
  }
}
