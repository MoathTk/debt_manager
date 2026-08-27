/// REMINDERS FEATURE — DATA LAYER: DEBT REMINDER MODEL
///
/// The persistence representation of a [DebtReminder]. This is the ONLY
/// place that knows about the SQLite table columns and the Firestore
/// document shape (map serialization, sync flags).
///
/// It exists because the domain entity stays pure — the model bridges
/// domain ↔ storage:
///   - [toMap]  → SQLite row / Firestore doc
///   - [fromMap] → reverse direction
///   - [toEntity] → domain entity
///   - [fromEntity] → back to a persistable model
/// ---------------------------------------------------------------------------
library;

import '../../domain/entities/debt_reminder.dart';

class DebtReminderModel {
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

  const DebtReminderModel({
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'debt_id': debtId,
      'reminder_date': reminderDate,
      'is_completed': isCompleted,
      'message': message,
      'owner_id': ownerId,
      'is_synced': isSynced ? 1 : 0,
      'is_deleted': isDeleted ? 1 : 0,
      'updated_at': updatedAt,
    };
  }

  factory DebtReminderModel.fromMap(Map<String, dynamic> map) {
    return DebtReminderModel(
      id: map['id'] as String,
      customerId: map['customer_id'] as String,
      debtId: map['debt_id'] as String?,
      reminderDate: map['reminder_date'] as String,
      isCompleted: map['is_completed'] as int? ?? 0,
      message: map['message'] as String?,
      ownerId: map['owner_id'] as String? ?? '',
      isSynced: (map['is_synced'] as int? ?? 0) == 1,
      isDeleted: (map['is_deleted'] as int? ?? 0) == 1,
      updatedAt: map['updated_at'] as String? ?? '',
    );
  }

  DebtReminderModel copyWith({
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
    return DebtReminderModel(
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

  DebtReminder toEntity() {
    return DebtReminder(
      id: id,
      customerId: customerId,
      debtId: debtId,
      reminderDate: reminderDate,
      isCompleted: isCompleted,
      message: message,
      ownerId: ownerId,
      isSynced: isSynced,
      isDeleted: isDeleted,
      updatedAt: updatedAt,
    );
  }

  factory DebtReminderModel.fromEntity(DebtReminder r) {
    return DebtReminderModel(
      id: r.id,
      customerId: r.customerId,
      debtId: r.debtId,
      reminderDate: r.reminderDate,
      isCompleted: r.isCompleted,
      message: r.message,
      ownerId: r.ownerId,
      isSynced: r.isSynced,
      isDeleted: r.isDeleted,
      updatedAt: r.updatedAt,
    );
  }
}