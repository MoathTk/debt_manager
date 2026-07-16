/// SUBSCRIPTION FEATURE — DOMAIN LAYER: REPOSITORY INTERFACE
///
/// This is the "contract" that the data layer must implement.
/// The domain layer says: "I need to read/write subscriptions,
/// but I don't care HOW — SQLite? Firestore? HTTP? I don't know."
///
/// This is the Dependency Inversion Principle (D):
/// - Domain defines the interface
/// - Data layer implements it
/// - Use cases depend on the interface, not the implementation
///
/// ARCHITECTURE RULE: This file must never import from data/ or presentation/.
/// ---------------------------------------------------------------------------
library;

import '../entities/subscription.dart';

abstract class SubscriptionRepository {
  /// Read subscription from local SQLite cache.
  Future<Subscription?> getLocal();

  /// Read subscription from Firestore (source of truth).
  Future<Subscription?> getRemote(String uid);

  /// Write subscription to local SQLite cache (for offline use).
  Future<void> saveLocal(Subscription sub);

  /// Write subscription to Firestore (source of truth).
  Future<void> saveRemote(String uid, Subscription sub, {String userName, String userEmail});

  /// Delete local cache (e.g., on sign-out or DB reset).
  Future<void> deleteLocal();
}
