import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/insurance_profile.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import 'package:budget_buddy/features/spaces/models/bring_in_past.dart';
import 'package:budget_buddy/features/spaces/presentation/delete_space_sheet.dart';
import 'package:budget_buddy/features/spaces/repositories/month_move_operations.dart';
import 'package:budget_buddy/features/spaces/repositories/space_role_guard.dart';
import 'package:budget_buddy/features/spaces/repositories/spaces_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import '../medical/repositories/medical_test_harness.dart';

/// T060 — deleting a space without destroying history, and FR-011 provisioning.
///
/// The per-month resolution flow (move a month back, or delete it) and the final
/// typed-name confirmation only hold if the data layer really refuses to remove a
/// space that still owns money. These drive a real Isar instance.
void main() {
  late MedicalTestHarness h;
  late SpacesRepository repo;
  late MonthMoveOperations ops;

  setUp(() async {
    h = await MedicalTestHarness.create();
    ops = MonthMoveOperations(h.isar, rateRegistry: MedicalTestHarness.rates);
    repo = SpacesRepository(h.isar, monthMoves: ops);
  });

  tearDown(() => h.close());

  Future<int> seedProfile(String name) async {
    final profile = UserProfile()
      ..name = name
      ..primaryCurrency = PrimaryCurrency.usd
      ..monthlyAvailableAmount = 0
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);
    late int id;
    await h.isar.writeTxn(() async {
      id = await h.isar.userProfiles.put(profile);
    });
    return id;
  }

  Future<SharedSpace> seedSpace(int ownerId) async {
    final space = SharedSpace()
      ..name = 'Test space'
      ..avatar = 'X'
      ..currency = PrimaryCurrency.usd
      ..defaultIncome = 0
      ..createdByProfileId = ownerId
      ..createdAt = DateTime(2026);
    await h.isar.writeTxn(() async {
      space.id = await h.isar.sharedSpaces.put(space);
    });
    return space;
  }

  Future<void> seedMember(
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

  Future<MonthlyBudget> seedSharedMonth(int spaceId, String yearMonth) async {
    final budget = MonthlyBudget()
      ..yearMonth = yearMonth
      ..sharedSpaceId = spaceId
      ..baseAvailableAmount = 0
      ..currency = 'usd'
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);
    await h.isar.writeTxn(() async {
      budget.id = await h.isar.monthlyBudgets.put(budget);
    });
    return budget;
  }

  Future<MonthlyBudget> seedPersonalMonth(
      int profileId, String yearMonth) async {
    final budget = MonthlyBudget()
      ..profileId = profileId
      ..yearMonth = yearMonth
      ..baseAvailableAmount = 0
      ..currency = 'usd'
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);
    await h.isar.writeTxn(() async {
      budget.id = await h.isar.monthlyBudgets.put(budget);
    });
    return budget;
  }

  /// Seeds one expense + reimbursement + medical bill scoped to [spaceId]'s month.
  Future<void> seedMoney(
    int spaceId,
    String yearMonth,
    int budgetId,
  ) async {
    await h.isar.writeTxn(() async {
      final expenseId = await h.isar.expenses.put(
        Expense(
          profileId: 0,
          sharedSpaceId: spaceId,
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
          profileId: 0,
          sharedSpaceId: spaceId,
          expenseId: expenseId,
          originYearMonth: yearMonth,
          amount: 500,
          currency: 'USD',
          date: DateTime(2026, 3, 6),
        ),
      );
      await h.isar.medicalBills.put(
        MedicalBill()
          ..sharedSpaceId = spaceId
          ..yearMonth = yearMonth
          ..billedAmount = 1000
          ..currency = 'USD'
          ..serviceDate = DateTime(2026, 3, 7),
      );
    });
  }

  Future<int> countShared(int spaceId, String yearMonth) async {
    final budgets = await h.isar.monthlyBudgets
        .filter()
        .sharedSpaceIdEqualTo(spaceId)
        .and()
        .yearMonthEqualTo(yearMonth)
        .count();
    final expenses = await h.isar.expenses
        .filter()
        .sharedSpaceIdEqualTo(spaceId)
        .and()
        .yearMonthEqualTo(yearMonth)
        .count();
    final reimbursements = await h.isar.reimbursements
        .filter()
        .sharedSpaceIdEqualTo(spaceId)
        .and()
        .originYearMonthEqualTo(yearMonth)
        .count();
    final bills = await h.isar.medicalBills
        .filter()
        .sharedSpaceIdEqualTo(spaceId)
        .and()
        .yearMonthEqualTo(yearMonth)
        .count();
    return budgets + expenses + reimbursements + bills;
  }

  test('a newly created space owns no month when the creator has none',
      () async {
    final owner = await seedProfile('Owner');

    final space = await repo.createSpace(
      createdByProfileId: owner,
      name: 'Fresh',
      currency: PrimaryCurrency.usd,
      bringIn: BringInPast.thisMonth,
      now: DateTime(2026, 6, 15),
    );

    final owned = await h.isar.monthlyBudgets
        .filter()
        .sharedSpaceIdEqualTo(space.id)
        .count();
    expect(owned, 0,
        reason: 'a brand-new space must not own a month it never received');
  });

  test('the current month moves in only once the personal month exists',
      () async {
    final owner = await seedProfile('Owner');
    final space = await repo.createSpace(
      createdByProfileId: owner,
      name: 'Fresh',
      currency: PrimaryCurrency.usd,
      bringIn: BringInPast.thisMonth,
      now: DateTime(2026, 6, 15),
    );
    await seedPersonalMonth(owner, '2026-06');

    await ops.moveMonth(
      ContextRef.personal(profileId: owner, yearMonth: '2026-06'),
      ContextRef.shared(spaceId: space.id, yearMonth: '2026-06'),
      '2026-06',
      actingProfileId: owner,
    );

    expect(await countShared(space.id, '2026-06'), greaterThan(0));
    final personal = await h.isar.monthlyBudgets
        .filter()
        .profileIdEqualTo(owner)
        .and()
        .yearMonthEqualTo('2026-06')
        .count();
    expect(personal, 0, reason: 'move, never copy');
  });

  test('deleteMonth removes every money row of the month but keeps directory',
      () async {
    final owner = await seedProfile('Owner');
    final space = await seedSpace(owner);
    await seedMember(space.id, owner, SharedMemberRole.owner);
    final month = await seedSharedMonth(space.id, '2026-03');
    await seedMoney(space.id, '2026-03', month.id);

    late int providerId;
    await h.isar.writeTxn(() async {
      providerId = await h.isar.medicalProviders.put(
        MedicalProvider()
          ..sharedSpaceId = space.id
          ..name = 'City Hospital',
      );
    });

    await ops.deleteMonth(
      ContextRef.shared(spaceId: space.id, yearMonth: '2026-03'),
      '2026-03',
      actingProfileId: owner,
    );

    expect(await countShared(space.id, '2026-03'), 0,
        reason: 'the budget and all its money rows are gone');
    expect(await h.isar.medicalProviders.get(providerId), isNotNull,
        reason: 'context-level directory rows survive a month deletion');
  });

  test('a viewer or non-member cannot delete a month', () async {
    final owner = await seedProfile('Owner');
    final viewer = await seedProfile('Viewer');
    final stranger = await seedProfile('Stranger');
    final space = await seedSpace(owner);
    await seedMember(space.id, owner, SharedMemberRole.owner);
    await seedMember(space.id, viewer, SharedMemberRole.viewer);
    final month = await seedSharedMonth(space.id, '2026-03');
    await seedMoney(space.id, '2026-03', month.id);

    expect(
      () => ops.deleteMonth(
        ContextRef.shared(spaceId: space.id, yearMonth: '2026-03'),
        '2026-03',
        actingProfileId: viewer,
      ),
      throwsA(isA<UnauthorizedSpaceAction>()),
    );
    expect(
      () => ops.deleteMonth(
        ContextRef.shared(spaceId: space.id, yearMonth: '2026-03'),
        '2026-03',
        actingProfileId: stranger,
      ),
      throwsA(isA<UnauthorizedSpaceAction>()),
    );
    expect(await countShared(space.id, '2026-03'), 4,
        reason: 'nothing may be deleted when the guard refuses');
  });

  test('a personal month can only be deleted by its own profile', () async {
    final owner = await seedProfile('Owner');
    final other = await seedProfile('Other');
    await seedPersonalMonth(owner, '2026-03');

    expect(
      () => ops.deleteMonth(
        ContextRef.personal(profileId: owner, yearMonth: '2026-03'),
        '2026-03',
        actingProfileId: other,
      ),
      throwsA(isA<UnauthorizedSpaceAction>()),
    );

    await ops.deleteMonth(
      ContextRef.personal(profileId: owner, yearMonth: '2026-03'),
      '2026-03',
      actingProfileId: owner,
    );
    final remaining = await h.isar.monthlyBudgets
        .filter()
        .profileIdEqualTo(owner)
        .and()
        .yearMonthEqualTo('2026-03')
        .count();
    expect(remaining, 0);
  });

  test('resolving every month lets the owner delete the space', () async {
    final owner = await seedProfile('Owner');
    final space = await seedSpace(owner);
    await seedMember(space.id, owner, SharedMemberRole.owner);
    await seedSharedMonth(space.id, '2026-04');
    await seedSharedMonth(space.id, '2026-05');

    // A month deletion in the space is refused while money rows remain.
    expect(
      () => repo.deleteSpace(actingProfileId: owner, spaceId: space.id),
      throwsA(isA<UnauthorizedSpaceAction>()),
    );

    // Resolve: move April back to the owner, delete May.
    await ops.moveMonth(
      ContextRef.shared(spaceId: space.id, yearMonth: '2026-04'),
      ContextRef.personal(profileId: owner, yearMonth: '2026-04'),
      '2026-04',
      actingProfileId: owner,
    );
    await ops.deleteMonth(
      ContextRef.shared(spaceId: space.id, yearMonth: '2026-05'),
      '2026-05',
      actingProfileId: owner,
    );

    final owned = await h.isar.monthlyBudgets
        .filter()
        .sharedSpaceIdEqualTo(space.id)
        .count();
    expect(owned, 0);

    await repo.deleteSpace(actingProfileId: owner, spaceId: space.id);

    expect(await h.isar.sharedSpaces.get(space.id), isNull);
    expect(
        await h.isar.sharedMembers
            .filter()
            .sharedSpaceIdEqualTo(space.id)
            .count(),
        0);
    expect(await h.isar.userProfiles.get(owner), isNotNull,
        reason: 'deleting a space never deletes member profiles');
    expect(
        await h.isar.monthlyBudgets
            .filter()
            .profileIdEqualTo(owner)
            .and()
            .yearMonthEqualTo('2026-04')
            .count(),
        greaterThan(0),
        reason: 'the moved-back month is preserved on the personal profile');
  });

  test('an editor cannot delete the space (Owner-only)', () async {
    final owner = await seedProfile('Owner');
    final editor = await seedProfile('Editor');
    final space = await seedSpace(owner);
    await seedMember(space.id, owner, SharedMemberRole.owner);
    await seedMember(space.id, editor, SharedMemberRole.editor);

    expect(
      () => repo.deleteSpace(actingProfileId: editor, spaceId: space.id),
      throwsA(isA<UnauthorizedSpaceAction>()),
    );
    expect(await h.isar.sharedSpaces.get(space.id), isNotNull);
  });

  group('typed-name confirmation gates the button', () {
    testWidgets('Delete stays disabled until the name matches exactly',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TypedNameConfirmDialog(spaceName: 'Beach House'),
          ),
        ),
      );

      FilledButton button() => tester.widget<FilledButton>(
          find.byKey(const Key('confirmDeleteSpaceButton')));
      expect(button().onPressed, isNull, reason: 'empty input cannot delete');

      await tester.enterText(
          find.byKey(const Key('deleteSpaceNameField')), 'Beach');
      await tester.pump();
      expect(button().onPressed, isNull, reason: 'partial name cannot delete');

      await tester.enterText(
          find.byKey(const Key('deleteSpaceNameField')), 'Beach House');
      await tester.pump();
      expect(button().onPressed, isNotNull,
          reason: 'exact name unlocks the delete');
    });
  });
}
