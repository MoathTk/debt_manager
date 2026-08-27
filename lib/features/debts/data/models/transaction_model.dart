/// DEBTS FEATURE — DATA LAYER: TRANSACTION MODEL
///
/// The persistence representation of a [Transaction]. This is the ONLY
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

import '../../domain/entities/transaction.dart';

class TransactionModel {
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

  const TransactionModel({
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

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
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

  TransactionModel copyWith({
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
    return TransactionModel(
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

  Transaction toEntity() {
    return Transaction(
      id: id,
      customerId: customerId,
      amount: amount,
      type: type,
      note: note,
      date: date,
      debtId: debtId,
      ownerId: ownerId,
      isSynced: isSynced,
      isDeleted: isDeleted,
      updatedAt: updatedAt,
    );
  }

  factory TransactionModel.fromEntity(Transaction t) {
    return TransactionModel(
      id: t.id,
      customerId: t.customerId,
      amount: t.amount,
      type: t.type,
      note: t.note,
      date: t.date,
      debtId: t.debtId,
      ownerId: t.ownerId,
      isSynced: t.isSynced,
      isDeleted: t.isDeleted,
      updatedAt: t.updatedAt,
    );
  }
}
