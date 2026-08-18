package com.example.local_debt_management

import io.flutter.embedding.android.FlutterActivity

/// Main entry point for the Android app.
///
/// The platform channel for the monotonic boot clock has been removed.
/// Clock integrity now uses a simpler approach: store NTP time on activation,
/// compare DateTime.now() against it on each launch.
class MainActivity : FlutterActivity()
