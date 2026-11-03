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

  MedicalBill directBill({
    required MedicalInsuranceRequestStatus request,
    required MedicalSalarySettlementStatus settlement,
    int? settlementAmount,
    double share = 20,
  }) =>
      MedicalBill()
        ..id = 1
        ..profileId = 1
        ..billedAmount = 10000
        ..patientSharePercent = share
        ..currency = 'usd'
        ..yearMonth = '2026-03'
        ..paymentMethod = MedicalPaymentMethod.insurerPaid
        ..providerPaymentStatus = MedicalProviderPaymentStatus.notRequired
        ..insuranceRequestStatus = request
        ..salarySettlementType = MedicalSalarySettlementType.userShareDeduction
        ..salarySettlementStatus = settlement
        ..settlementAmountMinor = settlementAmount;

  testWidgets('100% approved bill asks for case completion', (tester) async {
    await pump(
      tester,
      directBill(
        request: MedicalInsuranceRequestStatus.approved,
        settlement: MedicalSalarySettlementStatus.notRequired,
        settlementAmount: 0,
        share: 0,
      ),
    );

    expect(find.text('Approved at 100%'), findsOneWidget);
    expect(find.text('Confirm case complete'), findsOneWidget);
    await tester.tap(find.byKey(const Key('managementPrimaryAction')));
    await tester.pumpAndSettle();
    expect(find.text('Confirm case complete?'), findsOneWidget);
  });

  testWidgets('approved share opens the deduction payslip sheet',
      (tester) async {
    await pump(
      tester,
      directBill(
        request: MedicalInsuranceRequestStatus.approved,
        settlement: MedicalSalarySettlementStatus.waitingForPayslip,
        settlementAmount: 2000,
      ),
      textScale: 2,
    );

    expect(find.text('Waiting for payslip'), findsOneWidget);
    expect(find.text('Check payslip'), findsOneWidget);
    await tester.tap(find.byKey(const Key('managementPrimaryAction')));
    await tester.pumpAndSettle();
    expect(find.text('Confirm salary deduction'), findsOneWidget);
    expect(find.text('Confirm deduction'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
