import 'package:flutter/services.dart';

/// Adds thousand separators (commas) to numeric input as the user types.
/// Strips non-numeric characters and formats with commas.
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    // Strip non-numeric chars (keep digits and one decimal point)
    final raw = newValue.text.replaceAll(RegExp(r'[^\d.]'), '');
    if (raw.isEmpty) return const TextEditingValue();

    // Handle multiple decimal points — keep only first
    final firstDot = raw.indexOf('.');
    final clean = firstDot >= 0
        ? '${raw.substring(0, firstDot + 1)}${raw.substring(firstDot + 1).replaceAll('.', '')}'
        : raw;

    final formatted = _formatWithCommas(clean);

    // Calculate cursor position based on meaningful chars (digits + dot) before cursor
    final cursorOffset = newValue.selection.baseOffset;
    final beforeCursor = newValue.text.substring(
      0,
      cursorOffset.clamp(0, newValue.text.length),
    );
    final meaningfulBefore = beforeCursor
        .replaceAll(RegExp(r'[^0-9.]'), '')
        .length;

    int newPos = 0;
    int meaningfulCount = 0;
    for (int i = 0; i < formatted.length; i++) {
      if (meaningfulCount >= meaningfulBefore) break;
      if (formatted[i] != ',') meaningfulCount++;
      newPos = i + 1;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newPos),
    );
  }

  String _formatWithCommas(String text) {
    final parts = text.split('.');
    final intPart = parts[0];
    final decPart = parts.length > 1 ? '.${parts[1]}' : '';
    final buf = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(',');
      buf.write(intPart[i]);
    }
    return '$buf$decPart';
  }
}

/// Formats a number with thousand separators for display.
/// 50 → "50", 1000 → "1,000", 10000.5 → "10,000.50"
String formatAmount(double n) {
  final s = n % 1 == 0 ? n.toStringAsFixed(0) : n.toStringAsFixed(2);
  final parts = s.split('.');
  final intPart = parts[0];
  final decPart = parts.length > 1 ? '.${parts[1]}' : '';
  final buf = StringBuffer();
  for (int i = 0; i < intPart.length; i++) {
    if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(',');
    buf.write(intPart[i]);
  }
  return '$buf$decPart';
}

/// Parses a formatted amount string (with commas) back to a double.
/// "1,000" → 1000.0, "10,000.50" → 10000.5
double? parseAmount(String s) => double.tryParse(s.replaceAll(',', ''));
