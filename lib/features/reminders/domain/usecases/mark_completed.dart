/// REMINDERS FEATURE — DOMAIN LAYER: MARK COMPLETED USE CASE
///
/// "MarkCompleted" answers: "Flag a reminder as done so it disappears
/// from the pending views." Settling the underlying debt (when the
/// reminder is attached to one) is composed at the presentation layer —
/// it lives in the debts feature.
/// ---------------------------------------------------------------------------
library;

import '../repositories/debt_reminder_repository.dart';

class MarkCompleted {
  final DebtReminderRepository repo;

  MarkCompleted(this.repo);

  Future<void> call(String id) async {
    await repo.markCompleted(id);
  }
}