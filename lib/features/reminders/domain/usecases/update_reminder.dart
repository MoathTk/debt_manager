/// REMINDERS FEATURE — DOMAIN LAYER: UPDATE REMINDER USE CASE
///
/// "UpdateReminder" answers: "Change an existing reminder's fields"
/// (e.g. a new due date or message). It receives the fully-built
/// [DebtReminder] to persist.
/// ---------------------------------------------------------------------------
library;

import '../entities/debt_reminder.dart';
import '../repositories/debt_reminder_repository.dart';

class UpdateReminder {
  final DebtReminderRepository repo;

  UpdateReminder(this.repo);

  Future<void> call(DebtReminder reminder) async {
    await repo.update(reminder);
  }
}