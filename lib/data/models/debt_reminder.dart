/// Represents a debt collection reminder for a customer.
///
/// Reminders help merchants track when to follow up on outstanding debts.
/// Each reminder is tied to a customer and has a scheduled date.
/// Merchants can mark reminders as completed once the follow-up is done.
class DebtReminder {
  final int? id;
  final int customerId;
  final String reminderDate;
  final int isCompleted;
  final String? message;

  const DebtReminder({
    this.id,
    required this.customerId,
    required this.reminderDate,
    this.isCompleted = 0,
    this.message,
  });

  /// Check if this reminder has been completed
  bool get completed => isCompleted == 1;

  /// Converts the DebtReminder instance to a Map for SQLite insertion.
  /// The Map keys match the column names in the 'debt_reminders' table.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'reminder_date': reminderDate,
      'is_completed': isCompleted,
      'message': message,
    };
  }

  /// Creates a DebtReminder instance from a SQLite query result Map.
  /// Used when reading data from the database.
  factory DebtReminder.fromMap(Map<String, dynamic> map) {
    return DebtReminder(
      id: map['id'] as int?,
      customerId: map['customer_id'] as int,
      reminderDate: map['reminder_date'] as String,
      isCompleted: map['is_completed'] as int? ?? 0,
      message: map['message'] as String?,
    );
  }

  /// Creates a new DebtReminder with selectively replaced fields.
  /// Useful for updates where only some fields change.
  DebtReminder copyWith({
    int? id,
    int? customerId,
    String? reminderDate,
    int? isCompleted,
    String? message,
  }) {
    return DebtReminder(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      reminderDate: reminderDate ?? this.reminderDate,
      isCompleted: isCompleted ?? this.isCompleted,
      message: message ?? this.message,
    );
  }

  @override
  String toString() {
    return 'DebtReminder(id: $id, customerId: $customerId, reminderDate: $reminderDate, isCompleted: $isCompleted, message: $message)';
  }
}
