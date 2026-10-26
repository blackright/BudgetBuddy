import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/network/rate_types.dart';
import 'package:budget_buddy/shared/presentation/money_conversion.dart';
import 'package:flutter_test/flutter_test.dart';

RateTable _table() => RateTable(
      usdRates: {
        CurrencyCode.usd: 1.0,
        CurrencyCode.eur: 0.86,
        CurrencyCode.huf: 345.0,
        CurrencyCode.cad: 1.36,
      },
      asOf: DateTime(2026, 1, 31),
      fetchedAt: DateTime(2026, 2, 1),
      source: RateSource.historical,
    );

void main() {
  final table = _table();

  group('convertAndFormat', () {
    test('shows the converted amount as primary and keeps the original', () {
      // 1000 Ft at 345 Ft/$ is $2.90.
      final result = convertAndFormat(
        1000,
        CurrencyCode.huf,
        CurrencyCode.usd,
        table,
      );

      expect(result.text, r'$ 2.90');
      expect(result.originalText, 'Ft 1,000');
      expect(result.wasConverted, isTrue);
    });

    test('same currency has no original tooltip', () {
      final result = convertAndFormat(
        500,
        CurrencyCode.usd,
        CurrencyCode.usd,
        table,
      );

      expect(result.text, r'$ 5.00');
      expect(result.originalText, isNull);
      expect(result.wasConverted, isFalse);
    });

    test('a missing table degrades to zero rather than inventing a rate', () {
      final result = convertAndFormat(
        1000,
        CurrencyCode.huf,
        CurrencyCode.usd,
        null,
      );

      expect(result.text, r'$ 0.00');
      expect(result.originalText, 'Ft 1,000');
    });
  });
}
