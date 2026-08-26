import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../features/subscription/presentation/widgets/mutation_guard.dart';
import 'add_debt_sheet/add_debt_sheet.dart';
import 'record_payment_sheet.dart';
import 'records_list_sheet.dart';

/// Gold segmented action bar with three action buttons.
class ActionBar extends ConsumerWidget {
  final String customerId;
  const ActionBar({super.key, required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: cs.surface,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B6914).withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, -3),
            ),
          ],
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _ActionBtn(
                icon: Icons.add_rounded,
                label: l10n.debt,
                color: const Color(0xFFC49A3C),
                onTap: () {
                  if (MutationGuard.checkBlocked(context, ref)) return;
                  showAddDebtSheet(context, ref, customerId);
                },
              ),
            ),
            _GoldDivider(),
            Expanded(
              child: _ActionBtn(
                icon: Icons.payments_rounded,
                label: l10n.payment,
                color: const Color(0xFFB08928),
                onTap: () {
                  if (MutationGuard.checkBlocked(context, ref)) return;
                  showRecordPaymentSheet(context, ref, customerId);
                },
              ),
            ),
            _GoldDivider(),
            Expanded(
              child: _ActionBtn(
                icon: Icons.edit_note_rounded,
                label: l10n.editRecords,
                color: const Color(0xFFD4AC50),
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

class _GoldDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: const Color(0xFFC49A3C).withValues(alpha: 0.2),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
