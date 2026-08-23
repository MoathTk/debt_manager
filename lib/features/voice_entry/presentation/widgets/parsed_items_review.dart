/// VOICE ENTRY FEATURE — PRESENTATION LAYER: PARSED ITEMS REVIEW
///
/// Shows the AI-parsed items in a reviewable list before saving.
/// Includes read-only transcript display, inline item editing,
/// and action buttons (Re-record, Retry, Accept).
/// ---------------------------------------------------------------------------
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/voice_parsed_debt.dart';

class ParsedItemsReview extends StatefulWidget {
  final VoiceParsedDebt parsedDebt;
  final String? transcript;
  final ValueChanged<VoiceParsedDebt> onChanged;
  final VoidCallback onAccept;
  final VoidCallback onRetry;
  final VoidCallback onReRecord;

  const ParsedItemsReview({
    super.key,
    required this.parsedDebt,
    this.transcript,
    required this.onChanged,
    required this.onAccept,
    required this.onRetry,
    required this.onReRecord,
  });

  @override
  State<ParsedItemsReview> createState() => _ParsedItemsReviewState();
}

class _ParsedItemsReviewState extends State<ParsedItemsReview> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

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
          if (widget.transcript != null && widget.transcript!.isNotEmpty) ...[
            _TranscriptSection(l10n: l10n, cs: cs, transcript: widget.transcript!),
            const SizedBox(height: 12),
          ],
          _Header(l10n: l10n, cs: cs),
          const SizedBox(height: 8),
          ...widget.parsedDebt.items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return _EditableItemRow(
              item: item,
              cs: cs,
              l10n: l10n,
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
              onChanged: (updated) {
                final newItems = List.of(widget.parsedDebt.items);
                newItems[i] = updated;
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
            onReRecord: widget.onReRecord,
            onRetry: widget.onRetry,
            onAccept: widget.onAccept,
          ),
        ],
      ),
    );
  }
}

class _TranscriptSection extends StatelessWidget {
  final AppLocalizations l10n;
  final ColorScheme cs;
  final String transcript;
  const _TranscriptSection({
    required this.l10n,
    required this.cs,
    required this.transcript,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.transcribe, size: 14, color: cs.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                l10n.transcript,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            transcript,
            style: TextStyle(
              fontSize: 13,
              color: cs.onSurface.withValues(alpha: 0.7),
              height: 1.4,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
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

class _EditableItemRow extends StatefulWidget {
  final VoiceParsedItem item;
  final ColorScheme cs;
  final AppLocalizations l10n;
  final VoidCallback onRemove;
  final ValueChanged<VoiceParsedItem> onChanged;
  const _EditableItemRow({
    required this.item,
    required this.cs,
    required this.l10n,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  State<_EditableItemRow> createState() => _EditableItemRowState();
}

class _EditableItemRowState extends State<_EditableItemRow> {
  bool _editing = false;
  late TextEditingController _nameController;
  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _amountController =
        TextEditingController(text: widget.item.amount.toInt().toString());
  }

  @override
  void didUpdateWidget(_EditableItemRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_editing) {
      _nameController.text = widget.item.name;
      _amountController.text = widget.item.amount.toInt().toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (name.isNotEmpty && amount > 0) {
      widget.onChanged(VoiceParsedItem(name: name, amount: amount));
    }
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_editing) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: _nameController,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onSubmitted: (_) => _save(),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              flex: 2,
              child: TextField(
                controller: _amountController,
                style: const TextStyle(fontSize: 13),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onSubmitted: (_) => _save(),
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: _save,
              child: Icon(Icons.check, size: 18, color: widget.cs.primary),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => setState(() => _editing = true),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.item.name,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            Text(
              '${widget.item.amount.toInt()}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: widget.cs.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            Semantics(
              label: widget.l10n.remove,
              button: true,
              child: GestureDetector(
                onTap: widget.onRemove,
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: widget.cs.error.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
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
  final VoidCallback onReRecord;
  final VoidCallback onRetry;
  final VoidCallback onAccept;
  const _ActionButtons({
    required this.l10n,
    required this.cs,
    required this.onReRecord,
    required this.onRetry,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onReRecord,
                icon: const Icon(Icons.mic, size: 18),
                label: Text(l10n.reRecord),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(l10n.retryParsing),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
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
