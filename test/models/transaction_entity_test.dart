import 'package:flutter_test/flutter_test.dart';
import 'package:local_debt_management/features/debts/domain/entities/transaction.dart';

void main() {
  group('Transaction entity', () {
    test('constants: debt=0, payment=1', () {
      expect(Transaction.debt, 0);
      expect(Transaction.payment, 1);
    });

    test('isDebt / isPayment getters', () {
      final debt = Transaction(
        id: 'uuid-t1',
        customerId: 'c1',
        amount: 500,
        type: 0,
        date: '2025-01-01',
      );
      final payment = Transaction(
        id: 'uuid-t2',
        customerId: 'c1',
        amount: 100,
        type: 1,
        date: '2025-01-02',
      );
      expect(debt.isDebt, true);
      expect(debt.isPayment, false);
      expect(payment.isDebt, false);
      expect(payment.isPayment, true);
    });

    test('copyWith replaces only specified fields', () {
      final t = Transaction(
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

    test('toString contains key fields', () {
      final t = Transaction(
        id: 'uuid-1',
        customerId: 'c2',
        amount: 100,
        type: 0,
        date: '2025-01-01',
      );
      final s = t.toString();
      expect(s, contains('id: uuid-1'));
      expect(s, contains('customerId: c2'));
      expect(s, contains('amount: 100'));
    });
  });
}
