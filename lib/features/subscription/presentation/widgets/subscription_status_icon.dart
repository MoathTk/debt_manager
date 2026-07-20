import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/subscription.dart';
import '../providers/subscription_provider.dart';
import 'subscription_status_dialog.dart';

class SubscriptionStatusIcon extends ConsumerWidget {
  const SubscriptionStatusIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sub = ref.watch(subscriptionProvider).subscription;
    if (sub == null) return const SizedBox.shrink();
    final color = dotColor(sub);
    return IconButton(
      onPressed: () => _showDetails(context, sub),
      icon: Semantics(
        label: 'Subscription status',
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(Icons.shield_outlined, color: color, size: 24),
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context, Subscription sub) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Subscription',
      transitionDuration: const Duration(milliseconds: 350),
      transitionBuilder: (ctx, a1, a2, child) => FadeTransition(
        opacity: a1,
        child: ScaleTransition(
          scale: CurvedAnimation(parent: a1, curve: Curves.easeOutCubic),
          child: child,
        ),
      ),
      pageBuilder: (ctx, a1, a2) =>
          SubscriptionStatusDialog(subscription: sub),
    );
  }
}
