/// DEBTS FEATURE — DOMAIN LAYER: RECORD PAYMENT USE CASE
///
/// "RecordPayment" answers: "A customer paid part of (or all of) their
/// debt — persist that payment."
///
/// It assigns an id, timestamps and persists a payment-type [Transaction]
/// optionally linked back to the debt being repaid via `debtId`.
/// ---------------------------------------------------------------------------
library;

import 'package:local_debt_management/utils/sync_id.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class RecordPayment {
  final TransactionRepository repo;
  final String Function() createId;
  final DateTime Function() now;

  RecordPayment(
    this.repo, {
    String Function()? createId,
    DateTime Function()? now,
  }) : createId = createId ?? generateId,
       now = now ?? DateTime.now;

  Future<Transaction> call({
    required String customerId,
    required double amount,
    String? note,
    String? debtId,
    required String ownerId,
  }) async {
    final timestamp = now().toIso8601String();
    final transaction = Transaction(
      id: createId(),
      customerId: customerId,
      amount: amount,
      type: Transaction.payment,
      note: note,
      date: timestamp,
      debtId: debtId,
      ownerId: ownerId,
      updatedAt: timestamp,
    );
    await repo.insert(transaction);
    return transaction;
  }
}
