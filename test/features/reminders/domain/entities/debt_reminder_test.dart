import 'package:flutter_test/flutter_test.dart';
import 'package:local_debt_management/features/reminders/domain/entities/debt_reminder.dart';

void main() {
  group('DebtReminder', () {
    test('default isCompleted = 0', () {
      final r = DebtReminder(
        id: 'uuid-d1',
        customerId: 'c1',
        reminderDate: '2025-01-01',
      );
      expect(r.isCompleted, 0);
      expect(r.completed, false);
    });

    test('completed getter returns true when isCompleted=1', () {
      final r = DebtReminder(
        id: 'uuid-d2',
        customerId: 'c1',
        reminderDate: '2025-01-01',
        isCompleted: 1,
      );
      expect(r.completed, true);
    });

    test('copyWith replaces only specified fields', () {
      final r = DebtReminder(
        id: 'uuid-1',
        customerId: 'c2',
        reminderDate: '2025-01-01',
        message: 'old',
        ownerId: 'user-1',
      );
      final updated = r.copyWith(isCompleted: 1, message: 'new');
      expect(updated.isCompleted, 1);
      expect(updated.message, 'new');
      expect(updated.id, 'uuid-1');
      expect(updated.ownerId, 'user-1');
    });

    test('toString contains key fields', () {
      final r = DebtReminder(
        id: 'uuid-3',
        customerId: 'c1',
        debtId: 'd2',
        reminderDate: '2025-05-05',
      );
      final s = r.toString();
      expect(s, contains('id: uuid-3'));
      expect(s, contains('customerId: c1'));
      expect(s, contains('debtId: d2'));
    });
  });
}