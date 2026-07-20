import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';
import 'package:local_debt_management/features/subscription/presentation/providers/subscription_provider.dart';
import '../../data/models/subscriber_model.dart';
import '../providers/subscribers_provider.dart';

class UpdateExpirySheet extends ConsumerStatefulWidget {
  final SubscriberModel sub;
  const UpdateExpirySheet({super.key, required this.sub});

  @override
  ConsumerState<UpdateExpirySheet> createState() => _UpdateExpirySheetState();
}

class _UpdateExpirySheetState extends ConsumerState<UpdateExpirySheet> {
  late DateTime _newExpiry;

  @override
  void initState() {
    super.initState();
    _newExpiry = widget.sub.isExpired ? DateTime.now()  : widget.sub.expiresAt;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final fmt = DateFormat('yyyy-MM-dd HH:mm');
    final name = widget.sub.userName.isNotEmpty
        ? widget.sub.userName : widget.sub.uid.substring(0, 8);

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.updateExpiry, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(name, style: TextStyle(color: cs.outline)),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                Icon(Icons.calendar_today, size: 20, color: cs.primary),
                const SizedBox(width: 10),
                Text(fmt.format(_newExpiry), style: const TextStyle(fontSize: 15)),
                const Spacer(),
                Icon(Icons.edit_calendar_rounded, size: 18, color: cs.outline),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            _quickBtn(l10n.extend15min, const Duration(minutes: 15)),
            const SizedBox(width: 8),
            _quickBtn(l10n.extend30min, const Duration(minutes: 30)),
            const SizedBox(width: 8),
            _quickBtn(l10n.extend1hour, const Duration(hours: 1)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            _quickBtn(l10n.extendWeek, const Duration(days: 7)),
            const SizedBox(width: 8),
            _quickBtn(l10n.extend2Weeks, const Duration(days: 14)),
            const SizedBox(width: 8),
            _quickBtn(l10n.extendMonth, const Duration(days: 30)),
          ]),
          const SizedBox(height: 20),
          FilledButton(onPressed: _save, child: Text(l10n.save)),
        ],
      ),
    );
  }

  Widget _quickBtn(String label, Duration duration) => Expanded(
    child: OutlinedButton(
      onPressed: () => setState(() => _newExpiry = _newExpiry.add(duration)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    ),
  );

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context, initialDate: _newExpiry, firstDate: now,
      lastDate: now.add(const Duration(days: 365)));
    if (picked != null) setState(() => _newExpiry = picked);
  }

  Future<void> _save() async {
    await ref.read(subscribersProvider.notifier).updateExpiry(widget.sub.uid, _newExpiry);
    ref.read(subscriptionProvider.notifier).load();
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.expiryUpdated)));
  }
}
