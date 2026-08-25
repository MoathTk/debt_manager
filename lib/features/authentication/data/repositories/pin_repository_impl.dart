/// AUTHENTICATION FEATURE — DATA LAYER: REPOSITORY IMPLEMENTATION
///
/// Implements [PinRepository] using Flutter Secure Storage + Firestore.
///
/// ARCHITECTURE RULE: This is the ONLY place that knows about storage APIs.
/// The domain layer never sees this implementation.
/// ---------------------------------------------------------------------------
library;

import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/repositories/pin_repository.dart';

class PinRepositoryImpl implements PinRepository {
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: false),
  );

  static String _secureKey(String uid) => 'user_pin_$uid';
  static String _saltKey(String uid) => 'user_pin_salt_$uid';

  static Future<String> _hashPin(String pin, String salt) async {
    final bytes = utf8.encode('$salt$pin');
    return sha256.convert(bytes).toString();
  }

  static String _generateSalt() {
    final rng = Random.secure();
    return List.generate(
      16,
      (_) => rng.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }

  @override
  Future<void> savePin({
    required String uid,
    required String pin,
    required String name,
    required String phone,
  }) async {
    final salt = _generateSalt();
    final hash = await _hashPin(pin, salt);

    await Future.wait([
      _secureStorage.write(key: _secureKey(uid), value: hash),
      _secureStorage.write(key: _saltKey(uid), value: salt),
    ]);

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'pinHash': hash,
      'pinSalt': salt,
      'name': name,
      'phone': phone,
      'role': 'user',
    }, SetOptions(merge: true));
  }

  @override
  Future<bool> hasPin(String uid) async {
    final local = await _secureStorage.read(key: _secureKey(uid));
    if (local != null) return true;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    return doc.data()?['pinHash'] != null;
  }

  @override
  Future<bool> validatePin({
    required String uid,
    required String pin,
  }) async {
    var hash = await _secureStorage.read(key: _secureKey(uid));
    var salt = await _secureStorage.read(key: _saltKey(uid));

    if (hash == null || salt == null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final data = doc.data();
      if (data == null) return false;

      hash = data['pinHash'] as String?;
      salt = data['pinSalt'] as String?;
      if (hash == null || salt == null) return false;

      await _secureStorage.write(key: _secureKey(uid), value: hash);
      await _secureStorage.write(key: _saltKey(uid), value: salt);
    }

    final inputHash = await _hashPin(pin, salt);
    return inputHash == hash;
  }

  @override
  Future<Map<String, String>?> getUserProfile(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    final data = doc.data();
    if (data == null) return null;
    return {
      'name': (data['name'] as String?) ?? '',
      'phone': (data['phone'] as String?) ?? '',
    };
  }

  @override
  Future<void> clearPin(String uid) async {
    await Future.wait([
      _secureStorage.delete(key: _secureKey(uid)),
      _secureStorage.delete(key: _saltKey(uid)),
    ]);
  }
}
