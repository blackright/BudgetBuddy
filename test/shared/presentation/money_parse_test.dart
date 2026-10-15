import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/money.dart';
import 'package:budget_buddy/shared/presentation/money_format.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pins the shared input parser (FR-002/FR-007): the grouping formatter inserts
/// commas, so every amount field must parse through [parseMoneyInput] and get the
/// true value back regardless of separators.
void main() {
  group('parseMoneyInput strips grouping and whitespace', () {
    test('grouped digits parse to the plain number', () {
      expect(parseMoneyInput('1,234.56'), 1234.56);
      expect(parseMoneyInput('1,000,000'), 1000000);
      expect(parseMoneyInput('1 234.56'), 1234.56);
      expect(parseMoneyInput('1000000'), 1000000);
    });

    test('surrounding whitespace is ignored', () {
      expect(parseMoneyInput('  12,345.67  '), 12345.67);
    });

    test('decimals and negatives pass through', () {
      expect(parseMoneyInput('0.5'), 0.5);
      expect(parseMoneyInput('0'), 0);
      expect(parseMoneyInput('-5'), -5);
    });
  });

  group('parseMoneyInput rejects non-numbers', () {
    test('empty and blank text yield null', () {
      expect(parseMoneyInput(''), isNull);
      expect(parseMoneyInput('   '), isNull);
    });

    test('non-numeric text yields null', () {
      expect(parseMoneyInput('abc'), isNull);
      expect(parseMoneyInput('1,2,3.4.5'), isNull);
    });
  });

  group('tryParseMoneyInput keeps its positive-only contract', () {
    test('parses grouped text into Money', () {
      expect(
        tryParseMoneyInput('1,234.56', CurrencyCode.usd),
        const Money(123456, CurrencyCode.usd),
      );
    });

    test('zero and negatives are refused at the input boundary', () {
      expect(tryParseMoneyInput('0', CurrencyCode.usd), isNull);
      expect(tryParseMoneyInput('-5', CurrencyCode.usd), isNull);
    });

    test('a currency symbol in the text is ignored', () {
      expect(
        tryParseMoneyInput(r'$1,234.56', CurrencyCode.usd),
        const Money(123456, CurrencyCode.usd),
      );
    });
  });
}
