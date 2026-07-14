class DebtReminder {
  final String? id;
  final String customerId;
  final String? debtId;
  final String reminderDate;
  final int isCompleted;
  final String? message;
  final bool isSynced;
  final String updatedAt;

  const DebtReminder({
    this.id,
    required this.customerId,
    this.debtId,
    required this.reminderDate,
    this.isCompleted = 0,
    this.message,
    this.isSynced = false,
    this.updatedAt = '',
  });

  bool get completed => isCompleted == 1;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'debt_id': debtId,
      'reminder_date': reminderDate,
      'is_completed': isCompleted,
      'message': message,
      'is_synced': isSynced ? 1 : 0,
      'updated_at': updatedAt,
    };
  }

  factory DebtReminder.fromMap(Map<String, dynamic> map) {
    return DebtReminder(
      id: map['id'] as String?,
      customerId: map['customer_id'] as String,
      debtId: map['debt_id'] as String?,
      reminderDate: map['reminder_date'] as String,
      isCompleted: map['is_completed'] as int? ?? 0,
      message: map['message'] as String?,
      isSynced: (map['is_synced'] as int? ?? 0) == 1,
      updatedAt: map['updated_at'] as String? ?? '',
    );
  }

  DebtReminder copyWith({
    String? id,
    String? customerId,
    String? debtId,
    String? reminderDate,
    int? isCompleted,
    String? message,
    bool? isSynced,
    String? updatedAt,
  }) {
    return DebtReminder(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      debtId: debtId ?? this.debtId,
      reminderDate: reminderDate ?? this.reminderDate,
      isCompleted: isCompleted ?? this.isCompleted,
      message: message ?? this.message,
      isSynced: isSynced ?? this.isSynced,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'DebtReminder(id: $id, customerId: $customerId, debtId: $debtId, reminderDate: $reminderDate, isCompleted: $isCompleted, message: $message)';
  }
}
