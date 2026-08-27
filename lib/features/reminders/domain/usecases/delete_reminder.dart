/// REMINDERS FEATURE — DOMAIN LAYER: DELETE REMINDER USE CASE
///
/// "DeleteReminder" answers: "Remove a single reminder." The repository's
/// `delete` is a soft delete so synced devices can pull the tombstone.
/// ---------------------------------------------------------------------------
library;

import '../repositories/debt_reminder_repository.dart';

class DeleteReminder {
  final DebtReminderRepository repo;

  DeleteReminder(this.repo);

  Future<void> call(String id) async {
    await repo.delete(id);
  }
}