import 'package:flutter/material.dart';

/// A label-value row used in bottom sheets.
class InfoRow extends StatelessWidget {
  final String label;
  final Widget child;
  const InfoRow({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          child,
        ],
      ),
    );
  }
}
