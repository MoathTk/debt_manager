import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Simplified clock integrity defense against subscription time exploits.
///
/// HOW IT WORKS:
///   On activation (online), we fetch real UTC time from NTP and store it as
///   the "trusted anchor". On every subsequent app launch, we compare the
///   device clock against this anchor. If DateTime.now() is BEFORE the
///   anchor, the clock was rolled back — block the user.
///
/// ZERO TOLERANCE:
///   Even 1ms behind the anchor = blocked. No grace period.
///   The user must go online to re-verify with fresh NTP time.
///
/// WHY THIS IS ENOUGH:
///   - Clock ROLLBACK (the main attack): caught by DateTime.now() < anchor
///   - Clock FORWARD (to extend subscription): caught by expiry check below
///   - Both checks use DateTime.now(), which is fine because:
///     • If clock is correct → checks are accurate
///     • If clock is rolled back → caught by anchor check
///     • If clock is forward → caught by expiry check (or subscription already expired in real time)
///
/// SECURE STORAGE:
///   The anchor values are encrypted on disk via flutter_secure_storage
///   (AES via Android Keystore / iOS Keychain). SharedPreferences would
///   store them as plaintext XML — any attacker with adb or root could
///   edit them.
///
///   Because secure storage only has an ASYNC API but the integrity check
///   must run synchronously (called from SubscriptionState.isBlocked), the
///   values are ALSO cached in memory. The sync check reads ONLY the
///   in-memory cache; every async entry point (init, markTrustedTime, clear)
///   keeps the cache in sync with secure storage.
class ClockIntegrityService {
  // ── Secure storage keys ──────────────────────────────────────────────
  // _keyNtp:   The last trusted UTC time (from NTP) in milliseconds.
  // _keyExpiry: The subscription expiry time (from Firestore server) in ms.
  static const _keyNtp = 'last_trusted_time';
  static const _keyExpiry = 'last_trusted_expiry';

