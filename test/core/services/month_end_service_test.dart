import 'package:budget_buddy/core/models/app_settings.dart';
import 'package:budget_buddy/core/models/live_rate_set.dart';
import '../../support/audit_test_support.dart';
import 'package:budget_buddy/features/vault/models/vault_entry.dart';
import 'package:budget_buddy/features/vault/vault_transfer_service.dart';
import 'package:budget_buddy/features/spaces/repositories/month_move_operations.dart';
import 'package:budget_buddy/features/spaces/repositories/space_role_guard.dart';
import 'package:budget_buddy/core/models/allocation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_buddy/core/database/isar_helper.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/selected_month_provider.dart';
import 'package:budget_buddy/features/finance/providers/month_end_providers.dart';
import 'package:budget_buddy/features/finance/providers/profile_providers.dart';
import 'package:budget_buddy/features/finance/providers/reserve_providers.dart';
import 'package:budget_buddy/features/finance/providers/finance_providers.dart';
import 'package:budget_buddy/features/finance/repositories/month_finance_repository.dart';
import 'package:budget_buddy/features/engine/providers/true_available_provider.dart';
import 'package:budget_buddy/features/engine/providers/month_summary_provider.dart';
import 'package:budget_buddy/features/settings/providers/settings_provider.dart';
import 'package:budget_buddy/core/models/income_source.dart';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/month_end_run.dart';
import 'package:budget_buddy/core/models/budget_profile.dart';
import 'package:budget_buddy/core/models/direct_expense_profile.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/identity.dart';
import 'package:budget_buddy/core/models/audit_event.dart';
import 'package:budget_buddy/core/models/change_record.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/core/models/month_rate_seal.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/core/services/month_end_service.dart';
import 'package:budget_buddy/core/services/month_end_report.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import 'package:budget_buddy/features/vault/models/savings_vault.dart';
import 'package:budget_buddy/features/finance/repositories/audit_repository.dart';
import 'package:budget_buddy/features/sync/repositories/sync_recorder.dart';
import 'package:budget_buddy/features/sync/domain/entity_applier.dart';
import 'package:budget_buddy/features/sync/domain/codecs/month_end_run_codec.dart';
import 'package:budget_buddy/core/database/schema_migrations.dart';

class _BrokenAudit extends AuditRepository {
  _BrokenAudit(super.isar);
  @override
  Future<void> appendMonthEnd(MonthEndRun run) async {
    throw StateError('audit failed');
  }
}

class _BrokenJournal extends SyncRecorder {
  _BrokenJournal(super.isar);
  @override
  Future<ChangeRecord?> recordMonthEnd(MonthEndRun run) async {
    throw StateError('journal failed');
  }
}

