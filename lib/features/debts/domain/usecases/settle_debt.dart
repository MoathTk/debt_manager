/// DEBTS FEATURE — DOMAIN LAYER: SETTLE DEBT USE CASE
///
/// "SettleDebt" answers: "Close out a debt right now by recording a
/// payment for (at least) its full outstanding amount." The payment is
/// linked to the debt so the balance and history stay correct.
/// ---------------------------------------------------------------------------
library;

import 'package:local_debt_management/core/utils/sync_id.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class SettleDebt {
  final TransactionRepository repo;
  final String Function() createId;
  final DateTime Function() now;

  SettleDebt(this.repo, {String Function()? createId, DateTime Function()? now})
    : createId = createId ?? generateId,
      now = now ?? DateTime.now;

  Future<Transaction> call({
    required String customerId,
    required double amount,
    String? note,
    required String debtId,
    required String ownerId,
  }) async {
    final timestamp = now().toIso8601String();
    final transaction = Transaction(
      id: createId(),
      customerId: customerId,
      amount: amount,
      type: Transaction.payment,
      note: note ?? 'Settle',
      date: timestamp,
      debtId: debtId,
      ownerId: ownerId,
      updatedAt: timestamp,
    );
    await repo.insert(transaction);
    return transaction;
  }
}
