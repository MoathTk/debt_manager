/// SUBSCRIPTION FEATURE — DATA LAYER: LOCAL DATASOURCE (SQLite)
///
/// Handles all SQLite operations for the subscription cache.
/// This is the "offline" side of the data layer.
///
/// WHY A LOCAL CACHE?
/// - Firestore is the source of truth, but requires internet
/// - SQLite lets us check subscription status when offline
/// - If user deletes SQLite → forces online re-verification
///
/// ERROR HANDLING:
/// - All operations throw [SubscriptionLocalException] on failure
/// - Callers (repository impl) can catch and handle or re-throw
/// ---------------------------------------------------------------------------
library;

import 'package:sqflite/sqflite.dart';
import 'package:local_debt_management/data/database_helper.dart';
import 'package:local_debt_management/features/subscription/domain/exceptions/subscription_exception.dart';
import '../models/subscription_model.dart';

class SubscriptionLocalDatasource {
  final DatabaseHelper _db;

  SubscriptionLocalDatasource(this._db);

  /// Read the cached subscription from SQLite.
  /// Returns null if no record exists (first launch, or DB was deleted).
  /// Throws [SubscriptionLocalException] on database error.
  Future<SubscriptionModel?> get() async {
    try {
      final database = await _db.database;
      final rows = await database.query('user_subscription', limit: 1);
      if (rows.isEmpty) return null;
      return SubscriptionModel.fromMap(rows.first);
    } catch (e) {
      throw SubscriptionLocalException('Failed to read subscription', e);
    }
  }

  /// Write subscription to SQLite cache.
  /// Uses ConflictAlgorithm.replace so re-login overwrites stale data.
  /// Throws [SubscriptionLocalException] on database error.
  Future<void> save(SubscriptionModel sub, String userId) async {
    try {
      final database = await _db.database;
      final result = await database.insert(
        'user_subscription',
        {'user_id': userId, ...sub.toMap()},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print("result: " + result.toString()
      );
      if (result == 0) {
        throw SubscriptionLocalException(
          'Insert returned 0 — row was not saved',
        );
      }
    } on SubscriptionLocalException {
      rethrow;
    } catch (e) {
      throw SubscriptionLocalException('Failed to save subscription', e);
    }
  }

  /// Delete cached subscription.
  /// No-op if no row exists (idempotent).
  Future<void> delete() async {
    try {
      final database = await _db.database;
      await database.delete('user_subscription');
    } catch (e) {
      throw SubscriptionLocalException('Failed to delete subscription', e);
    }
  }
}
