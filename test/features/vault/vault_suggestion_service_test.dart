import 'package:isar/isar.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/pending_action.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/pending_actions/services/pending_action_service.dart';
import 'package:budget_buddy/features/vault/models/savings_vault.dart';
import 'package:budget_buddy/features/vault/models/vault_entry.dart';
import 'package:budget_buddy/features/vault/vault_suggestion_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../medical/repositories/medical_test_harness.dart';

void main() {
  late MedicalTestHarness harness;
  late UserProfile profile;

  setUp(() async {
    harness = await MedicalTestHarness.create();
    profile = UserProfile()
      ..id = 1
      ..name = 'Me'
      ..primaryCurrency = PrimaryCurrency.usd
      ..monthlyAvailableAmount = 100000
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);
    await harness.isar.writeTxn(() async {
      await harness.isar.userProfiles.put(profile);
    });
  });

  tearDown(() => harness.close());

  PendingActionService actionService() => PendingActionService(
        harness.isar,
        profileId: 1,
        clock: () => DateTime(2026, 10, 23),
      );

  VaultSuggestionService service({DateTime? now}) => VaultSuggestionService(
        harness.isar,
        profileId: 1,
        registry: RateTableRegistry(),
        actions: actionService(),
        clock: () => now ?? DateTime(2026, 10, 23),
      );

  Future<void> seedMonth(String yearMonth,
      {bool confirmed = true, double opening = 100}) async {
    await harness.isar.writeTxn(() async {
      await harness.isar.monthlyBudgets.put(MonthlyBudget()
        ..profileId = 1
        ..yearMonth = yearMonth
        ..baseAvailableAmount = opening
        ..netSalaryOverride = opening
        ..currency = 'usd'
        ..openingBalanceConfirmed = confirmed
        ..createdAt = DateTime(2026)
        ..updatedAt = DateTime(2026));
    });
  }

  Future<void> seedVault({String lastSweep = ''}) async {
    await harness.isar.writeTxn(() async {
      await harness.isar.savingsVaults.put(SavingsVault()
        ..profileId = 1
        ..totalMinor = 0
        ..currency = 'usd'
        ..lastSweepYearMonth = lastSweep
        ..updatedAt = DateTime(2026));
    });
  }

  Future<void> seedSweep(String yearMonth) async {
    await harness.isar.writeTxn(() async {
      await harness.isar.vaultEntrys.put(VaultEntry()
        ..operationKey = 'vault:1:sweep:$yearMonth'
        ..profileId = 1
        ..kind = 'sweep'
        ..yearMonth = yearMonth
        ..amountMinor = 0
        ..currency = 'usd'
        ..balanceAfterMinor = 0
        ..createdAt = DateTime(2026, 10, 1)
        ..breakdownJson = '{}');
    });
  }

  Future<void> seedDeposit(
    String key, {
    required int amountMinor,
    required String yearMonth,
    String? targetMonth,
    String currency = 'usd',
    int vaultBefore = 0,
  }) async {
    await harness.isar.writeTxn(() async {
      await harness.isar.vaultEntrys.put(VaultEntry()
        ..operationKey = key
        ..profileId = 1
        ..kind = 'deposit'
        ..yearMonth = yearMonth
        ..amountMinor = amountMinor
        ..currency = currency
        ..balanceAfterMinor = vaultBefore + amountMinor
        ..createdAt = DateTime(2026, 10, 1)
        ..breakdownJson = _depositJson(
          amountMinor: amountMinor,
          yearMonth: yearMonth,
          currency: currency,
          vaultBefore: vaultBefore,
          targetMonth: targetMonth,
        ));
    });
  }

  Future<void> seedReversal(String key, VaultEntry original) async {
    final amount = original.amountMinor;
    await harness.isar.writeTxn(() async {
      await harness.isar.vaultEntrys.put(VaultEntry()
        ..operationKey = key
        ..profileId = 1
        ..kind = 'reversal'
        ..yearMonth = original.yearMonth
        ..amountMinor = -amount
        ..currency = original.currency
        ..balanceAfterMinor = original.balanceAfterMinor - amount
        ..createdAt = DateTime(2026, 10, 2)
        ..breakdownJson = '{"version":1,'
            '"vaultDelta":${-amount},"monthDelta":$amount,'
            '"month":"${original.yearMonth}","currency":"${original.currency}",'
            '"vaultBefore":${original.balanceAfterMinor},'
            '"bankBefore":${-amount},"bankAfter":0,'
            '"reserveBefore":${-amount},"reserveAfter":0,'
            '"note":"Undo","reverses":"${original.operationKey}"}');
    });
  }

  test('creates one suggestion per finished positive month and moves nothing',
      () async {
    await seedMonth('2026-08', opening: 100);
    await seedMonth('2026-09', opening: 250);

    final result = await service().check();

    expect(result.created, 2);
    expect(result.suggested, 2);
    expect(result.skipped, isEmpty);
    expect(result.message, contains('2 finished months'));
    final actions = await harness.isar.pendingActions.where().findAll();
    expect(actions, hasLength(2));
    final september =
        actions.singleWhere((a) => a.expectedMonth == '2026-09');
    expect(september.actionType, vaultDepositSuggestedType);
    expect(september.recordRef, '1:2026-09');
    expect(september.dedupeKey, 'vault.depositSuggested|1:2026-09|2026-09');
    expect(september.expectedAmountMinor, 25000);
    expect(september.currency, 'usd');
    expect(september.status, 'pending');
    expect(september.deepLink, '/vault');

    // Discovery only: the Vault and its ledger are untouched.
    expect(await harness.isar.vaultEntrys.count(), 0);
    expect(await harness.isar.savingsVaults.count(), 0);
  });

  test('the current and future months are never suggested', () async {
    await seedMonth('2026-10');
    await seedMonth('2026-11');

    final result = await service().check();

    expect(result.created, 0);
    expect(await harness.isar.pendingActions.count(), 0);
  });

  test('repeated checks keep one row and preserve read state', () async {
    await seedMonth('2026-09');
    final first = await service().check();
    expect(first.created, 1);
    final row = (await harness.isar.pendingActions.where().findAll()).single;
    await actionService().markRead(row.guid);

    final second = await service().check();

    expect(second.created, 0);
    expect(second.suggested, 1);
    final again = (await harness.isar.pendingActions.where().findAll()).single;
    expect(again.id, row.id);
    expect(again.guid, row.guid);
    expect(again.notificationReadAt, isNotNull);
  });

  test('unconfirmed, zero and negative finished months create no suggestion',
      () async {
    await seedMonth('2026-07', confirmed: false, opening: 100);
    await seedMonth('2026-08', opening: 0);
    await seedMonth('2026-09', opening: 0);

    final result = await service().check();

    expect(result.created, 0);
    expect(await harness.isar.pendingActions.count(), 0);
  });

  test('an existing legacy sweep suppresses only its own month', () async {
    await seedMonth('2026-08');
    await seedMonth('2026-09');
    await seedVault(lastSweep: '2026-08');
    await seedSweep('2026-09');

    final result = await service().check();

    expect(result.created, 1);
    final row = (await harness.isar.pendingActions.where().findAll()).single;
    // `lastSweepYearMonth` never suppresses; only real saved history does.
    expect(row.expectedMonth, '2026-08');
  });

  test('planned withdrawals are derived from deposits with a target month',
      () async {
    await seedDeposit('dep-late', amountMinor: 3000, yearMonth: '2026-09',
        targetMonth: '2027-01', vaultBefore: 0);
    await seedDeposit('dep-next', amountMinor: 2000, yearMonth: '2026-09',
        targetMonth: '2026-12', vaultBefore: 3000);
    await seedDeposit('dep-due', amountMinor: 1000, yearMonth: '2026-09',
        targetMonth: '2026-10', vaultBefore: 5000);
    await seedDeposit('dep-none', amountMinor: 500, yearMonth: '2026-09',
        vaultBefore: 6000);

    final history = await harness.isar.vaultEntrys.where().findAll();
    final planned =
        plannedWithdrawalsFrom(history: history, actions: const []);

    expect(planned.map((p) => p.deposit.operationKey).toList(),
        ['dep-due', 'dep-next', 'dep-late']);
    expect(planned.map((p) => p.targetMonth).toList(),
        ['2026-10', '2026-12', '2027-01']);
    expect(planned.first.isDue('2026-10'), isTrue);
    expect(planned.last.isDue('2026-10'), isFalse);
  });

  test('a reversed deposit and a completed withdrawal action stop the reminder',
      () async {
    await seedDeposit('keep', amountMinor: 3000, yearMonth: '2026-09',
        targetMonth: '2027-01');
    await seedDeposit('reversed', amountMinor: 2000, yearMonth: '2026-09',
        targetMonth: '2026-11', vaultBefore: 3000);
    final reversed = (await harness.isar.vaultEntrys
            .filter()
            .operationKeyEqualTo('reversed')
            .findFirst())!;
    await seedReversal('undo', reversed);
    await seedDeposit('withdrawn', amountMinor: 1000, yearMonth: '2026-09',
        targetMonth: '2026-10', vaultBefore: 5000);
    await harness.isar.writeTxn(() async {
      await harness.isar.pendingActions.put(PendingAction()
        ..profileId = 1
        ..actionType = vaultWithdrawalDueType
        ..title = 'Withdrawal due'
        ..nextAction = 'Withdraw'
        ..feature = 'vault'
        ..recordRef = 'withdrawn'
        ..expectedMonth = '2026-10'
        ..status = 'completed'
        ..dedupeKey = 'vault.withdrawalDue|withdrawn|2026-10'
        ..createdAt = DateTime(2026)
        ..updatedAt = DateTime(2026));
    });

    final history = await harness.isar.vaultEntrys.where().findAll();
    final actions = await harness.isar.pendingActions.where().findAll();
    final planned =
        plannedWithdrawalsFrom(history: history, actions: actions);

    expect(planned.map((p) => p.deposit.operationKey).toList(), ['keep']);
  });

  test('active suggestions are sorted by month and exclude terminal actions',
      () {
    PendingAction row(String month, String status) => PendingAction()
      ..profileId = 1
      ..actionType = vaultDepositSuggestedType
      ..title = 'Money left in $month'
      ..nextAction = 'Review'
      ..feature = 'vault'
      ..recordRef = '1:$month'
      ..expectedMonth = month
      ..status = status
      ..dedupeKey = 'vault.depositSuggested|1:$month|$month'
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);

    final active = activeVaultDepositSuggestions([
      row('2026-09', 'pending'),
      row('2026-07', 'due'),
      row('2026-08', 'completed'),
      row('2026-10', 'dismissed'),
    ]);

    expect(active.map((a) => a.expectedMonth).toList(), ['2026-07', '2026-09']);
  });
}

String _depositJson({
  required int amountMinor,
  required String yearMonth,
  required String currency,
  required int vaultBefore,
  String? targetMonth,
}) =>
    '{"version":1,'
    '"vaultDelta":$amountMinor,"monthDelta":${-amountMinor},'
    '"month":"$yearMonth","currency":"$currency",'
    '"vaultBefore":$vaultBefore,'
    '"bankBefore":0,"bankAfter":${-amountMinor},'
    '"reserveBefore":0,"reserveAfter":${-amountMinor},'
    '"note":"",'
    '"targetWithdrawalMonth":${targetMonth == null ? 'null' : '"$targetMonth"'}}';
