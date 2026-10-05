import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/features/finance/repositories/month_finance_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../medical/repositories/medical_test_harness.dart';

void main() {
  late MedicalTestHarness harness;
  late MonthFinanceRepository repository;

  setUp(() async {
    harness = await MedicalTestHarness.create();
    repository = MonthFinanceRepository(harness.isar);
  });

  tearDown(() async {
    await harness.close();
  });

  Future<int> seedProfile({
    double defaultNetSalary = 0.0,
    PrimaryCurrency currency = PrimaryCurrency.usd,
  }) async {
    final profile = UserProfile()
      ..id = 1
      ..name = 'Test'
      ..primaryCurrency = currency
      ..monthlyAvailableAmount = 0
      ..defaultNetSalary = defaultNetSalary
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);
    await harness.isar.writeTxn(() async {
      await harness.isar.userProfiles.put(profile);
    });
    return profile.id;
  }

  group('month provisioning', () {
    test('getMonth returns null for a month that was never opened', () async {
      await seedProfile();
      expect(await repository.getMonth('2026-03'), isNull);
    });

    test('ensureMonth creates the month with an unconfirmed zero balance',
        () async {
      await seedProfile();

      final month = await repository.ensureMonth('2026-03');

      expect(month.yearMonth, '2026-03');
      expect(month.baseAvailableAmount, 0.0);
      expect(
        month.openingBalanceConfirmed,
        isFalse,
        reason: 'a provisioned month has never had a balance entered',
      );
      expect(month.netSalaryOverride, isNull);
    });

    test('ensureMonth is idempotent', () async {
      await seedProfile();

      final first = await repository.ensureMonth('2026-03');
      final second = await repository.ensureMonth('2026-03');

      expect(second.id, first.id);
      expect(await harness.budgetCount(), 1);
    });

    test('a new month inherits the active profile currency', () async {
      await seedProfile(currency: PrimaryCurrency.eur);

      final month = await repository.ensureMonth('2026-03');

      expect(month.currency, PrimaryCurrency.eur);
    });

    test('FR-007: no balance is carried forward into a new month', () async {
      await seedProfile();
      await repository.saveOpeningBalance('2026-01', 5000);
      expect((await repository.getMonth('2026-01'))!.baseAvailableAmount, 5000);

      final february = await repository.ensureMonth('2026-02');

      expect(february.baseAvailableAmount, 0.0);
      expect(february.openingBalanceConfirmed, isFalse);
    });

    test('watchMonth emits the provisioned month', () async {
      await seedProfile();
      await repository.ensureMonth('2026-04');

      final emitted = await repository.watchMonth('2026-04').first;

      expect(emitted, isNotNull);
      expect(emitted!.yearMonth, '2026-04');
    });
  });

  group('opening balance', () {
    test('saving a balance confirms it', () async {
      await seedProfile();

      await repository.saveOpeningBalance('2026-05', 1200);

      final month = await repository.getMonth('2026-05');
      expect(month!.baseAvailableAmount, 1200);
      expect(month.openingBalanceConfirmed, isTrue);
    });

    test('FR-010: a saved zero is confirmed, unlike an untouched month',
        () async {
      await seedProfile();
      await repository.saveOpeningBalance('2026-05', 0);

      final month = await repository.getMonth('2026-05');
      expect(month!.baseAvailableAmount, 0);
      expect(month.openingBalanceConfirmed, isTrue);

      final untouched = await repository.ensureMonth('2026-06');
      expect(untouched.baseAvailableAmount, 0);
      expect(untouched.openingBalanceConfirmed, isFalse);
    });

    test('FR-011: a past month stays editable', () async {
      await seedProfile();
      await repository.saveOpeningBalance('2020-01', 100);

      await repository.saveOpeningBalance('2020-01', 250);

      final month = await repository.getMonth('2020-01');
      expect(month!.baseAvailableAmount, 250);
      expect(month.openingBalanceConfirmed, isTrue);
    });

    test('a negative balance is rejected', () async {
      await seedProfile();

      expect(
        () => repository.saveOpeningBalance('2026-05', -1),
        throwsArgumentError,
      );
    });
  });

  group('income resolution', () {
    test('resolveIncome falls back to the profile default', () async {
      await seedProfile(defaultNetSalary: 4000);

      final income = await repository.resolveIncome('2026-01');

      expect(income.amount, 4000);
      expect(income.usesOverride, isFalse);
    });

    test('a per-month override beats the profile default (FR-003)', () async {
      await seedProfile(defaultNetSalary: 4000);
      await repository.saveNetSalaryOverride('2026-02', 5000);

      final income = await repository.resolveIncome('2026-02');

      expect(income.amount, 5000);
      expect(income.usesOverride, isTrue);
    });

    test('clearing the override hands the month back to the default', () async {
      await seedProfile(defaultNetSalary: 4000);
      await repository.saveNetSalaryOverride('2026-02', 5000);

      await repository.saveNetSalaryOverride('2026-02', null);

      final income = await repository.resolveIncome('2026-02');
      expect(income.amount, 4000);
      expect(income.usesOverride, isFalse);
    });

    test('a negative override is rejected', () async {
      await seedProfile();

      expect(
        () => repository.saveNetSalaryOverride('2026-02', -5),
        throwsArgumentError,
      );
    });

    test('an override of zero is honoured, not treated as unset', () async {
      await seedProfile(defaultNetSalary: 4000);
      await repository.saveNetSalaryOverride('2026-02', 0);

      final income = await repository.resolveIncome('2026-02');
      expect(income.amount, 0);
      expect(income.usesOverride, isTrue);
    });

    test('FR-004: changing the default does not rewrite existing months',
        () async {
      await seedProfile(defaultNetSalary: 4000);
      await repository.ensureMonth('2026-01');
      await repository.ensureMonth('2026-02');

      await repository.saveDefaultNetSalary(6000);

      // Existing months keep following the new default...
      expect((await repository.resolveIncome('2026-01')).amount, 6000);
      expect((await repository.resolveIncome('2026-02')).amount, 6000);

      // ...until one of them carries its own override, which then wins and is
      // not disturbed by later default changes.
      await repository.saveNetSalaryOverride('2026-02', 4500);
      await repository.saveDefaultNetSalary(7000);

      expect((await repository.resolveIncome('2026-01')).amount, 7000);
      final overridden = await repository.resolveIncome('2026-02');
      expect(overridden.amount, 4500);
      expect(overridden.usesOverride, isTrue);
    });

    test('the default salary reads and writes through the profile', () async {
      await seedProfile();

      expect(await repository.getDefaultNetSalary(), 0.0);

      await repository.saveDefaultNetSalary(4200);

      expect(await repository.getDefaultNetSalary(), 4200);
    });

    test('a negative default salary is rejected', () async {
      await seedProfile();

      expect(
        () => repository.saveDefaultNetSalary(-1),
        throwsArgumentError,
      );
    });
  });

  group('month isolation', () {
    test('each month keeps its own balance and override', () async {
      await seedProfile(defaultNetSalary: 4000);
      await repository.saveOpeningBalance('2026-01', 1000);
      await repository.saveNetSalaryOverride('2026-01', 4100);
      await repository.saveOpeningBalance('2026-02', 2500);

      final january = await repository.getMonth('2026-01');
      final february = await repository.getMonth('2026-02');

      expect(january!.baseAvailableAmount, 1000);
      expect(january.netSalaryOverride, 4100);
      expect(february!.baseAvailableAmount, 2500);
      expect(
        february.netSalaryOverride,
        isNull,
        reason: 'February must not inherit January\'s override',
      );
    });

    test('writing one month leaves the other untouched', () async {
      await seedProfile(defaultNetSalary: 4000);
      await repository.saveOpeningBalance('2026-01', 1000);
      await repository.saveOpeningBalance('2026-02', 2000);

      await repository.saveOpeningBalance('2026-01', 1234);

      expect((await repository.getMonth('2026-01'))!.baseAvailableAmount, 1234);
      expect((await repository.getMonth('2026-02'))!.baseAvailableAmount, 2000);
    });
  });
}
