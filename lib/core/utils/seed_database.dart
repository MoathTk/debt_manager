import 'dart:math';
import 'package:sqflite/sqflite.dart';
import '../../data/database_helper.dart';
import 'sync_id.dart';

class SeedDatabase {
  static final _db = DatabaseHelper.instance;
  static final _rand = Random();

  static final _names = [
    'أحمد محمد',
    'علي حسن',
    'حسين كريم',
    'عمر خالد',
    'سعيد عبدالله',
    'خالد ياسر',
    'مصطفى حيدر',
    'رامي أحمد',
    'بلال سعيد',
    'فراس نور',
    'عادل إبراهيم',
    'حمزة عمر',
    'يوسف خليل',
    'زيد حسن',
    'طارق سعيد',
    'فيصل رامي',
    'نبيل كريم',
    'عماد حسام',
    'ليث مصطفى',
    'ضياء ناصر',
    'بتول فاطمة',
    'هدى زينب',
    'نور ليلى',
    'دانة سارة',
    'ريم علي',
    'رنا محمد',
    'سارة أحمد',
    'لينا حسن',
    'مريم خالد',
    'ياسمين عمر',
    'أميرة زيد',
    'فاطمة كريم',
    'هجر مصطفى',
    'ندى سعيد',
    'سلمى هبة',
    'وليد سعيد',
    'طارق جمال',
    'أنس باسل',
    'معتز بالله',
    'عبدالرحمن طه',
    'حسن مهدي',
    'منتصر علي',
    'أسامة فيصل',
    'راد سامي',
    'غسان مازن',
    'إيثار كرار',
    'بيان قاسم',
    'ريم سيف',
    'أسرار حبيب',
    'شيماء عادل',
  ];

  static final _debtNotes = [
    'دين قهوة',
    'فاتورة موبايل',
    'شراء بضاعة',
    'قرض شخصي',
    'مصاريف مدرسية',
    'إصلاح سيارة',
    'اشتراك إنترنت',
    'فاتورة كهرباء',
    'شراء ملابس',
    'توصيل طلبات',
    null,
    null,
    null,
  ];

  static final _paymentNotes = [
    'دفعة نقدية',
    'تحويل بنكي',
    'جزئي',
    'دفعة كاملة',
    null,
    null,
  ];

static final _reminderMessages = [
    'تذكير بالدين',
    'متابعة السداد',
    'موعد الدفع',
    'مبلغ متبقي',
    null,
    null,
    null,
  ];

  /// Bigger name pools used by the stress seeder (Arabic + Latin mixes).
  static const _givenAr = [
    'أحمد', 'علي', 'حسين', 'عمر', 'سعيد', 'خالد', 'مصطفى', 'رامي', 'بلال',
    'فراس', 'عادل', 'حمزة', 'يوسف', 'زيد', 'طارق', 'فيصل', 'نبيل', 'عماد',
    'ليث', 'ضياء', 'بتول', 'هدى', 'نور', 'دانة', 'ريم', 'رنا', 'سارة', 'لينا',
    'مريم', 'ياسمين', 'أميرة', 'فاطمة', 'هجر', 'ندى', 'سلمى', 'وليد', 'أنس',
    'معتز', 'حسن', 'منتصر', 'أسامة', 'غسان', 'إيثار', 'بيان', 'عبدالرحمن',
  ];
  static const _familyAr = [
    'محمد', 'حسن', 'كريم', 'خالد', 'عبدالله', 'ياسر', 'حيدر', 'أحمد', 'سعيد',
    'نور', 'إبراهيم', 'علي', 'خليل', 'رامي', 'جمال', 'باسل', 'بالله', 'طه',
    'مهدي', 'فيصل', 'سامي', 'مازن', 'كرار', 'قاسم', 'سيف', 'حبيب', 'عادل',
    'مصطفى', 'زينب', 'فاطمة', 'سارة', 'عمر', 'ليلى', 'سلمان', 'صالح',
  ];
  static const _givenEn = [
    'Mohammed', 'Ali', 'Hussein', 'Omar', 'Said', 'Khalid', 'Mustafa', 'Rami',
    'Bilal', 'Firas', 'Adel', 'Hamza', 'Yousef', 'Zaid', 'Tarek', 'Faisal',
    'Nabil', 'Emad', 'Laith', 'Diaa', 'Batool', 'Huda', 'Noor', 'Dana', 'Reem',
    'Rana', 'Sara', 'Lina', 'Mariam', 'Yasmin', 'Amina', 'Fatima', 'Waleed',
    'Anas', 'Hasan', 'Montaser', 'Osama', 'Ghassan', 'Bayan',
  ];
  static const _familyEn = [
    'Ahmed', 'Hassan', 'Karim', 'Khalid', 'Abdullah', 'Yasser', 'Haidar',
    'Said', 'Noor', 'Ibrahim', 'Ali', 'Khaleel', 'Jamil', 'Basil', 'Taha',
    'Mahdi', 'Faisal', 'Sami', 'Mazen', 'Karrar', 'Qasim', 'Saif', 'Habib',
    'Adel', 'Saleh', 'Salman',
  ];
  static const _englishDebtNotes = [
    'car repair',
    'electricity bill',
    'phone top-up',
    'personal loan',
    'grocery tab',
    'rent share',
  ];
  static const _englishReminders = [
    'Follow up on payment',
    'Payment due soon',
    'Remaining balance reminder',
  ];

