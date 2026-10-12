import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/features/spaces/models/bring_in_past.dart';
import 'package:budget_buddy/features/spaces/repositories/month_move_operations.dart';
import 'package:budget_buddy/features/spaces/repositories/spaces_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import '../medical/repositories/medical_test_harness.dart';

/// T061 — the "bring in past months" choice at space creation (FR-005/010, US5).
///
/// The choice must re-home the creator's eligible **existing** personal months
/// into the new space and never invent months that do not exist. These drive a
/// real Isar instance through the create transaction.
void main() {
  late MedicalTestHarness h;
  late SpacesRepository repo;

  setUp(() async {
    h = await MedicalTestHarness.create();
    repo = SpacesRepository(
      h.isar,
      monthMoves:
          MonthMoveOperations(h.isar, rateRegistry: MedicalTestHarness.rates),
    );
  });

  tearDown(() => h.close());

  Future<int> seedProfile() async {
    final profile = UserProfile()
      ..name = 'Creator'
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

  Future<void> seedPersonal(int profileId, String yearMonth) async {
    final budget = MonthlyBudget()
      ..profileId = profileId
      ..yearMonth = yearMonth
      ..baseAvailableAmount = 0
      ..currency = 'usd'
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);
    await h.isar.writeTxn(() async {
      await h.isar.monthlyBudgets.put(budget);
    });
  }

  Future<List<String>> personalMonths(int profileId) async {
    final rows = await h.isar.monthlyBudgets
        .filter()
        .profileIdEqualTo(profileId)
        .findAll();
    return (rows.map((b) => b.yearMonth).toList())..sort();
  }

  Future<List<String>> sharedMonths(int spaceId) async {
    final rows = await h.isar.monthlyBudgets
        .filter()
        .sharedSpaceIdEqualTo(spaceId)
        .findAll();
    return (rows.map((b) => b.yearMonth).toList())..sort();
  }

  test('bringIn thisMonth moves only the creator\'s current personal month',
      () async {
    final creator = await seedProfile();
    await seedPersonal(creator, '2026-05');
    await seedPersonal(creator, '2026-06');
    await seedPersonal(creator, '2025-12');

    final space = await repo.createSpace(
      createdByProfileId: creator,
      name: 'This month',
      currency: PrimaryCurrency.usd,
      bringIn: BringInPast.thisMonth,
      now: DateTime(2026, 6, 15),
    );

    expect(await sharedMonths(space.id), ['2026-06']);
    expect(await personalMonths(creator), ['2025-12', '2026-05']);
  });

  test('bringIn thisYear moves every personal month of the current year',
      () async {
    final creator = await seedProfile();
    await seedPersonal(creator, '2026-01');
    await seedPersonal(creator, '2026-06');
    await seedPersonal(creator, '2025-12');

    final space = await repo.createSpace(
      createdByProfileId: creator,
      name: 'This year',
      currency: PrimaryCurrency.usd,
      bringIn: BringInPast.thisYear,
      now: DateTime(2026, 6, 15),
    );

    expect(await sharedMonths(space.id), ['2026-01', '2026-06']);
    expect(await personalMonths(creator), ['2025-12'],
        reason: 'last year is left behind');
  });

  test('bringIn everything moves all of the creator\'s personal months',
      () async {
    final creator = await seedProfile();
    await seedPersonal(creator, '2025-12');
    await seedPersonal(creator, '2026-01');
    await seedPersonal(creator, '2026-06');

    final space = await repo.createSpace(
      createdByProfileId: creator,
      name: 'Everything',
      currency: PrimaryCurrency.usd,
      bringIn: BringInPast.everything,
      now: DateTime(2026, 6, 15),
    );

    expect(await sharedMonths(space.id), ['2025-12', '2026-01', '2026-06']);
    expect(await personalMonths(creator), isEmpty);
  });

  test('a missing current month is skipped, not invented', () async {
    final creator = await seedProfile();
    await seedPersonal(creator, '2026-05');

    final space = await repo.createSpace(
      createdByProfileId: creator,
      name: 'Skipped',
      currency: PrimaryCurrency.usd,
      bringIn: BringInPast.thisMonth,
      now: DateTime(2026, 6, 15),
    );

    expect(await sharedMonths(space.id), isEmpty,
        reason: 'the space must not fabricate a current month');
    expect(await personalMonths(creator), ['2026-05']);
  });

  test('bringIn with no months at all leaves a brand-new empty space',
      () async {
    final creator = await seedProfile();

    final space = await repo.createSpace(
      createdByProfileId: creator,
      name: 'Empty',
      currency: PrimaryCurrency.usd,
      bringIn: BringInPast.everything,
      now: DateTime(2026, 6, 15),
    );

    expect(await sharedMonths(space.id), isEmpty);
  });
}
