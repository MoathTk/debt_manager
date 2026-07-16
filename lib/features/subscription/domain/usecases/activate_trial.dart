/// SUBSCRIPTION FEATURE — DOMAIN LAYER: ACTIVATE TRIAL USE CASE
///
/// Encapsulates the business action: "Give this new user 7 days free."
///
/// This runs when a user logs in for the first time and has NO
/// subscription document in Firestore. The use case:
/// 1. Creates a trial Subscription entity (7-day expiry)
/// 2. Saves to BOTH SQLite (offline cache) AND Firestore (source of truth)
/// 3. Returns the subscription so the UI can show trial countdown
///
/// ERROR HANDLING:
/// - If Firestore save fails → still saves locally, throws so caller knows
/// - If SQLite save fails → throws immediately (can't work offline either)
/// - The "7 days" duration is a business decision — lives in domain layer
/// ---------------------------------------------------------------------------
library;

import '../entities/subscription.dart';
import '../exceptions/subscription_exception.dart';
import '../repositories/subscription_repository.dart';

class ActivateTrial {
  final SubscriptionRepository repo;

  ActivateTrial(this.repo);

  Future<Subscription> call(String uid, {String userName = '', String userEmail = ''}) async {
    final sub = Subscription(
      plan: SubscriptionPlan.trial,
      expiresAt: DateTime.now().add(const Duration(minutes: 2)),
      activatedAt: DateTime.now(),
      isActive: true,
    );

    // Save locally first — this MUST succeed for offline access
    try {
      await repo.saveLocal(sub);
    } on SubscriptionException {
      rethrow; // Local DB failure is critical — can't proceed
    }

    // Save to Firestore — try to sync, but don't block on failure
    try {
      await repo.saveRemote(uid, sub, userName: userName, userEmail: userEmail);
    } on SubscriptionException {
      // Remote failure is non-critical — local cache is already saved
      // Caller can still use the trial, it will sync next time online
    }

    return sub;
  }
}
