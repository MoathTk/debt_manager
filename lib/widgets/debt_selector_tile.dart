import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Selectable debt tile showing original amount and remaining balance.
class DebtSelectorTile extends StatelessWidget {
  final int id;
  final double amount;
  final double remaining;
  final String? note;
  final bool isSelected;
  final VoidCallback onTap;

  const DebtSelectorTile({
    super.key,
    required this.id,
    required this.amount,
    required this.remaining,
    this.note,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final border = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.outlineVariant.withValues(alpha: 0.3);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: isSelected
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border, width: isSelected ? 2 : 1),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _Info(amount: amount, note: note),
                ),
                _Badge(remaining: remaining, l10n: l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final double amount;
  final String? note;
  const _Info({required this.amount, this.note});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fmt = _fmt(amount);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          fmt,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.3,
          ),
        ),
        if (note?.isNotEmpty == true)
          Text(
            note!,
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  String _fmt(double n) {
    final s = n % 1 == 0 ? n.toStringAsFixed(0) : n.toStringAsFixed(2);
    return s.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}

class _Badge extends StatelessWidget {
  final double remaining;
  final AppLocalizations l10n;
  const _Badge({required this.remaining, required this.l10n});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fmt = _fmt(remaining);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            l10n.remaining.toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.error.withValues(alpha: 0.7),
              letterSpacing: 0.5,
            ),
          ),
          Text(
            fmt,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.error,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(double n) {
    final s = n % 1 == 0 ? n.toStringAsFixed(0) : n.toStringAsFixed(2);
    return s.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}
