/// Represents a customer in the debt management system.
///
/// Customers are the primary entities who owe debts or make payments.
/// Each customer can have multiple transactions and debt reminders.
/// The [firebaseId] field is reserved for future cloud sync with Firebase.
class Customer {
  final int? id;
  final String name;
  final String? phone;
  final String createdAt;
  final String? firebaseId;

  const Customer({
    this.id,
    required this.name,
    this.phone,
    required this.createdAt,
    this.firebaseId,
  });

  /// Converts the Customer instance to a Map for SQLite insertion.
  /// The Map keys match the column names in the 'customers' table.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'created_at': createdAt,
      'firebase_id': firebaseId,
    };
  }

  /// Creates a Customer instance from a SQLite query result Map.
  /// Used when reading data from the database.
  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      createdAt: map['created_at'] as String,
      firebaseId: map['firebase_id'] as String?,
    );
  }

  /// Creates a new Customer with selectively replaced fields.
  /// Useful for updates where only some fields change.
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
