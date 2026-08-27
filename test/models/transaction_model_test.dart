import 'package:flutter_test/flutter_test.dart';
import 'package:local_debt_management/features/debts/data/models/transaction_model.dart';

void main() {
  group('TransactionModel', () {
    test('toMap includes all fields', () {
      final t = TransactionModel(
        id: 'uuid-5',
        customerId: 'c2',
        amount: 123.45,
        type: 0,
        note: 'test note',
        date: '2025-06-15',
        debtId: 'd10',
        ownerId: 'user-1',
      );
      final map = t.toMap();
      expect(map['id'], 'uuid-5');
      expect(map['customer_id'], 'c2');
      expect(map['amount'], 123.45);
      expect(map['type'], 0);
      expect(map['note'], 'test note');
      expect(map['date'], '2025-06-15');
      expect(map['debt_id'], 'd10');
      expect(map['owner_id'], 'user-1');
      expect(map['is_synced'], 0);
    });

    test('toMap with null optional fields', () {
      final t = TransactionModel(
        id: 'uuid-t3',
        customerId: 'c1',
        amount: 50,
        type: 1,
        date: '2025-01-01',
      );
      final map = t.toMap();
      expect(map['id'], 'uuid-t3');
      expect(map['note'], null);
      expect(map['debt_id'], null);
    });

    test('fromMap round-trip preserves all fields', () {
      final original = TransactionModel(
        id: 'uuid-3',
        customerId: 'c7',
        amount: 999.99,
        type: 0,
        note: 'round trip',
        date: '2025-03-20',
        debtId: 'd2',
        ownerId: 'user-1',
      );
      final restored = TransactionModel.fromMap(original.toMap());
      expect(restored.id, original.id);
      expect(restored.customerId, original.customerId);
      expect(restored.amount, original.amount);
      expect(restored.type, original.type);
      expect(restored.note, original.note);
      expect(restored.date, original.date);
      expect(restored.debtId, original.debtId);
      expect(restored.ownerId, original.ownerId);
    });

    test('fromMap handles int amounts (SQLite stores as num)', () {
      final map = {
        'id': 'uuid-1',
        'customer_id': 'c1',
        'amount': 500,
        'type': 0,
        'note': null,
        'date': '2025-01-01',
        'debt_id': null,
      };
      final t = TransactionModel.fromMap(map);
      expect(t.amount, 500.0);
    });

    test('copyWith replaces only specified fields', () {
      final t = TransactionModel(
        id: 'uuid-1',
        customerId: 'c2',
        amount: 100,
        type: 0,
        note: 'old',
        date: '2025-01-01',
        debtId: 'd5',
        ownerId: 'user-1',
      );
      final updated = t.copyWith(amount: 200, note: 'new');
      expect(updated.amount, 200);
      expect(updated.note, 'new');
      expect(updated.id, 'uuid-1');
      expect(updated.ownerId, 'user-1');
    });
  });
}
