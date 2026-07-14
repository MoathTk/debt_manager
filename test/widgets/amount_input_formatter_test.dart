import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:local_debt_management/widgets/amount_input_formatter.dart';

void main() {
  group('ThousandsSeparatorInputFormatter', () {
    final formatter = ThousandsSeparatorInputFormatter();

    TextEditingValue fmt(String input, [int cursorPos = -1]) {
      final old = const TextEditingValue();
      final sel = cursorPos >= 0
          ? TextSelection.collapsed(offset: cursorPos)
          : TextSelection.collapsed(offset: input.length);
      return formatter.formatEditUpdate(old, TextEditingValue(text: input, selection: sel));
    }

    test('empty input returns empty', () {
      expect(fmt('').text, '');
    });

    test('plain number — no commas for < 1000', () {
      expect(fmt('50').text, '50');
      expect(fmt('999').text, '999');
    });

    test('adds commas for thousands', () {
      expect(fmt('1000').text, '1,000');
      expect(fmt('12345').text, '12,345');
      expect(fmt('1234567').text, '1,234,567');
    });

    test('decimal input — comma after whole part', () {
      expect(fmt('1000.5').text, '1,000.5');
      expect(fmt('12345.67').text, '12,345.67');
    });

    test('strips non-numeric characters', () {
      expect(fmt('abc').text, '');
      expect(fmt('12ab34').text, '1,234');
    });

    test('handles multiple decimal points — keeps only first', () {
      expect(fmt('1.2.3').text, '1.23');
    });

    test('cursor position — simple', () {
      final result = fmt('1000', 2);
      expect(result.text, '1,000');
      expect(result.selection.baseOffset, 3);
    });
  });

  group('formatAmount', () {
    test('integer amounts — no decimals', () {
      expect(formatAmount(50), '50');
      expect(formatAmount(1000), '1,000');
      expect(formatAmount(1234567), '1,234,567');
    });

    test('decimal amounts — 2 decimal places', () {
      expect(formatAmount(50.5), '50.50');
      expect(formatAmount(1234.56), '1,234.56');
      expect(formatAmount(0.1), '0.10');
    });

    test('zero', () {
      expect(formatAmount(0), '0');
    });

    test('NaN returns "0"', () {
      expect(formatAmount(double.nan), '0');
    });

    test('Infinity returns "0"', () {
      expect(formatAmount(double.infinity), '0');
      expect(formatAmount(double.negativeInfinity), '0');
    });

    test('exact .50 values show .50', () {
      expect(formatAmount(100.50), '100.50');
    });
  });

  group('parseAmount', () {
    test('parses plain number', () {
      expect(parseAmount('50'), 50.0);
    });

    test('parses comma-formatted number', () {
      expect(parseAmount('1,000'), 1000.0);
      expect(parseAmount('12,345.67'), 12345.67);
    });

    test('returns null for invalid input', () {
      expect(parseAmount('abc'), null);
      expect(parseAmount(''), null);
    });
  });
}
