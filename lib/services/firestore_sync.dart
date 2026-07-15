import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/database_helper.dart';
import '../data/models/customer.dart';
import '../data/models/transaction.dart' as model;
import '../data/models/debt_reminder.dart';

class FirestoreSync {
  final _db = DatabaseHelper.instance;

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  String _userPath(String uid) => 'users/$uid';

  Future<void> syncAll(String uid) async {
    bool customersPushed = false;
    bool transactionsPushed = false;

    // PUSH PHASE (dependency chain: customers → transactions → reminders)
    try {
      await _pushCustomers(uid);
      customersPushed = true;
    } catch (_) {
      // customers push failed → skip transactions & reminders
    }

    if (customersPushed) {
      try {
        await _pushTransactions(uid);
        transactionsPushed = true;
      } catch (_) {
        // transactions push failed → skip reminders
      }
    }

    if (transactionsPushed) {
      try {
        await _pushReminders(uid);
      } catch (_) {}
    }

    // PULL PHASE (always runs to get latest data from other devices)
    try {
      await _pullCustomers(uid);
    } catch (_) {}
    try {
      await _pullTransactions(uid);
    } catch (_) {}
    try {
      await _pullReminders(uid);
    } catch (_) {}

    await _saveLastSync(uid);
  }

  // ======================== PUSH ========================

  static const _batchLimit = 500;

  Future<void> _pushCustomers(String uid) async {
    final repo = _CustomerSyncRepo(_db);
    final unsynced = await repo.getUnsynced();
    if (unsynced.isEmpty) return;
    final col = _firestore.collection('${_userPath(uid)}/customers');
    final ids = <String>[];
    for (var i = 0; i < unsynced.length; i += _batchLimit) {
      final chunk = unsynced.sublist(
        i,
        i + _batchLimit > unsynced.length ? unsynced.length : i + _batchLimit,
      );
      final batch = _firestore.batch();
      for (final c in chunk) {
        batch.set(col.doc(c.id), c.toMap());
        ids.add(c.id!);
      }
      await batch.commit();
    }
    await repo.markSynced(ids);
  }

  Future<void> _pushTransactions(String uid) async {
    final repo = _TransactionSyncRepo(_db);
    final unsynced = await repo.getUnsynced();
    if (unsynced.isEmpty) return;
    final col = _firestore.collection('${_userPath(uid)}/transactions');
    final ids = <String>[];
    for (var i = 0; i < unsynced.length; i += _batchLimit) {
      final chunk = unsynced.sublist(
        i,
        i + _batchLimit > unsynced.length ? unsynced.length : i + _batchLimit,
      );
      final batch = _firestore.batch();
      for (final t in chunk) {
        batch.set(col.doc(t.id), t.toMap());
        ids.add(t.id!);
      }
      await batch.commit();
    }
    await repo.markSynced(ids);
  }

  Future<void> _pushReminders(String uid) async {
    final repo = _ReminderSyncRepo(_db);
    final unsynced = await repo.getUnsynced();
    if (unsynced.isEmpty) return;
    final col = _firestore.collection('${_userPath(uid)}/reminders');
    final ids = <String>[];
    for (var i = 0; i < unsynced.length; i += _batchLimit) {
      final chunk = unsynced.sublist(
        i,
        i + _batchLimit > unsynced.length ? unsynced.length : i + _batchLimit,
      );
      final batch = _firestore.batch();
      for (final r in chunk) {
        batch.set(col.doc(r.id), r.toMap());
        ids.add(r.id!);
      }
      await batch.commit();
    }
    await repo.markSynced(ids);
  }

  // ======================== PULL ========================

  Future<void> _pullCustomers(String uid) async {
    final repo = _CustomerSyncRepo(_db);
    final lastSync = await _getLastSync(uid);
    Query query = _firestore.collection('${_userPath(uid)}/customers');
    if (lastSync != null) {
      query = query.where('updated_at', isGreaterThan: lastSync);
    }
    final snap = await query.get();//might null!!!!.
    final records = snap.docs
        .map((d) => Customer.fromMap(d.data() as Map<String, dynamic>))
        .toList();
    if (records.isNotEmpty) await repo.upsertFromCloud(records);
  }

  Future<void> _pullTransactions(String uid) async {
    final repo = _TransactionSyncRepo(_db);
    final lastSync = await _getLastSync(uid);
    Query query = _firestore.collection('${_userPath(uid)}/transactions');
    if (lastSync != null) {
      query = query.where('updated_at', isGreaterThan: lastSync);
    }
    final snap = await query.get();
    final records = snap.docs
        .map((d) => model.Transaction.fromMap(d.data() as Map<String, dynamic>))
        .toList();
    if (records.isNotEmpty) await repo.upsertFromCloud(records);
  }

