import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Collapsible section header with icon, label, count badge, and delete-all.
class ReminderSectionHeader extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final int count;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onDeleteAll;
  const ReminderSectionHeader({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.count,
    required this.expanded,
    required this.onToggle,
    required this.onDeleteAll,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => _confirmDeleteAll(context, l10n),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: cs.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  size: 16,
                  color: cs.error,
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedRotation(
              turns: expanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 22,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteAll(BuildContext ctx, AppLocalizations l10n) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text(l10n.deleteAll),
        content: Text(l10n.confirmDeleteAll),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.no)),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDeleteAll();
            },
            child: Text(
              l10n.yes,
              style: TextStyle(color: Theme.of(ctx).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
