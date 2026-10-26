import 'dart:async';
import 'dart:convert';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/models/income_source.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/vault/models/savings_vault.dart';
import 'package:budget_buddy/features/vault/models/vault_entry.dart';
import 'package:budget_buddy/features/vault/vault_transfer_service.dart';
import 'package:budget_buddy/features/vault/vault_transfer_ledger.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:budget_buddy/core/models/budget_profile.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/month_end_run.dart';
import 'package:budget_buddy/core/models/month_rate_seal.dart';
import 'package:budget_buddy/core/database/isar_helper.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/features/engine/providers/sweep_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_buddy/features/settings/presentation/profile_switcher_section.dart';
import 'package:budget_buddy/features/spaces/repositories/month_move_operations.dart';
import 'package:budget_buddy/features/spaces/repositories/space_role_guard.dart';
import 'package:budget_buddy/core/network/rate_types.dart';
import 'package:budget_buddy/core/database/schema_migrations.dart';
import 'package:budget_buddy/features/vault/repositories/vault_repository.dart';
import 'package:budget_buddy/features/vault/vault_math.dart';
import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/core/providers/selected_month_provider.dart';
import 'package:budget_buddy/features/finance/providers/finance_providers.dart';
import 'package:budget_buddy/features/finance/repositories/month_finance_repository.dart';
import 'package:budget_buddy/features/finance/providers/reserve_providers.dart';
import 'package:budget_buddy/features/finance/providers/profile_providers.dart';
import 'package:budget_buddy/features/engine/providers/true_available_provider.dart';
import 'package:budget_buddy/features/engine/providers/month_summary_provider.dart';
import 'package:budget_buddy/features/vault/providers/vault_providers.dart';
import 'package:budget_buddy/core/services/refund_service.dart';
import '../medical/repositories/medical_test_harness.dart';

