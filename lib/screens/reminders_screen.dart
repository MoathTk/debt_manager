import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../Providers/database_provider.dart';
import '../data/models/debt_reminder.dart';
import '../widgets/reminder_filters.dart';
import '../widgets/reminder_card.dart';
import '../widgets/reminder_detail_sheet.dart';

class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});
  @override
  ConsumerState<RemindersScreen> createState() => _RemindersState();
}

class _RemindersState extends ConsumerState<RemindersScreen> {
  String _query = '';
  String _statusFilter = 'all';
  String _sortBy = 'dateNewest';
  Map<String, String> _names = {};
  Map<String, double> _amounts = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final customers = await ref.read(customersProvider.future);
    final reminders = await ref.read(allRemindersProvider.future);
    final repo = ref.read(transactionRepositoryProvider);
    final amounts = <String, double>{};
    for (final r in reminders) {
      if (r.debtId != null && !amounts.containsKey(r.debtId)) {
        final txn = await repo.getById(r.debtId!);
        if (txn != null) amounts[r.debtId!] = txn.amount;
      }
    }
    if (mounted) {
      setState(() {
        _names = {for (var c in customers) c.id!: c.name};
        _amounts = amounts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final remindersAsync = ref.watch(allRemindersProvider);
    final allReminders = remindersAsync.valueOrNull ?? [];
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(allRemindersProvider);
        await _loadData();
      },
      child: Column(
        children: [
          ReminderSearchBar(onChanged: (q) => setState(() => _query = q)),
          ReminderFilterBar(
            statusFilter: _statusFilter,
            sortBy: _sortBy,
            statusCounts: _counts(allReminders),
            onStatusChanged: (v) => setState(() => _statusFilter = v),
            onSortChanged: (v) => setState(() => _sortBy = v),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: remindersAsync.when(
              data: (all) {
                final filtered = _sort(_filter(all));
                if (filtered.isEmpty) {
                  return _EmptyState(
                    l10n: l10n,
                    hasFilter: _query.isNotEmpty || _statusFilter != 'all',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) => ReminderCard(
                    reminder: filtered[i],
                    accent: _accent(filtered[i]),
                    onTap: () => showReminderDetailSheet(ctx, ref, filtered[i]),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  List<DebtReminder> _filter(List<DebtReminder> all) {
    final todayStr = _todayStr();
    List<DebtReminder> list;
    switch (_statusFilter) {
      case 'late':
        list = all
            .where(
              (r) => !r.completed && r.reminderDate.compareTo(todayStr) < 0,
            )
            .toList();
      case 'pending':
        list = all
            .where(
              (r) => !r.completed && r.reminderDate.compareTo(todayStr) >= 0,
            )
            .toList();
      case 'completed':
        list = all.where((r) => r.completed).toList();
      default:
        list = all.toList();
    }
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((r) {
        final name = _names[r.customerId]?.toLowerCase() ?? '';
        final msg = r.message?.toLowerCase() ?? '';
        return name.contains(q) || msg.contains(q);
      }).toList();
    }
    return list;
  }

  List<DebtReminder> _sort(List<DebtReminder> list) {
    list.sort((a, b) {
      switch (_sortBy) {
        case 'dateOldest':
          return a.reminderDate.compareTo(b.reminderDate);
        case 'amountHighest':
          final aa = _amounts[a.debtId] ?? 0, bb = _amounts[b.debtId] ?? 0;
          return bb.compareTo(aa);
        case 'amountLowest':
          final aa = _amounts[a.debtId] ?? 0, bb = _amounts[b.debtId] ?? 0;
          return aa.compareTo(bb);
        case 'nameAZ':
          final na = _names[a.customerId] ?? '',
              nb = _names[b.customerId] ?? '';
          return na.compareTo(nb);
        default:
          return b.reminderDate.compareTo(a.reminderDate);
      }
    });
    return list;
  }

  Color _accent(DebtReminder r) {
    if (r.completed) return Colors.grey;
    final todayStr = _todayStr();
    if (r.reminderDate.compareTo(todayStr) < 0) return Colors.red;
    if (r.reminderDate == todayStr) return Colors.orange;
    return Colors.blue;
  }

  Map<String, int> _counts(List<DebtReminder> all) {
    final todayStr = _todayStr();
    return {
      'all': all.length,
      'late': all
          .where((r) => !r.completed && r.reminderDate.compareTo(todayStr) < 0)
          .length,
      'pending': all
          .where((r) => !r.completed && r.reminderDate.compareTo(todayStr) >= 0)
          .length,
      'completed': all.where((r) => r.completed).length,
    };
  }

  String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations l10n;
  final bool hasFilter;
  const _EmptyState({required this.l10n, this.hasFilter = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasFilter
                ? Icons.search_off_rounded
                : Icons.notifications_none_rounded,
            size: 64,
            color: cs.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            hasFilter ? l10n.noResults : l10n.noReminders,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noRemindersMessage,
            style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
