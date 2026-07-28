import 'package:flutter/material.dart';

class UpdateDialogHeader extends StatelessWidget {
  final Animation<double> pulse;
  final bool forceUpdate;

  const UpdateDialogHeader({
    super.key,
    required this.pulse,
    required this.forceUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = forceUpdate ? cs.error : cs.primary;

    return Container(
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
          scale: Tween(begin: 0.92, end: 1.0).animate(
            CurvedAnimation(parent: pulse, curve: Curves.easeInOut),
          ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Semantics(
              label: forceUpdate ? 'Required update' : 'Update available',
              child: Icon(
                forceUpdate ? Icons.warning_rounded : Icons.system_update_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
