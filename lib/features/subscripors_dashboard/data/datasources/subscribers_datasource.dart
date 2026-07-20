import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subscriber_model.dart';

class SubscribersDatasource {
  final FirebaseFirestore _firestore;

  SubscribersDatasource(this._firestore);

  CollectionReference get _col => _firestore.collection('subscriptions');

  Future<List<SubscriberModel>> getAll() async {
    final snap = await _col.get();
    return snap.docs
        .map((d) => SubscriberModel.fromFirestore(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  Future<void> mirrorFromUser(String uid, SubscriberModel sub) async {
    await _col.doc(uid).set(sub.toFirestore(), SetOptions(merge: true));
  }

  Future<void> updateExpiry(String uid, DateTime newExpiry) async {
    final ts = Timestamp.fromDate(newExpiry);
    final batch = _firestore.batch();

    batch.update(_col.doc(uid), {'expiresAt': ts});

    batch.update(
      _firestore
          .collection('users')
          .doc(uid)
          .collection('subscription')
          .doc('status'),
      {'expiresAt': ts},
    );

    try {
      await batch.commit();
    } on FirebaseException catch (e) {
      throw Exception(
        "Failed to update subscription for $uid: ${e.message}",
      );
    }
  }
//dangrous in the failure !!
  Future<void> expireNow(String uid) async {
    final ts = Timestamp.fromDate(DateTime.now());
    final batch = _firestore.batch();

    batch.update(_col.doc(uid), {'expiresAt': ts});

    batch.update(
      _firestore
          .collection('users')
          .doc(uid)
          .collection('subscription')
          .doc('status'),
      {'expiresAt': ts},
    );

    try {
      await batch.commit();
    } on FirebaseException catch (e) {
      throw Exception(
        "Failed to expire subscription for $uid: ${e.message}",
      );
    }
  }

  Stream<List<SubscriberModel>> watchAll() {
    return _col.snapshots().map(
      (snap) => snap.docs
          .map((d) => SubscriberModel.fromFirestore(
              d.data() as Map<String, dynamic>, d.id))
          .toList(),
    );
  }
}
