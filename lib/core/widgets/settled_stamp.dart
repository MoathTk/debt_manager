import 'package:flutter/material.dart';
import 'package:local_debt_management/core/theme/app_type.dart';

/// Signature element: a rotated, hairline-bordered stamp marking a debt as
/// fully settled or paid off — an echo of the physical postage marked on
/// ledger books.
///
/// The stamp is intentionally quiet: transparent fill, a thin border and
/// tracked uppercase text. Rotate it a few degrees so it reads as an
/// imprint on the card rather than a chrome badge.
class SettledStamp extends StatelessWidget {
  final String label;

  /// Ink color of the border and text. Defaults to the theme's success color.
  final Color? color;

  /// Rotation applied around the stamp's center, in radians.
  final double rotation;

  const SettledStamp({
    super.key,
    required this.label,
    this.color,
    this.rotation = -0.08,
  });

  @override
  Widget build(BuildContext context) {
    final ink = color ?? Theme.of(context).colorScheme.tertiary;
    return Transform.rotate(
      angle: rotation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: ink, width: 1.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label.toUpperCase(),
          textAlign: TextAlign.center,
          style: AppType.labelSmall.copyWith(
            color: ink,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}