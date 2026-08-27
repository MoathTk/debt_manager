/// DEBTS FEATURE — DOMAIN LAYER: TRANSACTION ENTITY
///
/// The core business object of the debts feature: a single money
/// movement attached to a customer. A row is either a debt
/// (`type == debt`) or a repayment against a debt (`type == payment`).
///
/// ARCHITECTURE RULE: This file must never import from data/ or
/// presentation/. It is plain Dart — no SQLite, no Firestore, no Flutter.
/// Keep it free of storage concerns (this is why it has no `toMap`, and
/// why `isSynced`/`isDeleted` are just plain booleans owned by the DB.
/// ---------------------------------------------------------------------------
library;

class Transaction {
  final String id;
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
    required this.id,
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
