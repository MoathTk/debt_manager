/// REMINDERS FEATURE — DOMAIN LAYER: REPOSITORY INTERFACE
///
/// This is the "contract" that the data layer must implement.
/// The domain layer says: "I need to read/write reminders, but I don't
/// care HOW — SQLite? Firestore? HTTP? I don't know."
///
/// This is the Dependency Inversion Principle (D):
/// - Domain defines the interface
/// - Data layer implements it
/// - Use cases depend on the interface, not the implementation
///
/// ARCHITECTURE RULE: This file must never import from data/ or presentation/.
///
/// The offline→online sync helpers (getUnsynced/markSynced/upsertFromCloud)
/// intentionally do NOT appear here — they belong to the datasource, which
/// the cloud sync service talks to directly.
/// ---------------------------------------------------------------------------
library;

import '../entities/debt_reminder.dart';

abstract class DebtReminderRepository {
  /// Persist a new reminder.
  Future<int> insert(DebtReminder reminder);

  /// Update an existing reminder's fields.
  Future<int> update(DebtReminder reminder);

  /// Soft-delete a reminder by id.
  Future<int> delete(String id);

  /// Soft-delete several reminders by id.
  Future<void> deleteBatch(List<String> ids);

  /// Soft-delete every reminder attached to a debt.
  Future<void> deleteByDebtId(String debtId);

  /// Soft-delete every reminder attached to a customer.
  Future<void> deleteByCustomerId(String customerId);

  /// All non-deleted reminders, nearest date first.
  Future<List<DebtReminder>> getAll({String? ownerId});

  /// Look up a single non-deleted reminder by id, null if not found.
  Future<DebtReminder?> getById(String id);

  /// All non-deleted reminders for a customer, nearest date first.
  Future<List<DebtReminder>> getByCustomer(String customerId);

  /// All non-deleted, not-yet-completed reminders. Optionally owner-scoped.
  Future<List<DebtReminder>> getPending({String? ownerId});

  /// All non-deleted, completed reminders. Optionally owner-scoped.
  Future<List<DebtReminder>> getCompleted({String? ownerId});

  /// Flag a reminder as completed.
  Future<int> markCompleted(String id);

  /// Flag a completed reminder back to pending.
  Future<int> markPending(String id);

  /// Non-deleted, pending reminders due on or before a date (default today).
  Future<List<DebtReminder>> getDueToday({String? date});

  /// Count of non-deleted, pending reminders. Optionally owner-scoped.
  Future<int> getPendingCount({String? ownerId});
}