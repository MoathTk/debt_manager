class Transaction {
  final String? id;
  final String customerId;
  final double amount;
  final int type;
  final String? note;
  final String date;
  final String? debtId;
  final String ownerId;
  final bool isSynced;
  final bool isDeleted;
  final String updatedAt;

  static const int debt = 0;
  static const int payment = 1;

  bool get isDebt => type == debt;
  bool get isPayment => type == payment;

  const Transaction({
    this.id,
    required this.customerId,
    required this.amount,
    required this.type,
    this.note,
    required this.date,
    this.debtId,
    this.ownerId = '',
    this.isSynced = false,
    this.isDeleted = false,
    this.updatedAt = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'amount': amount,
      'type': type,
      'note': note,
      'date': date,
      'debt_id': debtId,
      'owner_id': ownerId,
      'is_synced': isSynced ? 1 : 0,
      'is_deleted': isDeleted ? 1 : 0,
      'updated_at': updatedAt,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as String?,
      customerId: map['customer_id'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] as int,
      note: map['note'] as String?,
      date: map['date'] as String,
      debtId: map['debt_id'] as String?,
      ownerId: map['owner_id'] as String? ?? '',
      isSynced: (map['is_synced'] as int? ?? 0) == 1,
      isDeleted: (map['is_deleted'] as int? ?? 0) == 1,
      updatedAt: map['updated_at'] as String? ?? '',
    );
  }

  Transaction copyWith({
    String? id,
    String? customerId,
    double? amount,
    int? type,
    String? note,
    String? date,
    String? debtId,
    String? ownerId,
    bool? isSynced,
    bool? isDeleted,
    String? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      note: note ?? this.note,
      date: date ?? this.date,
      debtId: debtId ?? this.debtId,
      ownerId: ownerId ?? this.ownerId,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Transaction(id: $id, customerId: $customerId, amount: $amount, type: $type)';
  }
}
