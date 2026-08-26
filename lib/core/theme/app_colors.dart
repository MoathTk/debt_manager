/// Centralized semantic color tokens for the application.
///
/// Provides theme-aware colors via [ThemeExtension] so every widget
/// can access domain-meaningful colors through `Theme.of(context).extension<AppColors>()!`.
///
/// USAGE: Always use AppColors instead of hardcoded hex values.
/// - Debt/payment states → [debt], [payment], [debtBg], [paymentBg]
/// - Customer accents → [customer]
/// - Reminder accents → [reminder]
/// - Status indicators → [success], [warning], [error], [expired]
/// - Luxury accent → [gold], [goldLight], [goldDark]
library;

import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color primary;
  final Color onPrimary;
  final Color surface;
  final Color surfaceContainer;
  final Color gold;
  final Color goldLight;
  final Color goldDark;
  final Color debt;
  final Color debtBg;
  final Color payment;
  final Color paymentBg;
  final Color customer;
  final Color customerBg;
  final Color reminder;
  final Color reminderBg;
  final Color success;
  final Color warning;
  final Color error;
  final Color expired;

  const AppColors({
    required this.primary,
    required this.onPrimary,
    required this.surface,
    required this.surfaceContainer,
    required this.gold,
    required this.goldLight,
    required this.goldDark,
    required this.debt,
    required this.debtBg,
    required this.payment,
    required this.paymentBg,
    required this.customer,
    required this.customerBg,
    required this.reminder,
    required this.reminderBg,
    required this.success,
    required this.warning,
    required this.error,
    required this.expired,
  });

  // ---------------------------------------------------------------------------
  // LIGHT THEME
  // ---------------------------------------------------------------------------

  static const light = AppColors(
    primary: Color(0xFF0F1D3D),
    onPrimary: Color(0xFFFFFFFF),
    surface: Color(0xFFFAFAF8),
    surfaceContainer: Color(0xFFF2F0EC),
    gold: Color(0xFFC49A3C),
    goldLight: Color(0xFFF5E6C0),
    goldDark: Color(0xFF8B6914),
    debt: Color(0xFFC62828),
    debtBg: Color(0xFFFDE8E8),
    payment: Color(0xFF2E7D32),
    paymentBg: Color(0xFFE8F5E9),
    customer: Color(0xFF1565C0),
    customerBg: Color(0xFFE3F2FD),
    reminder: Color(0xFFE8A317),
    reminderBg: Color(0xFFFFF8E1),
    success: Color(0xFF2E7D32),
    warning: Color(0xFFE65100),
    error: Color(0xFFC62828),
    expired: Color(0xFFB71C1C),
  );

  // ---------------------------------------------------------------------------
  // DARK THEME
  // ---------------------------------------------------------------------------

  static const dark = AppColors(
    primary: Color(0xFF6B8FC7),
    onPrimary: Color(0xFFFFFFFF),
    surface: Color(0xFF0A1628),
    surfaceContainer: Color(0xFF132238),
    gold: Color(0xFFE0B94D),
    goldLight: Color(0xFF3D3018),
    goldDark: Color(0xFFC49A3C),
    debt: Color(0xFFEF5350),
    debtBg: Color(0xFF3A1518),
    payment: Color(0xFF66BB6A),
    paymentBg: Color(0xFF152718),
    customer: Color(0xFF42A5F5),
    customerBg: Color(0xFF0D2137),
    reminder: Color(0xFFFFB74D),
    reminderBg: Color(0xFF33240A),
    success: Color(0xFF66BB6A),
    warning: Color(0xFFFF9800),
    error: Color(0xFFEF5350),
    expired: Color(0xFFE53935),
  );

  // ---------------------------------------------------------------------------
  // ThemeExtension copyWith + lerp
  // ---------------------------------------------------------------------------

  @override
  AppColors copyWith({
    Color? primary,
    Color? onPrimary,
    Color? surface,
    Color? surfaceContainer,
    Color? gold,
    Color? goldLight,
    Color? goldDark,
    Color? debt,
    Color? debtBg,
    Color? payment,
    Color? paymentBg,
    Color? customer,
    Color? customerBg,
    Color? reminder,
    Color? reminderBg,
    Color? success,
    Color? warning,
    Color? error,
    Color? expired,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      surface: surface ?? this.surface,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      gold: gold ?? this.gold,
      goldLight: goldLight ?? this.goldLight,
      goldDark: goldDark ?? this.goldDark,
      debt: debt ?? this.debt,
      debtBg: debtBg ?? this.debtBg,
      payment: payment ?? this.payment,
      paymentBg: paymentBg ?? this.paymentBg,
      customer: customer ?? this.customer,
      customerBg: customerBg ?? this.customerBg,
      reminder: reminder ?? this.reminder,
      reminderBg: reminderBg ?? this.reminderBg,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      expired: expired ?? this.expired,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceContainer: Color.lerp(surfaceContainer, other.surfaceContainer, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      goldLight: Color.lerp(goldLight, other.goldLight, t)!,
      goldDark: Color.lerp(goldDark, other.goldDark, t)!,
      debt: Color.lerp(debt, other.debt, t)!,
      debtBg: Color.lerp(debtBg, other.debtBg, t)!,
      payment: Color.lerp(payment, other.payment, t)!,
      paymentBg: Color.lerp(paymentBg, other.paymentBg, t)!,
      customer: Color.lerp(customer, other.customer, t)!,
      customerBg: Color.lerp(customerBg, other.customerBg, t)!,
      reminder: Color.lerp(reminder, other.reminder, t)!,
      reminderBg: Color.lerp(reminderBg, other.reminderBg, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      expired: Color.lerp(expired, other.expired, t)!,
    );
  }

  // ---------------------------------------------------------------------------
  // Convenience accessor
  // ---------------------------------------------------------------------------

  /// Shorthand to get [AppColors] from context.
  ///
  /// Usage: `final appColors = AppColors.of(context);`
  static AppColors of(BuildContext context) {
    return Theme.of(context).extension<AppColors>()!;
  }
}
