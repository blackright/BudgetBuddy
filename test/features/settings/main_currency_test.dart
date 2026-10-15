import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/month_rate_seal.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/features/engine/currency_resolution.dart';
import 'package:budget_buddy/features/settings/providers/settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../medical/repositories/medical_test_harness.dart';

/// US3 (FR-009, FR-010, Constitution A2): the profile is the single main
/// currency authority, changing it is instant and side-effect free, and two
/// profiles never bleed into each other or the device-global rate seals.
void main() {
  late MedicalTestHarness harness;

  setUp(() async {
    harness = await MedicalTestHarness.create();
  });

  tearDown(() async {
    await harness.close();
  });

  Future<int> seedProfile(String name, PrimaryCurrency currency) async {
    final profile = UserProfile()
      ..name = name
      ..primaryCurrency = currency
      ..monthlyAvailableAmount = 0
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);
    late int id;
    await harness.isar.writeTxn(() async {
      id = await harness.isar.userProfiles.put(profile);
    });
    return id;
  }

  group('main currency provider (FR-009)', () {
    test('defaults to HUF while no profile exists', () {
      final container = ProviderContainer(
        overrides: [
          activeProfileProvider.overrideWith((ref) => Stream.value(null)),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(mainCurrencyProvider), CurrencyCode.huf);
    });

    test('reflects the active profile main currency', () async {
      final id = await seedProfile('A', PrimaryCurrency.eur);

      final profile = await harness.isar.userProfiles.get(id);
      expect(profile, isNotNull);

      final container = ProviderContainer(
        overrides: [
          activeProfileProvider.overrideWith((ref) => Stream.value(profile)),
        ],
      );
      addTearDown(container.dispose);

      // The stream provider needs a microtask to deliver its first value.
      await container.read(activeProfileProvider.future);
      expect(container.read(mainCurrencyProvider), CurrencyCode.eur);
    });
  });

  group('month follows its profile (FR-009, FR-011)', () {
    test('a month without a convert-to uses the profile main currency',
        () async {
      final usd = await seedProfile('A', PrimaryCurrency.usd);
      final eur = await seedProfile('B', PrimaryCurrency.eur);
      final month = MonthlyBudget()
        ..yearMonth = '2026-01'
        ..baseAvailableAmount = 0
        ..createdAt = DateTime(2026)
        ..updatedAt = DateTime(2026);

      expect(
        resolveDisplayCurrency(
          month: month,
          profile: await harness.isar.userProfiles.get(usd),
        ),
        CurrencyCode.usd,
      );
      expect(
        resolveDisplayCurrency(
          month: month,
          profile: await harness.isar.userProfiles.get(eur),
        ),
        CurrencyCode.eur,
      );
    });

    test('the same month displays differently per profile, nothing written',
        () async {
      final usd = await seedProfile('A', PrimaryCurrency.usd);
      final eur = await seedProfile('B', PrimaryCurrency.eur);
      final month = await harness.isar.writeTxn(() async {
        final row = MonthlyBudget()
          ..yearMonth = '2026-02'
          ..baseAvailableAmount = 0
          ..createdAt = DateTime(2026)
          ..updatedAt = DateTime(2026);
        row.id = await harness.isar.monthlyBudgets.put(row);
        return row;
      });

      expect(
        resolveDisplayCurrency(
          month: month,
          profile: await harness.isar.userProfiles.get(usd),
        ),
        CurrencyCode.usd,
      );
      expect(
        resolveDisplayCurrency(
          month: month,
          profile: await harness.isar.userProfiles.get(eur),
        ),
        CurrencyCode.eur,
      );

      // The stored month row is untouched by either read.
      final reloaded = await harness.isar.monthlyBudgets.get(month.id);
      expect(reloaded!.currency, isNull);
    });
  });

  group('multi-profile independence (FR-009, Constitution A2)', () {
    test('changing the active main currency leaves other profiles alone',
        () async {
      final a = await seedProfile('A', PrimaryCurrency.usd);
      final b = await seedProfile('B', PrimaryCurrency.eur);

      await MainCurrencyController(harness.isar)
          .setMainCurrency(PrimaryCurrency.cad);

      expect((await harness.isar.userProfiles.get(a))!.primaryCurrency,
          PrimaryCurrency.cad);
      expect((await harness.isar.userProfiles.get(b))!.primaryCurrency,
          PrimaryCurrency.eur,
          reason: 'a second profile keeps its own main currency');
    });

    test('changing the main currency never touches device-global seals',
        () async {
      await seedProfile('A', PrimaryCurrency.usd);
      final seal = MonthRateSeal()
        ..yearMonth = '2025-12'
        ..status = SealStatus.sealed
        ..applyUsdRates(const {
          CurrencyCode.usd: 1.0,
          CurrencyCode.eur: 0.86,
          CurrencyCode.huf: 345.0,
          CurrencyCode.cad: 1.36,
        })
        ..asOf = DateTime(2025, 12, 31)
        ..fetchedAt = DateTime(2026, 1, 1)
        ..closedAt = DateTime(2026, 1, 1)
        ..updatedAt = DateTime(2026, 1, 1);
      await harness.isar.writeTxn(() async {
        await harness.isar.monthRateSeals.put(seal);
      });

      await MainCurrencyController(harness.isar)
          .setMainCurrency(PrimaryCurrency.huf);

      final after = await harness.isar.monthRateSeals.getByYearMonth('2025-12');
      expect(after, isNotNull);
      expect(after!.status, SealStatus.sealed);
      expect(after.ratesHuf, 345.0);
    });
  });
}
