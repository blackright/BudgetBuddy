import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/month_rate_seal.dart';
import 'package:budget_buddy/core/network/exchange_rate_client.dart';
import 'package:budget_buddy/core/network/rate_types.dart';
import 'package:budget_buddy/features/engine/seal_coordinator.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'rate_test_support.dart';

void main() {
  late RateTestHarness harness;

  setUp(() async {
    harness = await RateTestHarness.create();
  });

  tearDown(() async {
    await harness.close();
  });

  group('month seal lifecycle (FR-006, FR-007, FR-008, SC-003)', () {
    test('an offline month close freezes a provisional seal', () async {
      await harness.seedBudget('2026-02');
      final client = FakeRateClient(failHistorical: true, failLatest: true);
      final coordinator = SealCoordinator(isar: harness.isar, client: client);

      // 3 days after the 2026-02 close — still inside the 7-day grace window.
      final result = await coordinator.runSealPass(DateTime(2026, 3, 3));

      final seal = await harness.sealFor('2026-02');
      expect(seal, isNotNull);
      expect(seal!.status, SealStatus.provisional);
      expect(seal.closedAt, DateTime(2026, 3, 3));
      expect(seal.attemptCount, 1);
      // Falls back to the bundled baseline — degraded labelling, never a
      // fabricated table.
      expect(seal.source, RateSource.bundled);
      expect(seal.toRateTable(), isNotNull);
      expect(result.provisionalMonths, contains('2026-02'));
    });

    test('a retry inside the grace window upgrades provisional → sealed',
        () async {
      await harness.seedBudget('2026-02');
      await harness.isar.writeTxn(() => harness.isar.monthRateSeals.put(
            rateSeal(
              yearMonth: '2026-02',
              status: SealStatus.provisional,
              closedAt: DateTime(2026, 3, 5),
              source: RateSource.bundled,
            ),
          ));
      final client = FakeRateClient(
        failLatest: true,
        historical: {
          '2026-02-28': snapshot(
            asOf: DateTime(2026, 2, 28),
            usdRates: const {
              CurrencyCode.usd: 1.0,
              CurrencyCode.eur: 0.9,
              CurrencyCode.huf: 360.0,
              CurrencyCode.cad: 1.4,
            },
          ),
        },
      );
      final coordinator = SealCoordinator(isar: harness.isar, client: client);

      final result = await coordinator.runSealPass(DateTime(2026, 3, 10));

      final seal = await harness.sealFor('2026-02');
      expect(seal!.status, SealStatus.sealed);
      expect(seal.source, RateSource.historical);
      expect(seal.usdRatesMap()[CurrencyCode.huf], 360.0);
      // The original closedAt is preserved across the upgrade.
      expect(seal.closedAt, DateTime(2026, 3, 5));
      expect(result.sealedMonths, contains('2026-02'));
    });

    test('grace expiry freezes a provisional seal as approximate', () async {
      await harness.seedBudget('2026-02');
      await harness.isar.writeTxn(() => harness.isar.monthRateSeals.put(
            rateSeal(
              yearMonth: '2026-02',
              status: SealStatus.provisional,
              closedAt: DateTime(2026, 2, 25), // 13 days before `now`
            ),
          ));
      final client = FakeRateClient(failHistorical: true, failLatest: true);
      final coordinator = SealCoordinator(isar: harness.isar, client: client);

      final result = await coordinator.runSealPass(DateTime(2026, 3, 10));

      final seal = await harness.sealFor('2026-02');
      expect(seal!.status, SealStatus.approximate);
      expect(seal.attemptCount, 2);
      expect(result.approximateMonths, contains('2026-02'));
    });

    test('a missed month long past is backfilled as approximate when offline',
        () async {
      await harness.seedBudget('2026-01');
      final client = FakeRateClient(failHistorical: true, failLatest: true);
      final coordinator = SealCoordinator(isar: harness.isar, client: client);

      await coordinator.runSealPass(DateTime(2026, 3, 10));

      final seal = await harness.sealFor('2026-01');
      expect(seal!.status, SealStatus.approximate);
      expect(seal.closedAt, isNull); // grace already gone
    });

    test('a missed month is backfilled as sealed when history is reachable',
        () async {
      await harness.seedBudget('2026-01');
      final client = FakeRateClient(
        failLatest: true,
        historical: {
          '2026-01-31': snapshot(asOf: DateTime(2026, 1, 31)),
        },
      );
      final coordinator = SealCoordinator(isar: harness.isar, client: client);

      await coordinator.runSealPass(DateTime(2026, 3, 10));

      final seal = await harness.sealFor('2026-01');
      expect(seal!.status, SealStatus.sealed);
      expect(seal.asOf, DateTime(2026, 1, 31));
    });

    test('the current (open) month is never sealed', () async {
      await harness.seedBudget('2026-03');
      final client = FakeRateClient(failHistorical: true, failLatest: true);
      final coordinator = SealCoordinator(isar: harness.isar, client: client);

      await coordinator.runSealPass(DateTime(2026, 3, 10));

      expect(await harness.sealFor('2026-03'), isNull);
    });

    test('the live table is refreshed at most once per 24h', () async {
      final client = FakeRateClient(
        latest: snapshot(
          source: RateSource.live,
          fetchedAt: DateTime(2026, 3, 10),
        ),
      );
      final coordinator = SealCoordinator(isar: harness.isar, client: client);

      final first = await coordinator.runSealPass(DateTime(2026, 3, 10));
      expect(first.liveRefreshed, isTrue);
      expect(client.latestCalls, 1);

      final second = await coordinator.runSealPass(DateTime(2026, 3, 10, 6));
      expect(second.liveRefreshed, isFalse);
      expect(client.latestCalls, 1);

      final third = await coordinator.runSealPass(DateTime(2026, 3, 11, 1));
      expect(third.liveRefreshed, isTrue);
      expect(client.latestCalls, 2);
    });

    test('a failed live refresh downgrades the label, never the data',
        () async {
      final seed = FakeRateClient(latest: snapshot(source: RateSource.live));
      final coordinator = SealCoordinator(isar: harness.isar, client: seed);
      await coordinator.runSealPass(DateTime(2026, 3, 10));

      final live = await harness.live();
      final before = live!.usdRatesMap();

      final failing = FakeRateClient(failLatest: true);
      final failingCoordinator =
          SealCoordinator(isar: harness.isar, client: failing);
      await failingCoordinator.runSealPass(DateTime(2026, 3, 12));

      final after = (await harness.live())!;
      expect(after.stale, isTrue);
      expect(after.usdRatesMap(), before); // numbers stay
    });
  });

  group('historical walk-back (client)', () {
    test('a weekend 404 walks back to the last business day', () async {
      final dio = Dio()
        ..httpClientAdapter = ScriptedRateAdapter((url) {
          if (url.contains('2026-09-25')) {
            return frankfurterBody('2026-09-25');
          }
          return null; // Saturday 26th, Sunday 27th …
        });
      final client = ExchangeRateClient(dio);

      final result = await client.fetchHistorical(DateTime(2026, 9, 26));

      expect(result, isNotNull);
      expect(result!.asOf, DateTime(2026, 9, 25));
      expect(result.source, RateSource.historical);
    });

    test('gives up after the 7-day walk-back window', () async {
      final dio = Dio()..httpClientAdapter = ScriptedRateAdapter((_) => null);
      final client = ExchangeRateClient(dio);

      final result = await client.fetchHistorical(DateTime(2026, 9, 26));

      expect(result, isNull);
    });
  });
}
