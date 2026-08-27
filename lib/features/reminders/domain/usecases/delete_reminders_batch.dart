/// REMINDERS FEATURE — DOMAIN LAYER: DELETE REMINDERS BATCH USE CASE
///
/// "DeleteRemindersBatch" answers: "Remove several reminders at once"
/// (used by clear-all flows).
/// ---------------------------------------------------------------------------
library;

import '../repositories/debt_reminder_repository.dart';

class DeleteRemindersBatch {
  final DebtReminderRepository repo;

  DeleteRemindersBatch(this.repo);

  Future<void> call(List<String> ids) async {
    await repo.deleteBatch(ids);
  }
}