/// SUBSCRIPTION FEATURE — DOMAIN LAYER: CHECK SUBSCRIPTION USE CASE
///
/// A use case encapsulates a single business action.
/// "CheckSubscription" answers: "Is this user allowed to use the app?"
///
/// USE CASE RULES:
/// - Each use case does ONE thing (Single Responsibility)
/// - It calls the repository (abstract interface) — never touches
///   SQLite or Firestore directly
/// - Business logic lives here; UI and data details do NOT
///
/// OFFLINE-FIRST STRATEGY:
/// 1. If online  → fetch from Firestore → cache in SQLite → return
/// 2. If offline → read from SQLite cache → return
/// 3. If offline + no cache → throw RequiresInternetException
///
/// ERROR PROPAGATION:
/// - [SubscriptionRemoteException] if Firestore fails (network, permission)
/// - [SubscriptionLocalException] if SQLite fails (corrupted, locked)
/// - [RequiresInternetException] if offline + no cache
/// - [SubscriptionParsingException] if stored data is corrupt
/// ---------------------------------------------------------------------------
library;

import 'package:local_debt_management/services/connectivity_service.dart';
import '../entities/subscription.dart';
import '../exceptions/subscription_exception.dart';
import '../repositories/subscription_repository.dart';

class CheckSubscription {
  final SubscriptionRepository repo;
  final ConnectivityService connectivity;

  CheckSubscription(this.repo, this.connectivity);

  /// Returns [Subscription] if found, null if new user (no doc yet),
  /// or throws a [SubscriptionException] subclass.
  Future<Subscription?> call(String uid) async {
    if (await connectivity.checkConnection()) {
      final remote = await repo.getRemote(uid);
      if (remote != null) {
        await repo.saveLocal(remote);
        return remote;
      }
      return null; // New user — no subscription doc in Firestore yet
    }
    final local = await repo.getLocal();
    if (local != null) return local;
    throw const RequiresInternetException();
  }
}
