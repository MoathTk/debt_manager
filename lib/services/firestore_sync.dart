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

  /// Push all unsynced local records to Firestore.
  /// Pull is handled by snapshots() listeners in SyncNotifier.
  Future<void> syncAll(String uid) async {
    print('[SYNC] push started uid=$uid');
    bool customersPushed = false;
    bool transactionsPushed = false;

    try {
      await _pushCustomers(uid);
      customersPushed = true;
    } catch (e) {
      print('[PUSH] customers FAILED: $e');
    }

    if (customersPushed) {
      try {
        await _pushTransactions(uid);
        transactionsPushed = true;
      } catch (e) {
        print('[PUSH] transactions FAILED: $e');
      }
    }

    if (transactionsPushed) {
      try {
        await _pushReminders(uid);
      } catch (e) {
        print('[PUSH] reminders FAILED: $e');
      }
    }

    print('[SYNC] push done');
  }

  // ======================== PUBLIC UPSERT (for snapshots) ========================

  Future<void> upsertCustomers(List<Customer> records) async {
    if (records.isEmpty) return;
    await _CustomerSyncRepo(_db).upsertFromCloud(records);
  }

  Future<void> upsertTransactions(List<model.Transaction> records) async {
    if (records.isEmpty) return;
    await _TransactionSyncRepo(_db).upsertFromCloud(records);
  }

  Future<void> upsertReminders(List<DebtReminder> records) async {
    if (records.isEmpty) return;
    await _ReminderSyncRepo(_db).upsertFromCloud(records);
  }

  // ======================== PUSH ========================

  static const _batchLimit = 500;

  Future<void> _pushCustomers(String uid) async {
    final repo = _CustomerSyncRepo(_db);
    final unsynced = await repo.getUnsynced();
    if (unsynced.isEmpty) return;
    print('[PUSH] customers: ${unsynced.length} unsynced');
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
      }
      await batch.commit();
    }
    await repo.markSynced(ids);
  }

  Future<void> _pushTransactions(String uid) async {
    final repo = _TransactionSyncRepo(_db);
    final unsynced = await repo.getUnsynced();
    if (unsynced.isEmpty) return;
    print('[PUSH] transactions: ${unsynced.length} unsynced');
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
      }
      await batch.commit();
    }
    await repo.markSynced(ids);
  }

  Future<void> _pushReminders(String uid) async {
    final repo = _ReminderSyncRepo(_db);
    final unsynced = await repo.getUnsynced();
    if (unsynced.isEmpty) return;
    print('[PUSH] reminders: ${unsynced.length} unsynced');
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
      }
      await batch.commit();
    }
    await repo.markSynced(ids);
  }

  // ======================== META ========================

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

  /// Deletes ALL user data from Firestore: customers, transactions,
  /// reminders, subscription, and meta. Also deletes the admin mirror.
  Future<void> deleteAllFirestoreData(String uid) async {
    final collections = [
      '${_userPath(uid)}/customers',
      '${_userPath(uid)}/transactions',
      '${_userPath(uid)}/reminders',
    ];
    for (final colPath in collections) {
      final snap = await _firestore.collection(colPath).get();
      for (var i = 0; i < snap.docs.length; i += _batchLimit) {
        final batch = _firestore.batch();
        final chunk = snap.docs.sublist(
          i,
          (i + _batchLimit > snap.docs.length)
              ? snap.docs.length
              : i + _batchLimit,
        );
        for (final doc in chunk) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
    }
    final batch = _firestore.batch();
    batch.delete(
      _firestore
          .collection('users')
          .doc(uid)
          .collection('subscription')
          .doc('status'),
    );
    batch.delete(_firestore.collection('subscriptions').doc(uid));
    batch.delete(_firestore.doc('${_userPath(uid)}/meta/lastSync'));
    await batch.commit();
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
