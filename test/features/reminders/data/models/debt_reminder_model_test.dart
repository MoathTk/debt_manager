import 'package:flutter_test/flutter_test.dart';
import 'package:local_debt_management/features/reminders/data/models/debt_reminder_model.dart';

void main() {
  group('DebtReminderModel', () {
    test('toMap includes all fields', () {
      final r = DebtReminderModel(
        id: 'uuid-7',
        customerId: 'c3',
        debtId: 'd12',
        reminderDate: '2025-06-20',
        isCompleted: 1,
        message: 'follow up',
        ownerId: 'user-1',
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
      final r = DebtReminderModel(
        id: 'uuid-d3',
        customerId: 'c1',
        reminderDate: '2025-01-01',
      );
      final map = r.toMap();
      expect(map['id'], 'uuid-d3');
      expect(map['debt_id'], null);
      expect(map['message'], null);
    });

    test('fromMap round-trip', () {
      final original = DebtReminderModel(
        id: 'uuid-2',
        customerId: 'c5',
        debtId: 'd8',
        reminderDate: '2025-09-01',
        isCompleted: 1,
        message: 'test',
        ownerId: 'user-2',
      );
      final restored = DebtReminderModel.fromMap(original.toMap());
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
        'id': 'uuid-1',
        'customer_id': 'c1',
        'debt_id': null,
        'reminder_date': '2025-01-01',
        'message': null,
      };
      final r = DebtReminderModel.fromMap(map);
      expect(r.isCompleted, 0);
    });

    test('toEntity/fromEntity round-trip', () {
      final model = DebtReminderModel(
        id: 'uuid-9',
        customerId: 'c9',
        debtId: 'd9',
        reminderDate: '2025-10-10',
        isCompleted: 1,
        message: 'm',
        ownerId: 'user-9',
      );
      final entity = model.toEntity();
      expect(entity.id, 'uuid-9');
      expect(entity.customerId, 'c9');
      expect(entity.debtId, 'd9');
      expect(entity.reminderDate, '2025-10-10');
      expect(entity.isCompleted, 1);
      expect(entity.message, 'm');
      expect(entity.ownerId, 'user-9');
      final back = DebtReminderModel.fromEntity(entity);
      expect(back.toMap(), model.toMap());
    });
  });
}