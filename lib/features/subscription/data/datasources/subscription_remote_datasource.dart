/// SUBSCRIPTION FEATURE — DATA LAYER: REMOTE DATASOURCE (Firestore)
///
/// Handles all Firestore operations for subscription verification.
/// This is the "online" side — the source of truth.
///
/// FIRESTORE STRUCTURE:
///   users/{uid}/subscription/status: {
///     plan: "trial" | "weekly" | "monthly",
///     expiresAt: "2026-07-23T10:00:00Z",
///     activatedAt: "2026-07-16T10:00:00Z",
///     is_active: true
///   }
///
/// ERROR HANDLING:
/// - All operations throw [SubscriptionRemoteException] on failure
/// - Network errors, permission errors, and parse errors are all caught
/// ---------------------------------------------------------------------------
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_debt_management/features/subscription/domain/exceptions/subscription_exception.dart';
import '../models/subscription_model.dart';

class SubscriptionRemoteDatasource {
  final FirebaseFirestore _firestore;

  SubscriptionRemoteDatasource(this._firestore);

  /// Fetch subscription from Firestore for the given user.
  /// Returns null if the document doesn't exist (new user).
  Future<SubscriptionModel?> get(String uid) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('subscription')
          .doc('status')
          .get();
      final data = doc.data();
      if (data == null) return null;

      return SubscriptionModel.fromFirestore(data);
    } on FirebaseException catch (e) {
      throw SubscriptionRemoteException(
        'Firestore read failed: ${e.message}',
        e,
      );
    } catch (e) {
      throw SubscriptionRemoteException(
        'Unexpected error reading subscription',
        e,
      );
    }
  }

  /// Write subscription to Firestore (set = create or overwrite).
  /// Throws [SubscriptionRemoteException] on Firestore or network error.
  Future<void> save(String uid, SubscriptionModel sub) async {
    try {
      final data = sub.toFirestore();

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('subscription')
          .doc('status')
          .set(data);
    } on FirebaseException catch (e) {
      throw SubscriptionRemoteException(
        'Firestore write failed: ${e.message}',
        e,
      );
    } catch (e) {
      throw SubscriptionRemoteException(
        'Unexpected error saving subscription',
        e,
      );
    }
  }

  /// Delete subscription from Firestore.
  Future<void> delete(String uid) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('subscription')
          .doc('status')
          .delete();
    } on FirebaseException catch (e) {
      throw SubscriptionRemoteException(
        'Firestore delete failed: ${e.message}',
        e,
      );
    } catch (e) {
      throw SubscriptionRemoteException(
        'Unexpected error deleting subscription',
        e,
      );
    }
  }
}
