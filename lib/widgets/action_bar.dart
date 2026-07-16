import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../features/subscription/presentation/widgets/mutation_guard.dart';
import 'add_debt_sheet.dart';
import 'record_payment_sheet.dart';
import 'records_list_sheet.dart';

/// Professional floating action bar with three action buttons.
class ActionBar extends ConsumerWidget {
  final String customerId;
  const ActionBar({super.key, required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),

      child: Container(
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.transparent,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _ActionBtn(
                icon: Icons.add_rounded,
                label: l10n.debt,
                gradient: [
                  theme.colorScheme.error,
                  theme.colorScheme.error.withValues(alpha: 0.8),
                ],
                shadowColor: theme.colorScheme.error.withValues(alpha: 0.3),
                onTap: () {
                  if (MutationGuard.checkBlocked(context, ref)) return;
                  showAddDebtSheet(context, ref, customerId);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionBtn(
                icon: Icons.payments_rounded,
                label: l10n.payment,
                gradient: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.8),
                ],
                shadowColor: theme.colorScheme.primary.withValues(alpha: 0.3),
                onTap: () {
                  if (MutationGuard.checkBlocked(context, ref)) return;
                  showRecordPaymentSheet(context, ref, customerId);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionBtn(
                icon: Icons.edit_rounded,
                label: l10n.editRecords,
                gradient: [
                  theme.colorScheme.tertiary,
                  theme.colorScheme.tertiary.withValues(alpha: 0.8),
                ],
                shadowColor: theme.colorScheme.tertiary.withValues(alpha: 0.3),
                onTap: () {
                  if (MutationGuard.checkBlocked(context, ref)) return;
                  showRecordsListSheet(context, ref, customerId);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final Color shadowColor;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.shadowColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              // BoxShadow(
              //   color: shadowColor,
              //   blurRadius: 12,
              //   offset: const Offset(0, 4),
              // ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 22),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
