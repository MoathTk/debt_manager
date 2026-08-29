/// Centralized type tokens for the application.
///
/// Two-family pairing grounded in the bilingual Arabic/English audience:
/// - [displayFamily] (Cairo) — geometric grotesque for headlines and figures,
///   carrying both Latin and Arabic glyphs.
/// - [bodyFamily] (Tajawal) — clean, highly legible face for body copy,
///   labels and inputs in both scripts.
///
/// Use [figures] for amounts and phone/OTP digits so numerals align
/// (tabular figures) instead of jittering as columns change width.
import 'package:flutter/painting.dart';

abstract final class AppType {
  static const String displayFamily = 'Cairo';
  static const String bodyFamily = 'Tajawal';

  // ---------------------------------------------------------------------------
  // Display / headings
  // ---------------------------------------------------------------------------

  static const displaySmall = TextStyle(
    fontFamily: displayFamily,
    fontSize: 36,
    fontWeight: FontWeight.w800,
    height: 1.1,
    letterSpacing: -0.6,
  );

  static const headlineLarge = TextStyle(
    fontFamily: displayFamily,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    height: 1.15,
    letterSpacing: -0.5,
  );

  static const headlineMedium = TextStyle(
    fontFamily: displayFamily,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: -0.4,
  );

  static const headlineSmall = TextStyle(
    fontFamily: displayFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.2,
  );

  static const titleLarge = TextStyle(
    fontFamily: displayFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static const titleMedium = TextStyle(
    fontFamily: displayFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.35,
  );

  static const titleSmall = TextStyle(
    fontFamily: displayFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.4,
  );

  // ---------------------------------------------------------------------------
  // Body copy
  // ---------------------------------------------------------------------------

  static const bodyLarge = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const bodyMedium = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.55,
  );

  static const bodySmall = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // ---------------------------------------------------------------------------
  // Labels / buttons
  // ---------------------------------------------------------------------------

  static const labelLarge = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const labelMedium = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const labelSmall = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.3,
  );

  // ---------------------------------------------------------------------------
  // Numerals — tabular figures so digit columns align
  // ---------------------------------------------------------------------------

  static TextStyle figures({
    double size = 32,
    FontWeight weight = FontWeight.w700,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: bodyFamily,
      fontSize: size,
      fontWeight: weight,
      height: 1.2,
      letterSpacing: letterSpacing ?? (size >= 24 ? -0.5 : 0),
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }
}