/// VOICE ENTRY FEATURE — PRESENTATION LAYER: PARSED ITEMS REVIEW
///
/// Shows the AI-parsed items in a reviewable list before saving.
/// Collapses to a compact summary after Accept, with an expand
/// button to re-show the full list.
/// ---------------------------------------------------------------------------
library;

import 'package:flutter/material.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';
import '../../domain/entities/voice_parsed_debt.dart';

class ParsedItemsReview extends StatefulWidget {
  final VoiceParsedDebt parsedDebt;
  final ValueChanged<VoiceParsedDebt> onChanged;
  final VoidCallback onAccept;
  final VoidCallback onRetry;

  const ParsedItemsReview({
    super.key,
    required this.parsedDebt,
    required this.onChanged,
    required this.onAccept,
    required this.onRetry,
  });

  @override
  State<ParsedItemsReview> createState() => _ParsedItemsReviewState();
}

class _ParsedItemsReviewState extends State<ParsedItemsReview> {
  bool _expanded = true;

  void _handleAccept() {
    widget.onAccept();
    setState(() => _expanded = false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    if (!_expanded) {
      return _CollapsedSummary(
        parsedDebt: widget.parsedDebt,
        l10n: l10n,
        cs: cs,
        onExpand: () => setState(() => _expanded = true),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(l10n: l10n, cs: cs),
          const SizedBox(height: 8),
          ...widget.parsedDebt.items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return _ItemRow(
              item: item,
              cs: cs,
              onRemove: () {
                final newItems = List.of(widget.parsedDebt.items)
                  ..removeAt(i);
                final newTotal =
                    newItems.fold(0.0, (sum, i) => sum + i.amount);
                widget.onChanged(
                  widget.parsedDebt.copyWith(
                    items: newItems,
                    totalAmount: newTotal,
                  ),
                );
              },
            );
          }),
          const SizedBox(height: 4),
          _TotalRow(l10n: l10n, cs: cs, total: widget.parsedDebt.totalAmount),
          if (widget.parsedDebt.dueDate != null) ...[
            const SizedBox(height: 4),
            _DueRow(
              l10n: l10n,
              cs: cs,
              dueDate: widget.parsedDebt.dueDate!,
            ),
          ],
          const SizedBox(height: 12),
          _ActionButtons(
            l10n: l10n,
            cs: cs,
            onRetry: widget.onRetry,
            onAccept: _handleAccept,
          ),
        ],
      ),
    );
  }
}

class _CollapsedSummary extends StatelessWidget {
  final VoiceParsedDebt parsedDebt;
  final AppLocalizations l10n;
  final ColorScheme cs;
  final VoidCallback onExpand;
  const _CollapsedSummary({
    required this.parsedDebt,
    required this.l10n,
    required this.cs,
    required this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: cs.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.itemsSummary(
                parsedDebt.items.length.toString(),
                parsedDebt.totalAmount.toInt().toString(),
              ),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: cs.primary,
              ),
            ),
          ),
          Semantics(
            label: 'Show parsed items',
            button: true,
            child: GestureDetector(
              onTap: onExpand,
              child: Icon(
                Icons.expand_more,
                size: 20,
                color: cs.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final AppLocalizations l10n;
  final ColorScheme cs;
  const _Header({required this.l10n, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.check_circle_outline, size: 16, color: cs.primary),
        const SizedBox(width: 6),
        Text(
          l10n.parsedItems,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: cs.primary,
          ),
        ),
      ],
    );
  }
}

class _ItemRow extends StatelessWidget {
  final dynamic item;
  final ColorScheme cs;
  final VoidCallback onRemove;
  const _ItemRow({
    required this.item,
    required this.cs,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(item.name, style: const TextStyle(fontSize: 14)),
          ),
          Text(
            '${item.amount.toInt()}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(width: 8),
          Semantics(
            label: 'Remove item',
            button: true,
            child: GestureDetector(
              onTap: onRemove,
              child: Icon(
                Icons.close,
                size: 16,
                color: cs.error.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final AppLocalizations l10n;
  final ColorScheme cs;
  final double total;
  const _TotalRow({
    required this.l10n,
    required this.cs,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10n.total,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        Text(
          '${total.toInt()}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: cs.primary,
          ),
        ),
      ],
    );
  }
}

class _DueRow extends StatelessWidget {
  final AppLocalizations l10n;
  final ColorScheme cs;
  final DateTime dueDate;
  const _DueRow({
    required this.l10n,
    required this.cs,
    required this.dueDate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.calendar_today, size: 14, color: cs.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          '${l10n.due}: ${dueDate.day}/${dueDate.month}/${dueDate.year}',
          style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final AppLocalizations l10n;
  final ColorScheme cs;
  final VoidCallback onRetry;
  final VoidCallback onAccept;
  const _ActionButtons({
    required this.l10n,
    required this.cs,
    required this.onRetry,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: Text(l10n.retryParsing),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: onAccept,
            icon: const Icon(Icons.check, size: 18),
            label: Text(l10n.acceptAndSave),
          ),
        ),
      ],
    );
  }
}
