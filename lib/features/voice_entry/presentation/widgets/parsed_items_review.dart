/// VOICE ENTRY FEATURE — PRESENTATION LAYER: PARSED ITEMS REVIEW
///
/// Shows the AI-parsed items in a reviewable list before saving.
/// Each item can be edited or removed. The total is displayed at the bottom.
/// ---------------------------------------------------------------------------
library;

import 'package:flutter/material.dart';
import '../../domain/entities/voice_parsed_debt.dart';

class ParsedItemsReview extends StatelessWidget {
  final VoiceParsedDebt parsedDebt;
  final ValueChanged<VoiceParsedDebt> onChanged;

  const ParsedItemsReview({
    super.key,
    required this.parsedDebt,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cs.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_outline, size: 16, color: cs.primary),
              const SizedBox(width: 6),
              Text(
                'Parsed Items',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: cs.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...parsedDebt.items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(fontSize: 14),
                    ),
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
                  GestureDetector(
                    onTap: () {
                      final newItems = List.of(parsedDebt.items)..removeAt(i);
                      final newTotal =
                          newItems.fold(0.0, (sum, i) => sum + i.amount);
                      onChanged(parsedDebt.copyWith(
                        items: newItems,
                        totalAmount: newTotal,
                      ));
                    },
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: cs.error.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            );
          }),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${parsedDebt.totalAmount.toInt()}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: cs.primary,
                ),
              ),
            ],
          ),
          if (parsedDebt.dueDate != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: cs.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  'Due: ${parsedDebt.dueDate!.day}/${parsedDebt.dueDate!.month}/${parsedDebt.dueDate!.year}',
                  style: TextStyle(
                    fontSize: 13,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
