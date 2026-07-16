import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/database_helper.dart';
import '../data/models/customer.dart';
import '../data/models/transaction.dart' as model;
import '../data/models/debt_reminder.dart';

class FirestoreSync {
  final _db = DatabaseHelper.instance;
  final FirebaseFirestore _firestore;

  FirestoreSync({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  String _userPath(String uid) => 'users/$uid';

  String? _maxTimestamp(String? a, String? b) {
    if (a == null) return b;
    if (b == null) return a;
    return a.compareTo(b) > 0 ? a : b;
  }

   

  Future<void> syncAll(String uid) async {
    print('[SYNC] syncAll started uid=$uid');
    String? pushMax;
    bool customersPushed = false;
    bool transactionsPushed = false;

    // PUSH PHASE (dependency chain: customers → transactions → reminders)
    try {
      final m = await _pushCustomers(uid);
      pushMax = _maxTimestamp(pushMax, m);
      customersPushed = true;
    } catch (e) {
      print('[PUSH] customers FAILED: $e');
    }

    if (customersPushed) {
      try {
        final m = await _pushTransactions(uid);
        pushMax = _maxTimestamp(pushMax, m);
        transactionsPushed = true;
      } catch (e) {
        print('[PUSH] transactions FAILED: $e');
      }
    }

    if (transactionsPushed) {
      try {
        final m = await _pushReminders(uid);
        pushMax = _maxTimestamp(pushMax, m);
      } catch (e) {
        print('[PUSH] reminders FAILED: $e');
      }
    }

    // PULL PHASE — always fetch ALL records (no lastSync filter)
    bool pullOk = true;
    String? pullMax;

    try {
      final m = await _pullCustomers(uid);
      pullMax = _maxTimestamp(pullMax, m);
    } catch (e) {
      print('[PULL] customers FAILED: $e');
      pullOk = false;
    }
    try {
      final m = await _pullTransactions(uid);
      pullMax = _maxTimestamp(pullMax, m);
    } catch (e) {
      print('[PULL] transactions FAILED: $e');
      pullOk = false;
    }
    try {
      final m = await _pullReminders(uid);
      pullMax = _maxTimestamp(pullMax, m);
    } catch (e) {
      print('[PULL] reminders FAILED: $e');
      pullOk = false;
    }

    final bestTimestamp = _maxTimestamp(pushMax, pullMax);
    if (pullOk && bestTimestamp != null) {
      await _saveLastSync(uid, bestTimestamp);
    } else if (!pullOk) {
      print('[SYNC] partial — lastSync NOT advanced');
    }
    print('[SYNC] syncAll done pushMax=$pushMax pullMax=$pullMax pullOk=$pullOk');
  }

  // ======================== PUSH ========================

  static const _batchLimit = 500;

  Future<String?> _pushCustomers(String uid) async {
    final repo = _CustomerSyncRepo(_db);
    final unsynced = await repo.getUnsynced();
    if (unsynced.isEmpty) return null;
    print('[PUSH] customers: ${unsynced.length} unsynced');
    String? maxTs;
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
        ids.add(c.id);
        maxTs = _maxTimestamp(maxTs, c.updatedAt);
      }
      await batch.commit();
    }
    await repo.markSynced(ids);
    return maxTs;
  }

  Future<String?> _pushTransactions(String uid) async {
    final repo = _TransactionSyncRepo(_db);
    final unsynced = await repo.getUnsynced();
    if (unsynced.isEmpty) return null;
    print('[PUSH] transactions: ${unsynced.length} unsynced');
    String? maxTs;
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
        ids.add(t.id);
        maxTs = _maxTimestamp(maxTs, t.updatedAt);
      }
      await batch.commit();
    }
    await repo.markSynced(ids);
    return maxTs;
  }

  Future<String?> _pushReminders(String uid) async {
    final repo = _ReminderSyncRepo(_db);
    final unsynced = await repo.getUnsynced();
    if (unsynced.isEmpty) return null;
    print('[PUSH] reminders: ${unsynced.length} unsynced');
    String? maxTs;
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
        ids.add(r.id);
        maxTs = _maxTimestamp(maxTs, r.updatedAt);
      }
      await batch.commit();
    }
    await repo.markSynced(ids);
    return maxTs;
  }

  // ======================== PULL ========================

  Future<String?> _pullCustomers(String uid) async {
    final repo = _CustomerSyncRepo(_db);
    final lastSync = await _getLastSync(uid);
    Query query = _firestore.collection('${_userPath(uid)}/customers');
    if (lastSync != null) {
      query = query.where('updated_at', isGreaterThan: lastSync);
    }
    final snap = await query.get();
    final records = snap.docs
        .map((d) => Customer.fromMap(d.data() as Map<String, dynamic>))
        .toList();
    print('[PULL] customers: ${records.length} fetched (lastSync=$lastSync)');
    if (records.isEmpty) return null;
    await repo.upsertFromCloud(records);
    return records.map((r) => r.updatedAt).reduce((a, b) => a.compareTo(b) > 0 ? a : b);
  }

  Future<String?> _pullTransactions(String uid) async {
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
    print('[PULL] transactions: ${records.length} fetched (lastSync=$lastSync)');
    if (records.isEmpty) return null;
    await repo.upsertFromCloud(records);
    return records.map((r) => r.updatedAt).reduce((a, b) => a.compareTo(b) > 0 ? a : b);
  }

  Future<String?> _pullReminders(String uid) async {
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
    print('[PULL] reminders: ${records.length} fetched (lastSync=$lastSync)');
    if (records.isEmpty) return null;
    await repo.upsertFromCloud(records);
    return records.map((r) => r.updatedAt).reduce((a, b) => a.compareTo(b) > 0 ? a : b);
  }

  // ======================== META ========================

  Future<String?> _getLastSync(String uid) async {
    final doc = await _firestore.doc('${_userPath(uid)}/meta/lastSync').get();
    return doc.data()?['timestamp'] as String?;
  }

  Future<void> _saveLastSync(String uid, String maxUpdatedAt) async {
    await _firestore.doc('${_userPath(uid)}/meta/lastSync').set({
      'timestamp': maxUpdatedAt,
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

  Future<void> deleteLastSyncMetadata(String uid) async {
    await _firestore.doc('${_userPath(uid)}/meta/lastSync').delete();
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
      final existing = await _getById(c.id);
      if (existing == null) {
        final map = c.toMap();
        map['is_synced'] = 1;
        await db.insert('customers', map);
      } else if (c.updatedAt.compareTo(existing.updatedAt) > 0) {
        final map = c.toMap();
        map['is_synced'] = 1;
        await db.update('customers', map, where: 'id = ?', whereArgs: [c.id]);
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
      final existing = await _getById(t.id);
      if (existing == null) {
        final map = t.toMap();
        map['is_synced'] = 1;
        await db.insert('transactions', map);
      } else if (t.updatedAt.compareTo(existing.updatedAt) > 0) {
        final map = t.toMap();
        map['is_synced'] = 1;
        await db.update(
          'transactions',
          map,
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
      final existing = await _getById(r.id);
      if (existing == null) {
        final map = r.toMap();
        map['is_synced'] = 1;
        await db.insert('debt_reminders', map);
      } else if (r.updatedAt.compareTo(existing.updatedAt) > 0) {
        final map = r.toMap();
        map['is_synced'] = 1;
        await db.update(
          'debt_reminders',
          map,
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
