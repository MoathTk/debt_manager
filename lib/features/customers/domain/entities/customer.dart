/// CUSTOMERS FEATURE — DOMAIN LAYER: CUSTOMER ENTITY
///
/// The core business object of the customers feature: a person who
/// owes money (debt) or has overpaid (credit).
///
/// ARCHITECTURE RULE: This file must never import from data/ or
/// presentation/. It is plain Dart — no SQLite, no Firestore, no Flutter.
/// Keep it free of storage concerns (this is why it has no `toMap`, and
/// why `isSynced`/`isDeleted` are just plain booleans owned by the DB.
///
/// ---------------------------------------------------------------------------
library;

class Customer {
  final String id;
  final String name;
  final String? phone;
  final String createdAt;
  final String ownerId;
  final bool isSynced;
  final bool isDeleted;
  final String updatedAt;

  const Customer({
    required this.id,
    required this.name,
    this.phone,
    required this.createdAt,
    this.ownerId = '',
    this.isSynced = false,
    this.isDeleted = false,
    this.updatedAt = '',
  });

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? createdAt,
    String? ownerId,
    bool? isSynced,
    bool? isDeleted,
    String? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      ownerId: ownerId ?? this.ownerId,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Two customers are equal when they share the same id.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Customer && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Customer(id: $id, name: $name, phone: $phone, createdAt: $createdAt)';
  }
}