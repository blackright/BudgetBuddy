import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/features/expenses/presentation/expense_destination_guard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host(Future<void> Function(BuildContext) open, {ThemeData? theme}) =>
      MaterialApp(
        theme: theme,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => open(context),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

  testWidgets('a paid Main expense explains and can be saved', (tester) async {
    ExpenseDestinationDecision? decision;
    await tester.pumpWidget(host((context) async {
      decision = await confirmExpenseDestination(context,
          amountText: 'Ft 1,000', status: ExpenseStatus.paid, title: 'Coffee');
    }));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Save without a budget?'), findsOneWidget);
    expect(
        find.textContaining('Ft 1,000 will come from your free-to-use money'),
        findsOneWidget);
    await tester.tap(find.text('Save to free-to-use'));
    await tester.pumpAndSettle();

    expect(decision, ExpenseDestinationDecision.save);
  });

  testWidgets('the user can choose a profile instead', (tester) async {
    ExpenseDestinationDecision? decision;
    await tester.pumpWidget(host((context) async {
      decision = await confirmExpenseDestination(context,
          amountText: 'Ft 1,000', status: ExpenseStatus.paid, title: 'Coffee');
    }));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Choose a profile'));
    await tester.pumpAndSettle();

    expect(decision, ExpenseDestinationDecision.changeProfile);
  });

  testWidgets('dismissing the warning cancels the save', (tester) async {
    ExpenseDestinationDecision? decision;
    await tester.pumpWidget(host((context) async {
      decision = await confirmExpenseDestination(context,
          amountText: 'Ft 1,000', status: ExpenseStatus.paid, title: 'Coffee');
    }));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(decision, ExpenseDestinationDecision.cancel);
  });

  testWidgets('a planned Main expense uses when-paid wording', (tester) async {
    await tester.pumpWidget(host((context) async {
      await confirmExpenseDestination(context,
          amountText: 'Ft 1,000',
          status: ExpenseStatus.planned,
          title: 'Coffee');
    }));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.textContaining('When it is paid, Ft 1,000 will come'),
        findsOneWidget);
  });

  testWidgets('a shared Main expense combines space and free-to-use',
      (tester) async {
    await tester.pumpWidget(host((context) async {
      await confirmExpenseDestination(context,
          amountText: 'Ft 1,000',
          status: ExpenseStatus.planned,
          title: 'Groceries',
          spaceName: 'Home');
    }));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Review this save'), findsOneWidget);
    expect(find.textContaining('Add "Groceries" (Ft 1,000) to "Home"?'),
        findsOneWidget);
    expect(find.textContaining("space's free-to-use money"), findsOneWidget);
  });

  test('the destination guard decides by destination and remaining allocation',
      () {
    expect(
        destinationGuardFor(
                isMain: true,
                isDirect: false,
                remainingMinor: null,
                amountMinorInContext: 1000)
            ?.kind,
        DestinationGuardKind.unbudgeted);
    expect(
        destinationGuardFor(
                isMain: false,
                isDirect: true,
                remainingMinor: null,
                amountMinorInContext: 1000)
            ?.kind,
        DestinationGuardKind.direct);
    expect(
        destinationGuardFor(
            isMain: false,
            isDirect: false,
            remainingMinor: 5000,
            amountMinorInContext: 3000),
        isNull);
    final over = destinationGuardFor(
        isMain: false,
        isDirect: false,
        remainingMinor: 5000,
        amountMinorInContext: 8000)!;
    expect(over.kind, DestinationGuardKind.overAllocation);
    expect(over.remainingMinor, 5000);
    expect(over.borrowMinor, 3000);
    final zero = destinationGuardFor(
        isMain: false,
        isDirect: false,
        remainingMinor: 0,
        amountMinorInContext: 1000)!;
    expect(zero.borrowMinor, 1000);
  });

  testWidgets('a direct profile warns in its own colour', (tester) async {
    await tester.pumpWidget(host((context) async {
      await confirmExpenseDestination(context,
          kind: DestinationGuardKind.direct,
          amountText: 'Ft 1,000',
          status: ExpenseStatus.planned,
          title: 'Taxi',
          profileName: 'Travel',
          profileColor: Colors.blue);
    }));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Save to Travel?'), findsOneWidget);
    expect(find.textContaining('no allocation'), findsOneWidget);
    expect(find.text('Save to Travel'), findsOneWidget);
  });

  testWidgets('an over-allocation warning names the remaining and borrow',
      (tester) async {
    await tester.pumpWidget(host((context) async {
      await confirmExpenseDestination(context,
          kind: DestinationGuardKind.overAllocation,
          amountText: 'Ft 3,000',
          status: ExpenseStatus.planned,
          title: 'Lunch',
          profileName: 'Food',
          profileColor: Colors.teal,
          remainingText: 'Ft 2,000',
          borrowText: 'Ft 1,000');
    }));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Save to Food anyway?'), findsOneWidget);
    expect(find.textContaining('Food has Ft 2,000 left'), findsOneWidget);
    expect(find.textContaining('borrow Ft 1,000'), findsOneWidget);
    expect(find.text('Save to Food'), findsOneWidget);
  });

  for (final dark in [false, true]) {
    testWidgets('guard stays reachable at 320 wide and 200% text, dark=$dark',
        (tester) async {
      tester.view.physicalSize = const Size(640, 1800);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpWidget(host((context) async {
        await confirmExpenseDestination(context,
            amountText: 'Ft 1,000',
            status: ExpenseStatus.paid,
            title: 'Coffee');
      },
          theme: ThemeData(
              brightness: dark ? Brightness.dark : Brightness.light)));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('destinationGuardDialog')), findsOneWidget);
      expect(find.text('Save to free-to-use'), findsOneWidget);
    });
  }
}
