import 'package:flutter/material.dart';

/// Modern pill-shaped period navigator with smooth tappable arrow buttons
/// and a centered date label on a tinted surface.
class PeriodNavigator extends StatelessWidget {
  final String label;
  final String? subtitle;
  final VoidCallback onBack;
  final VoidCallback onForward;
  final VoidCallback? onToday;
  const PeriodNavigator({
    super.key,
    required this.label,
    this.subtitle,
    required this.onBack,
    required this.onForward,
    this.onToday,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          _ArrowBtn(
            icon: Icons.chevron_left_rounded ,
            onTap: onBack,
            color: cs.primary,
          ),
          Expanded(
            child: GestureDetector(
              onTap: onToday,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ),
          _ArrowBtn(
            icon: Icons.chevron_right_rounded,
            onTap: onForward,
            color: cs.primary,
          ),
        ],
      ),
    );
  }
}

class _ArrowBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  const _ArrowBtn({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  State<_ArrowBtn> createState() => _ArrowBtnState();
}

class _ArrowBtnState extends State<_ArrowBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 44,
        height: 44,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: _pressed
              ? widget.color.withValues(alpha: 0.15)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(widget.icon, color: widget.color, size: 26),
      ),
    );
  }
}
