import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../Providers/database_provider.dart';

/// Modern customer tile with premium card design.
///
/// Features a subtle gradient avatar, clean typography hierarchy,
/// and a semantic balance badge for instant financial status recognition.
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
          // Subtle border for premium "glass/card" feel
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
            // Softer splash effect
            splashColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            highlightColor: theme.colorScheme.primary.withValues(alpha: 0.05),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _GradientAvatar(name: name),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _CustomerInfo(name: name, phone: phone),
                  ),
                  const SizedBox(width: 12),
                  balanceAsync.when(
                    data: (balance) =>
                        _BalanceBadge(balance: balance, l10n: l10n),
                    loading: () => const _LoadingBadge(),
                    error: (_, __) => const _ErrorBadge(),
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

/// A highly polished gradient avatar using the theme's primary colors.
class _GradientAvatar extends StatelessWidget {
  final String name;

  const _GradientAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onPrimary,
        ),
      ),
    );
  }
}

/// Clean hierarchy: Strong name, subtle phone number with icon alignment.
class _CustomerInfo extends StatelessWidget {
  final String name;
  final String? phone;

  const _CustomerInfo({required this.name, this.phone});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (phone != null && phone!.trim().isNotEmpty) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.phone_rounded,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  phone!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Semantic balance badge that adapts beautifully to dark/light modes.
class _BalanceBadge extends StatelessWidget {
  final double balance;
  final AppLocalizations l10n;

  const _BalanceBadge({required this.balance, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    // Semantic Colors (Red for Owes, Green for Overpaid, Grey for Settled)
    final textColor = _getTextColor(isDark, theme);
    final bgColor = _getBgColor(isDark, theme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _formatNumber(balance.abs()),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: -0.3,
            ),
          ),
          Text(
            _getLabel().toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: textColor.withValues(alpha: 0.8),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTextColor(bool isDark, ThemeData theme) {
    if (balance > 0) {
      return isDark ? const Color(0xFFFFB4AB) : theme.colorScheme.error;
    }
    if (balance < 0) {
      return isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32);
    }
    return theme.colorScheme.onSurfaceVariant;
  }

  Color _getBgColor(bool isDark, ThemeData theme) {
    if (balance > 0) {
      return isDark
          ? const Color(0xFF93000A).withValues(alpha: 0.3)
          : theme.colorScheme.errorContainer;
    }
    if (balance < 0) {
      return isDark
          ? const Color(0xFF005313).withValues(alpha: 0.3)
          : const Color(0xFFE8F5E9);
    }
    return theme.colorScheme.surfaceContainerHighest;
  }

  String _getLabel() {
    if (balance > 0) return l10n.owes;
    if (balance < 0) return l10n.overpaid;
    return l10n.settled;
  }

  /// Clean regex-based number formatting (e.g., 1000000 -> 1,000,000)
  String _formatNumber(double n) {
    final s = n % 1 == 0 ? n.toStringAsFixed(0) : n.toStringAsFixed(2);
    return s.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

class _LoadingBadge extends StatelessWidget {
  const _LoadingBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2.5),
      ),
    );
  }
}

class _ErrorBadge extends StatelessWidget {
  const _ErrorBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '--',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onErrorContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
