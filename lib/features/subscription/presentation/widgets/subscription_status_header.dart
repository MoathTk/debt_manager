import 'package:flutter/material.dart';

class SubscriptionStatusHeader extends StatelessWidget {
  final Color color;
  final Animation<double> pulse;
  const SubscriptionStatusHeader({
    super.key,
    required this.color,
    required this.pulse,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 28),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [color, color.withValues(alpha: 0.7)],
      ),
    ),
    child: Center(
      child: ScaleTransition(
        scale: Tween(
          begin: 0.92,
          end: 1.0,
        ).animate(CurvedAnimation(parent: pulse, curve: Curves.easeInOut)),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.shield_rounded,
            color: Colors.white,
            size: 36,
          ),
        ),
      ),
    ),
  );
}

class StatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  const StatusBadge(this.text, this.color, {super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      text,
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color),
    ),
  );
}
