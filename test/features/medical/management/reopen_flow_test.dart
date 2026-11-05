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
          amount: 10000,
          currency: 'usd',
          categoryId: 'health',
          date: DateTime.utc(2026, 3, 1),
          budgetId: 1,
          type: ExpenseType.medical,
          status: ExpenseStatus.paid,
        ),
        approvals: const [],
        returns: const [],
        revisions: const [],
        receivedMinor: 0,
        closure: null,
      );

  Future<void> pump(WidgetTester tester, MedicalBill bill) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        medicalBillProvider.overrideWith((ref, id) => Stream.value(bill)),
        medicalReceiptHistoryProvider
            .overrideWith((ref, id) => Stream.value(history(bill))),
      ],
      child: const MaterialApp(
        home: MedicalManagementDetail(billId: 1),
      ),
    ));
    await tester.pumpAndSettle();
  }

  MedicalBill bill({
    MedicalOverallStatus overall = MedicalOverallStatus.open,
    MedicalInsuranceRequestStatus request =
        MedicalInsuranceRequestStatus.completed,
    MedicalSalarySettlementStatus settlement =
        MedicalSalarySettlementStatus.received,
    MedicalProviderPaymentStatus provider = MedicalProviderPaymentStatus.paid,
  }) =>
      MedicalBill()
        ..id = 1
        ..profileId = 1
        ..billedAmount = 10000
        ..patientSharePercent = 20
        ..currency = 'usd'
        ..yearMonth = '2026-03'
        ..overallStatus = overall
        ..insuranceRequestStatus = request
        ..salarySettlementType = MedicalSalarySettlementType.insuranceRefund
        ..salarySettlementStatus = settlement
        ..providerPaymentStatus = provider
        ..settledAmountMinor = 8000;

  testWidgets('closed bill exposes reopen', (tester) async {
    await pump(
      tester,
      bill(overall: MedicalOverallStatus.closed),
    );
    expect(find.text('Bill closed'), findsOneWidget);
    expect(find.text('Reopen bill'), findsOneWidget);
    await tester.tap(find.byKey(const Key('managementPrimaryAction')));
    await tester.pumpAndSettle();
    expect(find.text('Reopen'), findsOneWidget);
  });

  testWidgets('provider refund is available for a paid provider',
      (tester) async {
    await pump(
        tester, bill(settlement: MedicalSalarySettlementStatus.notRequired));
    expect(find.text('Provider refund'), findsOneWidget);
  });

  testWidgets('received refund exposes correction', (tester) async {
    await pump(tester, bill());
    expect(find.text('Correct amount/month'), findsOneWidget);
    await tester.tap(find.text('Correct amount/month'));
    await tester.pumpAndSettle();
    expect(find.text('Correct amount or month'), findsOneWidget);
  });
}
