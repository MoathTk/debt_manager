import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Locale provider managing AR/EN language toggle.
///
/// Uses [StateNotifierProvider] to hold the current [Locale].
/// Defaults to Arabic (ar) since the app targets local Iraqi merchants.
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

/// Manages the application's locale for bilingual support.
///
/// Supports Arabic (ar) and English (en) with full RTL/LTR switching.
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('ar'));

  /// Sets the locale to Arabic (RTL).
  void setArabic() {
    state = const Locale('ar');
  }

  /// Sets the locale to English (LTR).
  void setEnglish() {
    state = const Locale('en');
  }

  /// Toggles between Arabic and English.
  void toggleLocale() {
    state = state.languageCode == 'ar'
        ? const Locale('en')
        : const Locale('ar');
  }

  /// Returns true if the current locale is Arabic.
  bool get isArabic => state.languageCode == 'ar';
}
