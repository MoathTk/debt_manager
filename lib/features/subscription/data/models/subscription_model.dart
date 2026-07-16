/// SUBSCRIPTION FEATURE — DATA LAYER: MODEL
///
/// The model extends the domain entity and adds SERIALIZATION —
/// the ability to convert between the entity and storage formats.
///
/// WHY A SEPARATE MODEL?
/// - Domain entity: pure Dart, no imports from sqflite/cloud_firestore
/// - Data model: knows HOW to serialize for SQLite AND Firestore
/// - This keeps the domain layer clean and testable
///
/// STORAGE FORMAT MAPPING:
/// - SQLite uses snake_case keys and integers for booleans:
///     { plan: "monthly", expires_at: "ISO8601", is_active: 1 }
/// - Firestore uses camelCase keys and native booleans:
///     { plan: "monthly", expiresAt: "ISO8601", is_active: true }
/// ---------------------------------------------------------------------------
library;

import 'package:local_debt_management/features/subscription/domain/entities/subscription.dart';

/// Data model extending domain entity with serialization logic.
/// Used by datasources to convert between entity ↔ storage format.
class SubscriptionModel extends Subscription {
  const SubscriptionModel({
    required super.plan,
    required super.expiresAt,
    required super.activatedAt,
    required super.isActive,
  });

  /// Deserialize from SQLite row → SubscriptionModel.
  factory SubscriptionModel.fromMap(Map<String, dynamic> m) {
    return SubscriptionModel(
      plan: _parsePlan(m['plan'] as String),
      expiresAt: DateTime.parse(m['expires_at'] as String),
      activatedAt: DateTime.parse(m['activated_at'] as String),
      isActive: (m['is_active'] as int) == 1,
    );
  }

  /// Serialize to SQLite-compatible map (snake_case, int booleans).
  Map<String, dynamic> toMap() {
    return {
      'plan': plan.name,
      'expires_at': expiresAt.toIso8601String(),
      'activated_at': activatedAt.toIso8601String(),
      'is_active': isActive ? 1 : 0,
    };
  }

  /// Deserialize from Firestore document → SubscriptionModel.
  factory SubscriptionModel.fromFirestore(Map<String, dynamic> data) {
    return SubscriptionModel(
      plan: _parsePlan(data['plan'] as String),
      expiresAt: DateTime.parse(data['expiresAt'] as String),
      activatedAt: DateTime.parse(data['activatedAt'] as String),
      isActive: data['is_active'] as bool? ?? true,
    );
  }

  /// Serialize to Firestore-compatible map (camelCase, native booleans).
  Map<String, dynamic> toFirestore() {
    return {
      'plan': plan.name,
      'expiresAt': expiresAt.toIso8601String(),
      'activatedAt': activatedAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  /// Safely parse plan string → enum, defaulting to trial if unknown.
  static SubscriptionPlan _parsePlan(String value) {
    return SubscriptionPlan.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SubscriptionPlan.trial,
    );
  }
}
