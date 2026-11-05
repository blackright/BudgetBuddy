import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_buddy/core/models/income_source.dart';
import 'package:budget_buddy/core/models/salary_cycle.dart';
import 'package:budget_buddy/features/finance/presentation/salary_receipt_sheet.dart';

void main() {
  IncomeSource source() => IncomeSource()
    ..name = 'Salary'
    ..type = IncomeSourceType.salary
    ..amount = 500000
    ..currency = 'huf'
    ..frequency = IncomeFrequency.monthly
    ..createdAt = DateTime.utc(2026, 10)
    ..updatedAt = DateTime.utc(2026, 10);

  SalaryCycle cycle() => SalaryCycle()
    ..sourceGuid = 'src-1'
    ..expectedAmountMinor = 500000
    ..currency = 'huf'
    ..occurrenceMonth = '2026-11'
    ..nominalPayday = DateTime.utc(2026, 10, 25)
    ..adjustedPayday = DateTime.utc(2026, 10, 25)
    ..confirmed = false
    ..state = 'unconfirmed'
    ..createdAt = DateTime.utc(2026, 10)
    ..updatedAt = DateTime.utc(2026, 10);

  Future<void> pumpSheet(WidgetTester tester,
          {DateTime? now, bool simplified = false, DateTime? initialDate}) =>
      tester.pumpWidget(ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SalaryReceiptSheet(
              source: source(),
              cycle: cycle(),
              now: now ?? DateTime(2026, 10, 28, 12),
              initialDate: initialDate,
              simplified: simplified,
              onConfirm: (p, k) async {},
            ),
          ),
        ),
      ));

  testWidgets('sheet shows the cash month, salary period and formatted amount',
      (tester) async {
    await pumpSheet(tester);
    await tester.pumpAndSettle();

    expect(find.text('Confirm salary received'), findsAtLeastNWidgets(1));
    expect(find.text('Counts in'), findsOneWidget);
    expect(find.text('October 2026'), findsOneWidget);
    expect(find.text('Salary period'), findsOneWidget);
    expect(find.text('November 2026'), findsOneWidget);
    expect(find.text('Amount received'), findsOneWidget);
    expect(find.text('Expected HUF 500,000'), findsOneWidget);
    expect(find.textContaining('Total that reached my bank'), findsOneWidget);
    expect(find.text('Not received yet'), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '500,000');
    expect(find.textContaining('Approved refunds'), findsNothing);
  });

  testWidgets('activation confirmation stays compact and keeps the period date',
      (tester) async {
    await pumpSheet(tester,
        simplified: true, initialDate: DateTime(2026, 10, 20, 12));
    await tester.pumpAndSettle();

    expect(find.text('Confirm received salary'), findsOneWidget);
    expect(find.text('Change time'), findsNothing);
    expect(find.text('Advanced options'), findsOneWidget);
    expect(find.textContaining('Oct 20, 2026'), findsOneWidget);
    expect(find.text('Expected HUF 500,000'), findsOneWidget);
  });

  testWidgets('received date allows past days and disables the future',
      (tester) async {
    await pumpSheet(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Received on'));
    await tester.pumpAndSettle();

    final dialog =
        tester.widget<DatePickerDialog>(find.byType(DatePickerDialog));
    expect(dialog.firstDate, DateTime(1970));
    expect(dialog.lastDate, DateTime(2026, 10, 28));
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsNothing);
  });

  testWidgets('change time uses the safe picker at small text scale',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 0.8;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpSheet(tester);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Change time'));
    await tester.tap(find.text('Change time'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(TimePickerDialog), findsOneWidget);

    await tester.tap(find.byIcon(Icons.keyboard_outlined));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
  });

  testWidgets('not received yet closes without confirming money',
      (tester) async {
    var confirmed = 0;
    final s = source();
    final c = cycle();
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showModalBottomSheet<bool>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => SalaryReceiptSheet(
                          source: s,
                          cycle: c,
                          now: DateTime(2026, 10, 28),
                          onConfirm: (p, k) async => confirmed++,
                        )),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Not received yet'));
    await tester.tap(find.text('Not received yet'));
    await tester.pumpAndSettle();

    expect(find.text('Confirm salary received'), findsNothing);
    expect(confirmed, 0);
  });
}
