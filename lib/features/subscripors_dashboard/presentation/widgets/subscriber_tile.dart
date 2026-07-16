import 'package:flutter/material.dart';
import '../../data/models/subscriber_model.dart';
import 'update_expiry_sheet.dart';

class SubscriberTile extends StatelessWidget {
  final SubscriberModel sub;
  const SubscriberTile({super.key, required this.sub});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (color, label) = _statusStyle(sub);
    final days = sub.daysRemaining;
    final daysText = sub.isExpired
        ? '${days.abs()}d ago'
        : days == 0
        ? 'Today'
        : '${days}d left';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(_planIcon(sub.plan), color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sub.userName.isNotEmpty
                        ? sub.userName
                        : sub.uid.substring(0, 8),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub.userEmail.isNotEmpty ? sub.userEmail : sub.plan,
                    style: TextStyle(fontSize: 12, color: cs.outline),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  daysText,
                  style: TextStyle(
                    fontSize: 11,
                    color: cs.outline,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                Icons.edit_calendar_rounded,
                size: 20,
                color: cs.primary,
              ),
              tooltip: 'Update expiry',
              onPressed: () => _showUpdateSheet(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => UpdateExpirySheet(sub: sub),
    );
  }

  (Color, String) _statusStyle(SubscriberModel sub) {
    if (sub.isExpired) return (Colors.red, 'Expired');
    if (sub.daysRemaining <= 1) return (Colors.orange, 'Expiring');
    return (Colors.green, 'Active');
  }

  IconData _planIcon(String plan) => switch (plan) {
    'weekly' => Icons.view_week_rounded,
    'monthly' => Icons.calendar_month_rounded,
    _ => Icons.science_rounded,
  };
}
