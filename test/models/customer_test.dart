import 'package:flutter_test/flutter_test.dart';
import 'package:local_debt_management/data/models/customer.dart';

void main() {
  group('Customer', () {
    test('toMap includes all fields', () {
      final c = Customer(
        id: 'uuid-10',
        name: 'Ahmed',
        phone: '07801234567',
        createdAt: '2025-01-01T00:00:00.000',
      );
      final map = c.toMap();
      expect(map['id'], 'uuid-10');
      expect(map['name'], 'Ahmed');
      expect(map['phone'], '07801234567');
      expect(map['created_at'], '2025-01-01T00:00:00.000');
      expect(map['is_synced'], 0);
    });

    test('toMap with null optional fields', () {
      final c = Customer(name: 'Ali', createdAt: '2025-01-01');
      final map = c.toMap();
      expect(map['id'], null);
      expect(map['phone'], null);
    });

    test('fromMap round-trip', () {
      final original = Customer(
        id: 'uuid-sara',
        name: 'Sara',
        phone: '07901234567',
        createdAt: '2025-06-15',
      );
      final restored = Customer.fromMap(original.toMap());
      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.phone, original.phone);
      expect(restored.createdAt, original.createdAt);
    });

    test('fromMap with null phone', () {
      final map = {
        'id': 'uuid-1',
        'name': 'NoPhone',
        'phone': null,
        'created_at': '2025-01-01',
      };
      final c = Customer.fromMap(map);
      expect(c.phone, null);
    });

    test('copyWith replaces only specified fields', () {
      final c = Customer(id: 'uuid-1', name: 'Old', createdAt: '2025-01-01');
      final updated = c.copyWith(name: 'New');
      expect(updated.name, 'New');
      expect(updated.id, 'uuid-1');
      expect(updated.createdAt, '2025-01-01');
    });

    test('toString contains key fields', () {
      final c = Customer(id: 'uuid-1', name: 'Test', createdAt: '2025-01-01');
      expect(c.toString(), contains('name: Test'));
    });
  });
}
