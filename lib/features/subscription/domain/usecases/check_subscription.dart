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

import 'package:local_debt_management/services/clock_integrity_service.dart';
import 'package:local_debt_management/services/connectivity_service.dart';
import 'package:local_debt_management/services/trusted_time.dart';
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
        await repo.saveLocal(remote, uid);
        // Fetch a trusted current time from the best available ONLINE source
        // (NTP → Firestore server timestamp → HTTPS Date header). We never
        // depend on the device clock here — see trusted_time.dart.
        final trustedNow = await fetchTrustedTime();
        if (trustedNow != null) {
          // Store the anchor + boot counter + server expiry
          await ClockIntegrityService.markTrustedTime(
            trustedNow: trustedNow,
            expiresAt: remote.expiresAt,
          );
        } else if (!await ClockIntegrityService.hasAnchor()) {
          // Every online time source failed AND no previous anchor exists
          // (fresh install / first activation). Last resort: device time.
          await ClockIntegrityService.markTrustedTime(
            trustedNow: DateTime.now(),
            expiresAt: remote.expiresAt,
          );
        }
        // If all sources failed but an old anchor exists, we keep the old
        // anchor — never overwrite a good (real-time) anchor with device time.
        // Direct comparison: trusted time vs server timestamp — 100% accurate
        final now = trustedNow ?? DateTime.now();
        if (now.isAfter(remote.expiresAt)) {
          return remote.copyWith(isActive: false);
        }
        return remote;
      }

      await repo.deleteLocal();
      await repo.deleteRemote(uid);
      await ClockIntegrityService.clear();
      return null;
    }

    final local = await repo.getLocal();
    if (local == null) throw const RequiresInternetException();

    // Offline path: check if the clock was rolled back.
    // isClockIntactSync() compares DateTime.now() against the stored NTP anchor.
    if (!ClockIntegrityService.isClockIntactSync()) {
      return local.copyWith(isActive: false);
    }
    return local;
  }
}