  Future<void> _pullReminders(String uid) async {
    final repo = _ReminderSyncRepo(_db);
    final lastSync = await _getLastSync(uid);
    Query query = _firestore.collection('${_userPath(uid)}/reminders');
    if (lastSync != null) {
      query = query.where('updated_at', isGreaterThan: lastSync);
    }
    final snap = await query.get();
    final records = snap.docs
        .map((d) => DebtReminder.fromMap(d.data() as Map<String, dynamic>))
        .toList();
    if (records.isNotEmpty) await repo.upsertFromCloud(records);
  }

  // ======================== META ========================

  Future<String?> _getLastSync(String uid) async {
    final doc = await _firestore.doc('${_userPath(uid)}/meta/lastSync').get();
    return doc.data()?['timestamp'] as String?;
  }

  Future<void> _saveLastSync(String uid) async {
    await _firestore.doc('${_userPath(uid)}/meta/lastSync').set({
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<int> getUnsyncedCount(String uid) async {
    final db = await _db.database;
    int count = 0;
    for (final table in ['customers', 'transactions', 'debt_reminders']) {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as c FROM $table WHERE is_synced = 0',
      );
      count += result.first['c'] as int;
    }
    return count;
  }
}

// ======================== LOCAL REPO HELPERS ========================

class _CustomerSyncRepo {
  final DatabaseHelper _db;
  _CustomerSyncRepo(this._db);

  Future<List<Customer>> getUnsynced() async {
    final db = await _db.database;
    final result = await db.query('customers', where: 'is_synced = 0');
    return result.map((m) => Customer.fromMap(m)).toList();
  }

  Future<void> markSynced(List<String> ids) async {
    if (ids.isEmpty) return;
    final db = await _db.database;
    final ph = ids.map((_) => '?').join(',');
    await db.update(
      'customers',
      {'is_synced': 1},
      where: 'id IN ($ph)',
      whereArgs: ids,
    );
  }

  Future<void> upsertFromCloud(List<Customer> records) async {
    final db = await _db.database;
    for (final c in records) {
      final existing = await _getById(c.id!);
      if (existing == null) {
        await db.insert('customers', c.toMap());
      } else if (c.updatedAt.compareTo(existing.updatedAt) > 0) {
        await db.update(
          'customers',
          c.toMap(),
          where: 'id = ?',
          whereArgs: [c.id],
        );
      }
    }
  }

  Future<Customer?> _getById(String id) async {
    final db = await _db.database;
    final result = await db.query(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Customer.fromMap(result.first);
  }
}

class _TransactionSyncRepo {
  final DatabaseHelper _db;
  _TransactionSyncRepo(this._db);

  Future<List<model.Transaction>> getUnsynced() async {
    final db = await _db.database;
    final result = await db.query('transactions', where: 'is_synced = 0');
    return result.map((m) => model.Transaction.fromMap(m)).toList();
  }

  Future<void> markSynced(List<String> ids) async {
    if (ids.isEmpty) return;
    final db = await _db.database;
    final ph = ids.map((_) => '?').join(',');
    await db.update(
      'transactions',
      {'is_synced': 1},
      where: 'id IN ($ph)',
      whereArgs: ids,
    );
  }

  Future<void> upsertFromCloud(List<model.Transaction> records) async {
    final db = await _db.database;
    for (final t in records) {
      final existing = await _getById(t.id!);
      if (existing == null) {
        await db.insert('transactions', t.toMap());
      } else if (t.updatedAt.compareTo(existing.updatedAt) > 0) {
        await db.update(
          'transactions',
          t.toMap(),
          where: 'id = ?',
          whereArgs: [t.id],
        );
      }
    }
  }

  Future<model.Transaction?> _getById(String id) async {
    final db = await _db.database;
    final result = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return model.Transaction.fromMap(result.first);
  }
}

class _ReminderSyncRepo {
  final DatabaseHelper _db;
  _ReminderSyncRepo(this._db);

  Future<List<DebtReminder>> getUnsynced() async {
    final db = await _db.database;
    final result = await db.query('debt_reminders', where: 'is_synced = 0');
    return result.map((m) => DebtReminder.fromMap(m)).toList();
  }

  Future<void> markSynced(List<String> ids) async {
    if (ids.isEmpty) return;
    final db = await _db.database;
    final ph = ids.map((_) => '?').join(',');
    await db.update(
      'debt_reminders',
      {'is_synced': 1},
      where: 'id IN ($ph)',
      whereArgs: ids,
    );
  }

  Future<void> upsertFromCloud(List<DebtReminder> records) async {
    final db = await _db.database;
    for (final r in records) {
      final existing = await _getById(r.id!);
      if (existing == null) {
        await db.insert('debt_reminders', r.toMap());
      } else if (r.updatedAt.compareTo(existing.updatedAt) > 0) {
        await db.update(
          'debt_reminders',
          r.toMap(),
          where: 'id = ?',
          whereArgs: [r.id],
        );
      }
    }
  }

  Future<DebtReminder?> _getById(String id) async {
    final db = await _db.database;
    final result = await db.query(
      'debt_reminders',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return DebtReminder.fromMap(result.first);
  }
}
