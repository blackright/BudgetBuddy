import 'package:budget_buddy/features/dashboard/providers/dashboard_providers.dart';
import 'dart:async';

import 'package:budget_buddy/core/models/change_record.dart';
import 'package:budget_buddy/core/models/context_kind.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/paired_context.dart';
import 'package:budget_buddy/core/models/sync_cursor.dart';
import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/features/dashboard/presentation/dashboard_screen.dart';
import 'package:budget_buddy/features/dashboard/presentation/month_navigator.dart';
import 'package:budget_buddy/features/engine/month_summary.dart';
import 'package:budget_buddy/features/engine/providers/month_summary_provider.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/engine/providers/true_available_provider.dart';
import 'package:budget_buddy/features/expenses/providers/category_provider.dart';
import 'package:budget_buddy/features/finance/providers/finance_providers.dart';
import 'package:budget_buddy/features/medical/providers/medical_providers.dart';
import 'package:budget_buddy/features/settings/providers/settings_provider.dart';
import 'package:budget_buddy/features/spaces/providers/spaces_providers.dart';
import 'package:budget_buddy/features/sync/providers/sync_status_provider.dart';
import 'package:budget_buddy/shared/presentation/widgets/sync_status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/sync_harness.dart';

/// Oracle for FR-008 / SC-005 and US3 (T047-T052).
///
/// The point of this phase is that the badge never lies: "waiting for peer" means
/// something really is queued, "up to date" means nothing is. The phase is
/// derived, so those two can no longer drift apart.
void main() {
  // Two distinct hex identities, as everywhere else in the suite (an accidental
  // shared id would make "our records" and "their records" indistinguishable).
  const selfId = 'a1b2c3d4e5f60718';
  const peerIdentity = 'b2c3d4e5f6071829';

  /// A store that has not answered yet. The states below are exactly what the
  /// notifier was told, so no refresh can overwrite them mid-assertion.
  Future<SyncStatusFacts> pendingForever() =>
      Completer<SyncStatusFacts>().future;

  ProviderContainer containerWithStore() => ProviderContainer(
        overrides: [
          syncStatusFactsProvider
              .overrideWith((ref, spaceId) => pendingForever()),
        ],
      );

  group('per-space phase (T047)', () {
    test('nothing pending reads as up to date, not "waiting for peer"', () {
      final container = containerWithStore();
      addTearDown(container.dispose);

      final state = container.read(syncStatusProvider(3));
      expect(state.status, SyncStatus.converged);
      expect(state.pending, 0);
      expect(state.hasConflicts, isFalse);
    });

    test('a queued change reads as waiting for peer', () {
      final container = containerWithStore();
      addTearDown(container.dispose);

      container
          .read(syncStatusProvider(3).notifier)
          .applyFacts(const SyncStatusFacts(pending: 2));

      final state = container.read(syncStatusProvider(3));
      expect(state.status, SyncStatus.waitingForPeer);
      expect(state.pending, 2);
    });

    test('an exchange in flight reads as "in progress", then settles honestly',
        () {
      final container = containerWithStore();
      addTearDown(container.dispose);
      final notifier = container.read(syncStatusProvider(3).notifier);

      notifier.roundStarted();
      expect(container.read(syncStatusProvider(3)).status, SyncStatus.syncing);

      // The round ends, but the store has not caught up: the queued change is
      // still owed, so the badge must not claim "up to date" yet (SC-005).
      notifier.roundFinished();
      notifier.applyFacts(const SyncStatusFacts(pending: 1));
      expect(
        container.read(syncStatusProvider(3)).status,
        SyncStatus.waitingForPeer,
      );

      // What the round delivered is now visible in the store.
      notifier.applyFacts(const SyncStatusFacts());
      expect(
          container.read(syncStatusProvider(3)).status, SyncStatus.converged);
    });

    test('two spaces hold independent states', () {
      final container = containerWithStore();
      addTearDown(container.dispose);

      container
          .read(syncStatusProvider(1).notifier)
          .applyFacts(const SyncStatusFacts(pending: 3));

      expect(container.read(syncStatusProvider(1)).status,
          SyncStatus.waitingForPeer);
      expect(container.read(syncStatusProvider(2)).status, SyncStatus.converged,
          reason: 'one space being behind says nothing about the other');
    });

    test('a kept-aside conflict is surfaced without faking a pending phase',
        () {
      final container = containerWithStore();
      addTearDown(container.dispose);

      container
          .read(syncStatusProvider(3).notifier)
          .applyFacts(const SyncStatusFacts(conflictCount: 2));

      final state = container.read(syncStatusProvider(3));
      expect(state.hasConflicts, isTrue);
      expect(state.conflictCount, 2);
      expect(state.status, SyncStatus.converged,
          reason: 'a losing edit was resolved, not left undelivered');
    });
  });

  group('SyncStatusFactsReader — derived from the store (T047)', () {
    late SyncTestHarness harness;

    setUp(() async {
      harness = await SyncTestHarness.create();
    });

    tearDown(() async {
      await harness.close();
    });

    Future<int> authorChange({
      required int spaceId,
      required String author,
      required int millis,
      String deviceId = 'devA',
    }) {
      return harness.isar.writeTxn(() => harness.isar.changeRecords.put(
            ChangeRecord()
              ..contextKind = ContextKind.shared
              ..contextSyncGuid = 'space-guid-$spaceId'
              ..contextLocalId = spaceId
              ..entityType = 'Expense'
              ..entitySyncGuid = 'entity-$spaceId-$millis'
              ..entityLocalId = millis
              ..op = 'upsert'
              ..payload = '{}'
              ..hlcMillis = millis
              ..hlcCounter = 0
              ..deviceId = deviceId
              ..authorIdentityId = author
              ..signature = 'signature'
              ..createdAt = DateTime(2026),
          ));
    }

    Future<void> writeSentWatermark({
      required int spaceId,
      required int peerId,
      required int sentMillis,
      int conflicts = 0,
    }) {
      return harness.isar.writeTxn(() => harness.isar.syncCursors.put(
            SyncCursor()
              ..peerId = peerId
              ..contextLocalId = spaceId
              ..lastSentHlcMillis = sentMillis
              ..lastSentCounter = 0
              ..lastSentDeviceId = 'devA'
              ..conflictCount = conflicts
              ..updatedAt = DateTime(2026, 3, 1),
          ));
    }

    test('a change no peer has been handed is pending', () async {
      final space = await harness.createSpace();
      await authorChange(spaceId: space, author: selfId, millis: 1000);

      final facts = await SyncStatusFactsReader(harness.isar)
          .read(spaceId: space, selfIdentityId: selfId);

      expect(facts.pending, 1,
          reason: 'no peer is paired, so it is still ours to deliver');
    });

    test('a change the only active peer received is no longer pending',
        () async {
      final space = await harness.createSpace();
      await authorChange(spaceId: space, author: selfId, millis: 1000);
      await harness.pairContext(peerId: 7, spaceId: space);
      await writeSentWatermark(spaceId: space, peerId: 7, sentMillis: 1000);

      final facts = await SyncStatusFactsReader(harness.isar)
          .read(spaceId: space, selfIdentityId: selfId);

      expect(facts.pending, 0);
      expect(facts.lastSyncedAt, isNotNull,
          reason: 'a cursor exists, so a peer has been talked to');
    });

    test('the lagging peer decides: one behind keeps the space waiting',
        () async {
      final space = await harness.createSpace();
      await harness.pairContext(peerId: 7, spaceId: space);
      await harness.pairContext(peerId: 8, spaceId: space);
      await authorChange(spaceId: space, author: selfId, millis: 1000);
      await authorChange(spaceId: space, author: selfId, millis: 2000);
      await writeSentWatermark(spaceId: space, peerId: 7, sentMillis: 2000);
      await writeSentWatermark(spaceId: space, peerId: 8, sentMillis: 1000);

      final facts = await SyncStatusFactsReader(harness.isar)
          .read(spaceId: space, selfIdentityId: selfId);

      expect(facts.pending, 1,
          reason:
              'the lowest watermark decides — the 2000 edit is not there yet');
    });

    test('an unpaired peer cannot pin the space at "waiting for peer" forever',
        () async {
      final space = await harness.createSpace();
      await authorChange(spaceId: space, author: selfId, millis: 1000);
      final paired = await harness.pairContext(peerId: 7, spaceId: space);
      await harness.isar.writeTxn(() async {
        final row = (await harness.isar.pairedContexts.get(paired))!;
        row.active = false; // unpaired (FR-014)
        await harness.isar.pairedContexts.put(row);
      });
      await writeSentWatermark(spaceId: space, peerId: 7, sentMillis: 1000);

      final facts = await SyncStatusFactsReader(harness.isar)
          .read(spaceId: space, selfIdentityId: selfId);

      expect(facts.pending, 1,
          reason:
              'a phone that left cannot receive, so the edit is still ours');
    });

    test('the peer\'s own history is never counted as our pending work',
        () async {
      final space = await harness.createSpace();
      await authorChange(
        spaceId: space,
        author: peerIdentity,
        millis: 1000,
        deviceId: 'devB',
      );

      final facts = await SyncStatusFactsReader(harness.isar)
          .read(spaceId: space, selfIdentityId: selfId);

      expect(facts.pending, 0);
    });

    test('kept-aside conflicts are summed off the cursors', () async {
      final space = await harness.createSpace();
      await harness.pairContext(peerId: 7, spaceId: space);
      await writeSentWatermark(
        spaceId: space,
        peerId: 7,
        sentMillis: 0,
        conflicts: 2,
      );

      final facts = await SyncStatusFactsReader(harness.isar)
          .read(spaceId: space, selfIdentityId: selfId);

      expect(facts.conflictCount, 2);
      expect(facts.pending, 0);
    });
  });

  group('SyncStatusChip (T048)', () {
    Widget chipIn(ProviderContainer container, int spaceId) {
      return UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(body: Center(child: SyncStatusChip(spaceId: spaceId))),
        ),
      );
    }

    ProviderContainer containerWithFacts(SyncStatusFacts facts) =>
        ProviderContainer(
          overrides: [
            syncStatusFactsProvider.overrideWith((ref, spaceId) async => facts),
          ],
        );

    testWidgets('names each phase the way the user reads it', (tester) async {
      final container = containerWithFacts(const SyncStatusFacts(pending: 1));
      addTearDown(container.dispose);
      await tester.pumpWidget(chipIn(container, 3));
      await tester.pumpAndSettle();
      expect(find.text('Waiting for peer'), findsOneWidget);

      final clean = containerWithFacts(const SyncStatusFacts());
      addTearDown(clean.dispose);
      await tester.pumpWidget(chipIn(clean, 3));
      await tester.pumpAndSettle();
      expect(find.text('Up to date'), findsOneWidget);
      expect(find.text('Waiting for peer'), findsNothing);
    });

    testWidgets('an exchange in flight reads "In progress"', (tester) async {
      final container = containerWithFacts(const SyncStatusFacts());
      addTearDown(container.dispose);
      container.read(syncStatusProvider(3).notifier).roundStarted();

      await tester.pumpWidget(chipIn(container, 3));
      await tester.pump();

      expect(find.text('In progress'), findsOneWidget);
    });

    testWidgets('conflicts are shown, never hidden', (tester) async {
      final container =
          containerWithFacts(const SyncStatusFacts(conflictCount: 2));
      addTearDown(container.dispose);

      await tester.pumpWidget(chipIn(container, 3));
      await tester.pumpAndSettle();

      expect(find.text('Up to date · 2 conflicts'), findsOneWidget);
    });

    testWidgets(
        'reads green for done, amber for busy and red for conflicts, in both '
        'light and dark (UX-001)', (tester) async {
      Widget themed(ProviderContainer container, Brightness brightness) {
        return UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: ThemeData(brightness: brightness, useMaterial3: true),
            home:
                const Scaffold(body: Center(child: SyncStatusChip(spaceId: 3))),
          ),
        );
      }

      for (final brightness in Brightness.values) {
        // Up to date -> green.
        final ok = containerWithFacts(const SyncStatusFacts());
        addTearDown(ok.dispose);
        await tester.pumpWidget(themed(ok, brightness));
        await tester.pumpAndSettle();
        expect(
          tester.widget<Icon>(find.byIcon(Icons.cloud_done_outlined)).color,
          SyncStatusChip.upToDateColor(brightness),
          reason: 'up to date is green ($brightness)',
        );

        // In progress -> amber.
        final busy = containerWithFacts(const SyncStatusFacts());
        addTearDown(busy.dispose);
        busy.read(syncStatusProvider(3).notifier).roundStarted();
        await tester.pumpWidget(themed(busy, brightness));
        await tester.pump();
        expect(
          tester.widget<Icon>(find.byIcon(Icons.sync)).color,
          SyncStatusChip.inProgressColor(brightness),
          reason: 'in progress is amber ($brightness)',
        );

        // Conflicts -> the theme's error red, exactly as before.
        final bad = containerWithFacts(const SyncStatusFacts(conflictCount: 6));
        addTearDown(bad.dispose);
        await tester.pumpWidget(themed(bad, brightness));
        await tester.pumpAndSettle();
        final conflictIcon = find.byIcon(Icons.report_problem_outlined);
        expect(
          tester.widget<Icon>(conflictIcon).color,
          Theme.of(tester.element(conflictIcon)).colorScheme.error,
          reason: 'conflicts keep the theme error red ($brightness)',
        );
        expect(find.text('Up to date · 6 conflicts'), findsOneWidget);
      }
    });

    testWidgets('two spaces show two independent badges', (tester) async {
      final container = ProviderContainer(
        overrides: [
          syncStatusFactsProvider.overrideWith(
            (ref, spaceId) async =>
                SyncStatusFacts(pending: spaceId == 1 ? 1 : 0),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  // Wrapped so the two chips are not siblings sharing one key.
                  SizedBox(child: SyncStatusChip(spaceId: 1)),
                  SizedBox(child: SyncStatusChip(spaceId: 2)),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Waiting for peer'), findsOneWidget);
      expect(find.text('Up to date'), findsOneWidget);
    });
  });

  group('the space status on the money screen (T049, US3 AC6)', () {
    MonthlyBudget budget() => MonthlyBudget()
      ..id = 1
      ..yearMonth = '2026-01'
      ..baseAvailableAmount = 1000
      ..openingBalanceConfirmed = true
      ..currency = 'usd'
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);

    /// The dashboard's own provider set (mirrors `dashboard_summary_test.dart`),
    /// plus the shared-space marker so the space strip is on screen.
    Widget dashboard({int? spaceId, SyncStatusFacts? facts}) {
      return ProviderScope(
        overrides: [
          activeProfileProvider.overrideWith((ref) => Stream.value(null)),
          budgetContextProvider.overrideWithValue(
            ContextRef.personal(profileId: 1, yearMonth: '2026-01'),
          ),
          activeBudgetProvider.overrideWith((ref) => Stream.value(budget())),
          monthSummaryProvider.overrideWithValue(
            const MonthSummary(
              yearMonth: '2026-01',
              income: 4000,
              usesOverriddenIncome: false,
              paymentsMade: 1200,
              moneyReturned: 300,
              planned: 800,
              cancelled: 150,
              medicalPaid: 200,
              excessReturned: 0,
              insuranceReturned: 0,
              expenseReturned: 0,
              openingBalance: 1000,
            ),
          ),
          rateRegistryProvider.overrideWithValue(RateTableRegistry()),
          mainCurrencyProvider.overrideWithValue(CurrencyCode.huf),
          dashboardProfilesProvider.overrideWithValue(const []),
          monthlyExpensesProvider.overrideWith((ref) => Stream.value([])),
          monthlyReimbursementsProvider.overrideWith((ref) => Stream.value([])),
          monthlyOriginReimbursementsProvider
              .overrideWith((ref) => Stream.value([])),
          medicalBillsProvider.overrideWith((ref) => Stream.value([])),
          monthFinanceProvider.overrideWith((ref) => Stream.value(budget())),
          activeSpaceMembersProvider.overrideWith((ref) => Stream.value([])),
          categoriesProvider.overrideWith((ref) async => []),
          if (spaceId != null)
            activeSpaceIdProvider.overrideWith((ref) => spaceId),
          if (facts != null)
            syncStatusFactsProvider.overrideWith((ref, id) async => facts),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      );
    }

    testWidgets('the active space\'s status is in the app bar, under the month',
        (tester) async {
      await tester.pumpWidget(dashboard(
        spaceId: 3,
        facts: const SyncStatusFacts(pending: 1),
      ));
      await tester.pumpAndSettle();

      final chip = find.byKey(const Key('syncStatusChip'));
      expect(chip, findsOneWidget,
          reason: 'visible without opening settings (AC6)');
      expect(
        find.ancestor(of: chip, matching: find.byType(AppBar)),
        findsOneWidget,
        reason: 'part of the month header, not buried in a settings page',
      );
      // Directly below the month navigator, so it reads as the month's status.
      expect(
        tester.getTopLeft(chip).dy,
        greaterThanOrEqualTo(
            tester.getBottomLeft(find.byType(MonthNavigator)).dy),
      );
      expect(find.byType(MonthNavigator), findsOneWidget);
      expect(
        find.byWidgetPredicate((w) => w is SyncStatusChip && w.spaceId == 3),
        findsOneWidget,
        reason: 'and it really reports this space, not a global state',
      );
      expect(find.text('Waiting for peer'), findsOneWidget);
    });

    testWidgets('a personal month shows no space badge', (tester) async {
      await tester.pumpWidget(dashboard());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('syncStatusChip')), findsNothing);
      expect(find.byType(MonthNavigator), findsOneWidget);
    });

    testWidgets('fits under the month on a phone-width screen', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(dashboard(
        spaceId: 3,
        facts: const SyncStatusFacts(pending: 1),
      ));
      await tester.pumpAndSettle();

      // An overflowing Row fails the test on its own; this pins that the badge
      // and the month still share a narrow app bar (a wide badge would push the
      // month off screen, which is worse than an ellipsis).
      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('syncStatusChip')), findsOneWidget);
      expect(find.byType(MonthNavigator), findsOneWidget);
    });
  });
}
