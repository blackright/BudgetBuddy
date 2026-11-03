import 'package:budget_buddy/core/database/isar_helper.dart';
import 'package:budget_buddy/core/models/pending_action.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/features/pending_actions/presentation/pending_actions_screen.dart';
import 'package:budget_buddy/features/pending_actions/providers/pending_actions_providers.dart';
import 'package:budget_buddy/features/pending_actions/services/pending_action_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../features/medical/repositories/medical_test_harness.dart';

void main() {
  late MedicalTestHarness h;
  final now = DateTime.utc(2026, 10, 23, 12);

  PendingAction action({
    required String guid,
    required String type,
    required String status,
    required String title,
    String record = 'record',
    String cycle = '2026-10',
    DateTime? expectedAt,
    String? deepLink,
    int? amount,
    String? dismissedReason,
  }) =>
      PendingAction()
        ..guid = guid
        ..profileId = 1
        ..actionType = type
        ..title = title
        ..nextAction = 'Do the next step'
        ..feature = 'test'
        ..recordRef = record
        ..status = status
        ..dedupeKey = '$type|$record|$cycle'
        ..expectedAt = expectedAt
        ..expectedAmountMinor = amount
        ..currency = amount == null ? null : 'usd'
        ..deepLink = deepLink
        ..dismissedReason = dismissedReason
        ..createdAt = now
        ..updatedAt = now;

  late _RecordingService recordingService;

  Future<GoRouter> open(WidgetTester tester, List<PendingAction> rows,
      {TextScaler? scaler}) async {
    await tester.runAsync(() async {
      h = await MedicalTestHarness.create();
      IsarHelper.instance = h.isar;
      recordingService = _RecordingService(h.isar);
      await h.isar.writeTxn(() async {
        await h.isar.pendingActions.putAll(rows);
      });
    });
    addTearDown(() => h.close());
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const PendingActionsScreen()),
      GoRoute(
          path: '/allocations',
          builder: (_, __) => const Scaffold(body: Text('Allocations stub'))),
    ]);
    addTearDown(router.dispose);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        budgetContextProvider.overrideWithValue(
            ContextRef.personal(profileId: 1, yearMonth: '2026-10')),
        activeProfileProvider.overrideWith((ref) => Stream.value(null)),
        pendingActionsSynthesisProvider.overrideWith((ref) async {}),
        pendingActionsProvider.overrideWith((ref) => Stream.value(rows)),
        pendingActionServiceProvider
            .overrideWith((ref) => recordingService),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        builder: scaler == null
            ? null
            : (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: scaler),
                child: child!),
      ),
    ));
    await tester.pumpAndSettle();
    return router;
  }

  testWidgets('three groups render with amounts and next steps',
      (tester) async {
    await open(tester, [
      action(
          guid: 'due',
          type: 'salary.confirm',
          status: 'due',
          title: 'Confirm salary received',
          expectedAt: DateTime.utc(2026, 10, 20),
          amount: 500000,
          deepLink: '/allocations'),
      action(
          guid: 'future',
          type: 'monthend.close',
          status: 'pending',
          title: 'Finish month-end',
          cycle: '2026-11',
          deepLink: '/allocations'),
      action(
          guid: 'done',
          type: 'vault.review',
          status: 'completed',
          title: 'Old review',
          cycle: '2026-09'),
    ]);

    expect(find.text('Needs you now (1)'), findsOneWidget);
    expect(find.text('Upcoming (1)'), findsOneWidget);
    expect(find.text('History (1)'), findsOneWidget);
    expect(find.text('Confirm salary received'), findsOneWidget);
    expect(find.textContaining('Do the next step'), findsNWidgets(3));
  });

  testWidgets('empty state is explicit', (tester) async {
    await open(tester, []);
    expect(find.text('Nothing needs you right now.'), findsOneWidget);
  });

  testWidgets('opening an action marks read and follows its deep link',
      (tester) async {
    await open(tester, [
      action(
          guid: 'due',
          type: 'salary.confirm',
          status: 'due',
          title: 'Confirm salary received',
          expectedAt: DateTime.utc(2026, 10, 20),
          deepLink: '/allocations'),
    ]);

    await tester.tap(find.text('Open').first);
    await tester.pumpAndSettle();
    expect(find.text('Allocations stub'), findsOneWidget);
    expect(recordingService.readGuid, 'due');
  });

  testWidgets('200% text at 320 dp keeps every action reachable',
      (tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await open(
      tester,
      [
        action(
            guid: 'due',
            type: 'salary.confirm',
            status: 'due',
            title: 'Confirm salary received',
            expectedAt: DateTime.utc(2026, 10, 20),
            amount: 500000,
            deepLink: '/allocations'),
        action(
            guid: 'over',
            type: 'allocation.overspent',
            status: 'overdue',
            title: 'Car is overspent',
            expectedAt: DateTime.utc(2026, 10, 1),
            amount: 5000,
            deepLink: '/allocations'),
      ],
      scaler: const TextScaler.linear(2),
    );

    expect(find.text('Confirm salary received'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Car is overspent'), 200);
    expect(find.text('Car is overspent'), findsOneWidget);
    expect(find.text('Open'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}

class _RecordingService extends PendingActionService {
  _RecordingService(super.db) : super(profileId: 1);

  String? readGuid;

  @override
  Future<void> markRead(String guid) async {
    readGuid = guid;
  }

  @override
  Future<void> cancel(String guid, String reason) async {}
}
