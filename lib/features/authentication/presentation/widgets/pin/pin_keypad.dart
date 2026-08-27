import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// In-app numeric keypad: 1-9 with 0 and backspace on the bottom row.
///
/// [bottomLeft] renders in the empty bottom-left slot — the submit key lives
/// there so the whole entry surface is one grid.
///
/// Layout is forced LTR so digits run 1-9 even under an RTL locale.
/// Each key gives light haptic feedback on tap and a springy scale-in press.
/// Long-pressing the backspace clears the whole PIN.
class PinKeypad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final Widget? bottomLeft;

  const PinKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    required this.onClear,
    this.bottomLeft,
  });

  static const _rows = <List<String>>[
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
  ];

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final row in _rows)
              Row(
                children: [
                  for (final key in row)
                    Expanded(child: _cell(_textKey(context, key, tt))),
                ],
              ),
            Row(
              children: [
                Expanded(child: _cell(bottomLeft ?? const SizedBox())),
                Expanded(child: _cell(_textKey(context, '0', tt))),
                Expanded(child: _cell(_backspaceKey(cs))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _cell(Widget child) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: AspectRatio(aspectRatio: 1, child: child),
    );
  }

  Widget _textKey(BuildContext context, String key, TextTheme tt) {
    return _PinKeyButton(
      onTap: () => onDigit(key),
      child: Text(
        key,
        style: tt.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _backspaceKey(ColorScheme cs) {
    return _PinKeyButton(
      onTap: onBackspace,
      onLongPress: onClear,
      child: const Icon(Icons.backspace_outlined, size: 26),
    );
  }
}

class _PinKeyButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _PinKeyButton({
    required this.child,
    required this.onTap,
    this.onLongPress,
  });

  @override
  State<_PinKeyButton> createState() => _PinKeyButtonState();
}

class _PinKeyButtonState extends State<_PinKeyButton> {
  bool _down = false;

  void _handleTapUp() {
    if (!_down) return;
    _down = false;
    setState(() {});
    HapticFeedback.selectionClick();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => _handleTapUp(),
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        scale: _down ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _down
                ? cs.primary.withValues(alpha: 0.14)
                : cs.surfaceContainerHighest.withValues(alpha: 0.75),
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}
