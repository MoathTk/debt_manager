/// DEBTS FEATURE — DOMAIN LAYER: UPDATE TRANSACTION USE CASE
///
/// "UpdateTransaction" answers: "Change the amount and/or note of an
/// existing transaction." The id, customer, type, date and linkage are
/// preserved; only amount + note change, and updated_at is stamped.
/// ---------------------------------------------------------------------------
library;

import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class UpdateTransaction {
  final TransactionRepository repo;
  final DateTime Function() now;

  UpdateTransaction(this.repo, {DateTime Function()? now})
    : now = now ?? DateTime.now;

  Future<Transaction> call({
    required Transaction transaction,
    required double amount,
    String? note,
  }) async {
    final updated = Transaction(
      id: transaction.id,
      customerId: transaction.customerId,
      amount: amount,
      type: transaction.type,
      note: note,
      date: transaction.date,
      debtId: transaction.debtId,
      ownerId: transaction.ownerId,
      updatedAt: now().toIso8601String(),
    );
    await repo.update(updated);
    return updated;
  }
}
