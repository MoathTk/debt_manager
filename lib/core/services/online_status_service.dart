import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OnlineStatusService with WidgetsBindingObserver {
  OnlineStatusService._();
  static final instance = OnlineStatusService._();

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  void init() {
    WidgetsBinding.instance.addObserver(this);
    _setOnline();
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  Future<void> _setOnline() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _userDoc(uid).set({
      'isOnline': true,
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _setOffline() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _userDoc(uid).set({
      'isOnline': false,
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _setOnline();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _setOffline();
    }
  }
}
