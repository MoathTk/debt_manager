/// Formats large numbers into compact Arabic text.
///
/// Examples:
/// - 500       → "500"
/// - 1500      → "1.5 ألف"
/// - 1250000   → "1.25 مليون"
/// - 3000000000 → "3 مليار"
class NumberFormatter {
  static String compact(double value) {
    final abs = value.abs();
    if (abs >= 1000000000) {
      final v = value / 1000000000;
      return _fmt(v, 'مليار');
    } else if (abs >= 1000000) {
      final v = value / 1000000;
      return _fmt(v, 'مليون');
    } else if (abs >= 1000) {
      final v = value / 1000;
      return _fmt(v, 'ألف');
    }
    return value.toStringAsFixed(0);
  }

  static String _fmt(double v, String suffix) {
    if (v == v.roundToDouble()) return '${v.toInt()} $suffix';
    final s = v.toStringAsFixed(2);
    final trimmed = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    return '$trimmed $suffix';
  }
}
