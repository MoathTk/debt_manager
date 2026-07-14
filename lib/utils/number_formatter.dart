/// Formats large numbers into compact text based on locale.
///
/// Examples (ar): "1.5 ألف", "1.25 مليون", "3 مليار"
/// Examples (en): "1.5 Thousand", "1.25 Million", "3 Billion"
class NumberFormatter {
  static String compact(double value, {String billion = 'مليار', String million = 'مليون', String thousand = 'ألف'}) {
    if (value.isNaN || value.isInfinite) return '0';
    final abs = value.abs();
    if (abs >= 1000000000) {
      final v = value / 1000000000;
      return _fmt(v, billion);
    } else if (abs >= 1000000) {
      final v = value / 1000000;
      return _fmt(v, million);
    } else if (abs >= 1000) {
      final v = value / 1000;
      return _fmt(v, thousand);
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
