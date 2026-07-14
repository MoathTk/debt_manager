class Customer {
  final String? id;
  final String name;
  final String? phone;
  final String createdAt;
  final bool isSynced;
  final String updatedAt;

  const Customer({
    this.id,
    required this.name,
    this.phone,
    required this.createdAt,
    this.isSynced = false,
    this.updatedAt = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'created_at': createdAt,
      'is_synced': isSynced ? 1 : 0,
      'updated_at': updatedAt,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as String?,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      createdAt: map['created_at'] as String,
      isSynced: (map['is_synced'] as int? ?? 0) == 1,
      updatedAt: map['updated_at'] as String? ?? '',
    );
  }

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? createdAt,
    bool? isSynced,
    String? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Customer(id: $id, name: $name, phone: $phone, createdAt: $createdAt)';
  }
}
