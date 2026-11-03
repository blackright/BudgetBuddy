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
    MedicalPaymentMethod method = MedicalPaymentMethod.selfPaid,
    MedicalInsuranceRequestStatus request =
        MedicalInsuranceRequestStatus.inProgress,
  }) =>
      MedicalBill()
        ..id = 1
        ..profileId = 1
        ..billedAmount = 10000
        ..patientSharePercent = 20
        ..currency = 'usd'
        ..yearMonth = '2026-03'
        ..paymentMethod = method
        ..providerPaymentStatus = method == MedicalPaymentMethod.insurerPaid
            ? MedicalProviderPaymentStatus.notRequired
            : MedicalProviderPaymentStatus.paid
        ..insuranceRequestStatus = request
        ..salarySettlementType = method == MedicalPaymentMethod.insurerPaid
            ? MedicalSalarySettlementType.userShareDeduction
            : MedicalSalarySettlementType.insuranceRefund;

  testWidgets('rejected user-paid bill offers accept or appeal',
      (tester) async {
    await pump(tester, bill(request: MedicalInsuranceRequestStatus.rejected));

    expect(find.text('Resolve rejection'), findsOneWidget);
    await tester.tap(find.byKey(const Key('managementPrimaryAction')));
    await tester.pumpAndSettle();
    expect(find.text('Accept rejection'), findsOneWidget);
    expect(find.text('Record an appeal'), findsOneWidget);
  });

  testWidgets('insurance-paid rejection offers the resolution choices',
      (tester) async {
    await pump(
      tester,
      bill(
        method: MedicalPaymentMethod.insurerPaid,
        request: MedicalInsuranceRequestStatus.rejected,
      ),
    );

    await tester.tap(find.byKey(const Key('managementPrimaryAction')));
    await tester.pumpAndSettle();
    expect(find.text('Provider cancelled the charge'), findsOneWidget);
    expect(find.text('I paid the provider'), findsOneWidget);
    expect(find.text('Adjusted salary deduction'), findsOneWidget);
  });

  testWidgets('in-progress request exposes cancellation', (tester) async {
    await pump(tester, bill(request: MedicalInsuranceRequestStatus.inProgress));

    expect(find.text('Cancel request'), findsOneWidget);
    await tester.tap(find.text('Cancel request'));
    await tester.pumpAndSettle();
    expect(find.text('Reason'), findsOneWidget);
  });

  testWidgets('appeal in progress opens the outcome choices', (tester) async {
    await pump(
        tester, bill(request: MedicalInsuranceRequestStatus.appealSubmitted));
    expect(find.text('Record appeal outcome'), findsOneWidget);
    await tester.tap(find.byKey(const Key('managementPrimaryAction')));
    await tester.pumpAndSettle();
    expect(find.text('Appeal approved'), findsOneWidget);
    expect(find.text('Appeal rejected'), findsOneWidget);
  });
}
