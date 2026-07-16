/// Subscription feature — Plan info card for blocked screen
library;

import 'package:flutter/material.dart';
import '../../domain/entities/subscription.dart';

class SubscriptionStatusCard extends StatelessWidget {
  final Subscription subscription;
  const SubscriptionStatusCard({super.key, required this.subscription});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subscription.planLabel,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Expired: ${subscription.expiresAt.toLocal().toString().split(' ')[0]}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