void main() {
  late Isar db;
  late Directory dir;
  var sequence = 0;
  final now = DateTime(2026, 10, 23);
  setUpAll(() async {
    await Isar.initializeIsarCore(download: false);
  });
  late SyncRecorder auditRecorder;
  setUp(() async {
    dir = await Directory.systemTemp.createTemp('budget_buddy_month_end_');
    db = await Isar.open([
      UserProfileSchema,
      MonthlyBudgetSchema,
      MonthEndRunSchema,
      BudgetProfileSchema,
      AllocationSchema,
      DirectExpenseProfileSchema,
      ExpenseSchema,
      ReimbursementSchema,
      IdentitySchema,
      SharedSpaceSchema,
      SharedMemberSchema,
      MonthRateSealSchema,
      LiveRateSetSchema,
      IncomeSourceSchema,
      SavingsVaultSchema,
      VaultEntrySchema,
      AuditEventSchema,
      ChangeRecordSchema,
      AppSettingsSchema,
      SchemaMigrationStampSchema
    ], directory: dir.path, name: 'month_end_${sequence++}');
    IsarHelper.instance = db;
    auditRecorder = await auditTestRecorder(db);
    await db.writeTxn(() async {
      await db.userProfiles.put(UserProfile()
        ..id = 1
        ..name = 'Me'
        ..primaryCurrency = PrimaryCurrency.huf
        ..monthlyAvailableAmount = 0
        ..defaultNetSalary = 100000
        ..createdAt = now
        ..updatedAt = now);
      await db.monthlyBudgets.put(MonthlyBudget()
        ..id = 1
        ..profileId = 1
        ..yearMonth = '2026-09'
        ..baseAvailableAmount = 100000
        ..openingBalanceConfirmed = true
        ..createdAt = now
        ..updatedAt = now);
      await db.budgetProfiles.put(BudgetProfile()
        ..id = 1
        ..syncGuid = 'food'
        ..profileId = 1
        ..yearMonth = '2026-09'
        ..name = 'Food'
        ..allocation = 100000
        ..spent = 999999
        ..createdAt = now
        ..updatedAt = now);
      await db.expenses.put(Expense(
          id: 1,
          profileId: 1,
          yearMonth: '2026-09',
          title: 'Paid',
          amount: 80000,
          currency: 'huf',
          categoryId: 'food',
          date: now,
          budgetId: 1,
          budgetProfileId: 1));
    });
  });
  tearDown(() async {
    await db.close(deleteFromDisk: true);
    final target = dir.absolute.path, root = Directory.systemTemp.absolute.path;
    if (!target.startsWith('$root${Platform.pathSeparator}') ||
        !dir.path
            .split(Platform.pathSeparator)
            .last
            .startsWith('budget_buddy_month_end_')) {
      throw StateError('Unsafe fixture cleanup');
    }
    await dir.delete(recursive: true);
  });
  MonthEndService service(
          {int actor = 1,
          ContextRef? context,
          AuditRepository? audit,
          SyncRecorder? recorder}) =>
      MonthEndService(db,
          context: context ??
              ContextRef.personal(profileId: 1, yearMonth: '2026-09'),
          actorId: actor,
          rates: RateTableRegistry(),
          clock: () => now,
          audit: audit,
          recorder: recorder ?? auditRecorder);
  List<MonthEndChoice> choice(
          {MonthEndRule rule = MonthEndRule.carryForward,
          String? destination}) =>
      [
        MonthEndChoice(
            sourceGuid: 'food',
            rule: rule,
            defaultAllocation: 100000,
            destinationGuid: destination)
      ];

  test('Month-End borrowing capacity includes a funded vault withdrawal once',
      () async {
    await db.writeTxn(() async {
      final e = (await db.expenses.get(1))!..amount = 130000;
      await db.expenses.put(e);
      final vault = SavingsVault()
        ..profileId = 1
        ..currency = 'huf'
        ..totalMinor = 50000
        ..lastSweepYearMonth = '2026-09'
        ..updatedAt = now;
      await db.savingsVaults.put(vault);
      await seedVaultOpeningInTxn(db, vault, now);
    });
    final before = await service().preview('2026-09', choices: choice());
    expect(before.lines.single.deficit, 30000);
    final transfer = VaultTransferService(db,
        actorId: 1,
        isStillActive: () => true,
        rates: () => RateTableRegistry(),
        clock: () => DateTime(2026, 9, 23));
    await transfer.confirm(await transfer.preview(
        kind: 'withdrawal', amount: 20000, requestId: 'fund-month'));
    final after = await service().preview('2026-09', choices: choice());
    expect(after.lines.single.borrowed, 20000);
    expect(after.lines.single.deficit, 10000);
    expect(after.fingerprint, isNot(before.fingerprint));
    expect(after.carried, 0);
  });

  test(
      'preview writes nothing and requires explicit legacy default confirmation',
      () async {
    final report = await service().preview('2026-09');
    expect(report.blockers.join(), contains('Confirm the default'));
    expect(await db.monthEndRuns.count(), 0);
    expect(await db.budgetProfiles.count(), 1);
    expect((await db.budgetProfiles.get(1))!.allocation, 100000);
  });
  for (final rule in MonthEndRule.values) {
    test('$rule uses live net spending, preserves source and applies once',
        () async {
      final choices = choice(rule: rule);
      final report = await service().preview('2026-09', choices: choices);
      expect(report.ready, isTrue);
      expect(report.lines.single.amounts.spent, 80000);
      final run = await service().confirm(report, choices: choices);
      final target = (await db.budgetProfiles
              .filter()
              .yearMonthEqualTo('2026-10')
              .findAll())
          .single;
      expect(target.allocation,
          rule == MonthEndRule.carryForward ? 120000 : 100000);
      expect(target.defaultAllocationMinor, 100000);
      expect(target.familyGuid, 'food');
      expect((await db.budgetProfiles.get(1))!.allocation, 100000);
      expect((await db.expenses.get(1))!.amount, 80000);
      expect(
          await db.auditEvents.filter().actionEqualTo('month.end').count(), 1);
      expect(
          await db.auditEvents
              .filter()
              .actionEqualTo('borrowing.deficit.change')
              .count(),
          1);
      expect(await db.allocations.count(), 1);
      expect((await db.allocations.where().findAll()).single.auditEventId,
          isNotNull);
      expect(run.carriedMinor, rule == MonthEndRule.carryForward ? 20000 : 0);
      await expectLater(
          service().confirm(report, choices: choice(rule: MonthEndRule.reset)),
          throwsA(isA<MonthEndException>()));
      expect(await db.monthEndRuns.count(), 1);
      expect((await db.budgetProfiles.get(target.id))!.allocation,
          target.allocation);
    });
  }
  test('partial refund changes unused without dropping the whole paid expense',
      () async {
    await db.writeTxn(() async {
      final e = (await db.expenses.get(1))!
        ..status = ExpenseStatus.partiallyReimbursed;
      await db.expenses.put(e);
      await db.reimbursements.put(Reimbursement(
          profileId: 1,
          expenseId: 1,
          originYearMonth: '2026-09',
          amount: 5000,
          currency: 'huf',
          date: now));
    });
    final r = await service().preview('2026-09', choices: choice());
    expect(r.carried, 25000);
    expect(r.lines.single.amounts.spent, 75000);
  });
  test('explicit legacy target link preserves its existing allocation',
      () async {
    await db.writeTxn(() async {
      await db.budgetProfiles.put(BudgetProfile()
        ..syncGuid = 'destination'
        ..profileId = 1
        ..yearMonth = '2026-10'
        ..name = 'Existing'
        ..allocation = 70000
        ..createdAt = now
        ..updatedAt = now);
    });
    final r = await service()
        .preview('2026-09', choices: choice(destination: 'destination'));
    await service().confirm(r, choices: choice(destination: 'destination'));
    final p = (await db.budgetProfiles
        .filter()
        .syncGuidEqualTo('destination')
        .findFirst())!;
    expect(p.allocation, 90000);
    expect(p.familyGuid, 'food');
    expect(await db.budgetProfiles.count(), 2);
  });
  test('changed expense makes preview stale and leaves destination untouched',
      () async {
    final r = await service().preview('2026-09', choices: choice());
    await db.writeTxn(() async {
      final e = (await db.expenses.get(1))!..amount = 70000;
      await db.expenses.put(e);
    });
    await expectLater(
        service().confirm(r, choices: choice()),
        throwsA(isA<MonthEndException>()
            .having((e) => e.message, 'message', contains('Data changed'))));
    expect(await db.monthEndRuns.count(), 0);
    expect(await db.budgetProfiles.count(), 1);
  });
  test('concurrent confirms produce one result', () async {
    final r = await service().preview('2026-09', choices: choice());
    final results = await Future.wait([
      for (var i = 0; i < 2; i++)
        service()
            .confirm(r, choices: choice())
            .then<Object>((v) => v)
            .catchError((Object e) => e)
    ]);
    expect(results.whereType<MonthEndRun>().length, 1);
    expect(results.whereType<MonthEndException>().length, 1);
    expect(await db.monthEndRuns.count(), 1);
  });
  for (final journal in [false, true]) {
    test(
        '${journal ? 'journal' : 'audit'} failure rolls back every month-end write',
        () async {
      final api = service(
          audit: journal ? null : _BrokenAudit(db),
          recorder: journal ? _BrokenJournal(db) : null);
      final r = await api.preview('2026-09', choices: choice());
      await expectLater(api.confirm(r, choices: choice()), throwsStateError);
      expect(await db.monthEndRuns.count(), 0);
      expect(await db.budgetProfiles.count(), 1);
      expect(await db.auditEvents.count(), 0);
      expect(await db.monthlyBudgets.count(), 1);
      expect(await db.allocations.count(), 0);
    });
  }
  test(
      'current/future months, earlier unfinished profiles and wrong owner cannot close',
      () async {
    expect((await service().preview('2026-10')).blockers.join(),
        contains('completed calendar'));
    await expectLater(service(actor: 2).preview('2026-09'),
        throwsA(isA<MonthEndException>()));
    await db.writeTxn(() async {
      await db.budgetProfiles.put(BudgetProfile()
        ..profileId = 1
        ..yearMonth = '2026-08'
        ..name = 'Earlier'
        ..createdAt = now
        ..updatedAt = now);
    });
    expect(
        (await service().preview('2026-09', choices: choice())).blockers.join(),
        contains('2026-08 first'));
  });
  test('already swept month blocks without changing the vault', () async {
    await db.writeTxn(() async {
      await db.savingsVaults.put(SavingsVault()
        ..profileId = 1
        ..totalMinor = 20000
        ..currency = 'huf'
        ..lastSweepYearMonth = '2026-10'
        ..updatedAt = now);
    });
    final r = await service().preview('2026-09', choices: choice());
    expect(r.blockers.join(), contains('vault has already'));
    await expectLater(service().confirm(r, choices: choice()),
        throwsA(isA<MonthEndException>()));
    expect((await db.savingsVaults.where().findAll()).single.totalMinor, 20000);
  });
  Future<ContextRef> shared(SharedMemberRole role) async {
    await db.writeTxn(() async {
      await db.sharedSpaces.put(SharedSpace()
        ..id = 1
        ..syncGuid = 'space'
        ..name = 'Our pot'
        ..currency = PrimaryCurrency.huf
        ..createdByProfileId = 1
        ..createdAt = now);
      await db.sharedMembers.put(SharedMember()
        ..sharedSpaceId = 1
        ..profileId = 1
        ..role = role
        ..joinedAt = now);
      final p = (await db.budgetProfiles.get(1))!
        ..profileId = null
        ..sharedSpaceId = 1;
      await db.budgetProfiles.put(p);
      final m = (await db.monthlyBudgets.get(1))!
        ..profileId = null
        ..sharedSpaceId = 1;
      await db.monthlyBudgets.put(m);
      final e = (await db.expenses.get(1))!
        ..profileId = 0
        ..sharedSpaceId = 1;
      await db.expenses.put(e);
    });
    return ContextRef.shared(spaceId: 1, yearMonth: '2026-09');
  }

  for (final role in SharedMemberRole.values) {
    test('shared $role may inspect; only Owner confirms', () async {
      final ctx = await shared(role);
      final r =
          await service(context: ctx).preview('2026-09', choices: choice());
      if (role == SharedMemberRole.owner) {
        await service(context: ctx).confirm(r, choices: choice());
        expect(
            (await db.monthEndRuns.where().findAll()).single.sharedSpaceId, 1);
      } else {
        expect(r.canConfirm, isFalse);
        await expectLater(service(context: ctx).confirm(r, choices: choice()),
            throwsA(isA<MonthEndException>()));
      }
    });
  }
  test(
      'remote replay is idempotent and differing offline confirmation flags conflict',
      () async {
    final ctx = await shared(SharedMemberRole.owner);
    final r = await service(context: ctx).preview('2026-09', choices: choice());
    final run = await service(context: ctx).confirm(r, choices: choice());
    final payload = const MonthEndRunCodec().toPayload(run);
    await db.writeTxn(() async {
      await const MonthEndRunApplier().upsert(db, payload);
      await const MonthEndRunApplier().upsert(db, payload);
    });
    expect(
        (await db.budgetProfiles.filter().yearMonthEqualTo('2026-10').findAll())
            .single
            .allocation,
        120000);
    final conflicting = const MonthEndRunCodec().fromPayload(payload)
      ..fingerprint = 'different';
    await db.writeTxn(() async {
      await const MonthEndRunApplier()
          .upsert(db, const MonthEndRunCodec().toPayload(conflicting));
    });
    expect(
        (await db.monthEndRuns.where().findAll()).single.hasConflict, isTrue);
    expect((await service(context: ctx).preview('2026-09')).blockers.join(),
        contains('conflicting'));
    expect(await db.auditEvents.filter().actionEqualTo('month.end').count(), 1);
    expect(
        await db.auditEvents
            .filter()
            .actionEqualTo('borrowing.deficit.change')
            .count(),
        1);
  });
  test('version 23 upgrade preserves profiles and leaves default unconfirmed',
      () async {
    await writeSchemaVersion(db, 23);
    await runSchemaMigrations(db);
    await runSchemaMigrations(db);
    expect(await readSchemaVersion(db), schemaVersion);
    expect((await db.budgetProfiles.get(1))!.defaultAllocationMinor, isNull);
    expect((await db.budgetProfiles.get(1))!.allocation, 100000);
    expect(await db.monthEndRuns.count(), 0);
  });
  for (final rule in MonthEndRule.values) {
    test('$rule reserve and summary count settlement funds exactly once',
        () async {
      final api = service();
      final choices = choice(rule: rule);
      final report = await api.preview('2026-09', choices: choices);
      final run = await api.confirm(report, choices: choices);
      final month = rule == MonthEndRule.reset ? '2026-09' : '2026-10';
      final profiles =
          await db.budgetProfiles.filter().yearMonthEqualTo(month).findAll();
      final monthly =
          (await db.monthlyBudgets.filter().yearMonthEqualTo(month).findAll())
              .single;
      final expenses = rule == MonthEndRule.reset
          ? await db.expenses.where().findAll()
          : [
              Expense(
                  id: 2,
                  profileId: 1,
                  yearMonth: month,
                  title: 'Next purchase',
                  amount: 80000,
                  currency: 'huf',
                  categoryId: 'food',
                  date: now,
                  budgetId: monthly.id,
                  budgetProfileId: profiles.single.id,
                  financialProfileType: FinancialProfileType.budget,
                  financialProfileSyncGuid: profiles.single.syncGuid)
            ];
      IsarHelper.instance = db;
      final container = ProviderContainer(overrides: [
        budgetContextProvider.overrideWithValue(
            ContextRef.personal(profileId: 1, yearMonth: month)),
        selectedYearMonthProvider.overrideWith((ref) => month),
        activeProfileProvider
            .overrideWith((ref) => Stream.value((db.userProfiles.getSync(1))!)),
        activeBudgetProvider.overrideWith((ref) => Stream.value(monthly)),
        mainCurrencyProvider.overrideWithValue(CurrencyCode.huf),
        rateRegistryProvider.overrideWithValue(RateTableRegistry()),
        resolvedIncomeProvider.overrideWithValue(
            const ResolvedIncome(amount: 100000, usesOverride: false)),
        monthFinanceProvider.overrideWith((ref) => Stream.value(monthly)),
        budgetProfilesProvider.overrideWith((ref) => Stream.value(profiles)),
        directExpenseProfilesProvider.overrideWith((ref) => Stream.value([])),
        monthlyExpensesProvider.overrideWith((ref) => Stream.value(expenses)),
        monthlyReimbursementsProvider.overrideWith((ref) => Stream.value([])),
        monthlyOriginReimbursementsProvider
            .overrideWith((ref) => Stream.value([])),
        monthEndRunsProvider.overrideWith((ref) => Stream.value([run])),
      ]);
      try {
        await container.read(activeProfileProvider.future);
        await container.read(activeBudgetProvider.future);
        await container.read(monthFinanceProvider.future);
        await container.read(budgetProfilesProvider.future);
        await container.read(directExpenseProfilesProvider.future);
        await container.read(monthlyExpensesProvider.future);
        await container.read(monthlyReimbursementsProvider.future);
        await container.read(monthlyOriginReimbursementsProvider.future);
        await container.read(monthEndRunsProvider.future);
        expect(container.read(availableReserveProvider),
            rule == MonthEndRule.reset ? 20000 : 0);
        final summary = container.read(monthSummaryProvider);
        expect(summary.income, 100000);
        expect(summary.kept, rule == MonthEndRule.reset ? 20000 : 0);
        if (rule == MonthEndRule.reset) {
          expenses.single.amount = 90000;
          container.invalidate(monthlyExpensesProvider);
          await container.read(monthlyExpensesProvider.future);
          expect(container.read(availableReserveProvider), 10000);
          expect(container.read(monthSummaryProvider).kept, 10000);
          expect(run.releasedMinor, 20000);
        }
        expect(monthly.baseAvailableAmount,
            rule == MonthEndRule.reset ? 100000 : 0);
      } finally {
        container.dispose();
      }
    });
  }
  for (final currency in PrimaryCurrency.values) {
    test('$currency month-end preserves exact minor units and ledger currency',
        () async {
      await db.writeTxn(() async {
        final user = (await db.userProfiles.get(1))!
          ..primaryCurrency = currency;
        await db.userProfiles.put(user);
        final expense = (await db.expenses.get(1))!..currency = currency.name;
        await db.expenses.put(expense);
      });
      final api = service();
      final choices = choice();
      final r = await api.preview('2026-09', choices: choices);
      final run = await api.confirm(r, choices: choices);
      expect(run.currency, currency.name);
      expect(run.carriedMinor, 20000);
      expect((await db.allocations.where().findAll()).single.amount, 120000);
      expect((await db.allocations.where().findAll()).single.currency,
          currency.name);
    });
  }
  test('overspending is reported but no deficit or debt is carried', () async {
    await db.writeTxn(() async {
      final e = (await db.expenses.get(1))!..amount = 130000;
      await db.expenses.put(e);
    });
    final api = service();
    final choices = choice();
    final r = await api.preview('2026-09', choices: choices);
    expect(r.carried, 0);
    expect(r.lines.single.deficit, 30000);
    await api.confirm(r, choices: choices);
    expect(
        (await db.budgetProfiles.filter().yearMonthEqualTo('2026-10').findAll())
            .single
            .allocation,
        100000);
  });
  test('ambiguous assignments and unsupported currencies refuse confirmation',
      () async {
    await db.writeTxn(() async {
      await db.directExpenseProfiles.put(DirectExpenseProfile()
        ..id = 1
        ..profileId = 1
        ..yearMonth = '2026-09'
        ..name = 'Ambiguous'
        ..createdAt = now
        ..updatedAt = now);
    });
    final api = service();
    final choices = choice();
    final r = await api.preview('2026-09', choices: choices);
    expect(r.blockers.join(), contains('Resolve the profile assignment'));
    await expectLater(
        api.confirm(r, choices: choices), throwsA(isA<MonthEndException>()));
    await db.writeTxn(() async {
      final e = (await db.expenses.get(1))!..currency = 'unsupported';
      await db.expenses.put(e);
    });
    await expectLater(api.preview('2026-09', choices: choices),
        throwsA(isA<MonthEndException>()));
    expect(await db.monthEndRuns.count(), 0);
  });
  test(
      'late source spending retains the outgoing carry reservation as a shortfall',
      () async {
    final api = service(), choices = choice();
    final preview = await api.preview('2026-09', choices: choices);
    final run = await api.confirm(preview, choices: choices);
    final source = (await db.budgetProfiles.get(1))!;
    final expense = (await db.expenses.get(1))!
      ..amount = 90000
      ..financialProfileType = FinancialProfileType.budget
      ..financialProfileSyncGuid = source.syncGuid;
    final container = ProviderContainer(overrides: [
      budgetContextProvider.overrideWithValue(
          ContextRef.personal(profileId: 1, yearMonth: '2026-09')),
      activeProfileProvider
          .overrideWith((ref) => Stream.value(db.userProfiles.getSync(1))),
      mainCurrencyProvider.overrideWithValue(CurrencyCode.huf),
      rateRegistryProvider.overrideWithValue(RateTableRegistry()),
      resolvedIncomeProvider.overrideWithValue(
          const ResolvedIncome(amount: 100000, usesOverride: false)),
      budgetProfilesProvider.overrideWith((ref) => Stream.value([source])),
      directExpenseProfilesProvider.overrideWith((ref) => Stream.value([])),
      contextExpensesProvider.overrideWithValue([expense]),
      monthlyReimbursementsProvider.overrideWith((ref) => Stream.value([])),
      monthEndRunsProvider.overrideWith((ref) => Stream.value([run])),
    ]);
    try {
      await container.read(activeProfileProvider.future);
      await container.read(budgetProfilesProvider.future);
      await container.read(directExpenseProfilesProvider.future);
      await container.read(monthlyReimbursementsProvider.future);
      await container.read(monthEndRunsProvider.future);
      expect(container.read(monthEndBalanceProvider).carryShortfall, 10000);
      expect(container.read(availableReserveProvider), -10000);
      expect(run.carriedMinor, 20000);
    } finally {
      container.dispose();
    }
  });
  test(
      'personal and shared settlement identities cannot collide across namespaces',
      () async {
    final personal = service();
    final choices = choice();
    final first = await personal.confirm(
        await personal.preview('2026-09', choices: choices),
        choices: choices);
    final ctx = await shared(SharedMemberRole.owner);
    await db.writeTxn(() async {
      final space = (await db.sharedSpaces.get(1))!..syncGuid = 'personal:1';
      await db.sharedSpaces.put(space);
    });
    final sharedApi = service(context: ctx);
    final second = await sharedApi.confirm(
        await sharedApi.preview('2026-09', choices: choices),
        choices: choices);
    expect(first.syncGuid, isNot(second.syncGuid));
    expect(await db.monthEndRuns.count(), 2);
    expect((await db.monthEndRuns.get(first.id))!.hasConflict, isFalse);
    expect((await db.monthEndRuns.get(first.id))!.profileId, 1);
  });
  test('legacy month moves/deletes cannot detach either settlement leg',
      () async {
    final ctx = await shared(SharedMemberRole.owner);
    final api = service(context: ctx), choices = choice();
    await api.confirm(await api.preview('2026-09', choices: choices),
        choices: choices);
    final ops = MonthMoveOperations(db);
    await expectLater(
        ops.moveMonth(ctx,
            ContextRef.personal(profileId: 2, yearMonth: '2026-09'), '2026-09',
            actingProfileId: 1),
        throwsA(isA<UnauthorizedSpaceAction>()));
    await expectLater(ops.deleteMonth(ctx, '2026-09', actingProfileId: 1),
        throwsA(isA<UnauthorizedSpaceAction>()));
    await expectLater(ops.deleteMonth(ctx, '2026-10', actingProfileId: 1),
        throwsA(isA<UnauthorizedSpaceAction>()));
    expect(await db.monthEndRuns.count(), 1);
    expect(await db.monthlyBudgets.count(), 2);
    expect(await db.expenses.count(), 1);
  });
}
