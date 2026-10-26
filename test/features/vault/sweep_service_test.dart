import 'package:isar/isar.dart';
import 'package:budget_buddy/features/finance/repositories/audit_repository.dart';
import 'package:budget_buddy/core/models/audit_event.dart';
import 'dart:convert';
import 'package:budget_buddy/core/database/schema_migrations.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/network/rate_types.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import 'package:budget_buddy/features/vault/models/vault_entry.dart';
import 'package:budget_buddy/features/vault/repositories/vault_repository.dart';
import 'package:budget_buddy/features/vault/vault_math.dart';
import 'package:budget_buddy/core/database/money_integrity.dart';
import 'package:budget_buddy/core/models/budget_profile.dart';
import 'package:budget_buddy/core/models/month_end_run.dart';
import 'package:budget_buddy/core/database/isar_helper.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/engine/providers/sweep_provider.dart';
import 'package:budget_buddy/features/vault/models/savings_vault.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../features/medical/repositories/medical_test_harness.dart';

String _yearMonth(DateTime date) => '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}';

String _previousMonth() {
  final now = DateTime.now();
  final previous = DateTime(now.year, now.month - 1);
  return _yearMonth(previous);
}

void main() {
  late MedicalTestHarness harness;
  late UserProfile profile;

  setUp(() async {
    harness = await MedicalTestHarness.create();
    IsarHelper.instance = harness.isar;

    profile = UserProfile()
      ..id = 1
      ..name = 'Me'
      ..primaryCurrency = PrimaryCurrency.usd
      ..monthlyAvailableAmount = 100000
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);
    await harness.isar.writeTxn(() async {
      await harness.isar.userProfiles.put(profile);
    });
  });

  tearDown(() async {
    await harness.close();
  });

  Future<void> seedMonth({
    required String yearMonth,
    required bool openingConfirmed,
    double opening = 1000,
  }) async {
    final budget = MonthlyBudget()
      ..profileId = profile.id
      ..yearMonth = yearMonth
      ..baseAvailableAmount = opening
      ..netSalaryOverride = opening
      ..currency = 'usd'
      ..openingBalanceConfirmed = openingConfirmed
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);
    await harness.isar.writeTxn(() async {
      await harness.isar.monthlyBudgets.put(budget);
    });
  }

  Future<void> seedVault(String lastSweep) async {
    final vault = SavingsVault()
      ..profileId = profile.id
      ..totalMinor = 0
      ..currency = 'usd'
      ..lastSweepYearMonth = lastSweep
      ..updatedAt = DateTime(2026);
    await harness.isar.writeTxn(() async {
      await harness.isar.savingsVaults.put(vault);
    });
  }

  ProviderContainer containerFor(
      {DateTime Function()? clock, Future<void> Function()? beforeCommit}) {
    final container = ProviderContainer(
      overrides: [
        activeProfileProvider.overrideWith((ref) => Stream.value(profile)),
        rateRegistryProvider.overrideWithValue(RateTableRegistry()),
        sweepServiceProvider.overrideWith((ref) =>
            SweepService(ref, clock: clock, beforeCommit: beforeCommit)),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test(
      'malformed audit head rolls back contribution and cursor instead of committing a pause',
      () async {
    await seedMonth(yearMonth: '2026-08', openingConfirmed: true, opening: 100);
    await seedVault('2026-08');
    await harness.isar.writeTxn(() async {
      await AuditRepository(harness.isar).append(
          profileId: 1,
          action: 'test.seed',
          objectType: 'Expense',
          objectGuid: 'seed');
      final head = (await harness.isar.schemaMigrationStamps
              .filter()
              .keyStartsWith('audit:head:')
              .findAll())
          .single;
      head.value = '{invalid';
      await harness.isar.schemaMigrationStamps.put(head);
    });
    final c = containerFor(clock: () => DateTime(2026, 10, 23));
    final failed = await c.read(sweepServiceProvider).executeSweepCheck();
    expect(failed.outcome, SweepOutcome.failed);
    final vault = (await harness.isar.savingsVaults.where().findAll()).single;
    expect(vault.totalMinor, 0);
    expect(vault.lastSweepYearMonth, '2026-08');
    expect(await harness.isar.vaultEntrys.filter().kindEqualTo('sweep').count(),
        0);
    expect(await harness.isar.auditEvents.count(), 1);
  });

  test(
      'partial progress survives a later pause and repeated/concurrent retries',
      () async {
    await seedMonth(yearMonth: '2026-08', openingConfirmed: true, opening: 100);
    await seedMonth(
        yearMonth: '2026-09', openingConfirmed: false, opening: 200);
    await seedVault('2026-08');
    final c = containerFor(clock: () => DateTime(2026, 10, 23));
    final service = c.read(sweepServiceProvider);
    final first = await service.executeSweepCheck();
    expect(first.outcome, SweepOutcome.paused);
    expect(first.addedMinor, 10000);
    var vault = (await harness.isar.savingsVaults.where().findAll()).single;
    expect(vault.totalMinor, 10000);
    expect(vault.lastSweepYearMonth, '2026-09');
    expect((await service.executeSweepCheck()).addedMinor, 0);
    await harness.isar.writeTxn(() async {
      final month = await harness.isar.monthlyBudgets
          .filter()
          .yearMonthEqualTo('2026-09')
          .findFirst();
      month!.openingBalanceConfirmed = true;
      await harness.isar.monthlyBudgets.put(month);
    });
    await Future.wait(List.generate(4, (_) => service.executeSweepCheck()));
    vault = (await harness.isar.savingsVaults.where().findAll()).single;
    expect(vault.totalMinor, 30000);
    expect(vault.lastSweepYearMonth, '2026-10');
    final entries = await harness.isar.vaultEntrys.where().findAll();
    expect(entries.where((e) => e.kind == 'sweep').length, 2);
    expect(entries.fold<int>(0, (sum, e) => sum + e.amountMinor),
        vault.totalMinor);
    expect(jsonDecode(entries.last.breakdownJson)['opening'], 20000);
  });

  test(
      'transaction failure rolls back balance, history and month cursor together',
      () async {
    await seedMonth(yearMonth: '2026-09', openingConfirmed: true);
    await seedVault('2026-09');
    final c = containerFor(
        clock: () => DateTime(2026, 10, 23),
        beforeCommit: () async {
          throw StateError('injected write failure');
        });
    expect((await c.read(sweepServiceProvider).executeSweepCheck()).outcome,
        SweepOutcome.failed);
    final vault = (await harness.isar.savingsVaults.where().findAll()).single;
    expect(vault.totalMinor, 0);
    expect(vault.lastSweepYearMonth, '2026-09');
    expect(await harness.isar.vaultEntrys.count(), 0);
  });

  test(
      'zero month records a reason; missing months do not invent contributions',
      () async {
    await seedMonth(yearMonth: '2026-08', openingConfirmed: true, opening: 0);
    await seedVault('2026-08');
    final c = containerFor(clock: () => DateTime(2026, 10, 23));
    expect((await c.read(sweepServiceProvider).executeSweepCheck()).outcome,
        SweepOutcome.unchanged);
    final entries =
        await harness.isar.vaultEntrys.filter().kindEqualTo('sweep').findAll();
    expect(entries.single.yearMonth, '2026-08');
    expect(entries.single.amountMinor, 0);
    expect(entries.single.reason, isNotEmpty);
    expect(
        (await harness.isar.savingsVaults.where().findAll())
            .single
            .lastSweepYearMonth,
        '2026-10');
  });

  test('version 24 migration preserves savings and seeds opening history once',
      () async {
    await seedVault('2026-09');
    await harness.isar.writeTxn(() async {
      final vault = (await harness.isar.savingsVaults.where().findAll()).single;
      vault.totalMinor = 123456;
      await harness.isar.savingsVaults.put(vault);
    });
    await writeSchemaVersion(harness.isar, 24);
    await runSchemaMigrations(harness.isar);
    await runSchemaMigrations(harness.isar);
    final entry = (await harness.isar.vaultEntrys.where().findAll()).single;
    expect(entry.kind, 'opening');
    expect(entry.amountMinor, 123456);
    expect(entry.yearMonth, isNull);
    final vault = (await harness.isar.savingsVaults.where().findAll()).single;
    expect(vault.totalMinor, 123456);
    expect(vault.currency, 'usd');
    expect(vault.lastSweepYearMonth, '2026-09');
    expect(await readSchemaVersion(harness.isar), schemaVersion);
  });

  test('goal validation and metadata edits preserve saved amounts and history',
      () async {
    await seedVault('2026-09');
    final repo = VaultRepository(harness.isar);
    await repo.saveGoal(
        profileId: 1,
        actorId: 1,
        expectedCurrency: 'usd',
        name: 'Emergency',
        targetMinor: 100000);
    expect((await repo.getVault(1))!.goalName, 'Emergency');
    expect((await repo.getVault(1))!.totalMinor, 0);
    await expectLater(
        repo.saveGoal(
            profileId: 1,
            actorId: 2,
            expectedCurrency: 'usd',
            name: 'Other',
            targetMinor: 5),
        throwsStateError);
    await expectLater(
        repo.saveGoal(
            profileId: 1,
            actorId: 1,
            expectedCurrency: 'usd',
            name: 'Invalid',
            targetMinor: 0),
        throwsArgumentError);
    await expectLater(
        repo.saveGoal(
            profileId: 1,
            actorId: 1,
            expectedCurrency: 'huf',
            name: 'Stale',
            targetMinor: 50),
        throwsStateError);
    await repo.saveGoal(profileId: 1, actorId: 1, expectedCurrency: 'usd');
    expect((await repo.getVault(1))!.goalTargetMinor, isNull);
    expect(await harness.isar.vaultEntrys.count(), 0);
  });

  test('shared context cannot trigger a personal sweep', () async {
    await seedMonth(yearMonth: '2026-09', openingConfirmed: true);
    await seedVault('2026-09');
    final c = ProviderContainer(overrides: [
      activeProfileProvider.overrideWith((ref) => Stream.value(profile)),
      budgetContextProvider.overrideWithValue(
          ContextRef.shared(spaceId: 2, yearMonth: '2026-09')),
    ]);
    addTearDown(c.dispose);
    expect((await c.read(sweepServiceProvider).executeSweepCheck()).outcome,
        SweepOutcome.unchanged);
    expect(
        (await harness.isar.savingsVaults.where().findAll()).single.totalMinor,
        0);
    expect(await harness.isar.vaultEntrys.count(), 0);
  });

  test(
      'invalid current-month balance pauses before creating opening history or clearing pause',
      () async {
    await seedVault('2026-10');
    await harness.isar.writeTxn(() async {
      final v = (await harness.isar.savingsVaults.where().findAll()).single;
      v.totalMinor = corruptedMinorSentinel;
      await harness.isar.savingsVaults.put(v);
    });
    final c = containerFor(clock: () => DateTime(2026, 10, 23));
    final result = await c.read(sweepServiceProvider).executeSweepCheck();
    expect(result.outcome, SweepOutcome.paused);
    final v = (await harness.isar.savingsVaults.where().findAll()).single;
    expect(v.totalMinor, corruptedMinorSentinel,
        reason: 'No guessed financial repair.');
    expect(v.sweepPaused, isTrue);
    expect(await harness.isar.vaultEntrys.count(), 0);
  });

  test(
      'invalid existing opening evidence is preserved and blocks another contribution',
      () async {
    await seedVault('2026-09');
    await seedMonth(yearMonth: '2026-09', openingConfirmed: true);
    await harness.isar.writeTxn(() async {
      await harness.isar.vaultEntrys.put(VaultEntry()
        ..operationKey = 'vault:1:opening'
        ..profileId = 1
        ..kind = 'opening'
        ..amountMinor = corruptedMinorSentinel
        ..balanceAfterMinor = corruptedMinorSentinel
        ..currency = 'usd'
        ..createdAt = DateTime(2026));
    });
    final c = containerFor(clock: () => DateTime(2026, 10, 23));
    expect((await c.read(sweepServiceProvider).executeSweepCheck()).outcome,
        SweepOutcome.paused);
    expect(
        (await harness.isar.vaultEntrys.where().findAll()).single.amountMinor,
        corruptedMinorSentinel);
    expect(
        (await harness.isar.savingsVaults.where().findAll()).single.totalMinor,
        0);
  });

  for (final opening in [double.nan, double.infinity, 1e100]) {
    test(
        'invalid or excessive opening $opening pauses without committing a month',
        () async {
      await seedMonth(
          yearMonth: '2026-09', openingConfirmed: true, opening: opening);
      await seedVault('2026-09');
      final c = containerFor(clock: () => DateTime(2026, 10, 23));
      expect((await c.read(sweepServiceProvider).executeSweepCheck()).outcome,
          SweepOutcome.paused);
      expect(
          (await harness.isar.savingsVaults.where().findAll())
              .single
              .lastSweepYearMonth,
          '2026-09');
      expect(
          await harness.isar.vaultEntrys.filter().kindEqualTo('sweep').count(),
          0);
    });
  }

  test(
      'history balance mismatch blocks sweeping without rewriting either amount',
      () async {
    await seedVault('2026-09');
    await harness.isar.writeTxn(() async {
      await harness.isar.vaultEntrys.put(VaultEntry()
        ..operationKey = 'vault:1:opening'
        ..profileId = 1
        ..kind = 'opening'
        ..amountMinor = 100
        ..balanceAfterMinor = 100
        ..currency = 'usd'
        ..createdAt = DateTime(2026));
    });
    final c = containerFor(clock: () => DateTime(2026, 10, 23));
    expect((await c.read(sweepServiceProvider).executeSweepCheck()).outcome,
        SweepOutcome.paused);
    expect(
        (await harness.isar.savingsVaults.where().findAll()).single.totalMinor,
        0);
    expect(
        (await harness.isar.vaultEntrys.where().findAll()).single.amountMinor,
        100);
  });

  for (final legacy in [double.nan, double.infinity, -10.0, 1e100]) {
    test('unsafe legacy $legacy is retained as evidence instead of consumed',
        () async {
      await seedVault('2026-10');
      await harness.isar.writeTxn(() async {
        final v = (await harness.isar.savingsVaults.where().findAll()).single;
        v.totalMinor = corruptedMinorSentinel;
        // ignore: deprecated_member_use_from_same_package
        v.totalAmount = legacy;
        await harness.isar.savingsVaults.put(v);
        await migrateLegacyVaultToMinorUnits(harness.isar);
      });
      final v = (await harness.isar.savingsVaults.where().findAll()).single;
      expect(v.totalMinor, corruptedMinorSentinel);
      // ignore: deprecated_member_use_from_same_package
      expect(v.totalAmount, legacy.isNaN ? isNaN : legacy);
      expect(v.sweepPaused, isTrue);
    });
  }

  test(
      'checked arithmetic rejects overflow and corrupted components before calculation',
      () {
    expect(vaultSum(maxVaultMinor, 0), maxVaultMinor);
    expect(() => vaultSum(maxVaultMinor, 1), throwsFormatException);
    expect(() => vaultSum(corruptedMinorSentinel, 1), throwsFormatException);
    expect(vaultBreakdown('{broken'), isNull);
    expect(
        vaultBreakdown(
            '{"currency":"usd","opening":10,"spent":0,"returned":0,"carry":0,"available":20}'),
        isNull);
  });

  for (final primary in PrimaryCurrency.values) {
    test(
        'exact ${primary.name} sweep includes partial refund once and preserves currency',
        () async {
      final code = CurrencyCode.tryParse(primary.name)!;
      profile.primaryCurrency = primary;
      await harness.isar.writeTxn(() async {
        await harness.isar.userProfiles.put(profile);
      });
      await seedMonth(
          yearMonth: '2026-09', openingConfirmed: true, opening: 100);
      await seedVault('2026-09');
      await harness.isar.writeTxn(() async {
        final budget =
            (await harness.isar.monthlyBudgets.where().findAll()).single;
        budget.currency = primary.name;
        await harness.isar.monthlyBudgets.put(budget);
        final vault =
            (await harness.isar.savingsVaults.where().findAll()).single;
        vault.currency = primary.name;
        await harness.isar.savingsVaults.put(vault);
        final expense = Expense(
            profileId: 1,
            yearMonth: '2026-09',
            title: 'Partial refund',
            amount: 40 * code.minorUnitsPerMajor,
            currency: primary.name,
            categoryId: 'general',
            status: ExpenseStatus.partiallyReimbursed,
            date: DateTime(2026, 9, 2),
            budgetId: budget.id);
        await harness.isar.expenses.put(expense);
        await harness.isar.reimbursements.put(Reimbursement(
            profileId: 1,
            expenseId: expense.id,
            originYearMonth: '2026-09',
            amount: 10 * code.minorUnitsPerMajor,
            currency: primary.name,
            date: DateTime(2026, 9, 3)));
      });
      final c = containerFor(clock: () => DateTime(2026, 10, 23));
      await c.read(sweepServiceProvider).executeSweepCheck();
      await c.read(sweepServiceProvider).executeSweepCheck();
      final vault = (await harness.isar.savingsVaults.where().findAll()).single;
      expect(vault.totalMinor, 70 * code.minorUnitsPerMajor);
      expect(vault.currency, primary.name);
      final entry = (await harness.isar.vaultEntrys
              .filter()
              .kindEqualTo('sweep')
              .findAll())
          .single;
      expect(jsonDecode(entry.breakdownJson)['returned'],
          10 * code.minorUnitsPerMajor);
    });
  }

  test('conversion history retains the original rate after registry changes',
      () async {
    await seedMonth(yearMonth: '2026-09', openingConfirmed: true, opening: 100);
    await seedVault('2026-09');
    await harness.isar.writeTxn(() async {
      final vault = (await harness.isar.savingsVaults.where().findAll()).single;
      vault.currency = 'huf';
      await harness.isar.savingsVaults.put(vault);
    });
    final c = ProviderContainer(overrides: [
      activeProfileProvider.overrideWith((ref) => Stream.value(profile)),
      rateRegistryProvider.overrideWithValue(RateTableRegistry(
          liveTable: RateTable(
              usdRates: {
            CurrencyCode.usd: 1,
            CurrencyCode.huf: 400,
            CurrencyCode.eur: 0.9,
            CurrencyCode.cad: 1.4
          },
              asOf: DateTime(2026, 9, 30),
              fetchedAt: DateTime(2026, 10, 1),
              source: RateSource.historical))),
      sweepServiceProvider.overrideWith(
          (ref) => SweepService(ref, clock: () => DateTime(2026, 10, 23))),
    ]);
    addTearDown(c.dispose);
    await c.read(sweepServiceProvider).executeSweepCheck();
    final entry =
        (await harness.isar.vaultEntrys.filter().kindEqualTo('sweep').findAll())
            .single;
    expect(entry.amountMinor, 40000);
    final snapshot = jsonDecode(entry.breakdownJson);
    expect(snapshot['conversions'].single['rate'], 400);
    expect(snapshot['rateSource'], 'historical');
    c.updateOverrides([
      activeProfileProvider.overrideWith((ref) => Stream.value(profile)),
      rateRegistryProvider.overrideWithValue(RateTableRegistry()),
      sweepServiceProvider.overrideWith(
          (ref) => SweepService(ref, clock: () => DateTime(2026, 10, 23))),
    ]);
    expect((await harness.isar.vaultEntrys.get(entry.id))!.breakdownJson,
        entry.breakdownJson);
  });

  test(
      'unsupported expense pauses without advancing or creating a monthly entry',
      () async {
    await seedMonth(yearMonth: '2026-09', openingConfirmed: true);
    await seedVault('2026-09');
    await harness.isar.writeTxn(() async {
      await harness.isar.expenses.put(Expense(
          profileId: 1,
          yearMonth: '2026-09',
          title: 'Legacy',
          amount: 100,
          currency: 'gbp',
          categoryId: 'general',
          status: ExpenseStatus.paid,
          date: DateTime(2026, 9, 2),
          budgetId: 1));
    });
    final c = containerFor(clock: () => DateTime(2026, 10, 23));
    expect((await c.read(sweepServiceProvider).executeSweepCheck()).outcome,
        SweepOutcome.paused);
    expect(
        (await harness.isar.savingsVaults.where().findAll())
            .single
            .lastSweepYearMonth,
        '2026-09');
    expect(await harness.isar.vaultEntrys.filter().kindEqualTo('sweep').count(),
        0);
  });

  test('sweeps the positive leftover of a finished month into the vault',
      () async {
    final month = _previousMonth();
    await seedMonth(yearMonth: month, openingConfirmed: true);
    await seedVault(month);

    final expense = Expense(
      profileId: 1,
      yearMonth: month,
      title: 'Paid',
      amount: 5000, // $50.00
      currency: 'usd',
      categoryId: 'general',
      status: ExpenseStatus.paid,
      date: DateTime(2026, 1, 10),
      budgetId: 1,
    );
    await harness.isar.writeTxn(() async {
      await harness.isar.expenses.put(expense);
    });

    await containerFor().read(sweepServiceProvider).executeSweepCheck();

    final list = await harness.isar.savingsVaults.where().findAll();
    final vault = list.single;
    expect(vault.totalMinor, 95000);
    expect(vault.currency, 'usd');
    expect(vault.sweepPaused, isFalse);
    expect(vault.lastSweepYearMonth, _yearMonth(DateTime.now()));
  });

  test('pauses on an unconfirmed opening balance and does not advance',
      () async {
    final month = _previousMonth();
    await seedMonth(yearMonth: month, openingConfirmed: false);
    await seedVault(month);

    await containerFor().read(sweepServiceProvider).executeSweepCheck();

    final list = await harness.isar.savingsVaults.where().findAll();
    final vault = list.single;
    expect(vault.totalMinor, 0);
    expect(vault.sweepPaused, isTrue);
    expect(vault.pauseReason, contains(month));
    expect(vault.lastSweepYearMonth, month);
  });

  test('does not sweep a newly created vault retroactively', () async {
    final container = containerFor();

    await container.read(sweepServiceProvider).executeSweepCheck();

    final list = await harness.isar.savingsVaults.where().findAll();
    final vault = list.single;
    expect(vault.totalMinor, 0);
    expect(vault.lastSweepYearMonth, _yearMonth(DateTime.now()));
  });
  test('budget profiles pause vault sweeping until month-end is reviewed',
      () async {
    final month = _previousMonth();
    await seedMonth(yearMonth: month, openingConfirmed: true);
    await seedVault(month);
    await harness.isar.writeTxn(() async {
      await harness.isar.budgetProfiles.put(BudgetProfile()
        ..profileId = 1
        ..yearMonth = month
        ..name = 'Food'
        ..allocation = 10000
        ..createdAt = DateTime(2026)
        ..updatedAt = DateTime(2026));
    });
    final container = containerFor();
    await container.read(activeProfileProvider.future);
    await container.read(sweepServiceProvider).executeSweepCheck();
    final vault = (await harness.isar.savingsVaults.where().findAll()).single;
    expect(vault.totalMinor, 0);
    expect(vault.sweepPaused, isTrue);
    expect(vault.pauseReason, contains('Review Month-End'));
    expect(vault.lastSweepYearMonth, month);
  });
  test('confirmed carry is excluded from vault sweep and cannot be swept twice',
      () async {
    final month = _previousMonth();
    await seedMonth(yearMonth: month, openingConfirmed: true);
    await seedVault(month);
    await harness.isar.writeTxn(() async {
      await harness.isar.budgetProfiles.put(BudgetProfile()
        ..syncGuid = 'food'
        ..profileId = 1
        ..yearMonth = month
        ..name = 'Food'
        ..allocation = 20000
        ..createdAt = DateTime(2026)
        ..updatedAt = DateTime(2026));
      await harness.isar.monthEndRuns.put(MonthEndRun()
        ..syncGuid = 'settled'
        ..profileId = 1
        ..contextGuid = 'personal:1'
        ..yearMonth = month
        ..destinationMonth = _yearMonth(DateTime.now())
        ..currency = 'usd'
        ..reportJson =
            '{"lines":[{"sourceGuid":"food","carried":20000,"released":0}]}'
        ..fingerprint = 'test'
        ..actor = 'profile:1'
        ..carriedMinor = 20000
        ..createdAt = DateTime(2026));
    });
    final container = containerFor();
    await container.read(activeProfileProvider.future);
    await container.read(sweepServiceProvider).executeSweepCheck();
    await container.read(sweepServiceProvider).executeSweepCheck();
    final vault = (await harness.isar.savingsVaults.where().findAll()).single;
    expect(vault.totalMinor, 80000);
    expect(vault.sweepPaused, isFalse);
  });
}
