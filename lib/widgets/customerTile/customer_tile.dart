import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../Providers/database_provider.dart';
import 'gradient_avatar.dart';
import 'customer_info.dart';
import 'balance_badge.dart';
import 'badge_states.dart';

/// Modern customer tile with premium card design.
class CustomerTile extends ConsumerWidget {
  final String name;
  final String? phone;
  final String customerId;
  final VoidCallback? onTap;

  const CustomerTile({
    super.key,
    required this.name,
    this.phone,
    required this.customerId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(customerBalanceProvider(customerId));
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            splashColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            highlightColor: theme.colorScheme.primary.withValues(alpha: 0.05),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GradientAvatar(name: name),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomerInfo(name: name, phone: phone),
                  ),
                  const SizedBox(width: 12),
                  balanceAsync.when(
                    data: (b) => BalanceBadge(balance: b, l10n: l10n),
                    loading: () => const LoadingBadge(),
                    error: (_, __) => const ErrorBadge(),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.5,
                    ),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
