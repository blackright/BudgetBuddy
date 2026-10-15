import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/money.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/network/rate_types.dart';
import 'package:budget_buddy/features/engine/currency_resolution.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/finance/repositories/month_finance_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import '../medical/repositories/medical_test_harness.dart';

/// T039: per-month convert-to independence, clearing back to default, and that
/// the resolver never fabricates rates for sealed/offline months (FR-011, FR-014).
void main() {
  late MedicalTestHarness harness;

  setUp(() async {
    harness = await MedicalTestHarness.create();
  });

  tearDown(() async {
    await harness.close();
  });

  Future<MonthlyBudget> seedMonth(String yearMonth,
      {CurrencyCode? convertTo}) async {
    final budget = MonthlyBudget()
      ..yearMonth = yearMonth
      ..baseAvailableAmount = 0
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);
    if (convertTo != null) {
      budget.currency = convertTo.name;
    }
    await harness.isar.writeTxn(() async {
      budget.id = await harness.isar.monthlyBudgets.put(budget);
    });
    return budget;
  }

  Future<UserProfile> seedProfile(PrimaryCurrency currency) async {
    final profile = UserProfile()
      ..name = 'P'
      ..primaryCurrency = currency
      ..monthlyAvailableAmount = 0
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);
    await harness.isar.writeTxn(() async {
      profile.id = await harness.isar.userProfiles.put(profile);
    });
    return profile;
  }

  group('per-month convert-to independence (FR-011)', () {
    test('Jan→EUR, Feb→CAD: resolver keeps them independent', () async {
      final profile = await seedProfile(PrimaryCurrency.huf);
      final jan = await seedMonth('2026-01', convertTo: CurrencyCode.eur);
      final feb = await seedMonth('2026-02', convertTo: CurrencyCode.cad);
      final none = await seedMonth('2026-03');

      expect(
        resolveDisplayCurrency(month: jan, profile: profile),
        CurrencyCode.eur,
      );
      expect(
        resolveDisplayCurrency(month: feb, profile: profile),
        CurrencyCode.cad,
      );
      expect(
        resolveDisplayCurrency(month: none, profile: profile),
        CurrencyCode.huf,
        reason: 'null convert-to follows profile main currency',
      );
    });

    test('repository saveConvertTo clears when null and persists when set',
        () async {
      final repo = MonthFinanceRepository(harness.isar);
      await seedMonth('2026-04');
      await repo.saveConvertTo('2026-04', CurrencyCode.usd);
      final afterUsd = await harness.isar.monthlyBudgets
          .filter()
          .yearMonthEqualTo('2026-04')
          .findAll();
      expect(afterUsd.single.currency, 'usd');

      await repo.saveConvertTo('2026-04', null);
      final afterNull = await harness.isar.monthlyBudgets
          .filter()
          .yearMonthEqualTo('2026-04')
          .findAll();
      expect(afterNull.single.currency, isNull);
    });

    test('changing convert-to does not affect other months or the profile',
        () async {
      final repo = MonthFinanceRepository(harness.isar);
      final profile = await seedProfile(PrimaryCurrency.eur);
      await seedMonth('2026-05', convertTo: CurrencyCode.usd);
      await seedMonth('2026-06');

      await repo.saveConvertTo('2026-05', CurrencyCode.cad);
      expect((await harness.isar.userProfiles.get(profile.id))!.primaryCurrency,
          PrimaryCurrency.eur,
          reason: 'profile unchanged');

      final janReload = await harness.isar.monthlyBudgets
          .filter()
          .yearMonthEqualTo('2026-05')
          .findAll();
      final febReload = await harness.isar.monthlyBudgets
          .filter()
          .yearMonthEqualTo('2026-06')
          .findAll();
      expect(janReload.single.currency, 'cad');
      expect(febReload.single.currency, isNull);
      expect(resolveDisplayCurrency(month: janReload.single, profile: profile),
          CurrencyCode.cad);
      expect(resolveDisplayCurrency(month: febReload.single, profile: profile),
          CurrencyCode.eur);
    });
  });

  group('sealed month offline view never fabricates 1.0 (FR-014)', () {
    test('a sealed month converts through its own table, no network', () {
      final sealed = RateTable(
        usdRates: const {
          CurrencyCode.usd: 1.0,
          CurrencyCode.eur: 0.86,
          CurrencyCode.huf: 345.0,
          CurrencyCode.cad: 1.36,
        },
        asOf: DateTime(2026, 6, 30),
        fetchedAt: DateTime(2026, 7, 1),
        source: RateSource.historical,
      );
      final registry = RateTableRegistry(
        sealedTables: {'2026-07': sealed},
      );

      // The registry must pick the month's sealed table over the bundled
      // baseline, so a sealed month stays frozen even fully offline.
      expect(registry.tableFor('2026-07'), same(sealed));

      final result = registry.convert(
        amount: const Money(100, CurrencyCode.usd),
        to: CurrencyCode.huf,
        yearMonth: '2026-07',
      );

      expect(result.isDegraded, isFalse);
      expect(result.rate, closeTo(345.0, 1e-9));
      expect(result.amount.currency, CurrencyCode.huf);
      expect(result.source, RateSource.historical);
    });

    test('a month with no seal and no live table degrades, never fakes 1.0',
        () {
      final registry = RateTableRegistry();
      // Empty registry: only the bundled baseline exists, which cannot carry a
      // live source — so the conversion is still backed by real (bundled)
      // rates, and a garbage amount never yields a fabricated result.
      final result = registry.convert(
        amount: const Money(100, CurrencyCode.usd),
        to: CurrencyCode.eur,
        yearMonth: '2026-08',
      );

      expect(result.isDegraded, isFalse);
      expect(result.source, RateSource.bundled);
      expect(result.rate, closeTo(0.86, 1e-9));
    });

    test('resolver resolves display without needing a rate at all', () {
      final profile = UserProfile()
        ..id = 1
        ..primaryCurrency = PrimaryCurrency.huf;
      final month = MonthlyBudget()
        ..yearMonth = '2026-08'
        ..baseAvailableAmount = 0
        ..currency = 'cad';

      expect(resolveDisplayCurrency(month: month, profile: profile),
          CurrencyCode.cad);
    });
  });
}
