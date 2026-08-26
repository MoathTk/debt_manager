/// CUSTOMER SEARCH PICKER — CustomerTile
///
/// RULES: <80 lines per class, Theme.of(context), Semantics, l10n.
library;

import 'package:flutter/material.dart';
import 'package:local_debt_management/core/theme/app_colors.dart';
import 'package:local_debt_management/data/models/customer.dart';
import 'package:local_debt_management/widgets/amount_input_formatter.dart';

class CustomerTile extends StatelessWidget {
  final Customer customer;
  final ColorScheme cs;
  final bool isSelected;
  final int debtCount;
  final double balance;
  final bool isLoading;
  final VoidCallback onTap;
  const CustomerTile({
    super.key,
    required this.customer,
    required this.cs,
    required this.isSelected,
    required this.debtCount,
    required this.balance,
    required this.isLoading,
    required this.onTap,
  });

  String get _initials {
    final parts = customer.name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Color get _avatarColor {
    final hue = (customer.name.hashCode % 360).abs().toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.55, 0.60).toColor();
  }

  bool get _hasBalance => balance > 0;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    return Semantics(
      label: customer.name,
      selected: isSelected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? cs.primaryContainer.withValues(alpha: 0.5)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? cs.primary.withValues(alpha: 0.5)
                  : cs.outlineVariant.withValues(alpha: 0.15),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              _Avatar(
                initials: _initials,
                color: _avatarColor,
                isSelected: isSelected,
                cs: cs,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: cs.onSurface,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (customer.phone != null && customer.phone!.isNotEmpty) ...[
                          Icon(Icons.phone_rounded, size: 11, color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
                          const SizedBox(width: 4),
                          Text(
                            customer.phone!,
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (!isLoading) ...[
                if (debtCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _hasBalance
                          ? appColors.debt.withValues(alpha: 0.1)
                          : appColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _hasBalance
                            ? appColors.debt.withValues(alpha: 0.2)
                            : appColors.success.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      _hasBalance ? formatAmount(balance) : '$debtCount',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _hasBalance ? appColors.debt : appColors.success,
                      ),
                    ),
                  ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.check_circle_rounded, size: 20, color: cs.primary),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String initials;
  final Color color;
  final bool isSelected;
  final ColorScheme cs;
  const _Avatar({
    required this.initials,
    required this.color,
    required this.isSelected,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isSelected
            ? LinearGradient(
                colors: [
                  cs.primary.withValues(alpha: 0.2),
                  cs.primary.withValues(alpha: 0.08),
                ],
              )
            : LinearGradient(
                colors: [
                  color.withValues(alpha: 0.15),
                  color.withValues(alpha: 0.05),
                ],
              ),
        border: Border.all(
          color: isSelected
              ? cs.primary.withValues(alpha: 0.3)
              : color.withValues(alpha: 0.2),
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: isSelected ? cs.primary : color,
          ),
        ),
      ),
    );
  }
}