void main() {
  late MedicalTestHarness h;
  late VaultTransferService service;
  setUp(() async {
    h = await MedicalTestHarness.create();
    await h.isar.writeTxn(() async {
      await h.isar.userProfiles.put(UserProfile()
        ..id = 1
        ..name = 'Owner'
        ..primaryCurrency = PrimaryCurrency.huf
        ..monthlyAvailableAmount = 0
        ..defaultNetSalary = 100000
        ..createdAt = DateTime(2026)
        ..updatedAt = DateTime(2026));
      await h.isar.monthlyBudgets.put(MonthlyBudget()
        ..profileId = 1
        ..yearMonth = '2026-10'
        ..baseAvailableAmount = 80000
        ..openingBalanceConfirmed = true
        ..createdAt = DateTime(2026)
        ..updatedAt = DateTime(2026));
      final vault = SavingsVault()
        ..profileId = 1
        ..totalMinor = 50000
        ..currency = 'huf'
        ..lastSweepYearMonth = '2026-10'
        ..updatedAt = DateTime(2026);
      await h.isar.savingsVaults.put(vault);
      await seedVaultOpeningInTxn(h.isar, vault, DateTime(2026));
    });
    service = VaultTransferService(h.isar,
        actorId: 1,
        isStillActive: () => true,
        rates: () => RateTableRegistry(),
        clock: () => DateTime(2026, 10, 23));
  });
  tearDown(() => h.close());

  Future<void> funding(
          {double opening = 100000,
          double income = 85000,
          int allocation = 60000,
          int spent = 0}) =>
      h.isar.writeTxn(() async {
        final owner = (await h.isar.userProfiles.get(1))!
          ..defaultNetSalary = income;
        await h.isar.userProfiles.put(owner);
        final month = (await h.isar.monthlyBudgets.where().findFirst())!
          ..baseAvailableAmount = opening;
        await h.isar.monthlyBudgets.put(month);
        final p = BudgetProfile()
          ..id = 1
          ..profileId = 1
          ..yearMonth = '2026-10'
          ..name = 'Food'
          ..allocation = allocation
          ..createdAt = DateTime(2026)
          ..updatedAt = DateTime(2026);
        await h.isar.budgetProfiles.put(p);
        if (spent > 0) {
          await h.isar.expenses.put(Expense(
              profileId: 1,
              yearMonth: '2026-10',
              title: 'Food',
              categoryId: 'food',
              amount: spent,
              currency: 'huf',
              date: DateTime(2026, 10),
              budgetId: month.id,
              budgetProfileId: p.id,
              status: ExpenseStatus.paid)
            ..financialProfileType = FinancialProfileType.budget);
        }
      });

  test('deposit matches Free to spend and protects unused allocations',
      () async {
    await funding();
    expect((await service.readiness()).maxDeposit, 25000);
    await expectLater(
        service.preview(kind: 'deposit', amount: 25001, requestId: 'large'),
        throwsA(isA<VaultTransferException>()));
    await service.confirm(await service.preview(
        kind: 'deposit', amount: 25000, requestId: 'max'));
    expect((await service.readiness()).maxDeposit, 0);
    expect((await h.isar.budgetProfiles.get(1))!.allocation, 60000);
  });

  test(
      'income-backed Free to spend permits zero-opening deposit and protects borrowing',
      () async {
    await funding(opening: 0, income: 1000000, allocation: 0);
    expect((await service.readiness()).maxDeposit, 1000000);
    await funding(
        opening: 100000, income: 85000, allocation: 60000, spent: 75000);
    expect((await service.readiness()).maxDeposit, 10000);
  });

  test(
      'withdrawal funds a later deposit and full reversal retains original evidence',
      () async {
    final original = await service.confirm(await service.preview(
        kind: 'deposit',
        amount: 10000,
        requestId: 'original',
        note: 'Emergency'));
    final reversed = await service.confirm(await service.preview(
        kind: 'reversal',
        amount: 10000,
        requestId: 'reverse',
        reverses: original.operationKey,
        note: 'Mistake'));
    expect(reversed.amountMinor, -10000);
    expect((await h.isar.vaultEntrys.get(original.id))!.reason, 'Emergency');
    expect(await readMonthlyVaultCredit(h.isar, 1, '2026-10', CurrencyCode.huf),
        0);
    await expectLater(
        service.preview(
            kind: 'reversal',
            amount: 10000,
            requestId: 'twice',
            reverses: original.operationKey,
            note: 'Again'),
        throwsA(isA<VaultTransferException>()));
    final withdrawal = await service.confirm(await service.preview(
        kind: 'withdrawal', amount: 10000, requestId: 'out'));
    await service.confirm(await service.preview(
        kind: 'reversal',
        amount: 10000,
        requestId: 'undo-out',
        reverses: withdrawal.operationKey,
        note: 'Undo'));
    final vault = (await h.isar.savingsVaults.where().findFirst())!;
    expect(vault.totalMinor, 50000);
    expect(await vaultHistoryProblem(h.isar, vault), isNull);
  });

  test('partial reversals and reversals without reasons are refused', () async {
    final original = await service.confirm(await service.preview(
        kind: 'deposit', amount: 10000, requestId: 'original'));
    for (final amount in [5000, 10000]) {
      await expectLater(
          service.preview(
              kind: 'reversal',
              amount: amount,
              requestId: 'bad',
              reverses: original.operationKey,
              note: amount == 5000 ? 'Partial' : ''),
          throwsA(isA<VaultTransferException>()));
    }
  });

  test('withdrawal reversal cannot use allocated or already-spent funds',
      () async {
    final original = await service.confirm(await service.preview(
        kind: 'withdrawal', amount: 50000, requestId: 'out'));
    await funding(opening: 0, income: 0, allocation: 50000);
    await expectLater(
        service.preview(
            kind: 'reversal',
            amount: 50000,
            requestId: 'undo',
            reverses: original.operationKey,
            note: 'Undo'),
        throwsA(isA<VaultTransferException>()));
  });

  test('stale preview and conflicting request reuse do not write money',
      () async {
    final a =
        await service.preview(kind: 'deposit', amount: 10000, requestId: 'a');
    final b =
        await service.preview(kind: 'withdrawal', amount: 1000, requestId: 'b');
    await service.confirm(b);
    await expectLater(
        service.confirm(a), throwsA(isA<VaultTransferException>()));
    final reused =
        await service.preview(kind: 'deposit', amount: 100, requestId: 'b');
    await expectLater(
        service.confirm(reused), throwsA(isA<VaultTransferException>()));
    expect((await h.isar.savingsVaults.where().findFirst())!.totalMinor, 49000);
  });

  test('simultaneous duplicate submissions commit once', () async {
    final p = await service.preview(
        kind: 'deposit', amount: 10000, requestId: 'same');
    final rows = await Future.wait(List.generate(4, (_) => service.confirm(p)));
    expect(rows.map((e) => e.id).toSet(), hasLength(1));
    expect((await h.isar.savingsVaults.where().findFirst())!.totalMinor, 60000);
  });

  test('competing withdrawals cannot overdraw the vault', () async {
    final previews = await Future.wait([
      for (final id in ['a', 'b'])
        service.preview(kind: 'withdrawal', amount: 40000, requestId: id)
    ]);
    var accepted = 0, refused = 0;
    await Future.wait(previews.map((p) async {
      try {
        await service.confirm(p);
        accepted++;
      } on VaultTransferException {
        refused++;
      }
    }));
    expect(accepted, 1);
    expect(refused, 1);
    expect((await h.isar.savingsVaults.where().findFirst())!.totalMinor, 10000);
  });

  test('failure after history write rolls both legs back', () async {
    final failing = VaultTransferService(h.isar,
        actorId: 1,
        isStillActive: () => true,
        rates: () => RateTableRegistry(),
        clock: () => DateTime(2026, 10, 23),
        beforeCommit: () async => throw StateError('injected'));
    final preview = await failing.preview(
        kind: 'deposit', amount: 10000, requestId: 'fail');
    await expectLater(failing.confirm(preview), throwsStateError);
    expect(await h.isar.vaultEntrys.count(), 1);
    expect((await h.isar.savingsVaults.where().findFirst())!.totalMinor, 50000);
  });

  test(
      'owner switch during confirmation rolls back and another owner cannot transfer',
      () async {
    var active = true;
    final s = VaultTransferService(h.isar,
        actorId: 1,
        isStillActive: () => active,
        rates: () => RateTableRegistry(),
        clock: () => DateTime(2026, 10, 23),
        beforeCommit: () async {
          active = false;
        });
    await expectLater(
        s.confirm(await s.preview(
            kind: 'deposit', amount: 1000, requestId: 'switch')),
        throwsA(isA<VaultTransferException>()));
    expect(await h.isar.vaultEntrys.count(), 1);
    final other = VaultTransferService(h.isar,
        actorId: 2,
        isStillActive: () => true,
        rates: () => RateTableRegistry());
    await expectLater(
        other.readiness(), throwsA(isA<VaultTransferException>()));
  });

  test('month rollover invalidates confirmation', () async {
    var now = DateTime(2026, 10, 31);
    final s = VaultTransferService(h.isar,
        actorId: 1,
        isStillActive: () => true,
        rates: () => RateTableRegistry(),
        clock: () => now);
    final preview =
        await s.preview(kind: 'deposit', amount: 1000, requestId: 'roll');
    now = DateTime(2026, 11);
    await expectLater(
        s.confirm(preview), throwsA(isA<VaultTransferException>()));
  });

  for (final kind in ['deposit', 'withdrawal']) {
    for (final amount in [0, -1, 9007199254740992]) {
      test('$kind rejects invalid amount $amount', () async {
        await expectLater(
            service.preview(kind: kind, amount: amount, requestId: 'invalid'),
            throwsA(isA<VaultTransferException>()));
      });
    }
  }

  test('unconfirmed funds, currency mismatch and sealed month refuse transfers',
      () async {
    await h.isar.writeTxn(() async {
      final m = (await h.isar.monthlyBudgets.where().findFirst())!
        ..openingBalanceConfirmed = false;
      await h.isar.monthlyBudgets.put(m);
    });
    await expectLater(
        service.readiness(), throwsA(isA<VaultTransferException>()));
    await h.isar.writeTxn(() async {
      final m = (await h.isar.monthlyBudgets.where().findFirst())!
        ..openingBalanceConfirmed = true;
      await h.isar.monthlyBudgets.put(m);
      final v = (await h.isar.savingsVaults.where().findFirst())!
        ..currency = 'usd';
      await h.isar.savingsVaults.put(v);
    });
    await expectLater(
        service.readiness(), throwsA(isA<VaultTransferException>()));
    await h.isar.writeTxn(() async {
      final v = (await h.isar.savingsVaults.where().findFirst())!
        ..currency = 'huf';
      await h.isar.savingsVaults.put(v);
      await h.isar.monthRateSeals.put(MonthRateSeal()
        ..yearMonth = '2026-10'
        ..status = SealStatus.sealed
        ..asOf = DateTime(2026, 10)
        ..fetchedAt = DateTime(2026, 10)
        ..updatedAt = DateTime(2026, 10));
    });
    await expectLater(
        service.readiness(), throwsA(isA<VaultTransferException>()));
  });

  test('settled source refuses a transfer', () async {
    await h.isar.writeTxn(() => h.isar.monthEndRuns.put(MonthEndRun()
      ..syncGuid = 'close'
      ..profileId = 1
      ..contextGuid = 'owner'
      ..yearMonth = '2026-10'
      ..destinationMonth = '2026-11'
      ..currency = 'huf'
      ..reportJson = '{"lines":[]}'
      ..fingerprint = 'f'
      ..actor = 'owner'
      ..createdAt = DateTime(2026, 10)));
    await expectLater(
        service.readiness(), throwsA(isA<VaultTransferException>()));
  });

  for (final currency in PrimaryCurrency.values) {
    test(
        '${currency.name} one minor unit transfers exactly and survives migration checks',
        () async {
      await h.isar.writeTxn(() async {
        final owner = (await h.isar.userProfiles.get(1))!
          ..primaryCurrency = currency;
        await h.isar.userProfiles.put(owner);
        final vault = (await h.isar.savingsVaults.where().findFirst())!
          ..currency = currency.code.code;
        await h.isar.savingsVaults.put(vault);
        final entry = (await h.isar.vaultEntrys.where().findFirst())!
          ..currency = currency.code.code;
        await h.isar.vaultEntrys.put(entry);
      });
      final preview =
          await service.preview(kind: 'deposit', amount: 1, requestId: 'unit');
      await service.confirm(preview);
      await VaultRepository(h.isar).saveGoal(
          profileId: 1,
          actorId: 1,
          expectedCurrency: currency.code.code,
          name: 'Goal',
          targetMinor: 70000);
      await runSchemaMigrations(h.isar);
      final vault = (await h.isar.savingsVaults.where().findFirst())!;
      expect(vault.totalMinor, 50001);
      expect(vault.goalTargetMinor, 70000);
      expect(await readMonthlyVaultCredit(h.isar, 1, '2026-10', currency.code),
          -1);
      expect(await vaultHistoryProblem(h.isar, vault), isNull);
      expect(await h.isar.vaultEntrys.count(), 2);
    });
  }

  test('bad notes, request identities and excess withdrawals are rejected',
      () async {
    for (final request in ['', 'bad:key']) {
      await expectLater(
          service.preview(kind: 'deposit', amount: 1, requestId: request),
          throwsA(isA<VaultTransferException>()));
    }
    await expectLater(
        service.preview(
            kind: 'deposit', amount: 1, requestId: 'ok', note: 'x' * 121),
        throwsA(isA<VaultTransferException>()));
    await expectLater(
        service.preview(kind: 'withdrawal', amount: 50001, requestId: 'large'),
        throwsA(isA<VaultTransferException>()));
  });

  test(
      'missing expense conversion rate blocks confirmation instead of inventing funds',
      () async {
    final s = VaultTransferService(h.isar,
        actorId: 1,
        isStillActive: () => true,
        clock: () => DateTime(2026, 10, 23),
        rates: () => RateTableRegistry(
            liveTable: RateTable(
                usdRates: const {CurrencyCode.usd: 1, CurrencyCode.huf: 350},
                asOf: DateTime(2026),
                fetchedAt: DateTime(2026),
                source: RateSource.live)));
    await h.isar.writeTxn(() => h.isar.expenses.put(Expense(
        profileId: 1,
        yearMonth: '2026-10',
        title: 'Foreign purchase',
        amount: 1000,
        currency: 'eur',
        categoryId: 'general',
        date: DateTime(2026, 10),
        budgetId: 1,
        status: ExpenseStatus.paid)));
    await expectLater(s.readiness(), throwsA(isA<VaultTransferException>()));
    expect(await h.isar.vaultEntrys.count(), 1);
  });

  test(
      'changing a source row after preview rejects confirmation even if totals match',
      () async {
    final p =
        await service.preview(kind: 'deposit', amount: 1, requestId: 'stale');
    await h.isar.writeTxn(() async {
      final m = (await h.isar.monthlyBudgets.where().findFirst())!
        ..updatedAt = DateTime(2026, 10, 24);
      await h.isar.monthlyBudgets.put(m);
    });
    await expectLater(
        service.confirm(p), throwsA(isA<VaultTransferException>()));
  });

  test(
      'invalid signed ledger evidence stops both balance use and further transfers',
      () async {
    final entry = await service.confirm(await service.preview(
        kind: 'deposit', amount: 1, requestId: 'corrupt'));
    await h.isar.writeTxn(() async {
      entry.breakdownJson = '{}';
      await h.isar.vaultEntrys.put(entry);
    });
    await expectLater(
        service.readiness(), throwsA(isA<VaultTransferException>()));
    await expectLater(
        readMonthlyVaultCredit(h.isar, 1, '2026-10', CurrencyCode.huf),
        throwsFormatException);
    expect(transferDetails(entry), isNull);
    expect(validVaultSignedAmount(entry.amountMinor), isTrue);
  });

  test('later sweep includes monthly transfer credit once', () async {
    await service.confirm(
        await service.preview(kind: 'deposit', amount: 10000, requestId: 'in'));
    await service.confirm(await service.preview(
        kind: 'withdrawal', amount: 4000, requestId: 'out'));
    IsarHelper.instance = h.isar;
    final owner = (await h.isar.userProfiles.get(1))!;
    final c = ProviderContainer(overrides: [
      activeProfileProvider.overrideWith((ref) => Stream.value(owner)),
      budgetContextProvider.overrideWithValue(
          ContextRef.personal(profileId: 1, yearMonth: '2026-11')),
      rateRegistryProvider.overrideWithValue(RateTableRegistry()),
      sweepServiceProvider.overrideWith(
          (ref) => SweepService(ref, clock: () => DateTime(2026, 11, 2))),
    ]);
    addTearDown(c.dispose);
    await c.read(activeProfileProvider.future);
    final results = await Future.wait(List.generate(
        3, (_) => c.read(sweepServiceProvider).executeSweepCheck()));
    expect(results.fold<int>(0, (sum, r) => sum + r.addedMinor), 94000);
    final vault = (await h.isar.savingsVaults.where().findFirst())!;
    expect(vault.totalMinor,
        150000); // initial savings 50,000 + monthly income 100,000
    expect(await vaultHistoryProblem(h.isar, vault), isNull);
    expect(await h.isar.vaultEntrys.count(), 4);
  });

  test(
      'live monthly bank, reserve, summary and refund quote include the transfer once',
      () async {
    IsarHelper.instance = h.isar;
    final owner = (await h.isar.userProfiles.get(1))!;
    final month = (await h.isar.monthlyBudgets.where().findFirst())!;
    final c = ProviderContainer(overrides: [
      activeProfileProvider.overrideWith((ref) => Stream.value(owner)),
      activeBudgetProvider.overrideWith((ref) => Stream.value(month)),
      monthFinanceProvider.overrideWith((ref) => Stream.value(month)),
      budgetContextProvider.overrideWithValue(
          ContextRef.personal(profileId: 1, yearMonth: '2026-10')),
      selectedYearMonthProvider.overrideWith((ref) => '2026-10'),
      rateRegistryProvider.overrideWithValue(RateTableRegistry()),
      resolvedIncomeProvider.overrideWithValue(
          const ResolvedIncome(amount: 100000, usesOverride: false)),
      budgetProfilesProvider.overrideWith((ref) => Stream.value([])),
      directExpenseProfilesProvider.overrideWith((ref) => Stream.value([])),
      monthlyExpensesProvider.overrideWith((ref) => Stream.value([])),
      monthlyReimbursementsProvider.overrideWith((ref) => Stream.value([])),
      monthlyOriginReimbursementsProvider
          .overrideWith((ref) => Stream.value([])),
    ]);
    addTearDown(c.dispose);
    await c.read(activeProfileProvider.future);
    await c.read(activeBudgetProvider.future);
    await c.read(monthFinanceProvider.future);
    await c.read(vaultHistoryProvider.future);
    await c.read(budgetProfilesProvider.future);
    await c.read(directExpenseProfilesProvider.future);
    await c.read(monthlyExpensesProvider.future);
    await c.read(monthlyReimbursementsProvider.future);
    await c.read(monthlyOriginReimbursementsProvider.future);
    final bankBefore = c.read(trueAvailableProvider);
    final reserveBefore = c.read(availableReserveProvider);
    final summaryBefore = c.read(monthSummaryProvider);
    final observed = Completer<void>();
    c.listen(vaultHistoryProvider, (_, next) {
      if (next.valueOrNull?.length == 3 && !observed.isCompleted) {
        observed.complete();
      }
    });
    await service.confirm(
        await service.preview(kind: 'deposit', amount: 10000, requestId: 'in'));
    await service.confirm(await service.preview(
        kind: 'withdrawal', amount: 4000, requestId: 'out'));
    await observed.future;
    expect(c.read(monthlyVaultCreditProvider), -6000);
    expect(c.read(trueAvailableProvider), bankBefore - 6000);
    expect(c.read(availableReserveProvider), reserveBefore - 6000);
    final summary = c.read(monthSummaryProvider);
    expect(summary.vaultTransfers, -6000);
    expect(summary.kept, summaryBefore.kept - 6000);
    expect(summary.moneyInBank, summaryBefore.moneyInBank! - 6000);
    expect(summary.income, summaryBefore.income);
    expect(summary.paymentsMade, summaryBefore.paymentsMade);
    final id = await h.isar.writeTxn(() => h.isar.expenses.put(Expense(
        profileId: 1,
        yearMonth: '2026-10',
        title: 'Purchase',
        amount: 1000,
        currency: 'huf',
        categoryId: 'general',
        date: DateTime(2026, 10),
        budgetId: month.id,
        status: ExpenseStatus.paid)));
    final quote = await RefundService(h.isar,
            context: ContextRef.personal(profileId: 1, yearMonth: '2026-10'),
            actingProfileId: 1,
            rates: RateTableRegistry())
        .quote(id);
    expect(quote.reserve, 94000);
  });

  test(
      'month deletion cannot orphan a transfer; whole profile deletion removes both legs',
      () async {
    await service.confirm(
        await service.preview(kind: 'deposit', amount: 1000, requestId: 'in'));
    await expectLater(
        MonthMoveOperations(h.isar).deleteMonth(
            ContextRef.personal(profileId: 1, yearMonth: '2026-10'), '2026-10',
            actingProfileId: 1),
        throwsA(isA<UnauthorizedSpaceAction>()));
    await h.isar.writeTxn(() => h.isar.userProfiles.put(UserProfile()
      ..id = 2
      ..name = 'Other'
      ..primaryCurrency = PrimaryCurrency.huf
      ..monthlyAvailableAmount = 0
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026)));
    await ProfileSwitcherController(h.isar)
        .deleteProfile(1, activeProfileId: 2);
    expect(await h.isar.vaultEntrys.filter().profileIdEqualTo(1).count(), 0);
    expect(await h.isar.monthlyBudgets.filter().profileIdEqualTo(1).count(), 0);
    expect(await h.isar.userProfiles.get(2), isNotNull);
  });

  test(
      'Income Sources funds deposits with confirmed zero opening and matches Free to spend',
      () async {
    await funding(opening: 0, income: 0, allocation: 80000);
    await h.isar.writeTxn(() async {
      await h.isar.incomeSources.put(IncomeSource()
        ..profileId = 1
        ..name = 'Salary'
        ..amount = 200000
        ..currency = 'huf'
        ..frequency = IncomeFrequency.monthly
        ..createdAt = DateTime(2026)
        ..updatedAt = DateTime(2026));
      await h.isar.expenses.put(Expense(
          profileId: 1,
          yearMonth: '2026-10',
          title: 'Paid cost',
          amount: 50000,
          currency: 'huf',
          categoryId: 'general',
          date: DateTime(2026, 10),
          budgetId: 1,
          status: ExpenseStatus.paid));
    });
    expect((await service.readiness()).freeFunds, 70000);
    expect((await service.readiness()).maxDeposit, 70000);
    final deposit = await service.preview(
        kind: 'deposit', amount: 20000, requestId: 'income-in');
    expect(deposit.freeAfter, 50000);
    final original = await service.confirm(deposit);
    await service.confirm(await service.preview(
        kind: 'withdrawal', amount: 5000, requestId: 'income-out'));
    expect((await service.readiness()).freeFunds, 55000);
    expect((await h.isar.savingsVaults.where().findFirst())!.totalMinor, 65000);
    expect(transferDetails(original)!['freeBefore'], 70000);
    expect(
        (await h.isar.monthlyBudgets.where().findFirst())!.baseAvailableAmount,
        0);
    expect((await h.isar.incomeSources.where().findFirst())!.amount, 200000);
  });

  test(
      'legacy version-1 transfer evidence remains valid without Free to spend fields',
      () async {
    final original = await service.confirm(await service.preview(
        kind: 'deposit', amount: 1000, requestId: 'legacy'));
    final data = transferDetails(original)!..['version'] = 1;
    data.remove('freeBefore');
    data.remove('freeAfter');
    await h.isar.writeTxn(() async {
      original.breakdownJson = jsonEncode(data);
      await h.isar.vaultEntrys.put(original);
    });
    expect(transferDetails(original), isNotNull);
    expect((await service.readiness()).freeFunds, 99000);
  });

  test('goal deadline validation and removal preserve transfer balance',
      () async {
    final repo = VaultRepository(h.isar);
    for (final month in ['2026-09', '2026-13', 'invalid']) {
      await expectLater(
          repo.saveGoal(
              profileId: 1,
              actorId: 1,
              expectedCurrency: 'huf',
              name: 'Goal',
              targetMinor: 1000000,
              targetYearMonth: month,
              clock: () => DateTime(2026, 10)),
          throwsArgumentError);
    }
    await repo.saveGoal(
        profileId: 1,
        actorId: 1,
        expectedCurrency: 'huf',
        name: 'Goal',
        targetMinor: 1000000,
        targetYearMonth: '2027-06',
        clock: () => DateTime(2026, 10));
    await service.confirm(await service.preview(
        kind: 'deposit', amount: 1000, requestId: 'goal-money'));
    await repo.saveGoal(profileId: 1, actorId: 1, expectedCurrency: 'huf');
    final saved = (await repo.getVault(1))!;
    expect(saved.goalTargetYearMonth, isNull);
    expect(saved.goalTargetMinor, isNull);
    expect(saved.totalMinor, 51000);
  });

  test('deposit and withdrawal move both legs once without rewriting opening',
      () async {
    final deposit = await service.preview(
        kind: 'deposit', amount: 10000, requestId: 'deposit-one');
    await service.confirm(deposit);
    await service.confirm(deposit);
    final withdrawal = await service.preview(
        kind: 'withdrawal', amount: 4000, requestId: 'withdraw-one');
    await service.confirm(withdrawal);
    final vault = (await h.isar.savingsVaults.where().findFirst())!;
    expect(vault.totalMinor, 56000);
    expect(await readMonthlyVaultCredit(h.isar, 1, '2026-10', CurrencyCode.huf),
        -6000);
    expect(
        (await h.isar.monthlyBudgets.where().findFirst())!.baseAvailableAmount,
        80000);
    expect(await vaultHistoryProblem(h.isar, vault), isNull);
    expect(await h.isar.vaultEntrys.count(), 3);
  });

  test(
      'native reopen preserves transfers, goals, opening history and source funds',
      () async {
    await service.confirm(await service.preview(
        kind: 'deposit', amount: 10000, requestId: 'saved'));
    await VaultRepository(h.isar).saveGoal(
        profileId: 1,
        actorId: 1,
        expectedCurrency: 'huf',
        name: 'Emergency',
        targetMinor: 100000);
    await h.isar.copyToFile('${h.directory.path}/reopened.isar');
    final restored = await Isar.open(MedicalTestHarness.schemas,
        directory: h.directory.path, name: 'reopened');
    try {
      await runSchemaMigrations(restored);
      final vault = (await restored.savingsVaults.where().findFirst())!;
      expect(vault.totalMinor, 60000);
      expect(vault.goalTargetMinor, 100000);
      expect(
          (await restored.monthlyBudgets.where().findFirst())!
              .baseAvailableAmount,
          80000);
      expect(await restored.vaultEntrys.count(), 2);
      expect(await vaultHistoryProblem(restored, vault), isNull);
      expect(
          await readMonthlyVaultCredit(
              restored, 1, '2026-10', CurrencyCode.huf),
          -10000);
    } finally {
      await restored.close(deleteFromDisk: true);
    }
  });
}
