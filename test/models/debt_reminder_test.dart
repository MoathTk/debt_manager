import 'package:flutter_test/flutter_test.dart';
import 'package:local_debt_management/data/models/debt_reminder.dart';

void main() {
  group('DebtReminder', () {
    test('default isCompleted = 0', () {
      final r = DebtReminder(customerId: 'c1', reminderDate: '2025-01-01');
      expect(r.isCompleted, 0);
      expect(r.completed, false);
    });

    test('completed getter returns true when isCompleted=1', () {
      final r = DebtReminder(
        customerId: 'c1', reminderDate: '2025-01-01', isCompleted: 1,
      );
      expect(r.completed, true);
    });

    test('toMap includes all fields', () {
      final r = DebtReminder(
        id: 'uuid-7', customerId: 'c3', debtId: 'd12',
        reminderDate: '2025-06-20', isCompleted: 1,
        message: 'follow up', ownerId: 'user-1',
      );
      final map = r.toMap();
      expect(map['id'], 'uuid-7');
      expect(map['customer_id'], 'c3');
      expect(map['debt_id'], 'd12');
      expect(map['reminder_date'], '2025-06-20');
      expect(map['is_completed'], 1);
      expect(map['message'], 'follow up');
      expect(map['owner_id'], 'user-1');
    });

    test('toMap null optional fields', () {
      final r = DebtReminder(customerId: 'c1', reminderDate: '2025-01-01');
      final map = r.toMap();
      expect(map['id'], null);
      expect(map['debt_id'], null);
      expect(map['message'], null);
    });

    test('fromMap round-trip', () {
      final original = DebtReminder(
        id: 'uuid-2', customerId: 'c5', debtId: 'd8',
        reminderDate: '2025-09-01', isCompleted: 1,
        message: 'test', ownerId: 'user-2',
      );
      final restored = DebtReminder.fromMap(original.toMap());
      expect(restored.id, original.id);
      expect(restored.customerId, original.customerId);
      expect(restored.debtId, original.debtId);
      expect(restored.reminderDate, original.reminderDate);
      expect(restored.isCompleted, original.isCompleted);
      expect(restored.message, original.message);
      expect(restored.ownerId, original.ownerId);
    });

    test('fromMap handles missing is_completed (defaults to 0)', () {
      final map = {
        'id': 'uuid-1', 'customer_id': 'c1',
        'debt_id': null, 'reminder_date': '2025-01-01',
        'message': null,
      };
      final r = DebtReminder.fromMap(map);
      expect(r.isCompleted, 0);
    });

    test('copyWith replaces only specified fields', () {
      final r = DebtReminder(
        id: 'uuid-1', customerId: 'c2',
        reminderDate: '2025-01-01', message: 'old', ownerId: 'user-1',
      );
      final updated = r.copyWith(isCompleted: 1, message: 'new');
      expect(updated.isCompleted, 1);
      expect(updated.message, 'new');
      expect(updated.id, 'uuid-1');
      expect(updated.ownerId, 'user-1');
    });

    test('toString contains key fields', () {
      final r = DebtReminder(
        id: 'uuid-3', customerId: 'c1', debtId: 'd2', reminderDate: '2025-05-05',
      );
      final s = r.toString();
      expect(s, contains('id: uuid-3'));
      expect(s, contains('customerId: c1'));
      expect(s, contains('debtId: d2'));
    });
  });
}
