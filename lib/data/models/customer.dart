class Customer {
  final int? id;
  final String name;
  final String? phone;
  final String createdAt;
  final String? firebaseId;

  const Customer({
    this.id,
    required this.name,
    required this.phone,
    required this.createdAt,
    this.firebaseId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'created_at': createdAt,
      'firebase_id': firebaseId,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      createdAt: map['created_at'] as String,
      firebaseId: map['firebase_id'] as String?,
    );
  }

  Customer copyWith({
    int? id,
    String? name,
    String? phone,
    String? createdAt,
    String? firebaseId,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      firebaseId: firebaseId ?? this.firebaseId,
    );
  }

  @override
  String toString() {
    return 'Customer(id: $id, name: $name, phone: $phone, createdAt: $createdAt, firebaseId: $firebaseId)';
  }
}
