import '../../support/audit_test_support.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/insurance_profile.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/network/rate_types.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import 'package:budget_buddy/features/spaces/repositories/month_move_operations.dart';
import 'package:budget_buddy/features/spaces/repositories/space_role_guard.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import '../medical/repositories/medical_test_harness.dart';

/// T038 — the month-move lifecycle (contracts/month-move-lifecycle, US3).
///
/// These drive a real Isar instance through [MonthMoveOperations], because the
/// exactly-one-context, move-not-copy and income-carry invariants only exist
/// once rows sit in real collections.
void main() {
  late MedicalTestHarness h;
  late MonthMoveOperations ops;

  setUp(() async {
    h = await MedicalTestHarness.create();
    ops = MonthMoveOperations(h.isar,
        recorder: await auditTestRecorder(h.isar),
        rateRegistry: MedicalTestHarness.rates);
  });

  tearDown(() => h.close());

  Future<void> addMember(
    int spaceId,
    int profileId,
    SharedMemberRole role,
  ) async {
    await h.isar.writeTxn(() async {
      await h.isar.sharedMembers.put(
        SharedMember()
          ..sharedSpaceId = spaceId
          ..profileId = profileId
          ..role = role
          ..joinedAt = DateTime(2026),
      );
    });
  }

  Future<int> makeSpace(PrimaryCurrency currency,
      {required int createdBy}) async {
    final space = SharedSpace()
      ..name = 'Test space'
      ..avatar = 'X'
      ..currency = currency
      ..defaultIncome = 0
      ..createdByProfileId = createdBy
      ..createdAt = DateTime(2026);
    await h.isar.writeTxn(() async {
      space.id = await h.isar.sharedSpaces.put(space);
    });
    return space.id;
  }

  Future<MonthlyBudget?> monthIn(ContextRef context) {
    final filter = h.isar.monthlyBudgets.filter();
    final scoped = context.isShared
        ? filter.sharedSpaceIdEqualTo(context.spaceId)
        : filter.profileIdEqualTo(context.profileKey);
    return scoped.and().yearMonthEqualTo(context.yearMonth).findFirst();
  }

  /// `MedicalTestHarness.seedBudget` writes an *unclaimed* budget (no context
  /// columns). The move resolves the personal context by `profileId`, so claim
  /// the seeded row for the profile under test.
  Future<MonthlyBudget> claimPersonal(int profileId, String yearMonth) async {
    final rows = await h.isar.monthlyBudgets
        .filter()
        .yearMonthEqualTo(yearMonth)
        .findAll();
    final row = rows.firstWhere(
      (b) => b.profileId == null && b.sharedSpaceId == null,
      orElse: () => rows.first,
    );
    row
      ..profileId = profileId
      ..sharedSpaceId = null;
    await h.isar.writeTxn(() => h.isar.monthlyBudgets.put(row));
    return row;
  }

  Future<void> seedExpense(
      int profileId, String yearMonth, int budgetId) async {
    await h.isar.writeTxn(() async {
      final id = await h.isar.expenses.put(
        Expense(
          profileId: profileId,
          yearMonth: yearMonth,
          title: 'Rent',
          amount: 12345,
          currency: 'USD',
          categoryId: 'general',
          date: DateTime(2026, 3, 5),
          budgetId: budgetId,
        ),
      );
      await h.isar.reimbursements.put(
        Reimbursement(
          profileId: profileId,
          expenseId: id,
          originYearMonth: yearMonth,
          amount: 500,
          currency: 'USD',
          date: DateTime(2026, 3, 6),
        ),
      );
    });
  }

  test('moves a whole month in and leaves the origin empty (move, not copy)',
      () async {
    final seeded = await h.seedBudget(yearMonth: '2026-03');
    final profileId = seeded.profileId;
    final spaceId = await makeSpace(PrimaryCurrency.usd, createdBy: profileId);
    await addMember(spaceId, profileId, SharedMemberRole.owner);
    await claimPersonal(profileId, '2026-03');
    await seedExpense(profileId, '2026-03', seeded.budgetId);

    final from =
        ContextRef.personal(profileId: profileId, yearMonth: '2026-03');
    final to = ContextRef.shared(spaceId: spaceId, yearMonth: '2026-03');

    final moved =
        await ops.moveMonth(from, to, '2026-03', actingProfileId: profileId);

    expect(moved.sharedSpaceId, spaceId);
    expect(moved.profileId, isNull);
    expect(await monthIn(from), isNull, reason: 'origin month must be empty');
    expect(await monthIn(to), isNotNull);

    final sharedExpenses = await h.isar.expenses
        .filter()
        .sharedSpaceIdEqualTo(spaceId)
        .and()
        .yearMonthEqualTo('2026-03')
        .findAll();
    expect(sharedExpenses, hasLength(1));
    expect(sharedExpenses.single.budgetId, moved.id);
    expect(sharedExpenses.single.profileId, 0);

    final sharedReimbursements = await h.isar.reimbursements
        .filter()
        .sharedSpaceIdEqualTo(spaceId)
        .and()
        .originYearMonthEqualTo('2026-03')
        .findAll();
    expect(sharedReimbursements, hasLength(1));

    final personalExpenses = await h.isar.expenses
        .filter()
        .profileIdEqualTo(profileId)
        .and()
        .yearMonthEqualTo('2026-03')
        .findAll();
    expect(personalExpenses, isEmpty, reason: 'origin expenses must be gone');
  });

  test('carries personal income into the shared pot override verbatim',
      () async {
    final seeded = await h.seedBudget(yearMonth: '2026-03');
    final profileId = seeded.profileId;
    final spaceId = await makeSpace(PrimaryCurrency.usd, createdBy: profileId);
    await addMember(spaceId, profileId, SharedMemberRole.owner);

    final budget = await claimPersonal(profileId, '2026-03');
    budget.netSalaryOverride = 3000.0;
    await h.isar.writeTxn(() => h.isar.monthlyBudgets.put(budget));

    final moved = await ops.moveMonth(
      ContextRef.personal(profileId: profileId, yearMonth: '2026-03'),
      ContextRef.shared(spaceId: spaceId, yearMonth: '2026-03'),
      '2026-03',
      actingProfileId: profileId,
    );

    expect(moved.sharedIncomeOverride, 300000,
        reason: 'usd 3000.00 carried verbatim as minor units');
    expect(moved.netSalaryOverride, isNull,
        reason: 'the personal pot override is cleared on the move');
  });

  test('carries shared income into the personal pot override', () async {
    final seeded = await h.seedBudget(yearMonth: '2026-03');
    final profileId = seeded.profileId;
    final spaceId = await makeSpace(PrimaryCurrency.usd, createdBy: profileId);
    await addMember(spaceId, profileId, SharedMemberRole.owner);
    await h.seedBudget(yearMonth: '2026-03', spaceId: spaceId);

    final sharedMonth = await monthIn(
        ContextRef.shared(spaceId: spaceId, yearMonth: '2026-03'));
    sharedMonth!.sharedIncomeOverride = 300000;
    await h.isar.writeTxn(() => h.isar.monthlyBudgets.put(sharedMonth));

    final moved = await ops.moveMonth(
      ContextRef.shared(spaceId: spaceId, yearMonth: '2026-03'),
      ContextRef.personal(profileId: profileId, yearMonth: '2026-03'),
      '2026-03',
      actingProfileId: profileId,
    );

    expect(moved.profileId, profileId);
    expect(moved.netSalaryOverride, 3000.0);
    expect(moved.sharedIncomeOverride, isNull);
  });

  test('converts income once when the move crosses currencies', () async {
    final seeded = await h.seedBudget(yearMonth: '2026-03');
    final profileId = seeded.profileId;
    final spaceId = await makeSpace(PrimaryCurrency.huf, createdBy: profileId);
    await addMember(spaceId, profileId, SharedMemberRole.owner);

    final budget = await claimPersonal(profileId, '2026-03');
    budget.netSalaryOverride = 100.0; // usd
    await h.isar.writeTxn(() => h.isar.monthlyBudgets.put(budget));

    final moved = await ops.moveMonth(
      ContextRef.personal(profileId: profileId, yearMonth: '2026-03'),
      ContextRef.shared(spaceId: spaceId, yearMonth: '2026-03'),
      '2026-03',
      actingProfileId: profileId,
    );

    // Bundled table: 1 USD = 345 HUF. 100.00 USD = 10000 minor USD
    // → 34500 minor HUF (HUF exponent 0), rounded once.
    expect(moved.sharedIncomeOverride, 34500);
  });

  test('refuses a second move when the target already owns the month',
      () async {
    final seeded = await h.seedBudget(yearMonth: '2026-03');
    final profileId = seeded.profileId;
    final spaceId = await makeSpace(PrimaryCurrency.usd, createdBy: profileId);
    await addMember(spaceId, profileId, SharedMemberRole.owner);
    await claimPersonal(profileId, '2026-03');
    // The space already owns this month.
    await h.seedBudget(yearMonth: '2026-03', spaceId: spaceId);

    expect(
      () => ops.moveMonth(
        ContextRef.personal(profileId: profileId, yearMonth: '2026-03'),
        ContextRef.shared(spaceId: spaceId, yearMonth: '2026-03'),
        '2026-03',
        actingProfileId: profileId,
      ),
      throwsA(isA<UnauthorizedSpaceAction>()),
    );
  });

  test('a sealed past month still moves with its amounts untouched', () async {
    final seeded = await h.seedBudget(yearMonth: '2025-12', year: 2025);
    final profileId = seeded.profileId;
    final spaceId = await makeSpace(PrimaryCurrency.huf, createdBy: profileId);
    await addMember(spaceId, profileId, SharedMemberRole.owner);

    final budget = await claimPersonal(profileId, '2025-12');
    budget.netSalaryOverride = 50.0; // usd
    await h.isar.writeTxn(() => h.isar.monthlyBudgets.put(budget));

    await h.isar.writeTxn(() async {
      await h.isar.expenses.put(
        Expense(
          profileId: profileId,
          yearMonth: '2025-12',
          title: 'Past rent',
          amount: 9999,
          currency: 'USD',
          categoryId: 'general',
          date: DateTime(2025, 12, 5),
          budgetId: seeded.budgetId,
        ),
      );
    });

    // A seal for the month, distinct from the bundled rates, so we can prove
    // the carry used the month's own table (100 HUF per USD, not 345).
    final sealed = RateTable(
      usdRates: {
        CurrencyCode.usd: 1.0,
        CurrencyCode.eur: 0.5,
        CurrencyCode.huf: 100.0,
        CurrencyCode.cad: 1.0,
      },
      asOf: DateTime.utc(2025, 12, 31),
      fetchedAt: DateTime.utc(2025, 12, 31),
      source: RateSource.historical,
    );
    final sealedOps = MonthMoveOperations(
      h.isar,
      recorder: await auditTestRecorder(h.isar),
      rateRegistry: RateTableRegistry(sealedTables: {'2025-12': sealed}),
    );

    final moved = await sealedOps.moveMonth(
      ContextRef.personal(profileId: profileId, yearMonth: '2025-12'),
      ContextRef.shared(spaceId: spaceId, yearMonth: '2025-12'),
      '2025-12',
      actingProfileId: profileId,
    );

    // 50.00 USD = 5000 minor USD → 5000 minor HUF at 100/1.
    expect(moved.sharedIncomeOverride, 5000);
    final movedExpense = await h.isar.expenses
        .filter()
        .sharedSpaceIdEqualTo(spaceId)
        .and()
        .yearMonthEqualTo('2025-12')
        .findFirst();
    expect(movedExpense!.amount, 9999, reason: 'stored amount is untouched');
  });

  test('recycles a same-named directory row instead of duplicating it',
      () async {
    final seeded = await h.seedBudget(yearMonth: '2026-03');
    final profileId = seeded.profileId;
    final spaceId = await makeSpace(PrimaryCurrency.usd, createdBy: profileId);
    await addMember(spaceId, profileId, SharedMemberRole.owner);
    await claimPersonal(profileId, '2026-03');

    // The space already has a provider named the same as the personal one.
    late int spaceProviderId;
    await h.isar.writeTxn(() async {
      spaceProviderId = await h.isar.medicalProviders.put(
        MedicalProvider()
          ..sharedSpaceId = spaceId
          ..name = 'City Hospital',
      );
      final personalProviderId = await h.isar.medicalProviders.put(
        MedicalProvider()
          ..profileId = profileId
          ..name = 'City Hospital',
      );
      await h.isar.medicalBills.put(
        MedicalBill()
          ..profileId = profileId
          ..yearMonth = '2026-03'
          ..providerId = personalProviderId
          ..billedAmount = 1000
          ..currency = 'USD'
          ..serviceDate = DateTime(2026, 3, 1),
      );
    });

    await ops.moveMonth(
      ContextRef.personal(profileId: profileId, yearMonth: '2026-03'),
      ContextRef.shared(spaceId: spaceId, yearMonth: '2026-03'),
      '2026-03',
      actingProfileId: profileId,
    );

    final sharedProviders = await h.isar.medicalProviders
        .filter()
        .sharedSpaceIdEqualTo(spaceId)
        .findAll();
    expect(sharedProviders, hasLength(1),
        reason: 'the existing same-named provider is recycled, not duplicated');
    final movedBill = await h.isar.medicalBills
        .filter()
        .sharedSpaceIdEqualTo(spaceId)
        .and()
        .yearMonthEqualTo('2026-03')
        .findFirst();
    expect(movedBill!.providerId, spaceProviderId);
  });

  test('a viewer or non-member cannot move a month', () async {
    final seeded = await h.seedBudget(yearMonth: '2026-03');
    final profileId = seeded.profileId;
    final spaceId = await makeSpace(PrimaryCurrency.usd, createdBy: profileId);
    await addMember(spaceId, profileId, SharedMemberRole.viewer);

    expect(
      () => ops.moveMonth(
        ContextRef.personal(profileId: profileId, yearMonth: '2026-03'),
        ContextRef.shared(spaceId: spaceId, yearMonth: '2026-03'),
        '2026-03',
        actingProfileId: profileId,
      ),
      throwsA(isA<UnauthorizedSpaceAction>()),
    );

    expect(
        await monthIn(
            ContextRef.shared(spaceId: spaceId, yearMonth: '2026-03')),
        isNull,
        reason: 'nothing may be persisted when the guard refuses');
  });

  test('a non-member cannot move a month', () async {
    final seeded = await h.seedBudget(yearMonth: '2026-03');
    final profileId = seeded.profileId;
    final spaceId = await makeSpace(PrimaryCurrency.usd, createdBy: profileId);

    expect(
      () => ops.moveMonth(
        ContextRef.personal(profileId: profileId, yearMonth: '2026-03'),
        ContextRef.shared(spaceId: spaceId, yearMonth: '2026-03'),
        '2026-03',
        actingProfileId: profileId,
      ),
      throwsA(isA<UnauthorizedSpaceAction>()),
    );
  });
}
