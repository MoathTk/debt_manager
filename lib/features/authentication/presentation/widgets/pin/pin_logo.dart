import 'package:flutter/material.dart';

/// Animated shield/lock logo with a soft pulse + glow.
/// Echoes the login screen's [AnimatedLogo] visual language.
class PinLogo extends StatefulWidget {
  final bool isSetup;

  const PinLogo({super.key, required this.isSetup});

  @override
  State<PinLogo> createState() => _PinLogoState();
}

class _PinLogoState extends State<PinLogo> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _scale = Tween(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _glow = Tween(begin: 0.18, end: 0.42).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) => Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cs.primary, cs.primary.withValues(alpha: 0.72)],
          ),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: _glow.value),
              blurRadius: 26,
              spreadRadius: 2,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Transform.scale(
          scale: _scale.value,
          child: Icon(
            widget.isSetup ? Icons.shield_rounded : Icons.lock_rounded,
            size: 36,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}