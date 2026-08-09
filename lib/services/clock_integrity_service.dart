import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'monotonic_clock.dart';

/// Three-layer clock integrity defense against subscription time exploits.
///
/// LAYER 1 — NTP (when online):
///   Fetches real UTC time from Google's NTP servers via ntp package.
///   100% accurate, zero device clock dependency.
///
/// LAYER 2 — Monotonic boot clock (when offline, no reboot):
///   Uses Android's SystemClock.elapsedRealtime() — a kernel-level counter
///   that NEVER decreases and is NOT affected by device date/time changes.
///   Computes: trustedNow = ntpAnchor + (currentBootMs - storedBootMs)
///   This gives us real UTC time without trusting the device clock at all.
///
/// LAYER 3 — Device-time fallback (after reboot):
///   When boot timer resets, falls back to strict device-time comparison
///   with ZERO tolerance. Even 1ms behind the NTP anchor = blocked.
///
/// STALE DETECTION:
///   If boot delta exceeds 24 hours, the anchor is considered stale.
///   User must go online to re-verify.
///
/// POWER-OFF HANDLING:
///   Boot timer freezes when device is off. Uses max(trustedNow, deviceNow)
///   so that real (correct) device time fills the gap when phone is turned
///   back on. If device clock was also rolled back, reboot path catches it.
///
/// ZERO TOLERANCE:
///   No grace period for clock rollback. If any check says time was
///   manipulated, the user is blocked until online re-verification.
///
/// SECURE STORAGE (why not SharedPreferences?):
///   The three anchor values below are the crown jewels of this defense.
///   SharedPreferences stores them in a PLAINTEXT XML file on disk that
///   anyone with adb access or a rooted device can open and edit — an
///   attacker could simply move the expiry forward and the checks would be
///   fooled. So the anchors are persisted with flutter_secure_storage, which
///   encrypts them with keys held by the Android Keystore (or iOS Keychain).
///   Editing the storage file no longer reveals or changes the values.
///
///   Because secure storage only has an ASYNC API but the integrity check
///   must run synchronously (called from SubscriptionState.isBlocked), the
///   values are ALSO cached in memory (_ntpMs/_bootMs/_expiryMs). The sync
///   check reads ONLY the in-memory cache; every async entry point
///   (init, markTrustedTime, clear) keeps the cache in sync with secure
///   storage. This keeps the sync path fast and exception-free.
class ClockIntegrityService {
  // Secure storage keys
  static const _keyNtp = 'last_trusted_time'; //the last one from online.
  static const _keyBoot = 'last_boot_ms'; //the last power on boos ms.
  static const _keyExpiry = 'last_trusted_expiry';

