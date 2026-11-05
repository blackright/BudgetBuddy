import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/income_source.dart';
import 'package:budget_buddy/features/budget_setup/domain/onboarding_starting_position.dart';
import 'package:budget_buddy/features/budget_setup/domain/onboarding_state.dart';
import 'package:budget_buddy/features/budget_setup/presentation/widgets/setup_review.dart';
import 'package:budget_buddy/shared/presentation/money_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/income_activation_fixture.dart';

void main() {
  test('free to use includes only opening and confirmed money', () {
    const position = OnboardingStartingPosition(
      month: '2026-11',
      currency: CurrencyCode.huf,
      openingMinor: 1000000,
      confirmedMinor: 500000,
      pendingMinor: 300000,
      skippedMinor: 200000,
      unconfiguredMinor: 100000,
      cancelledMinor: 0,
      confirmed: [StartingPositionLine('Salary', 500000, note: 'Received')],
      pending: [
        StartingPositionLine('Freelance', 300000, note: 'Expected later')
      ],
      skipped: [
        StartingPositionLine('Rent', 200000, note: 'Starts next period')
      ],
      unconfigured: [
        StartingPositionLine('Bonus', 100000, note: 'Not configured')
      ],
      future: [],
      cancelled: [],
    );

    expect(position.freeToUseMinor, 1500000);
  });

  testWidgets('review separates opening, confirmed, pending and skipped values',
      (tester) async {
    const position = OnboardingStartingPosition(
      month: '2026-11',
      currency: CurrencyCode.huf,
      openingMinor: 1000000,
      confirmedMinor: 500000,
      pendingMinor: 300000,
      skippedMinor: 200000,
      unconfiguredMinor: 100000,
      cancelledMinor: 0,
      confirmed: [StartingPositionLine('Salary', 500000, note: 'Received')],
      pending: [
        StartingPositionLine('Freelance', 300000, note: 'Expected later')
      ],
      skipped: [
        StartingPositionLine('Rent', 200000, note: 'Starts next period')
      ],
      unconfigured: [
        StartingPositionLine('Bonus', 100000, note: 'Not configured')
      ],
      future: [],
      cancelled: [],
    );

    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(
                child: StartingPositionReview(position: position)))));

    expect(find.text('Your starting position'), findsOneWidget);
    expect(find.textContaining('Confirmed current income'), findsOneWidget);
    expect(find.textContaining('Pending expected income'), findsOneWidget);
    expect(find.textContaining('Skipped current period'), findsOneWidget);
    expect(find.textContaining('Not configured yet'), findsOneWidget);
    expect(find.textContaining('Initial Free to Use'), findsOneWidget);
    expect(
        find.textContaining(
            formatMinorUnits(position.freeToUseMinor!, CurrencyCode.huf)),
        findsOneWidget);
    expect(find.textContaining('Pending amounts are excluded'), findsOneWidget);
    expect(
        find.textContaining('Skipped amounts are not money'), findsOneWidget);
  });

  test('loader reads pending, skipped, unconfigured and future sources',
      () async {
    final fixture = await IncomeActivationFixture.create();
    addTearDown(fixture.close);
    final pending = await fixture.addSource(name: 'Pending');
    await fixture.addCycle(pending, state: 'pending');
    final skipped = await fixture.addSource(name: 'Skipped');
    await fixture.addCycle(skipped, state: 'skipped');
    await fixture.addSource(
        name: 'Unconfigured', type: IncomeSourceType.freelance);
    await fixture.addSource(
        name: 'Future',
        type: IncomeSourceType.freelance,
        startDate: DateTime(2026, 12, 1));

    final position = await OnboardingStartingPosition.load(
      fixture.db,
      profileId: fixture.profileId,
      month: '2026-11',
      opening: const OnboardingOpeningDraft(
          choice: OnboardingOpeningChoice.known,
          amountText: '10,000',
          minorUnits: 1000000,
          currency: CurrencyCode.huf),
      currency: CurrencyCode.huf,
    );

    expect(position.openingMinor, 1000000);
    expect(position.confirmedMinor, 0);
    expect(position.pendingMinor, 500000);
    expect(position.skippedMinor, 500000);
    expect(position.unconfiguredMinor, 500000);
    expect(position.future.length, 1);
    expect(position.pending.single.name, 'Pending');
    expect(position.skipped.single.name, 'Skipped');
    expect(position.unconfigured.single.name, 'Unconfigured');
    expect(position.future.single.name, 'Future');
    expect(position.freeToUseMinor, 1000000);
  });
}
