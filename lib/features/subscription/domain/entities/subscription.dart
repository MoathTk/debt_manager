/// SUBSCRIPTION FEATURE — DOMAIN LAYER
///
/// This file defines the core [Subscription] entity.
/// The domain layer is the innermost layer — it has ZERO dependencies
/// on Flutter, Firebase, SQLite, or any external package.
///
/// An entity represents the business object itself: what a subscription IS,
/// not where it's stored or how it's displayed. All business rules
/// (like status calculation) live here.
///
/// ARCHITECTURE RULE: Domain entities must never import from data/ or presentation/.
/// ---------------------------------------------------------------------------
library;

/// Subscription plan types — maps to what the admin assigns in Firestore.
enum SubscriptionPlan { trial, weekly, monthly }

/// Subscription status — derived from the entity's own data.
/// Used by presentation layer to decide what UI to show.
enum SubscriptionStatus { active, expiring, grace, blocked, noData }

/// Core subscription entity — pure domain, no framework dependencies.
///
/// STATUS LOGIC:
/// - active:    subscription is valid AND more than 3 hours until expiry
/// - expiring:  subscription is valid BUT less than 3 hours until expiry
/// - grace:     subscription expired BUT less than 3 hours have passed since
/// - blocked:   subscription expired AND more than 3 hours have passed
/// - noData:    no subscription record exists (new user, no trial yet)
class Subscription {
  final SubscriptionPlan plan;
  final DateTime expiresAt;
  final DateTime activatedAt;
  final bool isActive;

  const Subscription({
    required this.plan,
    required this.expiresAt,
    required this.activatedAt,
    required this.isActive,
  });

  Subscription copyWith({
    SubscriptionPlan? plan,
    DateTime? expiresAt,
    DateTime? activatedAt,
    bool? isActive,
  }) {
    return Subscription(
      plan: plan ?? this.plan,
      expiresAt: expiresAt ?? this.expiresAt,
      activatedAt: activatedAt ?? this.activatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Business rule: determine current status based on expiry time.
  ///
  /// [now] — the current time to compare against. When null (default),
  /// falls back to [DateTime.now]. Callers with access to trusted time
  /// (from [ClockIntegrityService.trustedNow]) should pass it so the
  /// result is not fooled by a manipulated device clock.
  SubscriptionStatus status([DateTime? now]) {
    final effectiveNow = now ?? DateTime.now();
    if (effectiveNow.isBefore(activatedAt)) return SubscriptionStatus.blocked;
    if (!isActive || expiresAt.isAfter(effectiveNow) == false) {
      return effectiveNow.difference(expiresAt).inMinutes > 1
          ? SubscriptionStatus.blocked
          : SubscriptionStatus.grace;
    }
    return expiresAt.difference(effectiveNow).inMinutes <= 1
        ? SubscriptionStatus.expiring
        : SubscriptionStatus.active;
  }

  int get daysRemaining => expiresAt.difference(DateTime.now()).inMinutes;
  bool get isTrial => plan == SubscriptionPlan.trial;

  String get planLabel {
    switch (plan) {
      case SubscriptionPlan.trial:
        return 'Free Trial';
      case SubscriptionPlan.weekly:
        return 'Weekly Plan';
      case SubscriptionPlan.monthly:
        return 'Monthly Plan';
    }
  }
}
