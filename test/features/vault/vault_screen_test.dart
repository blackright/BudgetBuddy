import 'dart:async';
import 'dart:convert';
import 'package:budget_buddy/core/database/isar_helper.dart';
import 'package:budget_buddy/core/database/money_integrity.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/features/dashboard/presentation/widgets/savings_vault_card.dart';
import 'package:budget_buddy/features/engine/providers/sweep_provider.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/vault/models/savings_vault.dart';
import 'package:budget_buddy/features/vault/models/vault_entry.dart';
import 'package:budget_buddy/features/vault/presentation/vault_screen.dart';
import 'package:budget_buddy/features/vault/providers/vault_providers.dart';
import 'package:budget_buddy/features/vault/repositories/vault_repository.dart';
import 'package:budget_buddy/features/vault/vault_recovery_service.dart';
import 'package:budget_buddy/features/vault/vault_transfer_service.dart';
import 'package:budget_buddy/features/vault/presentation/vault_transfer_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:isar/isar.dart';
import '../medical/repositories/medical_test_harness.dart';

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump();
    await Future<void>.delayed(const Duration(milliseconds: 25));
  }
  await tester.pumpAndSettle();
}

void main() {
  late MedicalTestHarness h;
  late UserProfile profile;
  late SavingsVault vault;
  setUp(() async {
    h = await MedicalTestHarness.create();
    IsarHelper.instance = h.isar;
    profile = UserProfile()
      ..id = 1
      ..name = 'Me'
      ..primaryCurrency = PrimaryCurrency.huf
      ..monthlyAvailableAmount = 0
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);
    vault = SavingsVault()
      ..profileId = 1
      ..totalMinor = 1000000
      ..currency = 'huf'
      ..lastSweepYearMonth = '2026-10'
      ..updatedAt = DateTime(2026, 10, 23);
    await h.isar.writeTxn(() async {
      await h.isar.userProfiles.put(profile);
      await h.isar.savingsVaults.put(vault);
      await seedVaultOpeningInTxn(h.isar, vault, DateTime(2026, 10, 23));
    });
  });
  tearDown(() => h.close());

  Future<void> waitForTransfer(WidgetTester tester, int count) async {
    for (var attempt = 0; attempt < 30; attempt++) {
      await settle(tester);
      if (await h.isar.vaultEntrys.count() == count &&
          find.byType(VaultTransferDialog).evaluate().isEmpty) {
        return;
      }
    }
    fail(
        'The transfer did not finish: ${tester.widgetList<Text>(find.byType(Text)).map((t) => t.data).join('\n')}');
  }

  Future<void> open(WidgetTester tester, {bool shared = false}) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final container = ProviderContainer(overrides: [
      vaultClockProvider.overrideWithValue(() => DateTime(2026, 10, 23)),
      activeProfileProvider.overrideWith((ref) => Stream.value(profile)),
      budgetContextProvider.overrideWithValue(shared
          ? ContextRef.shared(spaceId: 2, yearMonth: '2026-10')
          : ContextRef.personal(profileId: 1, yearMonth: '2026-10')),
      sweepServiceProvider.overrideWith(
          (ref) => SweepService(ref, clock: () => DateTime(2026, 10, 23))),
      vaultRecoveryServiceProvider.overrideWith((ref) => VaultRecoveryService(
          h.isar,
          actorId: 1,
          isStillActive: () => !shared,
          clock: () => DateTime(2026, 10, 23))),
      vaultTransferServiceProvider.overrideWith((ref) => VaultTransferService(
          h.isar,
          actorId: 1,
          isStillActive: () => !shared,
          rates: () => ref.read(rateRegistryProvider),
          clock: () => DateTime(2026, 10, 23))),
    ]);
    addTearDown(container.dispose);
    await container.read(activeProfileProvider.future);
    await container.read(vaultProvider.future);
    await container.read(vaultHistoryProvider.future);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: container, child: const MaterialApp(home: VaultScreen())));
    await settle(tester);
  }

  testWidgets(
      'phone transfer preview, cancel, confirm and reversal retain history',
      (tester) async {
    await tester.runAsync(() async {
      profile.defaultNetSalary = 100000;
      await h.isar.writeTxn(() async {
        await h.isar.userProfiles.put(profile);
        await h.isar.monthlyBudgets.put(MonthlyBudget()
          ..profileId = 1
          ..yearMonth = '2026-10'
          ..baseAvailableAmount = 100000
          ..openingBalanceConfirmed = true
          ..createdAt = DateTime(2026)
          ..updatedAt = DateTime(2026));
      });
      await open(tester);
      expect(find.text('Maximum deposit: Ft 100,000'), findsOneWidget,
          reason: tester
              .widgetList<Text>(find.byType(Text))
              .map((t) => t.data)
              .join('\n'));
      await tester.ensureVisible(find.text('Deposit'));
      await tester.pump();
      await tester.tap(find.text('Deposit'));
      await settle(tester);
      await tester.enterText(
          find.byKey(const Key('vaultTransferAmount')), '10000');
      expect(
          tester
              .widget<TextField>(find.byKey(const Key('vaultTransferAmount')))
              .controller!
              .text,
          '10,000');
      await tester.tap(find.text('Review transfer'));
      await settle(tester);
      expect(
          find.text('Savings: Ft 1,000,000 -> Ft 1,010,000'), findsOneWidget);
      expect(find.text('Monthly bank funds: Ft 200,000 -> Ft 190,000'),
          findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await settle(tester);
      expect((await VaultRepository(h.isar).getVault(1))!.totalMinor, 1000000);
      await tester.tap(find.text('Deposit'));
      await settle(tester);
      await tester.enterText(
          find.byKey(const Key('vaultTransferAmount')), '10000');
      await tester.enterText(
          find.byKey(const Key('vaultTransferNote')), 'Emergency saving');
      await tester.tap(find.text('Review transfer'));
      await settle(tester);
      await tester.tap(find.text('Confirm transfer'));
      await waitForTransfer(tester, 2);
      expect((await VaultRepository(h.isar).getVault(1))!.totalMinor, 1010000);
      expect(find.text('Maximum deposit: Ft 90,000'), findsOneWidget);
      await tester.ensureVisible(find.text('Deposit - + Ft 10,000'));
      await tester.pump();
      await tester.tap(find.text('Deposit - + Ft 10,000'));
      await settle(tester);
      await tester.ensureVisible(find.text('Reverse full transfer'));
      await tester.pump();
      await tester.tap(find.text('Reverse full transfer'));
      await settle(tester);
      await tester.tap(find.text('Review transfer'));
      await settle(tester);
      expect(find.textContaining('requires the original transfer and a reason'),
          findsOneWidget);
      await tester.enterText(
          find.byKey(const Key('vaultTransferNote')), 'Entered by mistake');
      await tester.tap(find.text('Review transfer'));
      await settle(tester);
      await tester.tap(find.text('Confirm transfer'));
      await waitForTransfer(tester, 3);
      expect((await VaultRepository(h.isar).getVault(1))!.totalMinor, 1000000);
      expect(await h.isar.vaultEntrys.count(), 3);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets(
      'optional target month shows guidance and can be removed without moving money',
      (tester) async {
    await tester.runAsync(() async {
      await VaultRepository(h.isar).saveGoal(
          profileId: 1,
          actorId: 1,
          expectedCurrency: 'huf',
          name: 'Emergency',
          targetMinor: 2000000,
          targetYearMonth: '2027-06',
          clock: () => DateTime(2026, 10, 23));
      await open(tester);
      expect(find.text('Suggested per month: Ft 111,112'), findsOneWidget);
      expect(
          find.text('9 saving months, including this month'), findsOneWidget);
      await tester.ensureVisible(find.text('Edit savings goal'));
      await tester.pump();
      await tester.tap(find.text('Edit savings goal'));
      await settle(tester);
      await tester.ensureVisible(find.text('Remove target month'));
      await tester.pump();
      await tester.tap(find.text('Remove target month'));
      await tester.tap(find.text('Save goal'));
      await settle(tester);
      var saved = (await VaultRepository(h.isar).getVault(1))!;
      expect(saved.goalTargetYearMonth, isNull);
      expect(saved.goalTargetMinor, 2000000);
      expect(saved.totalMinor, 1000000);
      await tester.ensureVisible(find.text('Edit savings goal'));
      await tester.pump();
      await tester.tap(find.text('Edit savings goal'));
      await settle(tester);
      await tester.tap(find.byKey(const Key('goalMonth')));
      await settle(tester);
      await tester.tap(find.text('OK'));
      await settle(tester);
      await tester.tap(find.text('Save goal'));
      await settle(tester);
      saved = (await VaultRepository(h.isar).getVault(1))!;
      expect(saved.goalTargetYearMonth, '2026-10');
      expect(saved.totalMinor, 1000000);
      expect(find.text('Suggested per month: Ft 1,000,000'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets(
      'phone goal validation, grouped input and metadata save preserve savings',
      (tester) async {
    await tester.runAsync(() async {
      await open(tester);
      await tester.ensureVisible(find.text('Add savings goal'));
      await tester.pump();
      await tester.tap(find.text('Add savings goal'));
      await settle(tester);
      await tester.tap(find.text('Save goal'));
      await settle(tester);
      expect(find.textContaining('positive target'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('goalName')), 'Emergency');
      await tester.enterText(find.byKey(const Key('goalTarget')), '2000000');
      expect(
          tester
              .widget<TextField>(find.byKey(const Key('goalTarget')))
              .controller!
              .text,
          '2,000,000');
      await tester.tap(find.text('Save goal'));
      await settle(tester);
      final saved = await VaultRepository(h.isar).getVault(1);
      expect(saved!.goalTargetMinor, 2000000);
      expect(saved.totalMinor, 1000000);
      expect(await h.isar.vaultEntrys.count(), 1);
      expect(find.text('Remaining: Ft 1,000,000'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Edit savings goal'));
      await tester.pump();
      await tester.tap(find.text('Edit savings goal'));
      await settle(tester);
      await tester.tap(find.text('Remove goal'));
      await settle(tester);
      expect((await VaultRepository(h.isar).getVault(1))!.goalName, isNull);
      expect((await VaultRepository(h.isar).getVault(1))!.totalMinor, 1000000);
    });
  });

  testWidgets('reached goal remains editable and check reports unchanged',
      (tester) async {
    await tester.runAsync(() async {
      await VaultRepository(h.isar).saveGoal(
          profileId: 1,
          actorId: 1,
          expectedCurrency: 'huf',
          name: 'Reached',
          targetMinor: 1000000);
      await open(tester);
      await tester.ensureVisible(find.text('Check for finished months'));
      await tester.pump();
      await tester.tap(find.text('Check for finished months'));
      await settle(tester);
      expect(find.textContaining('UNCHANGED:'), findsOneWidget);
      expect(find.text('Goal reached'), findsOneWidget);
      expect(find.text('Edit savings goal'), findsOneWidget);
      await tester.ensureVisible(find.text('Edit savings goal'));
      await tester.pump();
      await tester.tap(find.text('Edit savings goal'));
      await settle(tester);
      await tester.enterText(find.byKey(const Key('goalName')), 'Unsaved');
      await tester.tap(find.text('Cancel'));
      await settle(tester);
      expect((await VaultRepository(h.isar).getVault(1))!.goalName, 'Reached');
    });
  });

  testWidgets('history explains zero-saved months and immutable calculation',
      (tester) async {
    await tester.runAsync(() async {
      await h.isar.writeTxn(() async {
        await h.isar.vaultEntrys.put(VaultEntry()
          ..operationKey = 'zero'
          ..profileId = 1
          ..kind = 'sweep'
          ..yearMonth = '2026-09'
          ..amountMinor = 0
          ..currency = 'huf'
          ..balanceAfterMinor = 1000000
          ..createdAt = DateTime(2026, 10, 24)
          ..reason = 'No positive funds remained.'
          ..breakdownJson = jsonEncode({
            'currency': 'huf',
            'opening': 100,
            'spent': 100,
            'returned': 0,
            'carry': 0,
            'available': 0
          }));
      });
      await open(tester);
      await tester.scrollUntilVisible(find.text('2026-09 • Saved Ft 0'), 180);
      await tester.ensureVisible(find.text('2026-09 • Saved Ft 0'));
      await tester.pump();
      await tester.tap(find.text('2026-09 • Saved Ft 0'));
      await settle(tester);
      expect(find.text('Spending: Ft 100'), findsOneWidget);
      expect(find.text('No positive funds remained.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('shared context blocks screen and hides dashboard card',
      (tester) async {
    await tester.runAsync(() async {
      await open(tester, shared: true);
      expect(find.text('The Savings Vault is personal'), findsOneWidget);
      expect(find.text('Check for finished months'), findsNothing);
      await tester.pumpWidget(ProviderScope(overrides: [
        budgetContextProvider.overrideWithValue(
            ContextRef.shared(spaceId: 2, yearMonth: '2026-10')),
      ], child: const MaterialApp(home: Scaffold(body: SavingsVaultCard()))));
      await settle(tester);
      expect(find.textContaining('across months'), findsNothing);
    });
  });

  testWidgets('dashboard card navigates to vault and labels lifetime balance',
      (tester) async {
    await tester.runAsync(() async {
      final router = GoRouter(routes: [
        GoRoute(
            path: '/',
            builder: (_, __) => const Scaffold(body: SavingsVaultCard())),
        GoRoute(path: '/vault', builder: (_, __) => const VaultScreen()),
      ]);
      addTearDown(router.dispose);
      await tester.pumpWidget(ProviderScope(overrides: [
        activeProfileProvider.overrideWith((ref) => Stream.value(profile)),
        budgetContextProvider.overrideWithValue(
            ContextRef.personal(profileId: 1, yearMonth: '2026-10')),
      ], child: MaterialApp.router(routerConfig: router)));
      await settle(tester);
      expect(find.text('Ft 1,000,000'), findsOneWidget);
      await tester.tap(find.text('Savings Vault • across months'));
      await settle(tester);
      expect(find.byType(VaultScreen), findsOneWidget);
    });
  });

  testWidgets('loading and failure never display an invented zero balance',
      (tester) async {
    await tester.runAsync(() async {
      final stream = StreamController<SavingsVault?>();
      addTearDown(stream.close);
      await tester.pumpWidget(ProviderScope(overrides: [
        budgetContextProvider.overrideWithValue(
            ContextRef.personal(profileId: 1, yearMonth: '2026-10')),
        vaultProvider.overrideWith((ref) => stream.stream),
      ], child: const MaterialApp(home: Scaffold(body: SavingsVaultCard()))));
      await tester.pump();
      expect(find.text('Loading savings…'), findsOneWidget);
      stream.addError(StateError('load failed'));
      await settle(tester);
      expect(find.textContaining('could not be loaded'), findsOneWidget);
      expect(find.textContaining('Ft 0'), findsNothing);
    });
  });

  testWidgets(
      'corrupted saved and opening amounts show review messages, never sentinel money',
      (tester) async {
    await tester.runAsync(() async {
      await h.isar.writeTxn(() async {
        vault.totalMinor = corruptedMinorSentinel;
        await h.isar.savingsVaults.put(vault);
        final entry = (await h.isar.vaultEntrys.where().findAll()).single;
        entry.amountMinor = corruptedMinorSentinel;
        entry.balanceAfterMinor = corruptedMinorSentinel;
        await h.isar.vaultEntrys.put(entry);
      });
      await open(tester);
      expect(find.text('Saved balance needs review'), findsOneWidget);
      expect(find.textContaining('9,223'), findsNothing);
      expect(find.text('Add savings goal'), findsNothing);
      await tester.scrollUntilVisible(
          find.text('History amount needs review'), 150);
      expect(find.text('History amount needs review'), findsOneWidget);
      await tester.ensureVisible(find.text('Check for finished months'));
      await tester.pump();
      await tester.tap(find.text('Check for finished months'));
      await settle(tester);
      expect(find.textContaining('PAUSED:'), findsOneWidget);
      expect((await VaultRepository(h.isar).getVault(1))!.totalMinor,
          corruptedMinorSentinel);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets(
      'malformed saved calculation is retained and displayed as needing review',
      (tester) async {
    await tester.runAsync(() async {
      await h.isar.writeTxn(() async {
        await h.isar.vaultEntrys.put(VaultEntry()
          ..operationKey = 'broken'
          ..profileId = 1
          ..kind = 'sweep'
          ..yearMonth = '2026-09'
          ..amountMinor = 0
          ..currency = 'huf'
          ..balanceAfterMinor = 1000000
          ..createdAt = DateTime(2026, 10, 24)
          ..breakdownJson = '{broken');
      });
      await open(tester);
      await tester.scrollUntilVisible(
          find.text('Saved calculation needs review'), 150);
      expect(find.text('Saved calculation needs review'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets(
      'recovery preview cancel is read-only; explicit confirmation repairs and retains evidence',
      (tester) async {
    await tester.runAsync(() async {
      await h.isar.writeTxn(() async {
        vault.totalMinor = corruptedMinorSentinel;
        await h.isar.savingsVaults.put(vault);
        final entry = (await h.isar.vaultEntrys.where().findAll()).single;
        entry.amountMinor = corruptedMinorSentinel;
        entry.balanceAfterMinor = corruptedMinorSentinel;
        await h.isar.vaultEntrys.put(entry);
        for (final month in ['2026-08', '2026-09']) {
          await h.isar.monthlyBudgets.put(MonthlyBudget()
            ..profileId = 1
            ..yearMonth = month
            ..baseAvailableAmount = 0
            ..openingBalanceConfirmed = true
            ..createdAt = DateTime(2026)
            ..updatedAt = DateTime(2026));
        }
      });
      await open(tester);
      await tester.ensureVisible(find.text('Review balance recovery'));
      await tester.pump();
      await tester.tap(find.text('Review balance recovery'));
      await settle(tester);
      expect(find.text('Verified replacement: Ft 0'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await settle(tester);
      expect((await VaultRepository(h.isar).getVault(1))!.totalMinor,
          corruptedMinorSentinel);
      await tester.tap(find.text('Review balance recovery'));
      await settle(tester);
      await tester.tap(find.text('Confirm recovery to Ft 0'));
      await settle(tester);
      expect((await VaultRepository(h.isar).getVault(1))!.totalMinor, 0);
      final entry = (await h.isar.vaultEntrys.where().findAll()).single;
      expect(
          jsonDecode(entry.breakdownJson)['recovery']['originalVault']['minor'],
          corruptedMinorSentinel.toString());
      expect(find.text('Review balance recovery'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
