import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/models/month_rate_seal.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import 'package:budget_buddy/features/expenses/repositories/expense_repository.dart';
import 'package:budget_buddy/features/expenses/repositories/reimbursement_repository.dart';
import 'package:budget_buddy/features/finance/repositories/month_finance_repository.dart';
import 'package:budget_buddy/features/medical/repositories/medical_repository.dart';
import 'package:budget_buddy/features/settings/presentation/profile_switcher_section.dart';
import 'package:budget_buddy/features/spaces/models/bring_in_past.dart';
import 'package:budget_buddy/features/spaces/repositories/month_move_operations.dart';
import 'package:budget_buddy/features/spaces/repositories/space_role_guard.dart';
import 'package:budget_buddy/features/spaces/repositories/space_write_guard.dart';
import 'package:budget_buddy/features/spaces/repositories/spaces_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import '../medical/repositories/medical_test_harness.dart';

/// T043 — the role enforcement matrix (contracts/space-roles, US4).
///
/// Three layers are checked so the guard is proven to be the single boundary:
///   1. the pure [SpaceAccessGuard] decision table (owner/editor/viewer/none);
///   2. the DB-backed [SpaceWriteGuard] that loads membership + month seal;
///   3. the real write paths (expense, reimbursement, medical bill, month
///      finance) all funnel through it and persist nothing when refused.
void main() {
  SpaceAccessGuard pureGuard() => const SpaceAccessGuard();

  SharedMember member(SharedMemberRole role) => SharedMember()
    ..sharedSpaceId = 1
    ..profileId = 1
    ..role = role
    ..joinedAt = DateTime(2026);

  group('SpaceAccessGuard decision table (FR-005)', () {
    test('view is any member; none cannot view', () {
      final g = pureGuard();
      expect(g.canView(member(SharedMemberRole.owner)), isTrue);
      expect(g.canView(member(SharedMemberRole.editor)), isTrue);
      expect(g.canView(member(SharedMemberRole.viewer)), isTrue);
      expect(g.canView(null), isFalse);
    });

    test('edit is owner or editor; viewer and none cannot edit', () {
      final g = pureGuard();
      expect(g.canEdit(member(SharedMemberRole.owner)), isTrue);
      expect(g.canEdit(member(SharedMemberRole.editor)), isTrue);
      expect(g.canEdit(member(SharedMemberRole.viewer)), isFalse);
      expect(g.canEdit(null), isFalse);
    });

    test('manage is owner only; editor, viewer and none cannot manage', () {
      final g = pureGuard();
      expect(g.canManage(member(SharedMemberRole.owner)), isTrue);
      expect(g.canManage(member(SharedMemberRole.editor)), isFalse);
      expect(g.canManage(member(SharedMemberRole.viewer)), isFalse);
      expect(g.canManage(null), isFalse);
    });

    test('a sealed month is refused for every role (I4, FR-012)', () {
      final g = pureGuard();
      for (final role in SharedMemberRole.values) {
        expect(
          () => g.assertMonthEditable(member(role), sealed: true),
          throwsA(isA<UnauthorizedSpaceAction>()),
          reason: 'even $role must be frozen out of a sealed month',
        );
      }
    });

    test('exactly-one-context is enforced (I5, FR-003)', () {
      final g = pureGuard();
      expect(
        () => g.assertExactlyOneContext(profileId: 1, sharedSpaceId: 2),
        throwsA(isA<UnauthorizedSpaceAction>()),
        reason: 'both contexts set is invalid',
      );
      expect(
        () => g.assertExactlyOneContext(profileId: null, sharedSpaceId: null),
        throwsA(isA<UnauthorizedSpaceAction>()),
        reason: 'neither context set is invalid',
      );
      expect(
        () => g.assertExactlyOneContext(profileId: 1, sharedSpaceId: null),
        returnsNormally,
      );
      expect(
        () => g.assertExactlyOneContext(profileId: null, sharedSpaceId: 2),
        returnsNormally,
      );
    });

    test('assertEdit/assertManage throw for the roles they exclude', () {
      final g = pureGuard();
      expect(
          () => g.assertEdit(member(SharedMemberRole.owner)), returnsNormally);
      expect(
          () => g.assertEdit(member(SharedMemberRole.editor)), returnsNormally);
      expect(() => g.assertEdit(member(SharedMemberRole.viewer)),
          throwsA(isA<UnauthorizedSpaceAction>()));
      expect(() => g.assertManage(member(SharedMemberRole.owner)),
          returnsNormally);
      expect(() => g.assertManage(member(SharedMemberRole.editor)),
          throwsA(isA<UnauthorizedSpaceAction>()));
    });
  });

  group('SpaceWriteGuard against the database', () {
    late MedicalTestHarness h;
    late SpaceWriteGuard writeGuard;

    setUp(() async {
      h = await MedicalTestHarness.create();
      writeGuard = SpaceWriteGuard(h.isar);
    });

    tearDown(() => h.close());

    Future<int> newProfile() async {
      final profile = UserProfile()
        ..name = 'P'
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

    Future<int> makeSpace(int ownerProfileId) async {
      final space = SharedSpace()
        ..name = 'Test space'
        ..avatar = 'X'
        ..currency = PrimaryCurrency.usd
        ..defaultIncome = 0
        ..createdByProfileId = ownerProfileId
        ..createdAt = DateTime(2026);
      await h.isar.writeTxn(() async {
        space.id = await h.isar.sharedSpaces.put(space);
      });
      return space.id;
    }

    Future<void> addMember(
        int spaceId, int profileId, SharedMemberRole role) async {
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

    test('owner and editor pass a shared money write; viewer fails', () async {
      final owner = await newProfile();
      final editor = await newProfile();
      final viewer = await newProfile();
      final spaceId = await makeSpace(owner);
      await addMember(spaceId, owner, SharedMemberRole.owner);
      await addMember(spaceId, editor, SharedMemberRole.editor);
      await addMember(spaceId, viewer, SharedMemberRole.viewer);

      for (final actor in [owner, editor]) {
        await expectLater(
          writeGuard.assertSharedMoneyWrite(
            sharedSpaceId: spaceId,
            actingProfileId: actor,
            yearMonth: '2026-03',
          ),
          completes,
        );
      }
      await expectLater(
        writeGuard.assertSharedMoneyWrite(
          sharedSpaceId: spaceId,
          actingProfileId: viewer,
          yearMonth: '2026-03',
        ),
        throwsA(isA<UnauthorizedSpaceAction>()),
      );
    });

    test('a non-member is refused', () async {
      final owner = await newProfile();
      final stranger = await newProfile();
      final spaceId = await makeSpace(owner);
      await addMember(spaceId, owner, SharedMemberRole.owner);

      await expectLater(
        writeGuard.assertSharedMoneyWrite(
          sharedSpaceId: spaceId,
          actingProfileId: stranger,
          yearMonth: '2026-03',
        ),
        throwsA(isA<UnauthorizedSpaceAction>()),
      );
    });

    test('a null acting profile is refused for a shared write', () async {
      final owner = await newProfile();
      final spaceId = await makeSpace(owner);
      await addMember(spaceId, owner, SharedMemberRole.owner);

      await expectLater(
        writeGuard.assertSharedMoneyWrite(
          sharedSpaceId: spaceId,
          actingProfileId: null,
          yearMonth: '2026-03',
        ),
        throwsA(isA<UnauthorizedSpaceAction>()),
      );
    });

    test('a sealed month is refused even for the owner (I4)', () async {
      final owner = await newProfile();
      final spaceId = await makeSpace(owner);
      await addMember(spaceId, owner, SharedMemberRole.owner);

      await h.isar.writeTxn(() async {
        await h.isar.monthRateSeals.put(
          MonthRateSeal()
            ..yearMonth = '2026-03'
            ..status = SealStatus.sealed
            ..asOf = DateTime.utc(2026, 3, 31)
            ..fetchedAt = DateTime.utc(2026, 3, 31)
            ..updatedAt = DateTime.utc(2026, 3, 31),
        );
      });

      expect(await writeGuard.monthIsSealed('2026-03'), isTrue);
      await expectLater(
        writeGuard.assertSharedMoneyWrite(
          sharedSpaceId: spaceId,
          actingProfileId: owner,
          yearMonth: '2026-03',
        ),
        throwsA(isA<UnauthorizedSpaceAction>()),
      );
    });

    test('a personal write (null space) passes through untouched', () async {
      await expectLater(
        writeGuard.assertSharedMoneyWrite(
          sharedSpaceId: null,
          actingProfileId: null,
          yearMonth: '2026-03',
        ),
        completes,
      );
    });

    test('manage requires the owner', () async {
      final owner = await newProfile();
      final editor = await newProfile();
      final spaceId = await makeSpace(owner);
      await addMember(spaceId, owner, SharedMemberRole.owner);
      await addMember(spaceId, editor, SharedMemberRole.editor);

      await expectLater(
        writeGuard.assertSharedManageWrite(
          sharedSpaceId: spaceId,
          actingProfileId: owner,
        ),
        completes,
      );
      await expectLater(
        writeGuard.assertSharedManageWrite(
          sharedSpaceId: spaceId,
          actingProfileId: editor,
        ),
        throwsA(isA<UnauthorizedSpaceAction>()),
      );
    });
  });

  group('real write paths funnel through the guard', () {
    late MedicalTestHarness h;

    setUp(() async {
      h = await MedicalTestHarness.create();
    });

    tearDown(() => h.close());

    Future<int> newProfile() async {
      final profile = UserProfile()
        ..name = 'P'
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

    Future<int> makeSpace(int ownerProfileId) async {
      final space = SharedSpace()
        ..name = 'Test space'
        ..avatar = 'X'
        ..currency = PrimaryCurrency.usd
        ..defaultIncome = 0
        ..createdByProfileId = ownerProfileId
        ..createdAt = DateTime(2026);
      await h.isar.writeTxn(() async {
        space.id = await h.isar.sharedSpaces.put(space);
      });
      return space.id;
    }

    Future<void> addMember(
        int spaceId, int profileId, SharedMemberRole role) async {
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

    Expense sharedExpense(int spaceId) => Expense(
          profileId: 0,
          sharedSpaceId: spaceId,
          yearMonth: '2026-03',
          title: 'Groceries',
          amount: 5000,
          currency: 'USD',
          categoryId: 'general',
          date: DateTime(2026, 3, 5),
          budgetId: 0,
        );

    test('ExpenseRepository refuses a viewer and persists nothing', () async {
      final owner = await newProfile();
      final spaceId = await makeSpace(owner);
      final viewer = await newProfile();
      await addMember(spaceId, owner, SharedMemberRole.owner);
      await addMember(spaceId, viewer, SharedMemberRole.viewer);

      final repo = ExpenseRepository(
        h.isar,
        guard: SpaceWriteGuard(h.isar),
        actingProfileId: viewer,
      );

      await expectLater(
        repo.addExpense(sharedExpense(spaceId)),
        throwsA(isA<UnauthorizedSpaceAction>()),
      );
      expect(await h.isar.expenses.count(), 0);

      final ownerRepo = ExpenseRepository(
        h.isar,
        guard: SpaceWriteGuard(h.isar),
        actingProfileId: owner,
      );
      await ownerRepo.addExpense(sharedExpense(spaceId));
      expect(await h.isar.expenses.count(), 1);
    });

    test('ReimbursementRepository refuses a viewer and persists nothing',
        () async {
      final owner = await newProfile();
      final spaceId = await makeSpace(owner);
      final viewer = await newProfile();
      await addMember(spaceId, owner, SharedMemberRole.owner);
      await addMember(spaceId, viewer, SharedMemberRole.viewer);

      final repo = ReimbursementRepository(
        h.isar,
        guard: SpaceWriteGuard(h.isar),
        actingProfileId: viewer,
      );

      await expectLater(
        repo.addReimbursement(
          Reimbursement(
            profileId: 0,
            sharedSpaceId: spaceId,
            originYearMonth: '2026-03',
            amount: 1000,
            currency: 'USD',
            date: DateTime(2026, 3, 6),
          ),
        ),
        throwsA(isA<UnauthorizedSpaceAction>()),
      );
      expect(await h.isar.reimbursements.count(), 0);
    });

    test('MedicalRepository.saveBill refuses a viewer and persists nothing',
        () async {
      final owner = await newProfile();
      final spaceId = await makeSpace(owner);
      final viewer = await newProfile();
      await addMember(spaceId, owner, SharedMemberRole.owner);
      await addMember(spaceId, viewer, SharedMemberRole.viewer);

      final context = MedicalBillContext(
        profileId: 0,
        sharedSpaceId: spaceId,
        budgetId: 0,
        yearMonth: '2026-03',
        primaryCurrency: 'USD',
        rateTable: MedicalTestHarness.rates.tableFor('2026-03'),
      );

      final repo = MedicalRepository(
        h.isar,
        rateRegistry: MedicalTestHarness.rates,
        guard: SpaceWriteGuard(h.isar),
        actingProfileId: viewer,
      );

      await expectLater(
        repo.saveBill(
          MedicalBill()
            ..profileId = null
            ..sharedSpaceId = spaceId
            ..yearMonth = '2026-03'
            ..billedAmount = 1000
            ..currency = 'USD'
            ..serviceDate = DateTime(2026, 3, 1),
          context,
        ),
        throwsA(isA<UnauthorizedSpaceAction>()),
      );
      expect(await h.isar.medicalBills.count(), 0);
      expect(await h.isar.expenses.count(), 0);
    });

    test('MonthFinanceRepository refuses a viewer on a shared month write',
        () async {
      final owner = await newProfile();
      final spaceId = await makeSpace(owner);
      final viewer = await newProfile();
      await addMember(spaceId, owner, SharedMemberRole.owner);
      await addMember(spaceId, viewer, SharedMemberRole.viewer);

      final repo = MonthFinanceRepository(
        h.isar,
        guard: SpaceWriteGuard(h.isar),
        actingProfileId: viewer,
      );

      final sharedMonth =
          ContextRef.shared(spaceId: spaceId, yearMonth: '2026-03');

      await expectLater(
        repo.saveOpeningBalanceInContext(sharedMonth, 100),
        throwsA(isA<UnauthorizedSpaceAction>()),
      );
      await expectLater(
        repo.saveConvertToInContext(sharedMonth, CurrencyCode.eur),
        throwsA(isA<UnauthorizedSpaceAction>()),
      );
      await expectLater(
        repo.saveOurIncomeOverrideInContext(sharedMonth, 250000),
        throwsA(isA<UnauthorizedSpaceAction>()),
      );

      // An owner may write the same month.
      final ownerRepo = MonthFinanceRepository(
        h.isar,
        guard: SpaceWriteGuard(h.isar),
        actingProfileId: owner,
      );
      await expectLater(
        ownerRepo.saveOpeningBalanceInContext(sharedMonth, 100),
        completes,
      );
    });

    test('a personal expense is never gated', () async {
      final profileId = await newProfile();
      final repo = ExpenseRepository(
        h.isar,
        guard: SpaceWriteGuard(h.isar),
        actingProfileId: profileId,
      );

      await expectLater(
        repo.addExpense(
          Expense(
            profileId: profileId,
            yearMonth: '2026-03',
            title: 'Personal',
            amount: 100,
            currency: 'USD',
            categoryId: 'general',
            date: DateTime(2026, 3, 5),
            budgetId: 0,
          ),
        ),
        completes,
      );
      expect(await h.isar.expenses.count(), 1);
    });
  });

  group('lifecycle moves and deletes funnel through the guard (T068)', () {
    late MedicalTestHarness h;
    late MonthMoveOperations ops;
    late SpacesRepository repo;

    setUp(() async {
      h = await MedicalTestHarness.create();
      ops = MonthMoveOperations(h.isar, rateRegistry: MedicalTestHarness.rates);
      repo = SpacesRepository(h.isar, monthMoves: ops);
    });

    tearDown(() => h.close());

    Future<int> newProfile() async {
      final profile = UserProfile()
        ..name = 'P'
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

    Future<int> makeSpace(int ownerProfileId) async {
      final space = SharedSpace()
        ..name = 'Test space'
        ..avatar = 'X'
        ..currency = PrimaryCurrency.usd
        ..defaultIncome = 0
        ..createdByProfileId = ownerProfileId
        ..createdAt = DateTime(2026);
      await h.isar.writeTxn(() async {
        space.id = await h.isar.sharedSpaces.put(space);
      });
      return space.id;
    }

    Future<void> addMember(
        int spaceId, int profileId, SharedMemberRole role) async {
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

    Future<void> seedPersonal(int profileId, String yearMonth) async {
      await h.isar.writeTxn(() async {
        await h.isar.monthlyBudgets.put(
          MonthlyBudget()
            ..profileId = profileId
            ..yearMonth = yearMonth
            ..baseAvailableAmount = 0
            ..currency = 'usd'
            ..createdAt = DateTime(2026)
            ..updatedAt = DateTime(2026),
        );
      });
    }

    Future<void> seedShared(int spaceId, String yearMonth) async {
      await h.isar.writeTxn(() async {
        await h.isar.monthlyBudgets.put(
          MonthlyBudget()
            ..sharedSpaceId = spaceId
            ..yearMonth = yearMonth
            ..baseAvailableAmount = 0
            ..currency = 'usd'
            ..createdAt = DateTime(2026)
            ..updatedAt = DateTime(2026),
        );
      });
    }

    test('an editor may move a month in; a viewer and non-member may not',
        () async {
      final owner = await newProfile();
      final editor = await newProfile();
      final viewer = await newProfile();
      final stranger = await newProfile();
      final spaceId = await makeSpace(owner);
      await addMember(spaceId, owner, SharedMemberRole.owner);
      await addMember(spaceId, editor, SharedMemberRole.editor);
      await addMember(spaceId, viewer, SharedMemberRole.viewer);

      await seedPersonal(viewer, '2026-03');
      await expectLater(
        ops.moveMonth(
          ContextRef.personal(profileId: viewer, yearMonth: '2026-03'),
          ContextRef.shared(spaceId: spaceId, yearMonth: '2026-03'),
          '2026-03',
          actingProfileId: viewer,
        ),
        throwsA(isA<UnauthorizedSpaceAction>()),
      );

      await expectLater(
        ops.moveMonth(
          ContextRef.personal(profileId: stranger, yearMonth: '2026-03'),
          ContextRef.shared(spaceId: spaceId, yearMonth: '2026-03'),
          '2026-03',
          actingProfileId: stranger,
        ),
        throwsA(isA<UnauthorizedSpaceAction>()),
      );

      await seedPersonal(editor, '2026-03');
      await expectLater(
        ops.moveMonth(
          ContextRef.personal(profileId: editor, yearMonth: '2026-03'),
          ContextRef.shared(spaceId: spaceId, yearMonth: '2026-03'),
          '2026-03',
          actingProfileId: editor,
        ),
        completes,
      );
    });

    test('only the owner may delete a shared month', () async {
      final owner = await newProfile();
      final editor = await newProfile();
      final viewer = await newProfile();
      final spaceId = await makeSpace(owner);
      await addMember(spaceId, owner, SharedMemberRole.owner);
      await addMember(spaceId, editor, SharedMemberRole.editor);
      await addMember(spaceId, viewer, SharedMemberRole.viewer);
      await seedShared(spaceId, '2026-03');

      for (final actor in [editor, viewer]) {
        await expectLater(
          ops.deleteMonth(
            ContextRef.shared(spaceId: spaceId, yearMonth: '2026-03'),
            '2026-03',
            actingProfileId: actor,
          ),
          throwsA(isA<UnauthorizedSpaceAction>()),
          reason: '$actor may not delete, only manage',
        );
      }

      await expectLater(
        ops.deleteMonth(
          ContextRef.shared(spaceId: spaceId, yearMonth: '2026-03'),
          '2026-03',
          actingProfileId: owner,
        ),
        completes,
      );
    });

    test('only the owner may delete the space', () async {
      final owner = await newProfile();
      final editor = await newProfile();
      final spaceId = await makeSpace(owner);
      await addMember(spaceId, owner, SharedMemberRole.owner);
      await addMember(spaceId, editor, SharedMemberRole.editor);

      await expectLater(
        repo.deleteSpace(actingProfileId: editor, spaceId: spaceId),
        throwsA(isA<UnauthorizedSpaceAction>()),
      );
      await expectLater(
        repo.deleteSpace(actingProfileId: owner, spaceId: spaceId),
        completes,
      );
    });

    test('creation makes the creator the Owner and owns only real months',
        () async {
      final creator = await newProfile();
      final space = await repo.createSpace(
        createdByProfileId: creator,
        name: 'Fresh',
        currency: PrimaryCurrency.usd,
        bringIn: BringInPast.thisMonth,
        now: DateTime(2026, 6, 15),
      );

      final member = await h.isar.sharedMembers
          .filter()
          .sharedSpaceIdEqualTo(space.id)
          .profileIdEqualTo(creator)
          .findFirst();
      expect(member!.role, SharedMemberRole.owner);
      expect(
          await h.isar.monthlyBudgets
              .filter()
              .sharedSpaceIdEqualTo(space.id)
              .count(),
          0,
          reason: 'no personal current month existed, so none is invented');
    });
  });

  group('profile deletion keeps a space owned (T075)', () {
    late MedicalTestHarness h;
    late ProfileSwitcherController controller;

    setUp(() async {
      h = await MedicalTestHarness.create();
      controller = ProfileSwitcherController(h.isar);
    });

    tearDown(() => h.close());

    Future<int> newProfile() async {
      final profile = UserProfile()
        ..name = 'P'
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

    Future<int> makeSpace(int ownerProfileId) async {
      final space = SharedSpace()
        ..name = 'Home'
        ..avatar = 'X'
        ..currency = PrimaryCurrency.usd
        ..defaultIncome = 0
        ..createdByProfileId = ownerProfileId
        ..createdAt = DateTime(2026);
      await h.isar.writeTxn(() async {
        space.id = await h.isar.sharedSpaces.put(space);
      });
      return space.id;
    }

    Future<void> addMember(
        int spaceId, int profileId, SharedMemberRole role) async {
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

    test('cannot delete a profile that is a space\'s only Owner', () async {
      final owner = await newProfile();
      final editor = await newProfile();
      final spaceId = await makeSpace(owner);
      await addMember(spaceId, owner, SharedMemberRole.owner);
      await addMember(spaceId, editor, SharedMemberRole.editor);

      await expectLater(
        controller.deleteProfile(owner, activeProfileId: editor),
        throwsA(isA<ProfileDeletionBlocked>()),
      );

      expect(await h.isar.userProfiles.get(owner), isNotNull);
      expect(await h.isar.sharedSpaces.get(spaceId), isNotNull);
      expect(
          await h.isar.sharedMembers.filter().profileIdEqualTo(owner).count(),
          1);
    });

    test('deleting a member removes only their membership, never the space',
        () async {
      final owner = await newProfile();
      final editor = await newProfile();
      final spaceId = await makeSpace(owner);
      await addMember(spaceId, owner, SharedMemberRole.owner);
      await addMember(spaceId, editor, SharedMemberRole.editor);

      await controller.deleteProfile(editor, activeProfileId: owner);

      expect(await h.isar.userProfiles.get(editor), isNull);
      expect(await h.isar.sharedSpaces.get(spaceId), isNotNull);
      expect(
          await h.isar.sharedMembers.filter().profileIdEqualTo(editor).count(),
          0);
      expect(
          await h.isar.sharedMembers.filter().profileIdEqualTo(owner).count(),
          1);
    });
  });
}
