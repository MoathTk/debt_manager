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
    await _col.doc(uid).update({
      'expiresAt': Timestamp.fromDate(newExpiry),
    });
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
