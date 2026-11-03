import 'package:budget_buddy/core/models/allocation.dart';
import 'package:budget_buddy/core/models/audit_event.dart';
import 'package:budget_buddy/core/models/budget_profile.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/income_receipt_group.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/services/allocation_operations_service.dart';
import 'package:budget_buddy/core/services/continuous_balance_service.dart';
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
      await h.isar.monthlyBudgets.put(MonthlyBudget()
        ..profileId = 1
        ..yearMonth = '2026-10'
        ..baseAvailableAmount = 2000
        ..openingBalanceConfirmed = true
        ..createdAt = DateTime.utc(2026)
        ..updatedAt = DateTime.utc(2026));
      await h.isar.budgetProfiles.put(BudgetProfile()
        ..syncGuid = 'car'
        ..familyGuid = 'car'
        ..profileId = 1
        ..yearMonth = '2026-10'
        ..name = 'Car'
        ..allocation = 0
        ..spent = 0
        ..defaultAllocationMinor = 0
        ..createdAt = DateTime.utc(2026)
        ..updatedAt = DateTime.utc(2026));
    });
  });

  tearDown(() => h.close());

  AllocationOperationsService service() => AllocationOperationsService(h.isar,
      actorId: 1, clock: () => DateTime.utc(2026, 10, 20));

  Future<int> free() async => (await ContinuousBalanceService(h.isar,
              clock: () => DateTime.utc(2026, 10, 20))
          .balance(profileId: 1, yearMonth: '2026-10'))
      .freeToUseMinor;

  Future<BudgetProfile> profile() async => (await h.isar.budgetProfiles
      .filter()
      .syncGuidEqualTo('car')
      .findFirst())!;

  test('reserve lowers free-to-use and creates a signed delta without income',
      () async {
    final before = await free();
    await service().reserve(profileId: 1, yearMonth: '2026-10', amount: 100000);

    final row = await profile();
    expect(row.allocation, 100000);
    expect(await free(), before - 100000);
    final delta = (await h.isar.allocations.where().findFirst())!;
    expect(delta.amount, 100000);
    expect(delta.profileId, 1);
    expect(await h.isar.incomeReceiptGroups.count(), 0);
    expect(await h.isar.expenses.count(), 0);
  });

  test('release raises free-to-use and writes no income', () async {
    await service().reserve(profileId: 1, yearMonth: '2026-10', amount: 100000);
    final before = await free();
    await service().release(
        profileId: 1, yearMonth: '2026-10', amount: 50000, reason: 'Done');

    final row = await profile();
    expect(row.allocation, 50000);
    expect(await free(), before + 50000);
    expect(await h.isar.incomeReceiptGroups.count(), 0);
    final deltas = await h.isar.allocations.where().findAll();
    expect(deltas.map((d) => d.amount).toSet(), {100000, -50000});
  });

  test('reserve above free-to-use is rejected without writes', () async {
    await expectLater(
        service().reserve(profileId: 1, yearMonth: '2026-10', amount: 200001),
        throwsA(isA<AllocationException>()
            .having((e) => e.code, 'code', 'insufficientFreeFunds')));
    expect((await profile()).allocation, 0);
    expect(await h.isar.allocations.count(), 0);
  });

  test('release above the remaining envelope is rejected', () async {
    await service().reserve(profileId: 1, yearMonth: '2026-10', amount: 50000);
    await expectLater(
        service().release(profileId: 1, yearMonth: '2026-10', amount: 50001),
        throwsA(isA<AllocationException>()
            .having((e) => e.code, 'code', 'allocationTooLarge')));
    expect((await profile()).allocation, 50000);
    expect(await h.isar.allocations.count(), 1);
  });

  test('a repeated operation key is idempotent', () async {
    await service().reserve(
        profileId: 1,
        yearMonth: '2026-10',
        amount: 10000,
        operationKey: 'once');
    await service().reserve(
        profileId: 1,
        yearMonth: '2026-10',
        amount: 10000,
        operationKey: 'once');

    expect((await profile()).allocation, 10000);
    expect(await h.isar.allocations.count(), 1);
  });

  test('a signed correction keeps the original deltas and reason audit',
      () async {
    await service().reserve(profileId: 1, yearMonth: '2026-10', amount: 50000);
    await service().correct(
        profileId: 1,
        yearMonth: '2026-10',
        amount: -20000,
        reason: 'Wrong envelope',
        operationKey: 'fix');

    expect((await profile()).allocation, 30000);
    final deltas = await h.isar.allocations.where().findAll();
    expect(deltas.map((row) => row.amount).toSet(), {50000, -20000});
    final audit = await h.isar.auditEvents
        .filter()
        .actionEqualTo('allocation.correct')
        .findFirst();
    expect(audit, isNotNull);
    expect(audit!.newValue, contains('Wrong envelope'));
  });

  test('a correction below zero is rejected without writes', () async {
    await service().reserve(profileId: 1, yearMonth: '2026-10', amount: 10000);
    await expectLater(
        service().correct(
            profileId: 1,
            yearMonth: '2026-10',
            amount: -10001,
            reason: 'Too much'),
        throwsA(isA<AllocationException>()));
    expect((await profile()).allocation, 10000);
    expect(await h.isar.allocations.count(), 1);
  });
}
