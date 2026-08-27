/// CUSTOMERS FEATURE — DATA LAYER: CUSTOMER MODEL
///
/// The persistence representation of a [Customer]. This is the ONLY
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

import '../../domain/entities/customer.dart';

class CustomerModel {
  final String id;
  final String name;
  final String? phone;
  final String createdAt;
  final String ownerId;
  final bool isSynced;
  final bool isDeleted;
  final String updatedAt;

  const CustomerModel({
    required this.id,
    required this.name,
    this.phone,
    required this.createdAt,
    this.ownerId = '',
    this.isSynced = false,
    this.isDeleted = false,
    this.updatedAt = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'created_at': createdAt,
      'owner_id': ownerId,
      'is_synced': isSynced ? 1 : 0,
      'is_deleted': isDeleted ? 1 : 0,
      'updated_at': updatedAt,
    };
  }

  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      createdAt: map['created_at'] as String,
      ownerId: map['owner_id'] as String? ?? '',
      isSynced: (map['is_synced'] as int? ?? 0) == 1,
      isDeleted: (map['is_deleted'] as int? ?? 0) == 1,
      updatedAt: map['updated_at'] as String? ?? '',
    );
  }

  CustomerModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? createdAt,
    String? ownerId,
    bool? isSynced,
    bool? isDeleted,
    String? updatedAt,
  }) {
    return CustomerModel(
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

  Customer toEntity() {
    return Customer(
      id: id,
      name: name,
      phone: phone,
      createdAt: createdAt,
      ownerId: ownerId,
      isSynced: isSynced,
      isDeleted: isDeleted,
      updatedAt: updatedAt,
    );
  }

  factory CustomerModel.fromEntity(Customer c) {
    return CustomerModel(
      id: c.id,
      name: c.name,
      phone: c.phone,
      createdAt: c.createdAt,
      ownerId: c.ownerId,
      isSynced: c.isSynced,
      isDeleted: c.isDeleted,
      updatedAt: c.updatedAt,
    );
  }
}