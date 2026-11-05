import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/services/medical_receipt_service.dart';
import 'package:budget_buddy/features/medical/presentation/medical_management_detail.dart';
import 'package:budget_buddy/features/medical/providers/medical_providers.dart';
import 'package:budget_buddy/features/medical/providers/medical_receipt_provider.dart';

void main() {
  MedicalReceiptHistory history(MedicalBill bill) => MedicalReceiptHistory(
        bill: bill,
        expense: Expense(
          profileId: 1,
          yearMonth: bill.yearMonth,
          title: 'Medical',
          amount: 0,
          currency: 'usd',
          categoryId: 'health',
          date: DateTime.utc(2026, 3, 1),
          budgetId: 1,
          type: ExpenseType.medical,
          status: ExpenseStatus.planned,
        ),
        approvals: const [],
        returns: const [],
        revisions: const [],
        receivedMinor: 0,
        closure: null,
      );

  Future<void> pump(WidgetTester tester, MedicalBill bill,
      {double textScale = 1}) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        medicalBillProvider.overrideWith((ref, id) => Stream.value(bill)),
        medicalReceiptHistoryProvider
            .overrideWith((ref, id) => Stream.value(history(bill))),
      ],
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: const MedicalManagementDetail(billId: 1),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('planned user-paid bill shows one next action and the sheet',
      (tester) async {
    final bill = MedicalBill()
      ..id = 1
      ..profileId = 1
      ..billedAmount = 10000
      ..patientSharePercent = 20
      ..currency = 'usd'
      ..yearMonth = '2026-03'
      ..serviceDate = DateTime.utc(2026, 3, 1);

    await pump(tester, bill);

    expect(find.text('Planned'), findsOneWidget);
    expect(find.text('Submit request'), findsOneWidget);
    expect(find.byKey(const Key('managementPrimaryAction')), findsOneWidget);

    await tester.tap(find.byKey(const Key('managementPrimaryAction')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('submitAmountField')), findsOneWidget);
    expect(find.byKey(const Key('submitRequestConfirm')), findsOneWidget);
  });

  testWidgets('secondary actions render as real buttons', (tester) async {
    final bill = MedicalBill()
      ..id = 1
      ..profileId = 1
      ..billedAmount = 10000
      ..patientSharePercent = 20
      ..currency = 'usd'
      ..yearMonth = '2026-03'
      ..serviceDate = DateTime.utc(2026, 3, 1)
      ..providerPaymentStatus = MedicalProviderPaymentStatus.paid
      ..insuranceRequestStatus = MedicalInsuranceRequestStatus.submitted;

    await pump(tester, bill);

    for (final label in [
      'Set reminder',
      'Cancel request',
      'Provider refund',
    ]) {
      expect(find.widgetWithText(OutlinedButton, label), findsOneWidget);
      expect(find.widgetWithText(TextButton, label), findsNothing);
    }
  });

  testWidgets('waiting request shows payslip action at 200 percent text',
      (tester) async {
    final bill = MedicalBill()
      ..id = 1
      ..profileId = 1
      ..billedAmount = 10000
      ..patientSharePercent = 20
      ..currency = 'usd'
      ..yearMonth = '2026-03'
      ..insuranceRequestStatus = MedicalInsuranceRequestStatus.approved
      ..salarySettlementStatus = MedicalSalarySettlementStatus.waitingForPayslip
      ..settlementAmountMinor = 8000;

    await pump(tester, bill, textScale: 2);

    expect(find.text('Waiting for payslip'), findsOneWidget);
    expect(find.text('Check payslip'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
