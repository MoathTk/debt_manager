import 'dart:math';
import '../data/database_helper.dart';
import 'sync_id.dart';

class SeedDatabase {
  static final _db = DatabaseHelper.instance;
  static final _rand = Random();

  static final _names = [
    'أحمد محمد', 'علي حسن', 'حسين كريم', 'عمر خالد', 'سعيد عبدالله',
    'خالد ياسر', 'مصطفى حيدر', 'رامي أحمد', 'بلال سعيد', 'فراس نور',
    'عادل إبراهيم', 'حمزة عمر', 'يوسف خليل', 'زيد حسن', 'طارق سعيد',
    'فيصل رامي', 'نبيل كريم', 'عماد حسام', 'ليث مصطفى', 'ضياء ناصر',
    'بتول فاطمة', 'هدى زينب', 'نور ليلى', 'دانة سارة', 'ريم علي',
    'رنا محمد', 'سارة أحمد', 'لينا حسن', 'مريم خالد', 'ياسمين عمر',
    'أميرة زيد', 'فاطمة كريم', 'هجر مصطفى', 'ندى سعيد', 'سلمى هبة',
    'وليد سعيد', 'طارق جمال', 'أنس باسل', 'معتز بالله', 'عبدالرحمن طه',
    'حسن مهدي', 'منتصر علي', 'أسامة فيصل', 'راد سامي', 'غسان مازن',
    'إيثار كرار', 'بيان قاسم', 'ريم سيف', 'أسرار حبيب', 'شيماء عادل',
  ];

  static final _debtNotes = [
    'دين قهوة', 'فاتورة موبايل', 'شراء بضاعة', 'قرض شخصي', 'مصاريف مدرسية',
    'إصلاح سيارة', 'اشتراك إنترنت', 'فاتورة كهرباء', 'شراء ملابس', 'توصيل طلبات',
    null, null, null,
  ];

  static final _paymentNotes = [
    'دفعة نقدية', 'تحويل بنكي', 'جزئي', 'دفعة كاملة', null, null,
  ];

  static final _reminderMessages = [
    'تذكير بالدين', 'متابعة السداد', 'موعد الدفع', 'مبلغ متبقي',
    null, null,
  ];

  static Future<int> seedDemoData() async {
    final db = await _db.database;
    int count = 0;

    await db.transaction((txn) async {
      final now = DateTime.now().toIso8601String();
      final customerIds = <String>[];
      for (var i = 0; i < 50; i++) {
        final id = generateId();
        customerIds.add(id);
        final createdAt = DateTime.now()
            .subtract(Duration(days: _rand.nextInt(180)))
            .toIso8601String();
        await txn.insert('customers', {
          'id': id,
          'name': _names[i % _names.length],
          'phone': _rand.nextBool()
              ? '07${_rand.nextInt(90) + 10}${_rand.nextInt(9000000) + 1000000}'
              : null,
          'created_at': createdAt,
          'is_synced': 0,
          'updated_at': now,
        });
        count++;
      }

      final debtIds = <String>[];
      final debtAmounts = <String, List<MapEntry<String, double>>>{};
      for (var i = 0; i < 200; i++) {
        final cid = customerIds[_rand.nextInt(customerIds.length)];
        final amount = (_rand.nextInt(49) + 1) * 10000.0;
        final daysAgo = _rand.nextInt(180);
        final date = DateTime.now()
            .subtract(Duration(days: daysAgo))
            .toIso8601String();
        final note = _debtNotes[_rand.nextInt(_debtNotes.length)];

        final id = generateId();
        debtIds.add(id);
        await txn.insert('transactions', {
          'id': id,
          'customer_id': cid,
          'amount': amount,
          'type': 0,
          'note': note,
          'date': date,
          'is_synced': 0,
          'updated_at': now,
        });
        debtAmounts.putIfAbsent(cid, () => []);
        debtAmounts[cid]!.add(MapEntry(id, amount));
        count++;
      }

      for (var i = 0; i < 150; i++) {
        final cid = customerIds[_rand.nextInt(customerIds.length)];
        final debts = debtAmounts[cid];
        if (debts == null || debts.isEmpty) continue;

        final debt = debts[_rand.nextInt(debts.length)];
        final maxPay = debt.value;
        final amount = maxPay > 0
            ? ((_rand.nextDouble() * maxPay * 0.9) + maxPay * 0.05)
            : 10000.0;
        final rounded = (amount / 1000).round() * 1000.0;
        final finalAmt = rounded < 1000 ? 1000.0 : rounded;

        final daysAgo = _rand.nextInt(180);
        final date = DateTime.now()
            .subtract(Duration(days: daysAgo))
            .toIso8601String();
        final note = _paymentNotes[_rand.nextInt(_paymentNotes.length)];

        await txn.insert('transactions', {
          'id': generateId(),
          'customer_id': cid,
          'amount': finalAmt,
          'type': 1,
          'note': note,
          'date': date,
          'debt_id': debt.key,
          'is_synced': 0,
          'updated_at': now,
        });
        count++;
      }

      final customerDebts = <String, List<String>>{};
      for (final entry in debtAmounts.entries) {
        customerDebts[entry.key] = entry.value.map((e) => e.key).toList();
      }

      for (var i = 0; i < 30; i++) {
        final cid = customerIds[_rand.nextInt(customerIds.length)];
        final daysOffset = _rand.nextInt(90) - 30;
        final date = DateTime.now().add(Duration(days: daysOffset));
        final dateStr =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final completed = _rand.nextInt(3) == 0 ? 1 : 0;

        final debts = customerDebts[cid];
        final debtId = (debts != null && debts.isNotEmpty)
            ? debts[_rand.nextInt(debts.length)]
            : null;

        await txn.insert('debt_reminders', {
          'id': generateId(),
          'customer_id': cid,
          'debt_id': debtId,
          'reminder_date': dateStr,
          'is_completed': completed,
          'message': _reminderMessages[_rand.nextInt(_reminderMessages.length)],
          'is_synced': 0,
          'updated_at': now,
        });
        count++;
      }
    });

    return count;
  }

  static Future<void> clearDemoData() async {
    final db = await _db.database;
    await db.delete('debt_reminders');
    await db.delete('transactions');
    await db.delete('customers');
  }
}
