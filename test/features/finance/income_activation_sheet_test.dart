import 'package:budget_buddy/core/models/income_source.dart';
import 'package:budget_buddy/features/finance/presentation/income_activation_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  IncomeSource source({DateTime? start}) => IncomeSource()
    ..name = 'Salary'
    ..type = IncomeSourceType.salary
    ..amount = 500000
    ..currency = 'huf'
    ..frequency = IncomeFrequency.monthly
    ..startDate = start ?? DateTime.utc(2026, 11, 1)
    ..createdAt = DateTime.utc(2026, 11, 1)
    ..updatedAt = DateTime.utc(2026, 11, 1);

  Widget subject({
    required IncomeSource source,
    required ValueChanged<IncomeActivationChoice> onChoice,
    VoidCallback? onClose,
    bool startsInFuture = false,
    DateTime? expectedDate,
    TextScaler? scaler,
  }) {
    final sheet = IncomeActivationSheet(
      source: source,
      periodKey: '2026-11',
      startsInFuture: startsInFuture,
      expectedDate: expectedDate,
      onChoice: onChoice,
      onClose: onClose ?? () {},
    );
    return MaterialApp(
      home: Scaffold(body: sheet),
      builder: scaler == null
          ? null
          : (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: scaler),
                child: child!,
              ),
    );
  }

  testWidgets('shows three choices and no choice before tapping',
      (tester) async {
    IncomeActivationChoice? chosen;
    await tester.pumpWidget(subject(
      source: source(),
      onChoice: (value) => chosen = value,
    ));

    expect(find.text('I already received it'), findsOneWidget);
    expect(find.text('I expect it later'), findsOneWidget);
    expect(find.text('Start from the next period'), findsOneWidget);
    expect(find.text('Not now'), findsOneWidget);
    expect(chosen, isNull);
  });

  testWidgets('shows the derived expected date for expect-later',
      (tester) async {
    final date = DateTime(2026, 11, 10);
    await tester.pumpWidget(subject(
      source: source(),
      onChoice: (_) {},
      expectedDate: date,
    ));

    expect(
        find.textContaining(DateFormat.yMMMd().format(date)), findsOneWidget);
    expect(find.text('I expect it later'), findsOneWidget);
  });

  testWidgets('each choice returns its own value', (tester) async {
    IncomeActivationChoice? chosen;
    await tester.pumpWidget(subject(
      source: source(),
      onChoice: (value) => chosen = value,
    ));

    await tester.tap(find.text('I already received it'));
    expect(chosen, IncomeActivationChoice.alreadyReceived);

    chosen = null;
    await tester.tap(find.text('I expect it later'));
    expect(chosen, IncomeActivationChoice.expectLater);

    chosen = null;
    await tester.tap(find.text('Start from the next period'));
    expect(chosen, IncomeActivationChoice.startNext);
  });

  testWidgets('Not now closes without a choice', (tester) async {
    IncomeActivationChoice? chosen;
    var closed = false;
    await tester.pumpWidget(subject(
      source: source(),
      onChoice: (value) => chosen = value,
      onClose: () => closed = true,
    ));

    await tester.tap(find.text('Not now'));

    expect(closed, isTrue);
    expect(chosen, isNull);
  });

  testWidgets('a future-start source explains the start and offers no choices',
      (tester) async {
    IncomeActivationChoice? chosen;
    await tester.pumpWidget(subject(
      source: source(start: DateTime.utc(2026, 12, 1)),
      onChoice: (value) => chosen = value,
      startsInFuture: true,
    ));

    expect(find.text('This income starts in December 2026.'), findsOneWidget);
    expect(find.text('I already received it'), findsNothing);
    expect(find.text('I expect it later'), findsNothing);
    expect(find.text('Start from the next period'), findsNothing);
    expect(find.text('Close'), findsOneWidget);
    expect(chosen, isNull);
  });

  testWidgets('200% text keeps the choices reachable', (tester) async {
    IncomeActivationChoice? chosen;
    await tester.pumpWidget(subject(
      source: source(),
      onChoice: (value) => chosen = value,
      scaler: const TextScaler.linear(2),
    ));

    expect(find.text('I already received it'), findsOneWidget);
    expect(find.text('I expect it later'), findsOneWidget);
    expect(find.text('Start from the next period'), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(chosen, isNull);
  });
}
