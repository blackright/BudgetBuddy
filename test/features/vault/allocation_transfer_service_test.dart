import 'package:budget_buddy/core/models/allocation.dart';
import 'package:budget_buddy/core/models/budget_profile.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/income_receipt_group.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/services/continuous_balance_service.dart';
import 'package:budget_buddy/features/vault/allocation_transfer_service.dart';
import 'package:budget_buddy/features/vault/models/savings_vault.dart';
import 'package:budget_buddy/features/vault/models/vault_entry.dart';
import 'package:budget_buddy/features/vault/vault_transfer_ledger.dart';
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
        ..allocation = 100000
        ..spent = 0
        ..defaultAllocationMinor = 100000
        ..createdAt = DateTime.utc(2026)
        ..updatedAt = DateTime.utc(2026));
    });
  });

  tearDown(() => h.close());

  AllocationTransferService service() => AllocationTransferService(h.isar,
      actorId: 1,
      clock: () => DateTime.utc(2026, 10, 20),
      isAccessCurrent: () => true);

  Future<int> free() async => (await ContinuousBalanceService(h.isar,
          clock: () => DateTime.utc(2026, 10, 20))
      .balance(profileId: 1, yearMonth: '2026-10'))
      .freeToUseMinor;

  test('move to Vault keeps free-to-use unchanged and raises the Vault',
      () async {
    final before = await free();
    final entry = await service().moveToVault(
        profileId: 1,
        yearMonth: '2026-10',
        amount: 50000,
        operationKey: 'move',
        note: 'Car savings');

    final profile = (await h.isar.budgetProfiles
            .filter()
            .syncGuidEqualTo('car')
            .findFirst())!;
    final vault = (await h.isar.savingsVaults.where().findFirst())!;
    expect(profile.allocation, 50000);
    expect(vault.totalMinor, 50000);
    expect(entry.kind, 'deposit');
    expect(entry.amountMinor, 50000);
    expect(await free(), before);
    expect(await h.isar.incomeReceiptGroups.count(), 0);
    expect(await h.isar.expenses.count(), 0);
    final delta = (await h.isar.allocations.where().findFirst())!;
    expect(delta.amount, -50000);
    expect(transferDetails(entry)!['sourceAllocationGuid'], 'car');
  });

  test('amount above remaining rolls the whole move back', () async {
    await expectLater(
        service().moveToVault(
            profileId: 1,
            yearMonth: '2026-10',
            amount: 100001,
            operationKey: 'too-much'),
        throwsA(isA<AllocationTransferException>()));
    expect(
        (await h.isar.budgetProfiles.filter().syncGuidEqualTo('car').findFirst())!
            .allocation,
        100000);
    expect(await h.isar.allocations.count(), 0);
    expect(await h.isar.savingsVaults.count(), 0);
  });

  test('a Vault validation failure rolls the allocation back', () async {
    await h.isar.writeTxn(() async {
      await h.isar.savingsVaults.put(SavingsVault()
        ..profileId = 1
        ..totalMinor = 0
        ..currency = 'eur'
        ..lastSweepYearMonth = '2026-10'
        ..updatedAt = DateTime.utc(2026));
    });

    await expectLater(
        service().moveToVault(
            profileId: 1,
            yearMonth: '2026-10',
            amount: 50000,
            operationKey: 'currency'),
        throwsA(isA<AllocationTransferException>()));
    expect(
        (await h.isar.budgetProfiles.filter().syncGuidEqualTo('car').findFirst())!
            .allocation,
        100000);
    expect(await h.isar.allocations.count(), 0);
    expect((await h.isar.savingsVaults.where().findFirst())!.totalMinor, 0);
  });

  test('the same operation key is idempotent', () async {
    await service().moveToVault(
        profileId: 1,
        yearMonth: '2026-10',
        amount: 50000,
        operationKey: 'once');
    await service().moveToVault(
        profileId: 1,
        yearMonth: '2026-10',
        amount: 50000,
        operationKey: 'once');

    expect(
        (await h.isar.budgetProfiles.filter().syncGuidEqualTo('car').findFirst())!
            .allocation,
        50000);
    expect(await h.isar.vaultEntrys.filter().kindEqualTo('deposit').count(), 1);
    expect(await h.isar.allocations.count(), 1);
  });
}