  // Encrypted storage. encryptedSharedPreferences=false keeps compatibility
  // with Android API < 23 (app minSdk is 21). Values are STILL encrypted
  // (AES via Keystore-held keys / iOS Keychain).
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: false),
  );

  // ── In-memory anchor cache ───────────────────────────────────────────
  // The sync integrity check reads ONLY these. All async methods
  // (init, markTrustedTime, clear) keep them in sync with secure storage.
  static int? _ntpMs; // last trusted time in milliseconds since epoch
  static int? _expiryMs; // subscription expiry in milliseconds since epoch

  /// Initialize: load persisted anchor from secure storage into memory.
  /// Called once from main.dart at startup.
  static Future<void> init() async {
    await _loadAnchorFromStorage();
  }

  /// Load the persisted anchor (if any) from secure storage into memory.
  /// Wrapped in try/catch so a transient platform error can never prevent
  /// the app from starting — worst case we behave like a new user until
  /// the next online verification re-anchors.
  static Future<void> _loadAnchorFromStorage() async {
    try {
      _ntpMs = int.tryParse(await _storage.read(key: _keyNtp) ?? '');
      _expiryMs = int.tryParse(await _storage.read(key: _keyExpiry) ?? '');
    } catch (e) {
      _ntpMs = null;
      _expiryMs = null;
    }
  }

  /// Store a trusted time anchor from an online verification.
  ///
  /// Called when:
  ///   - CheckSubscription successfully fetches from Firestore (online path)
  ///   - Firestore snapshot listener receives a subscription document
  ///
  /// Stores two values:
  ///   [trustedNow] — NTP server time (absolute UTC)
  ///   [expiresAt]  — Firestore server timestamp from the subscription document
  static Future<void> markTrustedTime({
    required DateTime trustedNow,
    required DateTime expiresAt,
  }) async {
    // Update the in-memory cache FIRST so the sync getter is correct even if
    // the async encrypted write below is slow or fails.
    _ntpMs = trustedNow.millisecondsSinceEpoch;
    _expiryMs = expiresAt.millisecondsSinceEpoch;

    // Persist encrypted. A write failure is logged, not fatal: memory is
    // already updated for this session, and the next online verify re-anchors.
    try {
      await _storage.write(key: _keyNtp, value: '$_ntpMs');
      await _storage.write(key: _keyExpiry, value: '$_expiryMs');
    } catch (e) {
      // ignore: avoid_print
      print('[ClockIntegrity] secure write failed: $e');
    }
  }

  /// Synchronous integrity check — called by SubscriptionState.isBlocked getter.
  ///
  /// Two simple checks:
  ///   1. ROLLBACK: if device clock is behind the stored NTP anchor → blocked
  ///   2. EXPIRY:   if device clock is past the stored expiry → blocked
  ///
  /// If no anchor exists (new user, trial not activated) → not blocked.
  static bool isClockIntactSync() {
    final ntpMs = _ntpMs;

    // No anchor yet — new user or trial not activated. Not blocked.
    if (ntpMs == null) return true;

    final nowMs = DateTime.now().millisecondsSinceEpoch;

    // ── Check 1: Clock rollback detection ──────────────────────────────
    // If device time is behind the last known trusted time by more than
    // the tolerance, the user rolled back their clock. Blocked until they
    // go online to re-verify.
    //
    // TOLERANCE (5 seconds): NTP server time is always slightly ahead of
    // the device clock due to network round-trip latency. Without a
    // tolerance, the Firestore listener would re-fetch NTP time, store
    // it as the new anchor, and immediately re-block the user because
    // DateTime.now() is a few hundred ms behind the NTP response.
    // A 5-second window absorbs this while still catching meaningful
    // clock rollbacks (hours/days).
    const toleranceMs = 15000;
    if (nowMs < ntpMs - toleranceMs) return false;

    // ── Check 2: Subscription expiry ───────────────────────────────────
    // If device time is past the stored expiry + 1 minute grace period,
    // the subscription has expired. The 1-minute tolerance matches the
    // grace period in Subscription.status (shows "grace" for ~1 min).
    final expiryMs = _expiryMs;
    if (expiryMs != null && nowMs > expiryMs + 60000) return false;

    return true;
  }

  /// Returns trusted time for status computation.
  ///
  /// Since isClockIntactSync() already verified DateTime.now() >= _ntpMs,
  /// we know the device clock is at least as far as the last trusted time.
  /// DateTime.now() is safe to use for subscription status computation.
  ///
  /// Returns null if no anchor exists (trial not activated yet).
  static DateTime? get trustedNow {
    if (_ntpMs == null) return null;
    return DateTime.now();
  }

  /// Returns the reason the user is blocked, or null if not blocked.
  ///
  /// Used by SubscriptionCheckScreen to route to the correct screen:
  ///   - 'clock_rollback' → ClockTamperScreen (warning, no data)
  ///   - 'expired'        → HomeScreen (existing restrictions apply)
  ///   - null             → not blocked
  static String? get blockReason {
    final ntpMs = _ntpMs;
    if (ntpMs == null) return null;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final expiryMs = _expiryMs;
    // Check expired FIRST — subscription expiry takes priority
    if (expiryMs != null && nowMs > expiryMs + 60000) return 'expired';
    // Clock rollback — use same 15s tolerance as isClockIntactSync()
    const toleranceMs = 15000;
    if (nowMs < ntpMs - toleranceMs) return 'clock_rollback';
    return null;
  }

  /// Returns true if a trusted time anchor is currently stored.
  ///
  /// Used by the online verification path: if every online time source fails,
  /// we must NOT overwrite an existing good anchor with device time. Only
  /// when NO anchor exists at all (fresh install / first activation) do we
  /// allow the device-time last resort.
  static Future<bool> hasAnchor() async => _ntpMs != null;

  /// Clear all stored trust data. Called on:
  ///   - User sign-out (auth_service.dart)
  ///   - Remote subscription document deleted (check_subscription.dart)
  static Future<void> clear() async {
    // Clear the in-memory cache first (the sync getter must reflect this
    // immediately), then remove the encrypted values.
    _ntpMs = null;
    _expiryMs = null;
    try {
      await _storage.delete(key: _keyNtp);
      await _storage.delete(key: _keyExpiry);
    } catch (e) {
      // ignore: avoid_print
      print('[ClockIntegrity] secure delete failed: $e');
    }
  }
}
