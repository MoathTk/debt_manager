import 'package:flutter/material.dart';

/// Animated counter that counts up from 0 to [targetValue].
///
/// Uses [AnimationController] with [CurvedAnimation] for smooth easing.
/// The number animates over [duration] when the widget first builds.
/// An optional [formatter] transforms the raw value before display.
class AnimatedCounter extends StatefulWidget {
  final double targetValue;
  final Duration duration;
  final TextStyle? style;
  final String Function(double value)? formatter;

  const AnimatedCounter({
    super.key,
    required this.targetValue,
    this.duration = const Duration(milliseconds: 6000),
    this.style,
    this.formatter,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(
      begin: 0,
      end: widget.targetValue,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetValue != widget.targetValue) {
      _animation = Tween<double>(begin: 0, end: widget.targetValue).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final val = _animation.value;
        final text = widget.formatter != null
            ? widget.formatter!(val)
            : val.toStringAsFixed(0);
        return Text(text, style: widget.style);
      },
    );
  }
}
