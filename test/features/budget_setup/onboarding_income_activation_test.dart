import 'package:budget_buddy/core/models/income_source.dart';
import 'package:budget_buddy/core/models/salary_cycle.dart';
import 'package:budget_buddy/features/budget_setup/presentation/widgets/income_activation_step.dart';
import 'package:budget_buddy/features/finance/providers/income_source_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  IncomeSource source(String name,
          {IncomeSourceType type = IncomeSourceType.other}) =>
      IncomeSource()
        ..profileId = 1
        ..name = name
        ..type = type
        ..amount = 500000
        ..currency = 'huf'
        ..frequency = IncomeFrequency.monthly
        ..startDate = DateTime(2026, 11, 1)
        ..createdAt = DateTime.utc(2026, 11, 1)
        ..updatedAt = DateTime.utc(2026, 11, 1);

  SalaryCycle cycle(IncomeSource source, String state) => SalaryCycle()
    ..profileId = 1
    ..sourceGuid = source.syncGuid
    ..scheduleGuid = 'sched'
    ..expectedAmountMinor = 500000
    ..currency = 'huf'
    ..occurrenceMonth = '2026-11'
    ..nominalPayday = DateTime(2026, 11, 25)
    ..adjustedPayday = DateTime(2026, 11, 25)
    ..confirmed = state == 'confirmed'
    ..state = state
    ..createdAt = DateTime.utc(2026, 11, 1)
    ..updatedAt = DateTime.utc(2026, 11, 1);

  Widget subject({
    required List<IncomeSource> sources,
    List<SalaryCycle> cycles = const [],
  }) =>
      ProviderScope(
        overrides: [
          onboardingActivationSourcesProvider
              .overrideWith((ref, profileId) async => sources),
          salaryCyclesProvider.overrideWith((ref) async => cycles),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: OnboardingIncomeActivationStep(
                profileId: 1,
                month: '2026-11',
              ),
            ),
          ),
        ),
      );

  testWidgets('each undecided source opens the shared three choices',
      (tester) async {
    final first = source('Salary', type: IncomeSourceType.salary);
    final second = source('Freelance', type: IncomeSourceType.freelance);

    await tester.pumpWidget(subject(sources: [first, second]));
    await tester.pumpAndSettle();

    expect(find.text('Set up this month’s income'), findsOneWidget);
    expect(
        find.textContaining('Current period not configured'), findsNWidgets(2));
    expect(find.byKey(Key('onboardingSourceSetUp-${first.syncGuid}')),
        findsOneWidget);
    expect(find.byKey(Key('onboardingSourceSetUp-${second.syncGuid}')),
        findsOneWidget);

    for (final source in [first, second]) {
      await tester
          .tap(find.byKey(Key('onboardingSourceSetUp-${source.syncGuid}')));
      await tester.pumpAndSettle();
      expect(find.text('I already received it'), findsOneWidget);
      expect(find.text('I expect it later'), findsOneWidget);
      expect(find.text('Start from the next period'), findsOneWidget);
      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('configured states are visible and are not offered again',
      (tester) async {
    final pending = source('Pending');
    final skipped = source('Skipped');
    final confirmed = source('Confirmed');

    await tester.pumpWidget(subject(
      sources: [pending, skipped, confirmed],
      cycles: [
        cycle(pending, 'pending'),
        cycle(skipped, 'skipped'),
        cycle(confirmed, 'confirmed'),
      ],
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('Expected later'), findsOneWidget);
    expect(find.textContaining('Starts next period'), findsOneWidget);
    expect(find.textContaining('· Confirmed'), findsOneWidget);
    expect(find.byKey(Key('onboardingSourceSetUp-${pending.syncGuid}')),
        findsNothing);
    expect(find.byKey(Key('onboardingSourceSetUp-${skipped.syncGuid}')),
        findsNothing);
    expect(find.byKey(Key('onboardingSourceSetUp-${confirmed.syncGuid}')),
        findsNothing);
  });
}
