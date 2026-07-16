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
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_debt_management/features/subscription/domain/exceptions/subscription_exception.dart';
import '../models/subscription_model.dart';

class SubscriptionRemoteDatasource {
  final FirebaseFirestore _firestore;

  SubscriptionRemoteDatasource(this._firestore);

  /// Fetch subscription from Firestore for the given user.
  /// Returns null if the document doesn't exist (new user).
  /// Also mirrors to top-level `subscriptions/{uid}` for admin dashboard backfill.
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

      // Backfill: mirror to top-level collection for admin dashboard
      final adminDoc = await _firestore.collection('subscriptions').doc(uid).get();
      if (!adminDoc.exists) {
        final user = FirebaseAuth.instance.currentUser;
        await _firestore.collection('subscriptions').doc(uid).set({
          ...data,
          'userName': user?.displayName ?? '',
          'userEmail': user?.email ?? '',
        }, SetOptions(merge: true));
      }

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
  /// Also mirrors to top-level `subscriptions/{uid}` for admin dashboard.
  /// Throws [SubscriptionRemoteException] on Firestore or network error.
  Future<void> save(String uid, SubscriptionModel sub, {String userName = '', String userEmail = ''}) async {
    try {
      final data = sub.toFirestore();
      final batch = _firestore.batch();

      final userSubRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('subscription')
          .doc('status');
      batch.set(userSubRef, data);

      final adminRef = _firestore.collection('subscriptions').doc(uid);
      batch.set(adminRef, {
        ...data,
        'userName': userName,
        'userEmail': userEmail,
      }, SetOptions(merge: true));

      await batch.commit();
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
}
