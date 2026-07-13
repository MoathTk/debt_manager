import 'dart:math';
import '../data/database_helper.dart';

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
      // 1. Insert 50 customers
      final customerIds = <int>[];
      final now = DateTime.now();
      for (var i = 0; i < 50; i++) {
        final createdAt = now.subtract(Duration(days: _rand.nextInt(180)));
        final id = await txn.insert('customers', {
          'name': _names[i % _names.length],
          'phone': _rand.nextBool()
              ? '07${_rand.nextInt(90) + 10}${_rand.nextInt(9000000) + 1000000}'
              : null,
          'created_at': createdAt.toIso8601String(),
        });
        customerIds.add(id);
        count++;
      }

      // 2. Insert ~200 debts spread across customers
      final debtIds = <int>[]; // (customerId, debtId)
      final debtAmounts = <int, List<MapEntry<int, double>>>{};
      for (var i = 0; i < 200; i++) {
        final cid = customerIds[_rand.nextInt(customerIds.length)];
        final amount = (_rand.nextInt(49) + 1) * 10000.0; // 10k–500k IQD
        final daysAgo = _rand.nextInt(180);
        final date = now.subtract(Duration(days: daysAgo));
        final note = _debtNotes[_rand.nextInt(_debtNotes.length)];

        final id = await txn.insert('transactions', {
          'customer_id': cid,
          'amount': amount,
          'type': 0, // debt
          'note': note,
          'date': date.toIso8601String(),
        });
        debtIds.add(id);
        debtAmounts.putIfAbsent(cid, () => []);
        debtAmounts[cid]!.add(MapEntry(id, amount));
        count++;
      }

      // 3. Insert ~150 payments linked to debts
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
        final date = now.subtract(Duration(days: daysAgo));
        final note = _paymentNotes[_rand.nextInt(_paymentNotes.length)];

        await txn.insert('transactions', {
          'customer_id': cid,
          'amount': finalAmt,
          'type': 1, // payment
          'note': note,
          'date': date.toIso8601String(),
          'debt_id': debt.key,
        });
        count++;
      }

      // 4. Insert 30 reminders (some pending, some completed)
      for (var i = 0; i < 30; i++) {
        final cid = customerIds[_rand.nextInt(customerIds.length)];
        final daysOffset = _rand.nextInt(90) - 30; // -30 to +60 days
        final date = now.add(Duration(days: daysOffset));
        final completed = _rand.nextInt(3) == 0 ? 1 : 0; // 33% completed

        await txn.insert('debt_reminders', {
          'customer_id': cid,
          'reminder_date': date.toIso8601String(),
          'is_completed': completed,
          'message': _reminderMessages[_rand.nextInt(_reminderMessages.length)],
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
