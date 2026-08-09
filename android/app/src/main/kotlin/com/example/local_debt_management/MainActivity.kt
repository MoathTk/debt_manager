package com.example.local_debt_management

import android.os.SystemClock
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.debtmanager/clock"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Platform channel to expose Android's monotonic boot clock.
        // SystemClock.elapsedRealtime() returns milliseconds since boot.
        // It is monotonically increasing, never decreases, and is NOT affected
        // by the user changing the device date/time settings.
        // Used by ClockIntegrityService to compute real UTC time offline
        // without trusting the device wall clock.
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "elapsedRealtime") {
                result.success(SystemClock.elapsedRealtime())
            } else {
                result.notImplemented()
            }
        }
    }
}
