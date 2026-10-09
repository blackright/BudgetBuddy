import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/month_rate_seal.dart';
import 'package:budget_buddy/core/network/rate_types.dart';
import 'package:budget_buddy/features/engine/seal_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';

import 'rate_test_support.dart';

/// A final seal is immutable: no automatic pass ever changes its rates or
/// status once it is written (FR-006, contract invariant I2, SC-002/SC-003).
void main() {
  late RateTestHarness harness;

  setUp(() async {
    harness = await RateTestHarness.create();
  });

  tearDown(() async {
    await harness.close();
  });

  final frozenRates = <CurrencyCode, double>{
    CurrencyCode.usd: 1.0,
    CurrencyCode.eur: 0.80,
    CurrencyCode.huf: 400.0,
    CurrencyCode.cad: 1.5,
  };

  test('a sealed row ignores a later successful fetch', () async {
    await harness.seedBudget('2026-01');
    await harness.isar.writeTxn(() => harness.isar.monthRateSeals.put(
          rateSeal(
            yearMonth: '2026-01',
            status: SealStatus.sealed,
            source: RateSource.historical,
            rates: frozenRates,
            closedAt: DateTime(2026, 2, 1),
            updatedAt: DateTime(2026, 2, 1),
          ),
        ));

    final client = FakeRateClient(
      failLatest: true,
      historical: {
        '2026-01-31': snapshot(
          asOf: DateTime(2026, 1, 31),
          usdRates: const {
            CurrencyCode.usd: 1.0,
            CurrencyCode.eur: 0.99,
            CurrencyCode.huf: 999.0,
            CurrencyCode.cad: 9.9,
          },
        ),
      },
    );
    final coordinator = SealCoordinator(isar: harness.isar, client: client);

    final result = await coordinator.runSealPass(DateTime(2026, 3, 10));

    final seal = await harness.sealFor('2026-01');
    expect(seal!.status, SealStatus.sealed);
    expect(seal.usdRatesMap(), frozenRates);
    expect(seal.updatedAt, DateTime(2026, 2, 1));
    // The sealed month is never even asked about.
    expect(client.historicalCalls, isNot(contains(DateTime(2026, 1, 31))));
    expect(result.sealedMonths, isNot(contains('2026-01')));
  });

  test('an approximate row is frozen permanently', () async {
    await harness.seedBudget('2026-01');
    await harness.isar.writeTxn(() => harness.isar.monthRateSeals.put(
          rateSeal(
            yearMonth: '2026-01',
            status: SealStatus.approximate,
            source: RateSource.lastKnown,
            rates: frozenRates,
            updatedAt: DateTime(2026, 2, 1),
          ),
        ));

    final client = FakeRateClient(
      failLatest: true,
      historical: {
        '2026-01-31': snapshot(),
      },
    );
    final coordinator = SealCoordinator(isar: harness.isar, client: client);

    await coordinator.runSealPass(DateTime(2026, 3, 10));

    final seal = await harness.sealFor('2026-01');
    expect(seal!.status, SealStatus.approximate);
    expect(seal.usdRatesMap(), frozenRates);
    expect(client.historicalCalls, isNot(contains(DateTime(2026, 1, 31))));
  });

  test('changing the live table never touches a sealed month', () async {
    await harness.seedBudget('2026-01');
    await harness.isar.writeTxn(() => harness.isar.monthRateSeals.put(
          rateSeal(
            yearMonth: '2026-01',
            status: SealStatus.sealed,
            source: RateSource.historical,
            rates: frozenRates,
          ),
        ));

    final client = FakeRateClient(
      latest: snapshot(
        source: RateSource.live,
        usdRates: const {
          CurrencyCode.usd: 1.0,
          CurrencyCode.eur: 0.5,
          CurrencyCode.huf: 100.0,
          CurrencyCode.cad: 0.5,
        },
      ),
    );
    final coordinator = SealCoordinator(isar: harness.isar, client: client);

    await coordinator.runSealPass(DateTime(2026, 3, 10));

    final seal = await harness.sealFor('2026-01');
    expect(seal!.usdRatesMap(), frozenRates);
  });
}
