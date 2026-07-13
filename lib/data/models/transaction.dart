class Transaction {
  final int? id;
  final int customerId;
  final double amount;
  final int type;
  final String? note;
  final String date;
  final String? firebaseId;

  const Transaction({
    this.id,
    required this.customerId,
    required this.amount,
    required this.type,
    this.note,
    required this.date,
    this.firebaseId,
  });

  static const int debt = 0;
  static const int payment = 1;

  bool get isDebt => type == debt;
  bool get isPayment => type == payment;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'amount': amount,
      'type': type,
      'note': note,
      'date': date,
      'firebase_id': firebaseId,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int?,
      customerId: map['customer_id'] as int,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] as int,
      note: map['note'] as String?,
      date: map['date'] as String,
      firebaseId: map['firebase_id'] as String?,
    );
  }

  Transaction copyWith({
    int? id,
    int? customerId,
    double? amount,
    int? type,
    String? note,
    String? date,
    String? firebaseId,
  }) {
    return Transaction(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      note: note ?? this.note,
      date: date ?? this.date,
      firebaseId: firebaseId ?? this.firebaseId,
    );
  }

  @override
  String toString() {
    return 'Transaction(id: $id, customerId: $customerId, amount: $amount, type: $type, note: $note, date: $date)';
  }
}
