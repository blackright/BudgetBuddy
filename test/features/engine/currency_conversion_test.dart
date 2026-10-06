import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/money.dart';
import 'package:budget_buddy/core/network/rate_types.dart';
import 'package:budget_buddy/features/engine/currency_conversion.dart';
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
  const codes = CurrencyCode.values;

  group('convert — conversion matrix (FR-012, FR-013, FR-014)', () {
    test('all 12 directed pairs use usdRate[to]/usdRate[from] exactly', () {
      final table = _table();

      for (final from in codes) {
        for (final to in codes) {
          if (from == to) continue;

          final amount = Money(1000000, from);
          final result = convert(amount, to, table);
          final expectedRate = _table().usdRates[to]! / _table().usdRates[from]!;
          final expectedMinor = (amount.minorUnits *
                  expectedRate *
                  to.minorUnitsPerMajor /
                  from.minorUnitsPerMajor)
              .round();

          expect(result.isDegraded, isFalse,
              reason: '${from.code}->${to.code} must not degrade');
          expect(result.rate, closeTo(expectedRate, 1e-12),
              reason: 'rate ${from.code}→${to.code}');
          expect(result.amount.currency, to);
          expect(result.amount, Money(expectedMinor, to));
        }
      }
    });

    test('A→B→C equals A→C within one display rounding step', () {
      final table = _table();
      const amount = Money(100000, CurrencyCode.huf); // Ft 100 000

      for (final mid in codes) {
        if (mid == CurrencyCode.huf) continue;
        for (final target in codes) {
          if (target == CurrencyCode.huf) continue;

          final first = convert(amount, mid, table);
          final viaMid = convert(first.amount, target, table);
          final direct = convert(amount, target, table);

          expect(
            viaMid.amount.minorUnits,
            closeTo(direct.amount.minorUnits, 1),
            reason: 'HUF → ${mid.code} → ${target.code} vs HUF → ${target.code}',
          );
        }
      }
    });

    test('same-currency conversion is an exact 1.0 no-op', () {
      final result = convert(
        const Money(12345, CurrencyCode.cad),
        CurrencyCode.cad,
        _table(),
      );

      expect(result.rate, 1.0);
      expect(result.amount, const Money(12345, CurrencyCode.cad));
      expect(result.isDegraded, isFalse);
    });

    test('a missing table degrades and never reports 1.0 (FR-014)', () {
      final result = convert(
        const Money(500000, CurrencyCode.huf),
        CurrencyCode.usd,
        null,
      );

      expect(result.isDegraded, isTrue);
      expect(result.rate, isNot(1.0));
      expect(result.rate, isNull);
      expect(result.amount, const Money(500000, CurrencyCode.huf));
      expect(result.source, isNull);
    });

    test('an incomplete table degrades for the missing currency only', () {
      final partial = RateTable(
        usdRates: const {
          CurrencyCode.usd: 1.0,
          CurrencyCode.eur: 0.9,
        },
        asOf: DateTime(2026, 1, 31),
        fetchedAt: DateTime(2026, 2, 1),
        source: RateSource.lastKnown,
      );

      final missing = convert(
        const Money(1000, CurrencyCode.huf),
        CurrencyCode.usd,
        partial,
      );
      expect(missing.isDegraded, isTrue);
      expect(missing.rate, isNull);

      final present = convert(
        const Money(1000, CurrencyCode.eur),
        CurrencyCode.usd,
        partial,
      );
      expect(present.isDegraded, isFalse);
      expect(present.rate, closeTo(1 / 0.9, 1e-12));
    });

    test('rounding is half-away-from-zero (data-model §1.2)', () {
      final table = RateTable(
        usdRates: const {
          CurrencyCode.usd: 1.0,
          CurrencyCode.eur: 2.5,
          CurrencyCode.huf: 1.0,
          CurrencyCode.cad: 1.0,
        },
        asOf: DateTime(2026, 1, 31),
        fetchedAt: DateTime(2026, 2, 1),
        source: RateSource.historical,
      );

      // 1 USD cent × 2.5 = 2.5 euro cents → 3 (half away from zero), not 2.
      final result = convert(
        const Money(1, CurrencyCode.usd),
        CurrencyCode.eur,
        table,
      );
      expect(result.amount, const Money(3, CurrencyCode.eur));
    });
  });
}