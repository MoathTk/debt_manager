/// Represents a financial transaction (debt or payment) for a customer.
///
/// Transaction types:
/// - [debt] (0): Money owed by the customer (increases their balance)
/// - [payment] (1): Money paid by the customer (decreases their balance)
///
/// The [firebaseId] field is reserved for future cloud sync with Firebase.
class Transaction {
  final int? id;
  final int customerId;
  final double amount;
  final int type;
  final String? note;
  final String date;
  final int? debtId;
  final String? firebaseId;

  const Transaction({
    this.id,
    required this.customerId,
    required this.amount,
    required this.type,
    this.note,
    required this.date,
    this.debtId,
    this.firebaseId,
  });

  /// Type constants for the 'type' field
  static const int debt = 0;
  static const int payment = 1;

  /// Check if this transaction is a debt
  bool get isDebt => type == debt;

  /// Check if this transaction is a payment
  bool get isPayment => type == payment;

  /// Converts the Transaction instance to a Map for SQLite insertion.
  /// The Map keys match the column names in the 'transactions' table.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'amount': amount,
      'type': type,
      'note': note,
      'date': date,
      'debt_id': debtId,
      'firebase_id': firebaseId,
    };
  }

  /// Creates a Transaction instance from a SQLite query result Map.
  /// Used when reading data from the database.
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int?,
      customerId: map['customer_id'] as int,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] as int,
      note: map['note'] as String?,
      date: map['date'] as String,
      debtId: map['debt_id'] as int?,
      firebaseId: map['firebase_id'] as String?,
    );
  }

  /// Creates a new Transaction with selectively replaced fields.
  /// Useful for updates where only some fields change.
  Transaction copyWith({
    int? id,
    int? customerId,
    double? amount,
    int? type,
    String? note,
    String? date,
    int? debtId,
    String? firebaseId,
  }) {
    return Transaction(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      note: note ?? this.note,
      date: date ?? this.date,
      debtId: debtId ?? this.debtId,
      firebaseId: firebaseId ?? this.firebaseId,
    );
  }

  @override
  String toString() {
    return 'Transaction(id: $id, customerId: $customerId, amount: $amount, type: $type, note: $note, date: $date)';
  }
}
