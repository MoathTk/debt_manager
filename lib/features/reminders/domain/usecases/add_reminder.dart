/// REMINDERS FEATURE — DOMAIN LAYER: ADD REMINDER USE CASE
///
/// "AddReminder" answers: "Schedule a due-date reminder for a customer."
///
/// It assigns an id, timestamps and persists a new [DebtReminder].
/// The returned reminder is the source of truth for what was saved.
/// ---------------------------------------------------------------------------
library;

import 'package:local_debt_management/core/utils/sync_id.dart';
import '../entities/debt_reminder.dart';
import '../repositories/debt_reminder_repository.dart';

class AddReminder {
  final DebtReminderRepository repo;
  final String Function() createId;
  final DateTime Function() now;

  AddReminder(
    this.repo, {
    String Function()? createId,
    DateTime Function()? now,
  }) : createId = createId ?? generateId,
       now = now ?? DateTime.now;

  Future<DebtReminder> call({
    required String customerId,
    required String reminderDate,
    String? debtId,
    String? message,
    required String ownerId,
  }) async {
    final timestamp = now().toIso8601String();
    final reminder = DebtReminder(
      id: createId(),
      customerId: customerId,
      debtId: debtId,
      reminderDate: reminderDate,
      message: message,
      ownerId: ownerId,
      updatedAt: timestamp,
    );
    await repo.insert(reminder);
    return reminder;
  }
}
