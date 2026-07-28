import 'package:shared_preferences/shared_preferences.dart';

class ClockIntegrityService {
  static const _keyLastTrustedTime = 'last_trusted_time';
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> markTrustedTime() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setInt(
      _keyLastTrustedTime,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<bool> isClockIntact({Duration tolerance = const Duration(hours: 1)}) async {
    _prefs ??= await SharedPreferences.getInstance();
    final stored = _prefs!.getInt(_keyLastTrustedTime);
    if (stored == null) return true;
    final now = DateTime.now().millisecondsSinceEpoch;
    return now >= stored - tolerance.inMilliseconds;
  }

  static bool isClockIntactSync({Duration tolerance = const Duration(hours: 1)}) {
    final stored = _prefs?.getInt(_keyLastTrustedTime);
    if (stored == null) return true;
    final now = DateTime.now().millisecondsSinceEpoch;
    return now >= stored - tolerance.inMilliseconds;
  }

  static Future<void> clear() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.remove(_keyLastTrustedTime);
  }
}