  // Encrypted storage instance.
  // encryptedSharedPreferences=false keeps compatibility with devices below
  // Android API 23 (this app's minSdk is 21). The values are STILL encrypted
  // (AES via Keystore-held keys / iOS Keychain) — never plaintext on disk.
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: false),
  );

  // In-memory anchor cache. This is the ONLY thing the synchronous integrity
  // check reads (secure storage has no sync API). All async methods below
  // keep it in sync with secure storage.
  static int? _ntpMs;
  static int? _bootMs;
  static int? _expiryMs;

  // Cached boot time for synchronous access from SubscriptionState.isBlocked.
  // Updated every 30 seconds by a timer, and immediately after markTrustedTime().
  static int? _cachedBootMs;
  static Timer? _refreshTimer;

  /// Initialize secure storage, load the persisted anchor into memory, and
  /// start the boot-time refresh timer. Called once from main.dart at startup.
  static Future<void> init() async {
    await _loadAnchorFromStorage();
    _startBootRefresh();
  }

  /// Load the persisted anchor (if any) from secure storage into memory.
  /// Wrapped in try/catch so a transient platform error (e.g. Keystore hiccup)
  /// can never prevent the app from starting — worst case we behave like a
  /// new user until the next online verification re-anchors.
  static Future<void> _loadAnchorFromStorage() async {
    try {
      _ntpMs = int.tryParse(await _storage.read(key: _keyNtp) ?? '');
      _bootMs = int.tryParse(await _storage.read(key: _keyBoot) ?? '');
      _expiryMs = int.tryParse(await _storage.read(key: _keyExpiry) ?? '');
    } catch (e) {
      _ntpMs = _bootMs = _expiryMs = null;
    }
  }

  /// Periodically refresh the cached boot time so the sync getter has fresh data.
  static void _startBootRefresh() {
    MonotonicClock.millis().then((ms) => _cachedBootMs = ms);
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      _cachedBootMs = await MonotonicClock.millis();
    });
  }

  /// Store a trusted time anchor from an online verification.
  ///
  /// Called when:
  ///   - CheckSubscription.call() successfully fetches from Firestore
  ///   - Firestore snapshot listener receives a subscription document
  ///
  /// Stores three values atomically:
  ///   [trustedNow] — NTP server time (absolute UTC)
  ///   [expiresAt]  — Firestore server timestamp from the subscription document
  ///   [bootMs]     — Kernel monotonic counter at this instant
  static Future<void> markTrustedTime({
    required DateTime trustedNow,
    required DateTime expiresAt,
  }) async {
    final bootMs = await MonotonicClock.millis();

    // Update the in-memory cache FIRST so the sync getter is correct even if
    // the async encrypted write below is slow or fails.
    _cachedBootMs = bootMs;
    _ntpMs = trustedNow.millisecondsSinceEpoch;
    _bootMs = bootMs;
    _expiryMs = expiresAt.millisecondsSinceEpoch;

    // Persist encrypted. A write failure is logged, not fatal: memory is
    // already updated for this session, and the next online verify re-anchors.
    try {
      await _storage.write(key: _keyNtp, value: '$_ntpMs');
      await _storage.write(key: _keyBoot, value: '$_bootMs');
      await _storage.write(key: _keyExpiry, value: '$_expiryMs');
    } catch (e) {
      // ignore: avoid_print
      print('[ClockIntegrity] secure write failed: $e');
    }
  }

  /// Synchronous integrity check — called by SubscriptionState.isBlocked getter.
  ///
  /// Returns false if the clock has been tampered with or the anchor is stale.
  ///
  /// PATH A — Monotonic boot clock (preferred, no reboot since last check):
  ///   trustedNow = ntpAnchor + (cachedBootMs - storedBootMs)
  ///   effectiveNow = max(trustedNow, DateTime.now())
  ///   Uses max() to handle power-off: boot timer freezes while off, but
  ///   device clock advances. If device clock is intact (ahead), it fills
  ///   the gap. If device clock was rolled back, max picks the boot-based
  ///   trustedNow instead.
  ///
  /// PATH B — Reboot fallback (boot timer reset):
  ///   Strict device-time comparison with ZERO tolerance.
  ///   Even 1ms behind the NTP anchor = blocked.
  /// //if it return a enum type that will be much better for us all.
  static bool isClockIntactSync() {
    // Reads come from the in-memory cache, which init()/markTrustedTime()/
    // clear() keep in sync with secure storage.
    final ntpMs = _ntpMs;
    final bootMs = _bootMs;
    final expiryMs = _expiryMs;

    // No anchor yet — new user or trial not activated. Not blocked.
    if (ntpMs == null) return true;

    // PATH A: monotonic boot clock available (no reboot)
    if (bootMs != null && _cachedBootMs != null && _cachedBootMs! >= bootMs) {
      // Stale detection: if boot delta > 24h, require online re-verification
      if (_cachedBootMs! - bootMs > const Duration(days: 1).inMilliseconds) {
        return false;
      }

      // Compute trusted UTC time from boot delta (device-clock-independent)
      final trustedNowMs = ntpMs + (_cachedBootMs! - bootMs);

      // Use max() to handle power-off: device clock fills the gap
      // when boot timer was frozen while phone was off
      final deviceNowMs = DateTime.now().millisecondsSinceEpoch;
      final effectiveNowMs = deviceNowMs > trustedNowMs
          ? deviceNowMs
          : trustedNowMs;

      // Check against stored server expiry (absolute UTC).
      // Tolerance = 1 minute to match the entity's grace period
      // (subscription.dart: status is "grace" for ~1 min after expiry).
      // Without this, the clock check would block users 100ms after expiry,
      // silently killing the grace period the UI is supposed to show.
      if (expiryMs != null && effectiveNowMs > expiryMs + 60000) {
        return false;
      }
      return true;
    }

    // PATH B: reboot detected or no boot cache
    // Strict device-time fallback with ZERO tolerance
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    if (nowMs < ntpMs) return false;
    // Also catch rollback past the stored expiry if the sub was already expired
    // at the time of the last check
    if (expiryMs != null && ntpMs > expiryMs && nowMs < expiryMs) return false;
    return true;
  }

  /// Async integrity check — called by CheckSubscription in the offline path.
  ///
  /// Fetches a fresh boot time before delegating to the sync logic.
  static Future<bool> isClockIntact() async {
    _cachedBootMs = await MonotonicClock.millis();
    return isClockIntactSync();
  }

  /// Returns true if a trusted time anchor is currently stored.
  ///
  /// Used by the online verification path: if every online time source fails
  /// (see trusted_time.dart), we must NOT overwrite an existing good anchor
  /// with device time. Only when NO anchor exists at all (fresh install /
  /// first activation) do we allow the device-time last resort.
  ///
  /// Reads the in-memory cache, which is the same data the sync check uses.
  static Future<bool> hasAnchor() async => _ntpMs != null;

  /// Clear all stored trust data. Called on:
  ///   - User sign-out (auth_service.dart)
  ///   - Remote subscription document deleted (check_subscription.dart)
  static Future<void> clear() async {
    // Clear the in-memory cache first (the sync getter must reflect this
    // immediately), then remove the encrypted values.
    _ntpMs = null;
    _bootMs = null;
    _expiryMs = null;
    try {
      await _storage.delete(key: _keyNtp);
      await _storage.delete(key: _keyBoot);
      await _storage.delete(key: _keyExpiry);
    } catch (e) {
      // ignore: avoid_print
      print('[ClockIntegrity] secure delete failed: $e');
    }
  }
}
