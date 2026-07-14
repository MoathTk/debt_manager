import 'package:flutter_test/flutter_test.dart';
import 'package:local_debt_management/utils/number_formatter.dart';

void main() {
  group('NumberFormatter.compact', () {
    test('returns raw number below 1000', () {
      expect(NumberFormatter.compact(0), '0');
      expect(NumberFormatter.compact(1), '1');
      expect(NumberFormatter.compact(999), '999');
      expect(NumberFormatter.compact(-50), '-50');
    });

    test('formats thousands', () {
      expect(NumberFormatter.compact(1000), '1 ألف');
      expect(NumberFormatter.compact(1500), '1.5 ألف');
      expect(NumberFormatter.compact(100000), '100 ألف');
    });

    test('formats millions', () {
      expect(NumberFormatter.compact(1000000), '1 مليون');
      expect(NumberFormatter.compact(1500000), '1.5 مليون');
      expect(NumberFormatter.compact(2500000), '2.5 مليون');
    });

    test('formats billions', () {
      expect(NumberFormatter.compact(1000000000), '1 مليار');
      expect(NumberFormatter.compact(2500000000), '2.5 مليار');
    });

    test('trailing zeros trimmed', () {
      expect(NumberFormatter.compact(1000), '1 ألف');
      expect(NumberFormatter.compact(2000), '2 ألف');
      expect(NumberFormatter.compact(1000000), '1 مليون');
    });

    test('custom suffixes (English)', () {
      expect(
        NumberFormatter.compact(1500, billion: 'Billion', million: 'Million', thousand: 'Thousand'),
        '1.5 Thousand',
      );
      expect(
        NumberFormatter.compact(2500000, billion: 'Billion', million: 'Million', thousand: 'Thousand'),
        '2.5 Million',
      );
    });

    test('NaN returns "0"', () {
      expect(NumberFormatter.compact(double.nan), '0');
    });

    test('Infinity returns "0"', () {
      expect(NumberFormatter.compact(double.infinity), '0');
      expect(NumberFormatter.compact(double.negativeInfinity), '0');
    });

    test('negative values', () {
      expect(NumberFormatter.compact(-1500), '-1.5 ألف');
      expect(NumberFormatter.compact(-2500000), '-2.5 مليون');
    });
  });
}
