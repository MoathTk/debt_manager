/// DEBTS FEATURE — DOMAIN LAYER: DELETE TRANSACTION USE CASE
///
/// "DeleteTransaction" answers: "Remove a single transaction
/// (soft-delete; tombstones are kept for sync)."
/// ---------------------------------------------------------------------------
library;

import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class DeleteTransaction {
  final TransactionRepository repo;

  DeleteTransaction(this.repo);

  Future<Transaction?> call(String id) async {
    final transaction = await repo.getById(id);
    await repo.delete(id);
    return transaction;
  }
}
