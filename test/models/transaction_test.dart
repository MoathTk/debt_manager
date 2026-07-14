import 'package:flutter_test/flutter_test.dart';
import 'package:local_debt_management/data/models/transaction.dart';

void main() {
  group('Transaction', () {
    test('constants: debt=0, payment=1', () {
      expect(Transaction.debt, 0);
      expect(Transaction.payment, 1);
    });

    test('isDebt / isPayment getters', () {
      final debt = Transaction(customerId: 1, amount: 500, type: 0, date: '2025-01-01');
      final payment = Transaction(customerId: 1, amount: 100, type: 1, date: '2025-01-02');
      expect(debt.isDebt, true);
      expect(debt.isPayment, false);
      expect(payment.isDebt, false);
      expect(payment.isPayment, true);
    });

    test('toMap includes all fields', () {
      final t = Transaction(
        id: 5,
        customerId: 2,
        amount: 123.45,
        type: 0,
        note: 'test note',
        date: '2025-06-15',
        debtId: 10,
        firebaseId: 'fb-abc',
      );
      final map = t.toMap();
      expect(map['id'], 5);
      expect(map['customer_id'], 2);
      expect(map['amount'], 123.45);
      expect(map['type'], 0);
      expect(map['note'], 'test note');
      expect(map['date'], '2025-06-15');
      expect(map['debt_id'], 10);
      expect(map['firebase_id'], 'fb-abc');
    });

    test('toMap with null optional fields', () {
      final t = Transaction(customerId: 1, amount: 50, type: 1, date: '2025-01-01');
      final map = t.toMap();
      expect(map['id'], null);
      expect(map['note'], null);
      expect(map['debt_id'], null);
      expect(map['firebase_id'], null);
    });

    test('fromMap round-trip preserves all fields', () {
      final original = Transaction(
        id: 3,
        customerId: 7,
        amount: 999.99,
        type: 0,
        note: 'round trip',
        date: '2025-03-20',
        debtId: 2,
        firebaseId: 'fb-xyz',
      );
      final restored = Transaction.fromMap(original.toMap());
      expect(restored.id, original.id);
      expect(restored.customerId, original.customerId);
      expect(restored.amount, original.amount);
      expect(restored.type, original.type);
      expect(restored.note, original.note);
      expect(restored.date, original.date);
      expect(restored.debtId, original.debtId);
      expect(restored.firebaseId, original.firebaseId);
    });

    test('fromMap handles int amounts (SQLite stores as num)', () {
      final map = {
        'id': 1,
        'customer_id': 1,
        'amount': 500, // int, not double
        'type': 0,
        'note': null,
        'date': '2025-01-01',
        'debt_id': null,
        'firebase_id': null,
      };
      final t = Transaction.fromMap(map);
      expect(t.amount, 500.0);
    });

    test('copyWith replaces only specified fields', () {
      final t = Transaction(
        id: 1,
        customerId: 2,
        amount: 100,
        type: 0,
        note: 'old',
        date: '2025-01-01',
        debtId: 5,
      );
      final updated = t.copyWith(amount: 200, note: 'new');
      expect(updated.amount, 200);
      expect(updated.note, 'new');
      expect(updated.id, 1);
      expect(updated.customerId, 2);
      expect(updated.type, 0);
      expect(updated.date, '2025-01-01');
      expect(updated.debtId, 5);
    });

    test('toString contains key fields', () {
      final t = Transaction(id: 1, customerId: 2, amount: 100, type: 0, date: '2025-01-01');
      final s = t.toString();
      expect(s, contains('id: 1'));
      expect(s, contains('customerId: 2'));
      expect(s, contains('amount: 100'));
    });
  });
}
