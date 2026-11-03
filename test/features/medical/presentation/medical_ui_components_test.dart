import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/features/medical/presentation/medical_bill_view_state.dart';
import 'package:budget_buddy/features/medical/presentation/medical_empty_state.dart';
import 'package:budget_buddy/features/medical/presentation/medical_money_row.dart';
import 'package:budget_buddy/features/medical/presentation/medical_section_card.dart';
import 'package:budget_buddy/features/medical/presentation/medical_status_pill.dart';
import 'package:budget_buddy/features/medical/presentation/medical_summary_card.dart';
import 'package:budget_buddy/features/medical/presentation/medical_theme.dart';

void main() {
  Widget host(Widget child, {double width = 400}) => MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(width: width, child: child),
          ),
        ),
      );

  testWidgets('status pill pairs text with an icon', (tester) async {
    await tester.pumpWidget(host(const MedicalStatusPill(
      label: 'Waiting for insurance refund',
      group: MedicalInboxGroup.waiting,
    )));
    expect(find.text('Waiting for insurance refund'), findsOneWidget);
    expect(find.byIcon(Icons.hourglass_top_outlined), findsOneWidget);
  });

  testWidgets('summary card shows count, amount and scope', (tester) async {
    await tester.pumpWidget(host(const MedicalSummaryCard(
      needsYouCount: 3,
      waitingCount: 2,
      approvedStillToReceiveMinor: 8000,
      currency: CurrencyCode.huf,
      mainCurrency: CurrencyCode.huf,
      rateTable: null,
    )));
    expect(find.byKey(const Key('medicalInboxSummary')), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.textContaining('8,000'), findsOneWidget);
    expect(find.textContaining('All open bills across all months'),
        findsOneWidget);
  });

  testWidgets('empty state exposes one clear action', (tester) async {
    var cleared = 0;
    await tester.pumpWidget(host(MedicalEmptyState(
      icon: Icons.filter_alt_off_outlined,
      title: 'No bills match these filters',
      message: 'Clear a filter or choose another month.',
      actions: [
        TextButton(
          onPressed: () => cleared++,
          child: const Text('Clear filters'),
        ),
      ],
    )));
    expect(find.text('No bills match these filters'), findsOneWidget);
    await tester.tap(find.text('Clear filters'));
    expect(cleared, 1);
  });

  testWidgets('money row stays readable at narrow width', (tester) async {
    await tester.pumpWidget(host(
      const MedicalMoneyRow(
        label: 'Still to receive',
        value: 'HUF 7,500',
      ),
      width: 300,
    ));
    expect(tester.takeException(), isNull);
    expect(find.text('Still to receive'), findsOneWidget);
    expect(find.text('HUF 7,500'), findsOneWidget);
  });

  testWidgets('medical tokens remain the shared minimum target',
      (tester) async {
    expect(MedicalTheme.minTouchTarget, 48);
    expect(MedicalTheme.screenGutter, 16);
  });

  testWidgets('section card keeps its title and content together',
      (tester) async {
    await tester.pumpWidget(host(const MedicalSectionCard(
      title: 'Documents',
      child: Text('No documents yet.'),
    )));
    expect(find.text('Documents'), findsOneWidget);
    expect(find.text('No documents yet.'), findsOneWidget);
  });
}
