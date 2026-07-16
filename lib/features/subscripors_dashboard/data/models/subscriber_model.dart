import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriberModel {
  final String uid;
  final String plan;
  final DateTime expiresAt;
  final DateTime activatedAt;
  final bool isActive;
  final String userName;
  final String userEmail;

  const SubscriberModel({
    required this.uid,
    required this.plan,
    required this.expiresAt,
    required this.activatedAt,
    required this.isActive,
    this.userName = '',
    this.userEmail = '',
  });

  int get daysRemaining => expiresAt.difference(DateTime.now()).inDays;
  bool get isExpired => expiresAt.isBefore(DateTime.now());

  String get statusLabel {
    if (isExpired) return 'expired';
    if (daysRemaining <= 1) return 'expiring';
    return 'active';
  }

  factory SubscriberModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return SubscriberModel(
      uid: uid,
      plan: data['plan'] ?? 'trial',
      expiresAt: _parseDate(data['expiresAt']),
      activatedAt: _parseDate(data['activatedAt']),
      isActive: data['is_active'] ?? false,
      userName: data['userName'] ?? '',
      userEmail: data['userEmail'] ?? '',
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  Map<String, dynamic> toFirestore() => {
    'plan': plan,
    'expiresAt': Timestamp.fromDate(expiresAt),
    'activatedAt': Timestamp.fromDate(activatedAt),
    'is_active': isActive,
    'userName': userName,
    'userEmail': userEmail,
  };
}
