/// Subscription feature — Presentation layer: state class
library;

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

  SubscriptionState copyWith({
    bool? isLoading,
    Subscription? subscription,
    String? error,
  }) =>
      SubscriptionState(
        isLoading: isLoading ?? this.isLoading,
        subscription: subscription ?? this.subscription,
        error: error ?? this.error,
      );
}
