/// DEBTS FEATURE — DOMAIN LAYER: DELETE DEBT USE CASE
///
/// "DeleteDebt" answers: "Remove a debt and every payment recorded
/// against it." Both rows are soft-deleted so synced devices can pull
/// the tombstones. Assigned reminders are cleaned up by the caller
/// (the reminders feature owns that table).
/// ---------------------------------------------------------------------------
library;

import '../repositories/transaction_repository.dart';

class DeleteDebt {
  final TransactionRepository repo;

  DeleteDebt(this.repo);

  Future<void> call(String debtId) async {
    await repo.delete(debtId);
    await repo.deletePaymentsByDebtId(debtId);
  }
}
