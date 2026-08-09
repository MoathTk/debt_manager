import 'package:flutter/services.dart';

/// Wraps Android's SystemClock.elapsedRealtime() via platform channel.
///
/// This clock is monotonically increasing, independent of the device wall clock.
/// Changing the device date/time settings has ZERO effect on it.
/// It is maintained by the Linux kernel, not userspace, so it cannot be faked.
///
/// On non-Android platforms or if the channel fails, falls back to
/// DateTime.now().millisecondsSinceEpoch (device clock).
class MonotonicClock {
  static const _channel = MethodChannel('com.debtmanager/clock');

  /// Returns milliseconds since boot from the kernel monotonic counter.
  static Future<int> millis() async {
    try {
      final result = await _channel.invokeMethod<int>('elapsedRealtime');
      if (result != null) return result;
    } catch (_) {}
    return DateTime.now().millisecondsSinceEpoch;
  }
}

 