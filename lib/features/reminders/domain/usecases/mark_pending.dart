/// REMINDERS FEATURE — DOMAIN LAYER: MARK PENDING USE CASE
///
/// "MarkPending" answers: "Re-open a completed reminder so it shows up
/// in the pending views again."
/// ---------------------------------------------------------------------------
library;

import '../repositories/debt_reminder_repository.dart';

class MarkPending {
  final DebtReminderRepository repo;

  MarkPending(this.repo);

  Future<void> call(String id) async {
    await repo.markPending(id);
  }
}