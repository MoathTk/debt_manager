import 'package:flutter_test/flutter_test.dart';
import 'package:local_debt_management/data/models/transaction.dart';

void main() {
  group('Transaction', () {
    test('constants: debt=0, payment=1', () {
      expect(Transaction.debt, 0);
      expect(Transaction.payment, 1);
    });

    test('isDebt / isPayment getters', () {
      final debt = Transaction(id: 'uuid-t1', customerId: 'c1', amount: 500, type: 0, date: '2025-01-01');
      final payment = Transaction(id: 'uuid-t2', customerId: 'c1', amount: 100, type: 1, date: '2025-01-02');
      expect(debt.isDebt, true);
      expect(debt.isPayment, false);
      expect(payment.isDebt, false);
      expect(payment.isPayment, true);
    });

    test('toMap includes all fields', () {
      final t = Transaction(
        id: 'uuid-5', customerId: 'c2', amount: 123.45, type: 0,
        note: 'test note', date: '2025-06-15', debtId: 'd10', ownerId: 'user-1',
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
      final t = Transaction(id: 'uuid-t3', customerId: 'c1', amount: 50, type: 1, date: '2025-01-01');
      final map = t.toMap();
      expect(map['id'], 'uuid-t3');
      expect(map['note'], null);
      expect(map['debt_id'], null);
    });

    test('fromMap round-trip preserves all fields', () {
      final original = Transaction(
        id: 'uuid-3', customerId: 'c7', amount: 999.99, type: 0,
        note: 'round trip', date: '2025-03-20', debtId: 'd2', ownerId: 'user-1',
      );
      final restored = Transaction.fromMap(original.toMap());
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
        'id': 'uuid-1', 'customer_id': 'c1', 'amount': 500,
        'type': 0, 'note': null, 'date': '2025-01-01', 'debt_id': null,
      };
      final t = Transaction.fromMap(map);
      expect(t.amount, 500.0);
    });

    test('copyWith replaces only specified fields', () {
      final t = Transaction(
        id: 'uuid-1', customerId: 'c2', amount: 100, type: 0,
        note: 'old', date: '2025-01-01', debtId: 'd5', ownerId: 'user-1',
      );
      final updated = t.copyWith(amount: 200, note: 'new');
      expect(updated.amount, 200);
      expect(updated.note, 'new');
      expect(updated.id, 'uuid-1');
      expect(updated.ownerId, 'user-1');
    });

    test('toString contains key fields', () {
      final t = Transaction(
        id: 'uuid-1', customerId: 'c2', amount: 100, type: 0, date: '2025-01-01',
      );
      final s = t.toString();
      expect(s, contains('id: uuid-1'));
      expect(s, contains('customerId: c2'));
      expect(s, contains('amount: 100'));
    });
  });
}
