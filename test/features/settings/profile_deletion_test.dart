import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/insurance_profile.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/models/medical_service_type.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import 'package:budget_buddy/features/settings/presentation/profile_switcher_section.dart';
import 'package:budget_buddy/features/vault/models/savings_vault.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import '../medical/repositories/medical_test_harness.dart';

/// T070 — deleting a personal profile cascades its own money and memberships
/// in one transaction, never touching shared rows or other profiles (FR-019).
///
/// The cascade only holds if every profile-scoped collection really drops the
/// target's rows, so these drive a real Isar instance.
void main() {
  late MedicalTestHarness h;
  late ProfileSwitcherController controller;

  setUp(() async {
    h = await MedicalTestHarness.create();
    controller = ProfileSwitcherController(h.isar);
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

  Future<int> seedSpace(int ownerId) async {
    final space = SharedSpace()
      ..name = 'Home'
      ..avatar = '🏠'
      ..currency = PrimaryCurrency.usd
      ..defaultIncome = 0
      ..createdByProfileId = ownerId
      ..createdAt = DateTime(2026);
    late int id;
    await h.isar.writeTxn(() async {
      id = await h.isar.sharedSpaces.put(space);
    });
    return id;
  }

  Future<void> seedMember(
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

  /// Seeds one of every personal collection for [profileId].
  Future<void> seedPersonalWorld(int profileId) async {
    final budget = MonthlyBudget()
      ..profileId = profileId
      ..yearMonth = '2026-03'
      ..baseAvailableAmount = 100
      ..currency = 'usd'
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);
    await h.isar.writeTxn(() async {
      final budgetId = await h.isar.monthlyBudgets.put(budget);
      final expenseId = await h.isar.expenses.put(
        Expense(
          profileId: profileId,
          yearMonth: '2026-03',
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
          expenseId: expenseId,
          originYearMonth: '2026-03',
          amount: 500,
          currency: 'USD',
          date: DateTime(2026, 3, 6),
        ),
      );
      await h.isar.savingsVaults.put(
        SavingsVault()
          ..profileId = profileId
          ..totalAmount = 42
          ..lastSweepYearMonth = '2026-03',
      );
      await h.isar.medicalBills.put(
        MedicalBill()
          ..profileId = profileId
          ..yearMonth = '2026-03'
          ..billedAmount = 1000
          ..currency = 'USD'
          ..serviceDate = DateTime(2026, 3, 7),
      );
      await h.isar.insuranceProfiles.put(
        InsuranceProfile()..profileId = profileId,
      );
      await h.isar.familyMembers.put(
        FamilyMember()
          ..profileId = profileId
          ..name = 'Self'
          ..relation = 'Self',
      );
      await h.isar.medicalProviders.put(
        MedicalProvider()
          ..profileId = profileId
          ..name = 'Dr. Smith',
      );
      await h.isar.medicalServiceTypes.put(
        MedicalServiceType()
          ..profileId = profileId
          ..name = 'Radiology',
      );
    });
  }

  /// Seeds one of every shared collection for [spaceId].
  Future<void> seedSharedWorld(int spaceId) async {
    final budget = MonthlyBudget()
      ..sharedSpaceId = spaceId
      ..yearMonth = '2026-03'
      ..baseAvailableAmount = 100
      ..currency = 'usd'
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);
    await h.isar.writeTxn(() async {
      final budgetId = await h.isar.monthlyBudgets.put(budget);
      final expenseId = await h.isar.expenses.put(
        Expense(
          profileId: 0,
          sharedSpaceId: spaceId,
          yearMonth: '2026-03',
          title: 'Home rent',
          amount: 999,
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
          originYearMonth: '2026-03',
          amount: 100,
          currency: 'USD',
          date: DateTime(2026, 3, 6),
        ),
      );
      await h.isar.medicalBills.put(
        MedicalBill()
          ..sharedSpaceId = spaceId
          ..yearMonth = '2026-03'
          ..billedAmount = 2000
          ..currency = 'USD'
          ..serviceDate = DateTime(2026, 3, 7),
      );
    });
  }

  test('deletes every personal row of the target and its memberships',
      () async {
    final target = await seedProfile('Bea');
    final keep = await seedProfile('Ava');
    final spaceId = await seedSpace(keep);
    await seedMember(spaceId, keep, SharedMemberRole.owner);
    await seedMember(spaceId, target, SharedMemberRole.editor);
    await seedPersonalWorld(target);

    final result =
        await controller.deleteProfile(target, activeProfileId: keep);

    expect(result.wasActive, isFalse);
    expect(await h.isar.userProfiles.get(target), isNull);
    expect(
        await h.isar.monthlyBudgets.filter().profileIdEqualTo(target).count(),
        0);
    expect(await h.isar.expenses.filter().profileIdEqualTo(target).count(), 0);
    expect(
        await h.isar.reimbursements.filter().profileIdEqualTo(target).count(),
        0);
    expect(await h.isar.savingsVaults.filter().profileIdEqualTo(target).count(),
        0);
    expect(
        await h.isar.medicalBills.filter().profileIdEqualTo(target).count(), 0);
    expect(
        await h.isar.insuranceProfiles
            .filter()
            .profileIdEqualTo(target)
            .count(),
        0);
    expect(await h.isar.familyMembers.filter().profileIdEqualTo(target).count(),
        0);
    expect(
        await h.isar.medicalProviders.filter().profileIdEqualTo(target).count(),
        0);
    expect(
        await h.isar.medicalServiceTypes
            .filter()
            .profileIdEqualTo(target)
            .count(),
        0);
    expect(await h.isar.sharedMembers.filter().profileIdEqualTo(target).count(),
        0);

    // The other profile and its space membership survive.
    expect(await h.isar.userProfiles.get(keep), isNotNull);
    expect(
        await h.isar.sharedMembers.filter().profileIdEqualTo(keep).count(), 1);
  });

  test('shared rows and other profiles are never touched', () async {
    final target = await seedProfile('Bea');
    final keep = await seedProfile('Ava');
    final spaceId = await seedSpace(keep);
    await seedMember(spaceId, keep, SharedMemberRole.owner);
    await seedMember(spaceId, target, SharedMemberRole.editor);
    await seedPersonalWorld(target);
    await seedPersonalWorld(keep);
    await seedSharedWorld(spaceId);

    await controller.deleteProfile(target, activeProfileId: target);

    // Shared money belongs to the space, not the member: it all survives.
    expect(
        await h.isar.monthlyBudgets
            .filter()
            .sharedSpaceIdEqualTo(spaceId)
            .count(),
        1);
    expect(await h.isar.expenses.filter().sharedSpaceIdEqualTo(spaceId).count(),
        1);
    expect(
        await h.isar.reimbursements
            .filter()
            .sharedSpaceIdEqualTo(spaceId)
            .count(),
        1);
    expect(
        await h.isar.medicalBills
            .filter()
            .sharedSpaceIdEqualTo(spaceId)
            .count(),
        1);
    expect(await h.isar.sharedSpaces.get(spaceId), isNotNull);

    // The other personal profile's money survives untouched.
    expect(
        await h.isar.monthlyBudgets.filter().profileIdEqualTo(keep).count(), 1);
    expect(await h.isar.expenses.filter().profileIdEqualTo(keep).count(), 1);
    expect(
        await h.isar.savingsVaults.filter().profileIdEqualTo(keep).count(), 1);
  });

  test('refuses to delete the last remaining profile', () async {
    final only = await seedProfile('Solo');
    await seedPersonalWorld(only);

    await expectLater(
      controller.deleteProfile(only, activeProfileId: only),
      throwsA(isA<ProfileDeletionBlocked>()),
    );

    expect(await h.isar.userProfiles.get(only), isNotNull);
    expect(await h.isar.expenses.filter().profileIdEqualTo(only).count(), 1,
        reason: 'a refused delete must write nothing');
  });

  test('refuses to delete the sole Owner of a space, naming it', () async {
    final owner = await seedProfile('Owner');
    final other = await seedProfile('Other');
    final spaceId = await seedSpace(owner);
    await seedMember(spaceId, owner, SharedMemberRole.owner);
    await seedPersonalWorld(owner);

    await expectLater(
      controller.deleteProfile(owner, activeProfileId: other),
      throwsA(
        isA<ProfileDeletionBlocked>().having(
          (e) => e.message,
          'message',
          contains('Home'),
        ),
      ),
    );

    expect(await h.isar.userProfiles.get(owner), isNotNull);
    expect(await h.isar.sharedSpaces.get(spaceId), isNotNull);
    expect(await h.isar.expenses.filter().profileIdEqualTo(owner).count(), 1,
        reason: 'blocked deletion writes nothing');
  });

  test('an Owner with a co-Owner can be deleted', () async {
    final ownerA = await seedProfile('OwnerA');
    final ownerB = await seedProfile('OwnerB');
    final spaceId = await seedSpace(ownerA);
    await seedMember(spaceId, ownerA, SharedMemberRole.owner);
    await seedMember(spaceId, ownerB, SharedMemberRole.owner);

    final result =
        await controller.deleteProfile(ownerA, activeProfileId: ownerB);

    expect(await h.isar.userProfiles.get(ownerA), isNull);
    expect(result.fallbackProfileId, ownerB);
    expect(await h.isar.sharedSpaces.get(spaceId), isNotNull);
    expect(await h.isar.sharedMembers.filter().profileIdEqualTo(ownerB).count(),
        1);
  });

  test('reports the fallback profile when the active profile is deleted',
      () async {
    final target = await seedProfile('Bea');
    final keep = await seedProfile('Ava');

    final result =
        await controller.deleteProfile(target, activeProfileId: target);

    expect(result.wasActive, isTrue);
    expect(result.fallbackProfileId, keep,
        reason: 'the app falls back to the lowest-id survivor');
  });

  test('summarizeProfile counts only the target profile\'s rows', () async {
    final target = await seedProfile('Bea');
    final keep = await seedProfile('Ava');
    await seedPersonalWorld(target);
    await seedPersonalWorld(keep);

    final summary = await controller.summarizeProfile(target);

    expect(summary.expenses, 1);
    expect(summary.medicalBills, 1);
    expect(summary.reimbursements, 1);
    expect(summary.hasVault, isTrue);
    expect(summary.describe(), contains('1 expense'));
    expect(summary.describe(), contains('a savings vault'));
  });
}
