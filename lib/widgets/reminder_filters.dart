import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Search bar for filtering reminders by customer name or message.
class ReminderSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const ReminderSearchBar({super.key, required this.onChanged});
  @override
  State<ReminderSearchBar> createState() => _ReminderSearchBarState();
}

class _ReminderSearchBarState extends State<ReminderSearchBar> {
  final _ctrl = TextEditingController();
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final hasQuery = _ctrl.text.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: TextField(
        controller: _ctrl,
        onChanged: (q) {
          widget.onChanged(q);
          setState(() {});
        },
        style: const TextStyle(fontSize: 18),
        decoration: InputDecoration(
          hintText: l10n.searchReminders,
          hintStyle: const TextStyle(fontSize: 16),
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: hasQuery
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _ctrl.clear();
                    widget.onChanged('');
                    setState(() {});
                  },
                )
              : null,
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.45,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}

/// Two dropdowns for filtering by status and sorting reminders.
class ReminderFilterBar extends StatelessWidget {
  final String statusFilter;
  final String sortBy;
  final Map<String, int> statusCounts;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onSortChanged;
  const ReminderFilterBar({
    super.key,
    required this.statusFilter,
    required this.sortBy,
    required this.statusCounts,
    required this.onStatusChanged,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: _ModernDropdown<String>(
              label: l10n.filter,
              value: statusFilter,
              items: [
                (
                  value: 'all',
                  label: l10n.all,
                  icon: Icons.tune_rounded,
                  color: null,
                  count: statusCounts['all'],
                ),
                (
                  value: 'late',
                  label: l10n.overdue,
                  icon: Icons.error_outline_rounded,
                  color: Colors.red,
                  count: statusCounts['late'],
                ),
                (
                  value: 'pending',
                  label: l10n.pendingReminders,
                  icon: Icons.schedule_rounded,
                  color: Colors.orange,
                  count: statusCounts['pending'],
                ),
                (
                  value: 'completed',
                  label: l10n.completedReminders,
                  icon: Icons.check_circle_outline_rounded,
                  color: Colors.green,
                  count: statusCounts['completed'],
                ),
              ],
              onChanged: (v) {
                if (v != null) onStatusChanged(v);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ModernDropdown<String>(
              label: l10n.sortBy,
              value: sortBy,
              items: [
                (
                  value: 'dateNewest',
                  label: l10n.sortByDateNewest,
                  icon: Icons.arrow_downward_rounded,
                  color: null,
                  count: null,
                ),
                (
                  value: 'dateOldest',
                  label: l10n.sortByDateOldest,
                  icon: Icons.arrow_upward_rounded,
                  color: null,
                  count: null,
                ),
                (
                  value: 'amountHighest',
                  label: l10n.sortByAmountHighest,
                  icon: Icons.trending_down_rounded,
                  color: null,
                  count: null,
                ),
                (
                  value: 'amountLowest',
                  label: l10n.sortByAmountLowest,
                  icon: Icons.trending_up_rounded,
                  color: null,
                  count: null,
                ),
                (
                  value: 'nameAZ',
                  label: l10n.sortByNameAZ,
                  icon: Icons.sort_by_alpha_rounded,
                  color: null,
                  count: null,
                ),
              ],
              onChanged: (v) {
                if (v != null) onSortChanged(v);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<({T value, String label, IconData icon, Color? color, int? count})>
  items;
  final ValueChanged<T?> onChanged;
  const _ModernDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final current = items.firstWhere((i) => i.value == value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: PopupMenuButton<T>(
            onSelected: onChanged,
            offset: const Offset(0, 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Icon(
                    current.icon,
                    size: 17,
                    color: current.color ?? cs.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      current.label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 19,
                    color: cs.onSurfaceVariant,
                  ),
                ],
              ),
            ),
            itemBuilder: (_) => items
                .map(
                  (i) => PopupMenuItem<T>(
                    value: i.value,
                    height: 44,
                    child: Row(
                      children: [
                        Icon(
                          i.icon,
                          size: 18,
                          color: i.color ?? cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            i.label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: i.value == value
                                  ? cs.primary
                                  : cs.onSurface,
                            ),
                          ),
                        ),
                        if (i.count != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: (i.color ?? cs.primary).withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${i.count}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: i.color ?? cs.primary,
                              ),
                            ),
                          ),
                        if (i.value == value)
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Icon(
                              Icons.check_rounded,
                              size: 17,
                              color: cs.primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
