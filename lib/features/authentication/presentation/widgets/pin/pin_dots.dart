import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Modern PIN indicator — a row of large square cells reveal each typed digit.
///
/// The cells size themselves from the available width ([LayoutBuilder]) so the
/// row always fits the screen: they grow to fill up to a max of 44px each.
///
/// Nice touches:
/// - Filled cells show the typed digit on the same surface background (no
///   background swap); only the border adopts the `primary`/`error` tint.
/// - The upcoming slot shows a subtle primary ring ("current position" hint).
/// - When [hasError] flips on, the row shakes with a damped sine and the
///   digits turn [ColorScheme.error] red.
class PinDots extends StatefulWidget {
  final String value;
  final int maxLength;
  final bool hasError;

  static const gap = 8.0;
  static const maxDotSize = 44.0;

  const PinDots({
    super.key,
    required this.value,
    required this.maxLength,
    this.hasError = false,
  });

  @override
  State<PinDots> createState() => _PinDotsState();
}

class _PinDotsState extends State<PinDots> with SingleTickerProviderStateMixin {
  late final AnimationController _shake;

  @override
  void initState() {
    super.initState();
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
  }

  @override
  void didUpdateWidget(covariant PinDots oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hasError && !oldWidget.hasError) {
      _shake.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = widget.hasError ? cs.error : cs.primary;
    final chars = widget.value.split('');
    final shown = chars.length > widget.maxLength
        ? chars.take(widget.maxLength).toList()
        : chars;

    return LayoutBuilder(
      builder: (context, constraints) {
final raw =
            (constraints.maxWidth - PinDots.gap * widget.maxLength - 1) /
                widget.maxLength;
        final size = math.min(raw, PinDots.maxDotSize);

        return AnimatedBuilder(
          animation: _shake,
          builder: (context, _) {
            final damped =
                math.sin(_shake.value * 5 * math.pi) * (1 - _shake.value);
            return Transform.translate(
              offset: Offset(widget.hasError ? damped * 14 : 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.maxLength, (i) {
                  final filled = i < shown.length;
                  final isNext = i == shown.length && !widget.hasError;
                  final digitColor = widget.hasError ? color : cs.onSurface;
                  return _Dot(
                    size: size,
                    filled: filled,
                    isNext: isNext,
                    digit: filled ? shown[i] : null,
                    color: color,
                    digitColor: digitColor,
                  );
                }),
              ),
            );
          },
        );
      },
    );
  }
}

class _Dot extends StatelessWidget {
  final double size;
  final bool filled;
  final bool isNext;
  final String? digit;
  final Color color;
  final Color digitColor;

  const _Dot({
    required this.size,
    required this.filled,
    required this.isNext,
    required this.digit,
    required this.color,
    required this.digitColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      margin: const EdgeInsets.symmetric(horizontal: PinDots.gap / 2),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(size * 0.22),
        color: cs.surface,
        border: Border.all(
          color: filled
              ? color.withValues(alpha: 0.7)
              : (isNext
                    ? color.withValues(alpha: 0.55)
                    : cs.outline.withValues(alpha: 0.28)),
          width: filled ? 2 : 1.8,
        ),
      ),
      child: digit == null
          ? null
          : Center(
              child: Text(
                digit!,
                style: TextStyle(
                  color: digitColor,
                  fontSize: size * 0.42,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ),
    );
  }
}
