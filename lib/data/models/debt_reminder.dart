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

  bool get completed => isCompleted == 1;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'reminder_date': reminderDate,
      'is_completed': isCompleted,
      'message': message,
    };
  }

  factory DebtReminder.fromMap(Map<String, dynamic> map) {
    return DebtReminder(
      id: map['id'] as int?,
      customerId: map['customer_id'] as int,
      reminderDate: map['reminder_date'] as String,
      isCompleted: map['is_completed'] as int? ?? 0,
      message: map['message'] as String?,
    );
  }

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