  static Future<int> seedDemoData({String? ownerId}) async {
    final db = await _db.database;
    int count = 0;

    await db.transaction((txn) async {
      final now = DateTime.now().toIso8601String();
      final ownerVal = ownerId ?? '';
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
          'owner_id': ownerVal,
          'is_synced': 1,
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
          'owner_id': ownerVal,
          'is_synced': 1,
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
          'owner_id': ownerVal,
          'is_synced': 1,
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
          'owner_id': ownerVal,
          'is_synced': 1,
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
    await db.delete('user_subscription');
  }

  // ---------------------------------------------------------------------------
  // Stress seeder — hundreds/thousands of rows covering every column variety
  // ---------------------------------------------------------------------------

  /// Seeds a large, varied dataset across all four tables to stress the app.
  ///
  /// Covers every column state: RTL/LTR/mixed names, missing/malformed/duplicate
  /// phones, owed/settled/overpaid ledgers, linked and unlinked payments,
  /// fractional and million-level amounts, past/today/future reminders,
  /// deleted-flag subsets, sync-flag variety and subscription rows.
  static Future<SeedResult> seedStressData({
    String? ownerId,
    int customerCount = 500,
    bool clear = true,
    int? randomSeed,
  }) async {
    final sw = Stopwatch()..start();
    final db = await _db.database;
    final rng = Random(randomSeed);
    if (clear) await clearDemoData();

    final ownerVal = ownerId ?? '';
    final activeUid = ownerVal.isEmpty ? 'default' : ownerVal;
    final now = DateTime.now();

    var cCount = 0, tCount = 0, rCount = 0, sCount = 0;
    final usedNames = <String>{};

    await db.transaction((txn) async {
      final customerIds = <String>[];
      final customerBatch = txn.batch();
      final firstPhone =
          '07${rng.nextInt(90) + 10}${rng.nextInt(9000000) + 1000000}';
      for (var i = 0; i < customerCount; i++) {
        final id = generateId();
        customerIds.add(id);
        final createdAt = now.subtract(
          Duration(
            days: rng.nextInt(730),
            seconds: rng.nextInt(86400),
          ),
        );
        customerBatch.insert('customers', {
          'id': id,
          'name': _pickName(rng, usedNames),
          // Duplicate pair on purpose (i == 1 reuses the first phone).
          'phone': i == 1 ? firstPhone : _pickPhone(rng),
          'created_at': createdAt.toIso8601String(),
          'owner_id': ownerVal,
          'is_synced': rng.nextInt(100) < 80 ? 1 : 0,
          'is_deleted': rng.nextInt(100) < 2 ? 1 : 0,
          'updated_at': rng.nextInt(20) == 0 ? '' : now.toIso8601String(),
        });
        cCount++;
      }
      await customerBatch.commit(noResult: true);

      final txBatch = txn.batch();
      final allDebtIds = <String>[];
      for (final cid in customerIds) {
        final debts = <_Debt>[];
        final nDebts = 1 + rng.nextInt(4);
        var debtSum = 0.0;
        for (var d = 0; d < nDebts; d++) {
          final amount = _randomAmount(rng);
          final id = generateId();
          debts.add(_Debt(id, amount));
          debtSum += amount;
          final date = rng.nextInt(20) == 0
              ? now.add(Duration(days: 1 + rng.nextInt(20)))
              : now.subtract(Duration(days: rng.nextInt(730)));
          txBatch.insert('transactions', {
            'id': id,
            'customer_id': cid,
            'amount': amount,
            'type': 0,
            'note': _pickNote(rng, _debtNotes, _englishDebtNotes),
            'date': date.toIso8601String(),
            'debt_id': null,
            'owner_id': ownerVal,
            'is_synced': rng.nextInt(100) < 80 ? 1 : 0,
            'is_deleted': rng.nextInt(100) < 1 ? 1 : 0,
            'updated_at': now.toIso8601String(),
          });
          allDebtIds.add(id);
          tCount++;
        }

        final scenario = _Scenario.pick(rng);
        final target = switch (scenario) {
          _Scenario.owed => debtSum * (0.2 + rng.nextDouble() * 0.6),
          _Scenario.settled => debtSum,
          _Scenario.overpaid => debtSum * (1.1 + rng.nextDouble() * 0.4),
          _Scenario.mixed => debtSum * (0.3 + rng.nextDouble() * 0.9),
        };
        final nPay = 1 + rng.nextInt(5);
        var paid = 0.0;
        for (var p = 0; p < nPay; p++) {
          var amt = p == nPay - 1
              ? target - paid
              : target * (0.1 + rng.nextDouble() * 0.9);
          amt = (amt * 100).roundToDouble() / 100;
          if (amt <= 0) continue;
          paid += amt;
          final debtRef = rng.nextInt(100) < 85 && debts.isNotEmpty
              ? debts[rng.nextInt(debts.length)].id
              : null;
          final date = now.subtract(Duration(days: rng.nextInt(730)));
          txBatch.insert('transactions', {
            'id': generateId(),
            'customer_id': cid,
            'amount': amt,
            'type': 1,
            'note': _pickNote(rng, _paymentNotes, null),
            'date': date.toIso8601String(),
            'debt_id': debtRef,
            'owner_id': ownerVal,
            'is_synced': rng.nextInt(100) < 80 ? 1 : 0,
            'is_deleted': rng.nextInt(100) < 1 ? 1 : 0,
            'updated_at': now.toIso8601String(),
          });
          tCount++;
        }
      }
      await txBatch.commit(noResult: true);

      final reminderBatch = txn.batch();
      final nRem = (customerCount * 2.4).round();
      for (var i = 0; i < nRem; i++) {
        final cid = customerIds[rng.nextInt(customerIds.length)];
        final daysOffset =
            rng.nextInt(10) == 0 ? 0 : rng.nextInt(150) - 45;
        final date = now.add(Duration(days: daysOffset));
        final dateStr =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        reminderBatch.insert('debt_reminders', {
          'id': generateId(),
          'customer_id': cid,
          'debt_id': rng.nextInt(100) < 55 && allDebtIds.isNotEmpty
              ? allDebtIds[rng.nextInt(allDebtIds.length)]
              : null,
          'reminder_date': dateStr,
          'is_completed': rng.nextInt(100) < 30 ? 1 : 0,
          'message': _pickNote(rng, _reminderMessages, _englishReminders),
          'owner_id': ownerVal,
          'is_synced': rng.nextInt(100) < 80 ? 1 : 0,
          'is_deleted': rng.nextInt(100) < 1 ? 1 : 0,
          'updated_at': now.toIso8601String(),
        });
        rCount++;
      }
      await reminderBatch.commit(noResult: true);

      final subBatch = txn.batch();
      subBatch.insert('user_subscription', {
        'user_id': activeUid,
        'plan': 'monthly',
        'expires_at': now.add(const Duration(days: 30)).toIso8601String(),
        'activated_at': now.subtract(const Duration(days: 10)).toIso8601String(),
        'is_active': 1,
      });
      subBatch.insert('user_subscription', {
        'user_id': 'user_other_a',
        'plan': 'weekly',
        'expires_at': now.subtract(const Duration(days: 5)).toIso8601String(),
        'activated_at':
            now.subtract(const Duration(days: 35)).toIso8601String(),
        'is_active': 0,
      });
      subBatch.insert('user_subscription', {
        'user_id': 'user_other_b',
        'plan': 'trial',
        'expires_at': now.add(const Duration(days: 7)).toIso8601String(),
        'activated_at': now.toIso8601String(),
        'is_active': 1,
      });
      await subBatch.commit(noResult: true);
      sCount = 3;
    });

    final insertElapsed = sw.elapsed;

    // --- Verification: exercise the real read paths and time them ---
    final verifySw = Stopwatch()..start();
    final checks = <String, String>{};
    final countQuery = (
      String table,
    ) async =>
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM $table'),
        );
    checks['customers'] = '${await countQuery('customers')}';
    checks['transactions'] = '${await countQuery('transactions')}';
    checks['reminders'] = '${await countQuery('debt_reminders')}';
    checks['subscriptions'] = '${await countQuery('user_subscription')}';

    final balanceRows = await db.rawQuery(
      'SELECT customer_id, ROUND(SUM(CASE WHEN type = 0 THEN amount ELSE -amount END), 2) AS bal '
      'FROM transactions WHERE is_deleted = 0 GROUP BY customer_id',
    );
    var owed = 0, settled = 0, overpaid = 0;
    for (final row in balanceRows) {
      final bal = (row['bal'] as num?)?.toDouble() ?? 0;
      if (bal > 0) {
        owed++;
      } else if (bal < 0) {
        overpaid++;
      } else {
        settled++;
      }
    }
    checks['owed_customers'] = '$owed';
    checks['settled_customers'] = '$settled';
    checks['overpaid_customers'] = '$overpaid';

    final today = now.toIso8601String().split('T').first;
    checks['due_today'] = '${Sqflite.firstIntValue(
      await db.rawQuery(
        "SELECT COUNT(*) FROM debt_reminders WHERE reminder_date = ? AND is_completed = 0",
        [today],
      ),
    )}';
    checks['pending_reminders'] = '${Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM debt_reminders WHERE is_completed = 0',
      ),
    )}';
    final subRows = await db.query(
      'user_subscription',
      where: 'user_id = ?',
      whereArgs: [activeUid],
    );
    checks['active_subscription'] = subRows.isEmpty
        ? 'none'
        : '${subRows.first['plan']}/${subRows.first['is_active']}';
    verifySw.stop();

    sw.stop();
    checks['verify_ms'] = '${verifySw.elapsedMilliseconds}';

    return SeedResult(
      customerCount: cCount,
      transactionCount: tCount,
      reminderCount: rCount,
      subscriptionCount: sCount,
      insertMs: insertElapsed.inMilliseconds,
      checks: checks,
    );
  }

  static String _pickName(Random rng, Set<String> used) {
    String name;
    do {
      final latin = rng.nextBool();
      name = latin
          ? '${_givenEn[rng.nextInt(_givenEn.length)]} '
              '${_familyEn[rng.nextInt(_familyEn.length)]}'
          : '${_givenAr[rng.nextInt(_givenAr.length)]} '
              '${_familyAr[rng.nextInt(_familyAr.length)]}';
    } while (used.contains(name));
    used.add(name);
    return name;
  }

  static String? _pickPhone(Random rng) {
    final r = rng.nextInt(100);
    if (r < 12) return null;
    if (r < 14) return rng.nextBool() ? '077' : '12345';
    return '07${rng.nextInt(90) + 10}${rng.nextInt(9000000) + 1000000}';
  }

  static double _randomAmount(Random rng) {
    if (rng.nextInt(10) == 0) return (rng.nextInt(400) + 1) / 4.0;
    return (rng.nextInt(5000) + 5) * 250.0;
  }

  static String? _pickNote(
    Random rng,
    List<String?> arabicPool,
    List<String>? englishPool,
  ) {
    if (englishPool != null && rng.nextBool()) {
      if (rng.nextInt(5) == 0) return null;
      return englishPool[rng.nextInt(englishPool.length)];
    }
    return arabicPool[rng.nextInt(arabicPool.length)];
  }
}

/// Outcome of a [SeedDatabase.seedStressData] run — counts + verification.
class SeedResult {
  final int customerCount;
  final int transactionCount;
  final int reminderCount;
  final int subscriptionCount;
  final int insertMs;
  final Map<String, String> checks;

  const SeedResult({
    required this.customerCount,
    required this.transactionCount,
    required this.reminderCount,
    required this.subscriptionCount,
    required this.insertMs,
    required this.checks,
  });
}

enum _Scenario {
  owed,
  settled,
  overpaid,
  mixed;

  static _Scenario pick(Random rng) {
    const weights = [44, 24, 8, 24];
    final roll = rng.nextInt(100);
    var acc = 0;
    for (var i = 0; i < weights.length; i++) {
      acc += weights[i];
      if (roll < acc) return _Scenario.values[i];
    }
    return _Scenario.owed;
  }
}

class _Debt {
  final String id;
  final double amount;
  const _Debt(this.id, this.amount);
}
