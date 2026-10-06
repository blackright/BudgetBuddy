import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/money.dart';
import 'package:budget_buddy/core/network/rate_types.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:flutter_test/flutter_test.dart';

RateTable _table(double huf,
        {RateSource source = RateSource.live, bool stale = false}) =>
    RateTable(
      usdRates: {
        CurrencyCode.usd: 1.0,
        CurrencyCode.eur: 0.86,
        CurrencyCode.huf: huf,
        CurrencyCode.cad: 1.36,
      },
      asOf: DateTime(2026, 1, 31),
      fetchedAt: DateTime(2026, 2, 1),
      source: source,
      isStale: stale,
    );

void main() {
  group('RateTableRegistry', () {
    test('converts using the live table when a month has no seal', () {
      final registry = RateTableRegistry(liveTable: _table(400));

      final result = registry.convert(
        amount: const Money(1000, CurrencyCode.usd),
        to: CurrencyCode.huf,
        yearMonth: '2026-02',
      );

      expect(result.isDegraded, isFalse);
      expect(result.rate, 400.0);
      expect(result.amount, const Money(4000, CurrencyCode.huf));
      expect(result.source, RateSource.live);
    });

    test('a month seal overrides the live table', () {
      final registry = RateTableRegistry(
        sealedTables: {'2026-01': _table(300, source: RateSource.historical)},
        liveTable: _table(400),
      );

      final result = registry.convert(
        amount: const Money(10000, CurrencyCode.huf),
        to: CurrencyCode.usd,
        yearMonth: '2026-01',
      );

      expect(result.source, RateSource.historical);
      expect(result.rate, closeTo(1 / 300, 1e-12));
    });

    test('falls back to the bundled table when nothing is persisted', () {
      final registry = RateTableRegistry();

      final result = registry.convert(
        amount: const Money(1000, CurrencyCode.usd),
        to: CurrencyCode.eur,
        yearMonth: '2026-02',
      );

      expect(result.isDegraded, isFalse);
      expect(result.source, RateSource.bundled);
    });

    test('same currency is a 1.0 no-op', () {
      final registry = RateTableRegistry(liveTable: _table(400));

      final result = registry.convert(
        amount: const Money(1234, CurrencyCode.eur),
        to: CurrencyCode.eur,
        yearMonth: '2026-02',
      );

      expect(result.rate, 1.0);
      expect(result.amount, const Money(1234, CurrencyCode.eur));
      expect(result.isDegraded, isFalse);
    });

    test('a table missing a currency degrades without inventing 1.0', () {
      final registry = RateTableRegistry(
        sealedTables: {
          '2026-01': RateTable(
            usdRates: const {CurrencyCode.usd: 1.0},
            asOf: DateTime(2026, 1, 31),
            fetchedAt: DateTime(2026, 2, 1),
            source: RateSource.historical,
          ),
        },
      );

      final result = registry.convert(
        amount: const Money(1000, CurrencyCode.usd),
        to: CurrencyCode.huf,
        yearMonth: '2026-01',
      );

      expect(result.isDegraded, isTrue);
      expect(result.rate, isNull);
      expect(result.amount, const Money(1000, CurrencyCode.usd));
    });

    test('stale live tables flag staleness through to the result', () {
      final registry = RateTableRegistry(liveTable: _table(400, stale: true));

      final result = registry.convert(
        amount: const Money(1000, CurrencyCode.usd),
        to: CurrencyCode.huf,
        yearMonth: '2026-02',
      );

      expect(result.isStale, isTrue);
      expect(result.isDegraded, isFalse);
    });
  });
}
