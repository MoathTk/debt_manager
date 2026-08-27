/// REMINDERS FEATURE — DOMAIN LAYER: DEBT REMINDER ENTITY
///
/// The core business object of the reminders feature: a single due-date
/// reminder attached to a customer (and optionally to a specific debt).
///
/// ARCHITECTURE RULE: This file must never import from data/ or
/// presentation/. It is plain Dart — no SQLite, no Firestore, no Flutter.
/// Keep it free of storage concerns (this is why it has no `toMap`, and
/// why `isSynced`/`isDeleted` are just plain booleans owned by the DB.
/// ---------------------------------------------------------------------------
library;

class DebtReminder {
  final String id;
  final String customerId;
  final String? debtId;
  final String reminderDate;
  final int isCompleted;
  final String? message;
  final String ownerId;
  final bool isSynced;
  final bool isDeleted;
  final String updatedAt;

  const DebtReminder({
    required this.id,
    required this.customerId,
    this.debtId,
    required this.reminderDate,
    this.isCompleted = 0,
    this.message,
    this.ownerId = '',
    this.isSynced = false,
    this.isDeleted = false,
    this.updatedAt = '',
  });

  bool get completed => isCompleted == 1;

  DebtReminder copyWith({
    String? id,
    String? customerId,
    String? debtId,
    String? reminderDate,
    int? isCompleted,
    String? message,
    String? ownerId,
    bool? isSynced,
    bool? isDeleted,
    String? updatedAt,
  }) {
    return DebtReminder(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      debtId: debtId ?? this.debtId,
      reminderDate: reminderDate ?? this.reminderDate,
      isCompleted: isCompleted ?? this.isCompleted,
      message: message ?? this.message,
      ownerId: ownerId ?? this.ownerId,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'DebtReminder(id: $id, customerId: $customerId, debtId: $debtId)';
  }
}