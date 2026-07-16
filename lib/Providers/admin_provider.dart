import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_debt_management/services/auth_service.dart';

final isAdminProvider = FutureProvider<bool>((ref) async {
  final uid = ref.watch(authServiceProvider).ownerId;
  if (uid == null) return false;
  try {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.data()?['role'] == 'admin';
  } catch (_) {
    return false;
  }
});
