import 'package:flutter_test/flutter_test.dart';
import 'package:local_debt_management/data/models/debt_reminder.dart';

void main() {
  group('DebtReminder', () {
    test('default isCompleted = 0', () {
      final r = DebtReminder(customerId: 1, reminderDate: '2025-01-01');
      expect(r.isCompleted, 0);
      expect(r.completed, false);
    });

    test('completed getter returns true when isCompleted=1', () {
      final r = DebtReminder(customerId: 1, reminderDate: '2025-01-01', isCompleted: 1);
      expect(r.completed, true);
    });

    test('toMap includes all fields', () {
      final r = DebtReminder(
        id: 7,
        customerId: 3,
        debtId: 12,
        reminderDate: '2025-06-20',
        isCompleted: 1,
        message: 'follow up',
      );
      final map = r.toMap();
      expect(map['id'], 7);
      expect(map['customer_id'], 3);
      expect(map['debt_id'], 12);
      expect(map['reminder_date'], '2025-06-20');
      expect(map['is_completed'], 1);
      expect(map['message'], 'follow up');
    });

    test('toMap null optional fields', () {
      final r = DebtReminder(customerId: 1, reminderDate: '2025-01-01');
      final map = r.toMap();
      expect(map['id'], null);
      expect(map['debt_id'], null);
      expect(map['message'], null);
    });

    test('fromMap round-trip', () {
      final original = DebtReminder(
        id: 2,
        customerId: 5,
        debtId: 8,
        reminderDate: '2025-09-01',
        isCompleted: 1,
        message: 'test',
      );
      final restored = DebtReminder.fromMap(original.toMap());
      expect(restored.id, original.id);
      expect(restored.customerId, original.customerId);
      expect(restored.debtId, original.debtId);
      expect(restored.reminderDate, original.reminderDate);
      expect(restored.isCompleted, original.isCompleted);
      expect(restored.message, original.message);
    });

    test('fromMap handles missing is_completed (defaults to 0)', () {
      final map = {
        'id': 1,
        'customer_id': 1,
        'debt_id': null,
        'reminder_date': '2025-01-01',
        // is_completed missing
        'message': null,
      };
      final r = DebtReminder.fromMap(map);
      expect(r.isCompleted, 0);
    });

    test('copyWith replaces only specified fields', () {
      final r = DebtReminder(
        id: 1,
        customerId: 2,
        reminderDate: '2025-01-01',
        message: 'old',
      );
      final updated = r.copyWith(isCompleted: 1, message: 'new');
      expect(updated.isCompleted, 1);
      expect(updated.message, 'new');
      expect(updated.id, 1);
      expect(updated.customerId, 2);
      expect(updated.reminderDate, '2025-01-01');
    });

    test('toString contains key fields', () {
      final r = DebtReminder(id: 3, customerId: 1, debtId: 2, reminderDate: '2025-05-05');
      final s = r.toString();
      expect(s, contains('id: 3'));
      expect(s, contains('customerId: 1'));
      expect(s, contains('debtId: 2'));
    });
  });
}
