import 'package:budget_buddy/core/models/allocation.dart';
import 'package:budget_buddy/core/models/budget_profile.dart';
import 'package:budget_buddy/core/models/month_end_run.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/services/month_carry_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import '../../features/medical/repositories/medical_test_harness.dart';

void main() {
  late MedicalTestHarness h;

  setUp(() async {
    h = await MedicalTestHarness.create();
    await h.isar.writeTxn(() async {
      await h.isar.userProfiles.put(UserProfile()
        ..id = 1
        ..name = 'Owner'
        ..primaryCurrency = PrimaryCurrency.usd
        ..monthlyAvailableAmount = 0
        ..createdAt = DateTime.utc(2026)
        ..updatedAt = DateTime.utc(2026));
    });
  });

  tearDown(() => h.close());

  Future<void> seedSource({
    int allocation = 100000,
    int spent = 20000,
    int? defaultAllocation = 20000,
    MonthEndRule rule = MonthEndRule.carryForward,
    String familyGuid = 'family-car',
    String month = '2026-10',
  }) =>
      h.isar.writeTxn(() async {
        await h.isar.budgetProfiles.put(BudgetProfile()
          ..syncGuid = 'source-$month'
          ..familyGuid = familyGuid
          ..defaultAllocationMinor = defaultAllocation
          ..profileId = 1
          ..yearMonth = month
          ..name = 'Car maintenance'
          ..allocation = allocation
          ..spent = spent
          ..monthEndRule = rule
          ..createdAt = DateTime.utc(2026)
          ..updatedAt = DateTime.utc(2026));
      });

  MonthCarryService service() =>
      MonthCarryService(h.isar, clock: () => DateTime.utc(2026, 11, 2));

  test('carryForward creates one destination with base + unused and a delta',
      () async {
    await seedSource();

    final created =
        await service().ensureCarry(profileId: 1, yearMonth: '2026-11');

    expect(created, 1);
    final destination = (await h.isar.budgetProfiles
        .filter()
        .yearMonthEqualTo('2026-11')
        .findFirst())!;
    expect(destination.familyGuid, 'family-car');
    expect(destination.name, 'Car maintenance');
    expect(destination.defaultAllocationMinor, 20000);
    expect(destination.allocation, 100000); // 20,000 base + 80,000 unused
    expect(destination.spent, 0);
    expect(destination.monthEndOriginGuid, 'auto-carry:2026-10:family-car');
    final delta = (await h.isar.allocations.where().findFirst())!;
    expect(delta.amount, 100000);
    expect(delta.yearMonth, '2026-11');
    expect(delta.syncGuid, 'auto-carry:${destination.syncGuid}');
  });

  test('reset uses the new default and carries nothing', () async {
    await seedSource(rule: MonthEndRule.reset, defaultAllocation: 30000);

    await service().ensureCarry(profileId: 1, yearMonth: '2026-11');

    final destination = (await h.isar.budgetProfiles
        .filter()
        .yearMonthEqualTo('2026-11')
        .findFirst())!;
    expect(destination.allocation, 30000);
    expect((await h.isar.allocations.where().findFirst())!.amount, 30000);
  });

  test('a second call is idempotent and empty families are skipped', () async {
    await seedSource();
    await seedSource(
        familyGuid: '', allocation: 50000, defaultAllocation: 50000);

    expect(await service().ensureCarry(profileId: 1, yearMonth: '2026-11'), 1);
    expect(await service().ensureCarry(profileId: 1, yearMonth: '2026-11'), 0);
    expect(
        await h.isar.budgetProfiles
            .filter()
            .yearMonthEqualTo('2026-11')
            .count(),
        1);
    expect(await h.isar.allocations.count(), 1);
  });

  test('a conflicting settlement blocks the carry without writes', () async {
    await seedSource();
    await h.isar.writeTxn(() async {
      await h.isar.monthEndRuns.put(MonthEndRun()
        ..syncGuid = 'run-conflict'
        ..profileId = 1
        ..contextGuid = 'personal:1'
        ..yearMonth = '2026-10'
        ..destinationMonth = '2026-11'
        ..currency = 'usd'
        ..reportJson = '{"lines":[]}'
        ..fingerprint = 'fp'
        ..actor = 'actor'
        ..createdAt = DateTime.utc(2026)
        ..hasConflict = true);
    });

    await expectLater(service().ensureCarry(profileId: 1, yearMonth: '2026-11'),
        throwsA(isA<MonthCarryException>()));
    expect(
        await h.isar.budgetProfiles
            .filter()
            .yearMonthEqualTo('2026-11')
            .count(),
        0);
    expect(await h.isar.allocations.count(), 0);
  });

  test('an existing destination family is never duplicated', () async {
    await seedSource();
    await h.isar.writeTxn(() async {
      await h.isar.budgetProfiles.put(BudgetProfile()
        ..syncGuid = 'already-there'
        ..familyGuid = 'family-car'
        ..profileId = 1
        ..yearMonth = '2026-11'
        ..name = 'Car maintenance'
        ..allocation = 100000
        ..createdAt = DateTime.utc(2026)
        ..updatedAt = DateTime.utc(2026));
    });

    expect(await service().ensureCarry(profileId: 1, yearMonth: '2026-11'), 0);
    expect(
        await h.isar.budgetProfiles
            .filter()
            .yearMonthEqualTo('2026-11')
            .count(),
        1);
    expect(await h.isar.allocations.count(), 0);
  });
}
