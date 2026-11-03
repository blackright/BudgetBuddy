import 'package:budget_buddy/core/models/income_receipt_group.dart';
import 'package:budget_buddy/core/models/income_source.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/pending_action.dart';
import 'package:budget_buddy/core/models/salary_cycle.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/core/providers/selected_month_provider.dart';
import 'package:budget_buddy/core/services/income_receipt_ledger.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/finance/presentation/income_sources_screen.dart';
import 'package:budget_buddy/features/finance/providers/income_source_providers.dart';
import 'package:budget_buddy/features/pending_actions/providers/pending_actions_providers.dart';
import 'package:budget_buddy/features/spaces/providers/spaces_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget cardSubject({
    required IncomeSource source,
    required List<SalaryCycle> cycles,
    required bool canEdit,
    List<PendingAction> actions = const [],
  }) {
    final profile = UserProfile()
      ..id = 1
      ..name = 'Owner'
      ..primaryCurrency = PrimaryCurrency.huf
      ..monthlyAvailableAmount = 0
      ..createdAt = DateTime.utc(2026, 10)
      ..updatedAt = DateTime.utc(2026, 10);
    return ProviderScope(
      overrides: [
        incomeSourcesProvider.overrideWith((ref) => Stream.value([source])),
        salaryCyclesProvider.overrideWith((ref) async => cycles),
        actualIncomeLedgerProvider.overrideWith((ref) => Stream.value(
            const IncomeLedgerSnapshot(groups: [], corrections: []))),
        pendingActionsProvider.overrideWith((ref) => Stream.value(actions)),
        budgetContextProvider.overrideWithValue(
            ContextRef.personal(profileId: 1, yearMonth: '2026-10')),
        activeProfileProvider.overrideWith((ref) => Stream.value(profile)),
        activeSpaceProvider.overrideWith((ref) => Stream.value(null)),
        activeBudgetProvider.overrideWith((ref) => Stream.value(MonthlyBudget()
          ..id = 1
          ..profileId = 1
          ..yearMonth = '2026-10'
          ..baseAvailableAmount = 0
          ..currency = 'huf'
          ..createdAt = DateTime.utc(2026, 10)
          ..updatedAt = DateTime.utc(2026, 10))),
        selectedYearMonthProvider.overrideWith((ref) => '2026-10'),
        rateRegistryProvider.overrideWithValue(RateTableRegistry()),
        activeContextCanEditProvider.overrideWithValue(canEdit),
      ],
      child: const MaterialApp(home: IncomeSourcesScreen()),
    );
  }

  IncomeSource cardSource() => IncomeSource()
    ..profileId = 1
    ..name = 'Freelance'
    ..type = IncomeSourceType.freelance
    ..amount = 300000
    ..currency = 'huf'
    ..frequency = IncomeFrequency.monthly
    ..createdAt = DateTime.utc(2026, 10)
    ..updatedAt = DateTime.utc(2026, 10);

  SalaryCycle cardCycle(IncomeSource source, String state) => SalaryCycle()
    ..profileId = 1
    ..sourceGuid = source.syncGuid
    ..scheduleGuid = 'sched'
    ..expectedAmountMinor = 300000
    ..currency = 'huf'
    ..occurrenceMonth = '2026-10'
    ..nominalPayday = DateTime.utc(2026, 10, 3)
    ..adjustedPayday = DateTime.utc(2026, 10, 3)
    ..confirmed = false
    ..state = state
    ..createdAt = DateTime.utc(2026, 10)
    ..updatedAt = DateTime.utc(2026, 10);

  testWidgets('each salary source shows expected and actual per cycle',
      (tester) async {
    final profile = UserProfile()
      ..id = 1
      ..name = 'Owner'
      ..primaryCurrency = PrimaryCurrency.huf
      ..monthlyAvailableAmount = 0
      ..createdAt = DateTime.utc(2026, 10)
      ..updatedAt = DateTime.utc(2026, 10);
    final source = IncomeSource()
      ..profileId = 1
      ..name = 'Salary'
      ..type = IncomeSourceType.salary
      ..amount = 500000
      ..currency = 'huf'
      ..frequency = IncomeFrequency.monthly
      ..createdAt = DateTime.utc(2026, 10)
      ..updatedAt = DateTime.utc(2026, 10);
    final cycle = SalaryCycle()
      ..profileId = 1
      ..sourceGuid = source.syncGuid
      ..scheduleGuid = 'sched'
      ..expectedAmountMinor = 500000
      ..currency = 'huf'
      ..occurrenceMonth = '2026-10'
      ..nominalPayday = DateTime.utc(2026, 10, 25)
      ..adjustedPayday = DateTime.utc(2026, 10, 25)
      ..confirmed = true
      ..state = 'confirmed'
      ..createdAt = DateTime.utc(2026, 10)
      ..updatedAt = DateTime.utc(2026, 10);
    final group = IncomeReceiptGroup()
      ..guid = 'group-1'
      ..profileId = 1
      ..sourceGuid = source.syncGuid
      ..cycleGuid = cycle.guid
      ..actualDate = DateTime.utc(2026, 10, 25)
      ..timezone = 'UTC'
      ..totalMinor = 485000
      ..currency = 'huf'
      ..destinationMonth = '2026-10'
      ..componentReceiptGuids = const ['receipt-1']
      ..componentRevisionRefs = const ['revision-1']
      ..fingerprint = 'fp'
      ..operationIdentity = 'op'
      ..createdAt = DateTime.utc(2026, 10)
      ..updatedAt = DateTime.utc(2026, 10);
    final ledger = IncomeReceiptLedger(group, 485000, 0, '2026-10');

    await tester.pumpWidget(ProviderScope(
      overrides: [
        incomeSourcesProvider.overrideWith((ref) => Stream.value([source])),
        salaryCyclesProvider.overrideWith((ref) async => [cycle]),
        actualIncomeLedgerProvider.overrideWith((ref) => Stream.value(
            IncomeLedgerSnapshot(groups: [ledger], corrections: const []))),
        budgetContextProvider.overrideWithValue(
            ContextRef.personal(profileId: 1, yearMonth: '2026-10')),
        activeProfileProvider.overrideWith((ref) => Stream.value(profile)),
        activeSpaceProvider.overrideWith((ref) => Stream.value(null)),
        activeBudgetProvider.overrideWith((ref) => Stream.value(MonthlyBudget()
          ..id = 1
          ..profileId = 1
          ..yearMonth = '2026-10'
          ..baseAvailableAmount = 0
          ..currency = 'huf'
          ..createdAt = DateTime.utc(2026, 10)
          ..updatedAt = DateTime.utc(2026, 10))),
        selectedYearMonthProvider.overrideWith((ref) => '2026-10'),
        rateRegistryProvider.overrideWithValue(RateTableRegistry()),
        activeContextCanEditProvider.overrideWithValue(false),
      ],
      child: const MaterialApp(
        home: IncomeSourcesScreen(),
      ),
    ));
    await tester.pumpAndSettle();

    // The override above resolves immediately; use the real ledger value for
    // the visible actual amount.
    expect(find.textContaining('Expected Ft 500,000'), findsOneWidget);
    expect(find.textContaining('Received Ft 485,000'), findsOneWidget);
  });

  testWidgets('an old unconfirmed source shows a visible setup action',
      (tester) async {
    final profile = UserProfile()
      ..id = 1
      ..name = 'Owner'
      ..primaryCurrency = PrimaryCurrency.huf
      ..monthlyAvailableAmount = 0
      ..createdAt = DateTime.utc(2026, 10)
      ..updatedAt = DateTime.utc(2026, 10);
    final source = IncomeSource()
      ..profileId = 1
      ..name = 'Freelance'
      ..type = IncomeSourceType.freelance
      ..amount = 300000
      ..currency = 'huf'
      ..frequency = IncomeFrequency.monthly
      ..createdAt = DateTime.utc(2026, 10)
      ..updatedAt = DateTime.utc(2026, 10);
    final cycle = SalaryCycle()
      ..profileId = 1
      ..sourceGuid = source.syncGuid
      ..scheduleGuid = 'sched'
      ..expectedAmountMinor = 300000
      ..currency = 'huf'
      ..occurrenceMonth = '2026-10'
      ..nominalPayday = DateTime.utc(2026, 10, 3)
      ..adjustedPayday = DateTime.utc(2026, 10, 3)
      ..confirmed = false
      ..state = 'unconfirmed'
      ..createdAt = DateTime.utc(2026, 10)
      ..updatedAt = DateTime.utc(2026, 10);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        incomeSourcesProvider.overrideWith((ref) => Stream.value([source])),
        salaryCyclesProvider.overrideWith((ref) async => [cycle]),
        actualIncomeLedgerProvider.overrideWith((ref) => Stream.value(
            const IncomeLedgerSnapshot(groups: [], corrections: []))),
        budgetContextProvider.overrideWithValue(
            ContextRef.personal(profileId: 1, yearMonth: '2026-10')),
        activeProfileProvider.overrideWith((ref) => Stream.value(profile)),
        activeSpaceProvider.overrideWith((ref) => Stream.value(null)),
        activeBudgetProvider.overrideWith((ref) => Stream.value(MonthlyBudget()
          ..id = 1
          ..profileId = 1
          ..yearMonth = '2026-10'
          ..baseAvailableAmount = 0
          ..currency = 'huf'
          ..createdAt = DateTime.utc(2026, 10)
          ..updatedAt = DateTime.utc(2026, 10))),
        selectedYearMonthProvider.overrideWith((ref) => '2026-10'),
        rateRegistryProvider.overrideWithValue(RateTableRegistry()),
        activeContextCanEditProvider.overrideWithValue(true),
      ],
      child: const MaterialApp(
        home: IncomeSourcesScreen(),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Set up current period'), findsOneWidget);
    expect(find.text('Confirm received'), findsNothing);
    expect(find.text('Not yet'), findsNothing);
    expect(
        find.textContaining('Current period not configured'), findsOneWidget);
    expect(find.textContaining('Expected Ft 300,000'), findsOneWidget);
  });

  testWidgets('a pending period shows confirm and cancel actions',
      (tester) async {
    final source = cardSource();
    final cycle = cardCycle(source, 'pending');

    await tester.pumpWidget(cardSubject(
      source: source,
      cycles: [cycle],
      canEdit: true,
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('Not received yet'), findsOneWidget);
    expect(find.text('Confirm received'), findsOneWidget);
    expect(find.text('Cancel expected income'), findsOneWidget);

    await tester.tap(find.text('Cancel expected income'));
    await tester.pumpAndSettle();
    expect(find.text('Reason'), findsOneWidget);
    expect(find.text('Cancel income'), findsOneWidget);
    await tester.tap(find.text('Keep'));
    await tester.pumpAndSettle();
  });

  testWidgets('a skipped period shows its state and no actions',
      (tester) async {
    final source = cardSource();
    final cycle = cardCycle(source, 'skipped');

    await tester.pumpWidget(cardSubject(
      source: source,
      cycles: [cycle],
      canEdit: true,
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('Skipped'), findsOneWidget);
    expect(find.textContaining('Starts next period'), findsOneWidget);
    expect(find.text('Confirm received'), findsNothing);
    expect(find.text('Cancel expected income'), findsNothing);
  });

  testWidgets('a cancelled period shows its reason and no actions',
      (tester) async {
    final source = cardSource();
    final cycle = cardCycle(source, 'cancelled');
    final action = PendingAction()
      ..profileId = 1
      ..actionType = 'income.confirm'
      ..title = 'Confirm Freelance received'
      ..nextAction = 'Confirm income received'
      ..feature = 'income'
      ..recordRef = cycle.guid
      ..expectedMonth = '2026-10'
      ..status = 'cancelled'
      ..dismissedReason = 'Not coming this month'
      ..dedupeKey = 'income.confirm|${cycle.guid}|2026-10'
      ..createdAt = DateTime.utc(2026, 10)
      ..updatedAt = DateTime.utc(2026, 10);

    await tester.pumpWidget(cardSubject(
      source: source,
      cycles: [cycle],
      canEdit: true,
      actions: [action],
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('Cancelled'), findsOneWidget);
    expect(find.textContaining('Not coming this month'), findsOneWidget);
    expect(find.text('Confirm received'), findsNothing);
    expect(find.text('Cancel expected income'), findsNothing);
  });
}
