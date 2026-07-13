import 'package:flutter/material.dart';

/// Shows a floating success overlay alert with a check icon.
void showSuccessSnackBar(BuildContext context, String message) {
  _showAppAlert(
    context: context,
    message: message,
    icon: Icons.check_circle_rounded,
    color: Theme.of(context).colorScheme.primary,
  );
}

/// Shows a floating error overlay alert with an error icon.
void showErrorSnackBar(BuildContext context, String message) {
  _showAppAlert(
    context: context,
    message: message,
    icon: Icons.error_rounded,
    color: Theme.of(context).colorScheme.error,
  );
}

void _showAppAlert({
  required BuildContext context,
  required String message,
  required IconData icon,
  required Color color,
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _AlertOverlay(
      message: message,
      icon: icon,
      color: color,
      onDismiss: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
}

class _AlertOverlay extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color color;
  final VoidCallback onDismiss;
  const _AlertOverlay({
    required this.message,
    required this.icon,
    required this.color,
    required this.onDismiss,
  });

  @override
  State<_AlertOverlay> createState() => _AlertOverlayState();
}

class _AlertOverlayState extends State<_AlertOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 3), _dismiss);
  }

  void _dismiss() {
    if (!mounted) return;
    _ctrl.reverse().then((_) {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top + 12;
    return Positioned(
      top: top,
      left: 20,
      right: 20,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(14),
            color: widget.color,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _dismiss,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                child: Row(
                  children: [
                    Icon(widget.icon, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
