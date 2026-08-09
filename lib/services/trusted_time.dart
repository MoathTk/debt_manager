import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:ntp/ntp.dart';

/// Fetches a trusted current UTC time from the best available ONLINE source.
///
/// WHY THIS EXISTS:
///   The subscription security relies on a "trusted anchor" — a real UTC
///   timestamp stored when the user verifies online. If we only ever use
///   NTP (UDP port 123) and it fails, we must NOT silently fall back to the
///   device clock — an attacker could block NTP with a firewall app and then
///   poison the anchor by rolling the clock back.
///
///   So instead of ONE online source, we try a CHAIN of sources:
///     1. NTP (UDP 123)              → sub-second precision
///     2. Firestore server timestamp → same HTTPS channel as the app's own
///                                     database (port 443, never blocked)
///     3. HTTPS Date header          → port 443 again, 1-second precision
///
///   KEY IDEA: sources 2 and 3 use plain HTTPS (port 443) — the exact same
///   connection the app already needs for Firestore. If the app is online
///   at all, these will almost always succeed. Only if EVERY source fails
///   do we return null (the caller then decides what to do).
///
///   Returns the trusted UTC time, or null if every online source failed.
Future<DateTime?> fetchTrustedTime() async {
  // Source 1 — NTP: the best precision (milliseconds). Preferred, but uses
  // UDP port 123 which some carriers/public Wi-Fi/firewalls block.
  try {
    return await NTP.now();
  } catch (_) {}

  // Source 2 — Firestore server timestamp: ask the server for ITS clock.
  // We write a tiny shared document containing FieldValue.serverTimestamp()
  // (the server stamps it with its own clock), then read it back.
  // This rides on the same HTTPS connection Firestore already uses, so it
  // works whenever the app can reach its own database. If the app's security
  // rules deny writes to this doc, the set() throws and we simply move on to
  // source 3 — the chain keeps going, nothing crashes.
  try {
    return await _fromFirestoreServerTimestamp();
  } catch (_) {}

  // Source 3 — HTTPS Date header: every HTTP response carries a mandatory
  // "Date:" header with the server's clock. We GET a stable Google endpoint
  // (the same infrastructure the app's own Firestore runs on) and read that
  // header. Port 443 is never blocked when the app is online.
  try {
    return await _fromHttpDateHeader();
  } catch (_) {}

  // Every online source failed. Return null and let the caller decide
  // (see the "keep old anchor" rule in check_subscription.dart /
  // subscription_provider.dart).
  return null;
}

/// Writes a shared "clock probe" document and reads back the server timestamp.
///
/// _time/now is a single shared document (one per app install region) that is
/// simply overwritten each time — it is not per-user and contains no data,
/// just the current server clock. It is deleted again immediately afterwards.
Future<DateTime> _fromFirestoreServerTimestamp() async {
  final firestore = FirebaseFirestore.instance;
  final ref = firestore.collection('_time').doc('now');

  // Server stamps this field with its OWN clock — not the device's.
  await ref.set({'ts': FieldValue.serverTimestamp()});

  // Read the stamped time back. It represents the server's wall-clock at the
  // moment of writing, i.e. "now" from the server's point of view.
  final snap = await ref.get();
  final ts = snap.data()?['ts'] as Timestamp?;
  if (ts == null) {
    throw const FormatException('No server timestamp returned');
  }

  // Best-effort cleanup — ignore failure so a denied delete never forces the
  // whole chain to fail after we already got the time.
  try {
    await ref.delete();
  } catch (_) {}

  return ts.toDate(); // Timestamp is already UTC.
}

/// Reads the "Date:" header from an HTTPS response to derive server time.
///
/// Uses the Firestore REST host — the same Google infrastructure the app
/// already talks to — so if Firestore works, this endpoint works too.
Future<DateTime> _fromHttpDateHeader() async {
  final resp = await http
      .get(
        Uri.parse('https://firestore.googleapis.com/'),
        headers: const {'Connection': 'close'},
      )
      .timeout(const Duration(seconds: 5));

  final dateHeader = resp.headers['date'];
  if (dateHeader == null) {
    throw const FormatException('No Date header in response');
  }

  // RFC 7231 format, e.g. "Sun, 09 Aug 2026 12:00:00 GMT". Convert to UTC.
  return HttpDate.parse(dateHeader).toUtc();
}
