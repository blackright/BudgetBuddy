// ignore_for_file: deprecated_member_use_from_same_package
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:budget_buddy/core/database/money_integrity.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/features/vault/models/savings_vault.dart';
import 'package:budget_buddy/features/vault/models/vault_entry.dart';
import 'package:budget_buddy/features/vault/vault_recovery_service.dart';
import '../medical/repositories/medical_test_harness.dart';

void main() {
  late MedicalTestHarness h;
  final now = DateTime(2026, 10, 23);
  setUp(() async {
    h = await MedicalTestHarness.create();
    await h.isar.writeTxn(() async {
      await h.isar.userProfiles.put(UserProfile()
        ..id = 1
        ..name = 'Me'
        ..primaryCurrency = PrimaryCurrency.huf
        ..monthlyAvailableAmount = 0
        ..createdAt = now
        ..updatedAt = now);
      await h.isar.savingsVaults.put(SavingsVault()
        ..profileId = 1
        ..totalMinor = corruptedMinorSentinel
        ..currency = 'huf'
        ..lastSweepYearMonth = '2026-10'
        ..updatedAt = now
        ..sweepPaused = true);
      await h.isar.vaultEntrys.put(VaultEntry()
        ..operationKey = 'vault:1:opening'
        ..profileId = 1
        ..kind = 'opening'
        ..amountMinor = corruptedMinorSentinel
        ..balanceAfterMinor = corruptedMinorSentinel
        ..currency = 'huf'
        ..createdAt = now);
      for (final month in ['2026-08', '2026-09', '2026-10', '2026-11']) {
        await h.isar.monthlyBudgets.put(MonthlyBudget()
          ..profileId = 1
          ..yearMonth = month
          ..baseAvailableAmount = 0
          ..openingBalanceConfirmed = true
          ..createdAt = now
          ..updatedAt = now);
      }
      await h.isar.monthlyBudgets.put(MonthlyBudget()
        ..sharedSpaceId = 7
        ..yearMonth = '2026-09'
        ..baseAvailableAmount = 1000000
        ..openingBalanceConfirmed = true
        ..createdAt = now
        ..updatedAt = now);
      await h.isar.expenses.put(Expense(
          profileId: 1,
          yearMonth: '2026-10',
          title: 'Current payment',
          amount: 27000,
          currency: 'huf',
          categoryId: 'general',
          status: ExpenseStatus.paid,
          date: now,
          budgetId: 1));
    });
  });
  tearDown(() => h.close());
  VaultRecoveryService service(
          {bool Function()? active, Future<void> Function()? failure}) =>
      VaultRecoveryService(h.isar,
          actorId: 1,
          isStillActive: active ?? () => true,
          clock: () => now,
          beforeCommit: failure);

  test(
      'preview is read-only; confirm repairs only the two invalid fields and preserves evidence',
      () async {
    final s = service();
    final preview = await s.preview();
    expect(preview.months, ['2026-08', '2026-09']);
    expect((await h.isar.savingsVaults.where().findAll()).single.totalMinor,
        corruptedMinorSentinel);
    await s.confirm(preview);
    final vault = (await h.isar.savingsVaults.where().findAll()).single;
    final entry = (await h.isar.vaultEntrys.where().findAll()).single;
    expect(vault.totalMinor, 0);
    expect(vault.lastSweepYearMonth, '2026-10');
    expect(vault.sweepPaused, isFalse);
    expect(entry.amountMinor, 0);
    expect(entry.balanceAfterMinor, 0);
    final evidence = jsonDecode(entry.breakdownJson)['recovery'];
    expect(
        evidence['originalVault']['minor'], corruptedMinorSentinel.toString());
    expect(
        evidence['originalEntry']['minor'], corruptedMinorSentinel.toString());
    expect(evidence['sourceMonths'], preview.months);
    expect(await vaultHistoryProblem(h.isar, vault), isNull);
    expect((await h.isar.expenses.where().findAll()).single.amount, 27000);
    expect(
        (await h.isar.monthlyBudgets
                .filter()
                .sharedSpaceIdEqualTo(7)
                .findFirst())!
            .baseAvailableAmount,
        1000000);
    expect(await h.isar.monthlyBudgets.count(), 5);
    await expectLater(
        s.confirm(preview), throwsA(isA<VaultRecoveryException>()));
  });

  test('new past financial activity blocks the zero repair', () async {
    final s = service();
    final p = await s.preview();
    await h.isar.writeTxn(() async {
      await h.isar.expenses.put(Expense(
          profileId: 1,
          yearMonth: '2026-09',
          title: 'Past payment',
          amount: 1,
          currency: 'huf',
          categoryId: 'general',
          status: ExpenseStatus.paid,
          date: now,
          budgetId: 1));
    });
    await expectLater(s.confirm(p), throwsA(isA<VaultRecoveryException>()));
    expect((await h.isar.savingsVaults.where().findAll()).single.totalMinor,
        corruptedMinorSentinel);
  });

  test('a changed opening balance or history requires fresh review', () async {
    final s = service();
    final p = await s.preview();
    await h.isar.writeTxn(() async {
      final e = (await h.isar.vaultEntrys.where().findAll()).single;
      e.reason = 'New evidence';
      await h.isar.vaultEntrys.put(e);
    });
    await expectLater(s.confirm(p), throwsA(isA<VaultRecoveryException>()));
    final p2 = await s.preview();
    await h.isar.writeTxn(() async {
      final m = (await h.isar.monthlyBudgets
              .filter()
              .yearMonthEqualTo('2026-09')
              .sharedSpaceIdIsNull()
              .findAll())
          .single;
      m.baseAvailableAmount = 1;
      await h.isar.monthlyBudgets.put(m);
    });
    await expectLater(s.confirm(p2), throwsA(isA<VaultRecoveryException>()));
  });

  test('injected failure rolls back repaired history and balance together',
      () async {
    final s = service(failure: () async {
      throw StateError('write failed');
    });
    final p = await s.preview();
    await expectLater(s.confirm(p), throwsStateError);
    expect((await h.isar.savingsVaults.where().findAll()).single.totalMinor,
        corruptedMinorSentinel);
    final e = (await h.isar.vaultEntrys.where().findAll()).single;
    expect(e.amountMinor, corruptedMinorSentinel);
    expect(e.breakdownJson, '{}');
  });

  test('active owner is rechecked before commit; a switch rolls back both rows',
      () async {
    var active = true;
    final s = service(
        active: () => active,
        failure: () async {
          active = false;
        });
    final p = await s.preview();
    await expectLater(s.confirm(p), throwsA(isA<VaultRecoveryException>()));
    expect((await h.isar.vaultEntrys.where().findAll()).single.amountMinor,
        corruptedMinorSentinel);
    await expectLater(service(active: () => false).preview(),
        throwsA(isA<VaultRecoveryException>()));
  });

  test('simultaneous confirmations apply once', () async {
    final s = service();
    final p = await s.preview();
    Future<bool> attempt() async {
      try {
        await s.confirm(p);
        return true;
      } on VaultRecoveryException {
        return false;
      }
    }

    expect(
        (await Future.wait([attempt(), attempt()])).where((v) => v).length, 1);
    expect(await h.isar.vaultEntrys.count(), 1);
  });
}
