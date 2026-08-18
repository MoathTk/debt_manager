/// Subscription feature — Presentation layer: state class
library;

import 'package:local_debt_management/services/clock_integrity_service.dart';
import '../../domain/entities/subscription.dart';

class SubscriptionState {
  final bool isLoading;
  final Subscription? subscription;
  final String? error;

  const SubscriptionState({
    this.isLoading = true,
    this.subscription,
    this.error,
  });

  bool get isBlocked {
    if (!ClockIntegrityService.isClockIntactSync()) return true;
    return subscription?.status(ClockIntegrityService.trustedNow) == SubscriptionStatus.blocked;
  }

  SubscriptionState copyWith({
    bool? isLoading,
    Subscription? subscription,
    bool clearSubscription = false,
    String? error,
  }) =>
      SubscriptionState(
        isLoading: isLoading ?? this.isLoading,
        subscription: clearSubscription ? null : (subscription ?? this.subscription),
        error: error ?? this.error,
      );
}
