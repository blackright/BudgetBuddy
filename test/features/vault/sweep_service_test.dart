import 'package:isar/isar.dart';
import 'package:budget_buddy/core/database/schema_migrations.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/pending_action.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import 'package:budget_buddy/features/vault/models/vault_entry.dart';
import 'package:budget_buddy/features/vault/repositories/vault_repository.dart';
import 'package:budget_buddy/features/vault/vault_math.dart';
import 'package:budget_buddy/features/vault/vault_suggestion_service.dart';
import 'package:budget_buddy/core/database/money_integrity.dart';
import 'package:budget_buddy/core/database/isar_helper.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/engine/providers/sweep_provider.dart';
import 'package:budget_buddy/features/pending_actions/providers/pending_actions_providers.dart';
import 'package:budget_buddy/features/pending_actions/services/pending_action_service.dart';
import 'package:budget_buddy/features/vault/models/savings_vault.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../features/medical/repositories/medical_test_harness.dart';

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

  Future<void> seedLegacyVault(String lastSweep) async {
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

  ProviderContainer containerFor({DateTime Function()? clock}) {
    final container = ProviderContainer(
      overrides: [
        activeProfileProvider.overrideWith((ref) => Stream.value(profile)),
        rateRegistryProvider.overrideWithValue(RateTableRegistry()),
        sweepServiceProvider.overrideWith(
            (ref) => SweepService(ref, clock: clock ?? DateTime.now)),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('creates one suggestion for a finished positive month and moves nothing',
      () async {
    await seedMonth(yearMonth: '2026-09', openingConfirmed: true, opening: 100);
    final c = containerFor(clock: () => DateTime(2026, 10, 23));
    final result = await c.read(sweepServiceProvider).executeSweepCheck();

    expect(result.outcome, SweepOutcome.unchanged);
    expect(result.addedMinor, 0);
    expect(await harness.isar.vaultEntrys.count(), 0);
    expect(await harness.isar.savingsVaults.count(), 0);
    final action = (await harness.isar.pendingActions.where().findAll()).single;
    expect(action.actionType, vaultDepositSuggestedType);
    expect(action.recordRef, '1:2026-09');
    expect(action.dedupeKey, 'vault.depositSuggested|1:2026-09|2026-09');
    expect(action.expectedAmountMinor, 10000);
    expect(action.currency, 'usd');
    expect(action.expectedMonth, '2026-09');
    expect(action.status, 'pending');
  });

  test('repeated and concurrent checks do not duplicate suggestions', () async {
    await seedMonth(yearMonth: '2026-08', openingConfirmed: true, opening: 100);
    await seedMonth(yearMonth: '2026-09', openingConfirmed: true, opening: 200);
    final c = containerFor(clock: () => DateTime(2026, 10, 23));
    final service = c.read(sweepServiceProvider);
    await service.executeSweepCheck();
    await Future.wait(List.generate(4, (_) => service.executeSweepCheck()));

    final actions = await harness.isar.pendingActions.where().findAll();
    expect(actions.length, 2);
    expect(actions.map((a) => a.expectedAmountMinor).toSet(), {10000, 20000});
    expect(await harness.isar.vaultEntrys.count(), 0);
  });

  test('a legacy automatic sweep for the month suppresses the suggestion',
      () async {
    await seedMonth(yearMonth: '2026-09', openingConfirmed: true, opening: 100);
    await seedLegacyVault('2026-09');
    await harness.isar.writeTxn(() async {
      await harness.isar.vaultEntrys.put(VaultEntry()
        ..operationKey = 'vault:1:sweep:2026-09'
        ..profileId = 1
        ..kind = 'sweep'
        ..yearMonth = '2026-09'
        ..amountMinor = 0
        ..currency = 'usd'
        ..balanceAfterMinor = 0
        ..createdAt = DateTime(2026, 10, 1)
        ..breakdownJson = '{}');
    });
    final c = containerFor(clock: () => DateTime(2026, 10, 23));
    await c.read(sweepServiceProvider).executeSweepCheck();

    expect(await harness.isar.pendingActions.count(), 0);
    expect(
        (await harness.isar.savingsVaults.where().findAll())
            .single
            .lastSweepYearMonth,
        '2026-09');
  });

  test('an unconfirmed opening month is ignored instead of paused', () async {
    await seedMonth(yearMonth: '2026-09', openingConfirmed: false);
    final c = containerFor(clock: () => DateTime(2026, 10, 23));
    final result = await c.read(sweepServiceProvider).executeSweepCheck();

    expect(result.outcome, SweepOutcome.unchanged);
    expect(await harness.isar.pendingActions.count(), 0);
    expect(await harness.isar.vaultEntrys.count(), 0);
  });

  test('a zero or negative finished month creates no suggestion', () async {
    await seedMonth(yearMonth: '2026-08', openingConfirmed: true, opening: 0);
    final c = containerFor(clock: () => DateTime(2026, 10, 23));
    await c.read(sweepServiceProvider).executeSweepCheck();

    expect(await harness.isar.pendingActions.count(), 0);
    expect(await harness.isar.vaultEntrys.count(), 0);
  });

  test('an unsupported expense is skipped and reported without moving money',
      () async {
    await seedMonth(yearMonth: '2026-09', openingConfirmed: true);
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
    final result = await c.read(sweepServiceProvider).executeSweepCheck();

    expect(result.skipped, ['2026-09']);
    expect(result.message, contains('review'));
    expect(await harness.isar.pendingActions.count(), 0);
    expect(await harness.isar.vaultEntrys.count(), 0);
  });

  test('a pending personal setup pauses without suggesting or moving money',
      () async {
    await seedMonth(yearMonth: '2026-09', openingConfirmed: true);
    await harness.isar.writeTxn(() async {
      await harness.isar.schemaMigrationStamps.put(SchemaMigrationStamp()
        ..key = 'onboarding_pending_owner:1'
        ..value = '1');
    });
    final c = containerFor(clock: () => DateTime(2026, 10, 23));
    final result = await c.read(sweepServiceProvider).executeSweepCheck();

    expect(result.outcome, SweepOutcome.paused);
    expect(result.message, contains('setup'));
    expect(await harness.isar.pendingActions.count(), 0);
    expect(await harness.isar.vaultEntrys.count(), 0);
  });

  test('shared context cannot trigger a personal suggestion check', () async {
    await seedMonth(yearMonth: '2026-09', openingConfirmed: true);
    final c = ProviderContainer(overrides: [
      activeProfileProvider.overrideWith((ref) => Stream.value(profile)),
      budgetContextProvider.overrideWithValue(
          ContextRef.shared(spaceId: 2, yearMonth: '2026-09')),
    ]);
    addTearDown(c.dispose);

    expect((await c.read(sweepServiceProvider).executeSweepCheck()).outcome,
        SweepOutcome.unchanged);
    expect(await harness.isar.pendingActions.count(), 0);
    expect(await harness.isar.vaultEntrys.count(), 0);
  });

  test('partial refund is valued once per currency and never auto-saved',
      () async {
    for (final primary in PrimaryCurrency.values) {
      final code = CurrencyCode.tryParse(primary.name)!;
      profile.primaryCurrency = primary;
      await harness.isar.writeTxn(() async {
        await harness.isar.userProfiles.put(profile);
      });
      await seedMonth(
          yearMonth: '2026-09', openingConfirmed: true, opening: 100);
      await harness.isar.writeTxn(() async {
        final budget =
            (await harness.isar.monthlyBudgets.where().findAll()).single;
        budget.currency = primary.name;
        await harness.isar.monthlyBudgets.put(budget);
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

      final action =
          (await harness.isar.pendingActions.where().findAll()).single;
      expect(action.expectedAmountMinor, 70 * code.minorUnitsPerMajor);
      expect(action.currency, primary.name);
      expect(await harness.isar.vaultEntrys.count(), 0);
      await harness.isar.writeTxn(() async {
        await harness.isar.pendingActions.clear();
        await harness.isar.expenses.clear();
        await harness.isar.reimbursements.clear();
        await harness.isar.monthlyBudgets.clear();
        await harness.isar.savingsVaults.clear();
      });
    }
  });

  test('a newly created profile is not saved retroactively', () async {
    final c = containerFor(clock: () => DateTime(2026, 10, 23));
    await c.read(sweepServiceProvider).executeSweepCheck();

    expect(await harness.isar.vaultEntrys.count(), 0);
    expect(await harness.isar.savingsVaults.count(), 0);
    expect(await harness.isar.pendingActions.count(), 0);
  });

  test('version 24 migration preserves savings and seeds opening history once',
      () async {
    await seedLegacyVault('2026-09');
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
    await seedLegacyVault('2026-09');
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

  for (final legacy in [double.nan, double.infinity, -10.0, 1e100]) {
    test('unsafe legacy $legacy is retained as evidence instead of consumed',
        () async {
      await seedLegacyVault('2026-10');
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

  test('a failing suggestion write is reported and leaves no partial money',
      () async {
    await seedMonth(yearMonth: '2026-09', openingConfirmed: true, opening: 100);
    final c = ProviderContainer(overrides: [
      activeProfileProvider.overrideWith((ref) => Stream.value(profile)),
      rateRegistryProvider.overrideWithValue(RateTableRegistry()),
      pendingActionServiceProvider
          .overrideWith((ref) => _FailingActions(harness.isar)),
    ]);
    addTearDown(c.dispose);
    final result = await c.read(sweepServiceProvider).executeSweepCheck();

    expect(result.outcome, SweepOutcome.unchanged);
    expect(result.skipped, ['2026-09']);
    expect(await harness.isar.pendingActions.count(), 0);
    expect(await harness.isar.vaultEntrys.count(), 0);
    expect(await harness.isar.savingsVaults.where().findAll(), isEmpty);
  });
}

class _FailingActions extends PendingActionService {
  _FailingActions(super.db) : super(profileId: 1);

  @override
  Future<PendingAction> upsert(PendingActionDraft draft) async {
    throw StateError('Simulated action write failure.');
  }
}
