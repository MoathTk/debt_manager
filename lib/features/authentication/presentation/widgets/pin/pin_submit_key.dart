import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Circular submit key that sits in the keypad's bottom-left slot, beside 0.
///
/// - [loading] → spinner in a primary container.
/// - [isNext] → forward arrow (moves to the confirm step), else a check
///   (submits the PIN).
class PinSubmitKey extends StatefulWidget {
  final bool loading;
  final bool enabled;
  final bool isNext;
  final VoidCallback onPressed;

  const PinSubmitKey({
    super.key,
    required this.loading,
    required this.enabled,
    required this.isNext,
    required this.onPressed,
  });

  @override
  State<PinSubmitKey> createState() => _PinSubmitKeyState();
}

class _PinSubmitKeyState extends State<PinSubmitKey> {
  bool _down = false;

  void _handleTapUp() {
    if (!_down) return;
    _down = false;
    setState(() {});
    HapticFeedback.selectionClick();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (widget.loading) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: cs.primaryContainer,
        ),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: cs.primary,
            ),
          ),
        ),
      );
    }

    final color = widget.enabled
        ? cs.primary
        : cs.primary.withValues(alpha: 0.3);
    return GestureDetector(
      onTapDown: (_) {
        if (!widget.enabled) return;
        setState(() => _down = true);
      },
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => _handleTapUp(),
      child: AnimatedScale(
        scale: _down ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          child: Icon(
            widget.isNext ? Icons.arrow_forward_rounded : Icons.check_rounded,
            size: 26,
            color: Colors.white.withValues(alpha: widget.enabled ? 1.0 : 0.5),
          ),
        ),
      ),
    );
  }
}
