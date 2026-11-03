import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/medical_approval.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/services/medical_receipt_service.dart';
import 'package:budget_buddy/features/medical/presentation/medical_document_picker.dart';
import 'package:budget_buddy/features/medical/presentation/medical_management_detail.dart';
import 'package:budget_buddy/features/medical/presentation/medical_management_drafts.dart';
import 'package:budget_buddy/features/medical/presentation/medical_management_sheets.dart';
import 'package:budget_buddy/features/medical/providers/medical_providers.dart';
import 'package:budget_buddy/features/medical/providers/medical_receipt_provider.dart';

void main() {
  test('management drafts round-trip and clear', () {
    MedicalManagementDrafts.setText(1, 'submit', 'amount', '100');
    MedicalManagementDrafts.setDate(
        1, 'submit', 'date', DateTime.utc(2026, 4, 1));
    MedicalManagementDrafts.setDocuments(1, 'submit', ['a.pdf']);
    expect(MedicalManagementDrafts.text(1, 'submit', 'amount'), '100');
    expect(MedicalManagementDrafts.date(1, 'submit', 'date'),
        DateTime.utc(2026, 4, 1));
    expect(MedicalManagementDrafts.documents(1, 'submit'), ['a.pdf']);
    MedicalManagementDrafts.clear(1, 'submit');
    expect(MedicalManagementDrafts.text(1, 'submit', 'amount'), isNull);
    expect(MedicalManagementDrafts.documents(1, 'submit'), isEmpty);
  });

  testWidgets('document picker lists and removes an attached file',
      (tester) async {
    var paths = ['payslip.pdf'];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) => MedicalDocumentPicker(
            paths: paths,
            onChanged: (next) => setState(() => paths = next),
          ),
        ),
      ),
    ));
    expect(find.text('payslip.pdf'), findsOneWidget);
    await tester.tap(find.byTooltip('Remove document'));
    await tester.pumpAndSettle();
    expect(find.text('payslip.pdf'), findsNothing);
    expect(paths, isEmpty);
  });

  testWidgets('money card, timeline and documents render at 320px',
      (tester) async {
    final bill = MedicalBill()
      ..id = 1
      ..profileId = 1
      ..billedAmount = 10000
      ..patientSharePercent = 20
      ..currency = 'usd'
      ..yearMonth = '2026-03'
      ..insuranceRequestStatus = MedicalInsuranceRequestStatus.completed
      ..salarySettlementStatus = MedicalSalarySettlementStatus.received
      ..settledAmountMinor = 8000
      ..actualSalaryMonth = '2026-05';
    final approval = MedicalApproval()
      ..billGuid = bill.syncGuid
      ..approvedMinor = 8000
      ..approvedBillMinor = 10000
      ..approvedShareMinor = 2000
      ..approvedInsuranceMinor = 8000
      ..currency = 'usd'
      ..decisionDate = DateTime.utc(2026, 4, 2)
      ..recordedAt = DateTime.utc(2026, 4, 2);
    final history = MedicalReceiptHistory(
      bill: bill,
      expense: Expense(
        profileId: 1,
        yearMonth: '2026-03',
        title: 'Medical',
        amount: 10000,
        currency: 'usd',
        categoryId: 'health',
        date: DateTime.utc(2026, 3, 1),
        budgetId: 1,
        type: ExpenseType.medical,
        status: ExpenseStatus.paid,
      ),
      approvals: [approval],
      returns: const [],
      revisions: const [],
      receivedMinor: 8000,
      closure: null,
      activities: [
        MedicalClaimActivity()
          ..billGuid = bill.syncGuid
          ..profileId = 1
          ..yearMonth = '2026-03'
          ..kind = 'refundReceived'
          ..reason = ''
          ..currency = 'usd'
          ..recordedAt = DateTime.utc(2026, 5, 10)
          ..transactionMonth = '2026-05'
          ..documentPaths = ['payslip.pdf']
          ..correctedByGuid = 'activity:correction'
          ..operationIdentity = 'activity:one'
          ..inputFingerprint = 'fp'
          ..afterMinor = 8000,
      ],
    );

    tester.view.physicalSize = const Size(320, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        medicalBillProvider.overrideWith((ref, id) => Stream.value(bill)),
        medicalReceiptHistoryProvider
            .overrideWith((ref, id) => Stream.value(history)),
      ],
      child: const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
              textScaler: TextScaler.linear(2), size: Size(320, 2000)),
          child: MedicalManagementDetail(billId: 1),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Money'), findsOneWidget);
    expect(find.text('Approved'), findsOneWidget);
    expect(find.text('Actual'), findsOneWidget);
    expect(find.text('Refund received'), findsWidgets);
    expect(find.textContaining('1 document(s)'), findsOneWidget);
    expect(find.text('corrected'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shared bill hides salary months from the money card',
      (tester) async {
    final bill = MedicalBill()
      ..id = 2
      ..sharedSpaceId = 7
      ..billedAmount = 10000
      ..patientSharePercent = 20
      ..currency = 'usd'
      ..yearMonth = '2026-03'
      ..expectedSalaryMonth = '2026-05'
      ..actualSalaryMonth = '2026-06'
      ..salarySettlementStatus = MedicalSalarySettlementStatus.received
      ..settledAmountMinor = 8000;
    final history = MedicalReceiptHistory(
      bill: bill,
      expense: Expense(
        profileId: 0,
        sharedSpaceId: 7,
        yearMonth: '2026-03',
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
    await tester.pumpWidget(ProviderScope(
      overrides: [
        medicalBillProvider.overrideWith((ref, id) => Stream.value(bill)),
        medicalReceiptHistoryProvider
            .overrideWith((ref, id) => Stream.value(history)),
      ],
      child: const MaterialApp(
        home: MedicalManagementDetail(billId: 2),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Expected salary month: 2026-05'), findsNothing);
    expect(find.text('Actual month'), findsNothing);
    expect(find.textContaining('2026-06'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('money values use thousands separators', (tester) async {
    final bill = MedicalBill()
      ..id = 4
      ..profileId = 1
      ..billedAmount = 1234567
      ..patientSharePercent = 20
      ..currency = 'huf'
      ..yearMonth = '2026-03';
    final history = MedicalReceiptHistory(
      bill: bill,
      expense: Expense(
        profileId: 1,
        yearMonth: '2026-03',
        title: 'Medical',
        amount: 1234567,
        currency: 'huf',
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
    await tester.pumpWidget(ProviderScope(
      overrides: [
        medicalBillProvider.overrideWith((ref, id) => Stream.value(bill)),
        medicalReceiptHistoryProvider
            .overrideWith((ref, id) => Stream.value(history)),
      ],
      child: const MaterialApp(
        home: MedicalManagementDetail(billId: 4),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('1,234,567'), findsWidgets);
    expect(find.textContaining('1234567'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('close bill asks for explicit confirmation with bill summary',
      (tester) async {
    final bill = MedicalBill()
      ..id = 5
      ..profileId = 1
      ..billedAmount = 10000
      ..patientSharePercent = 20
      ..currency = 'usd'
      ..yearMonth = '2026-03'
      ..serviceDate = DateTime.utc(2026, 3, 1)
      ..insuranceRequestStatus = MedicalInsuranceRequestStatus.completed
      ..salarySettlementType = MedicalSalarySettlementType.insuranceRefund
      ..salarySettlementStatus = MedicalSalarySettlementStatus.received
      ..settledAmountMinor = 8000;
    final history = MedicalReceiptHistory(
      bill: bill,
      expense: Expense(
        profileId: 1,
        yearMonth: '2026-03',
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
      receivedMinor: 8000,
      closure: null,
    );
    await tester.pumpWidget(ProviderScope(
      overrides: [
        medicalBillProvider.overrideWith((ref, id) => Stream.value(bill)),
        medicalReceiptHistoryProvider
            .overrideWith((ref, id) => Stream.value(history)),
      ],
      child: const MaterialApp(
        home: MedicalManagementDetail(billId: 5),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('managementPrimaryAction')));
    await tester.pumpAndSettle();

    expect(find.text('Close this bill?'), findsOneWidget);
    expect(find.text('Bill total'), findsWidgets);
    expect(find.text('Your share'), findsWidgets);
    expect(find.text('Payment'), findsWidgets);
    expect(find.text('Service date'), findsWidgets);
    expect(find.text('Current status'), findsOneWidget);
    final confirm = find.byKey(const Key('closeBillConfirm'));
    expect(tester.widget<FilledButton>(confirm).onPressed, isNull);

    await tester.tap(find.byKey(const Key('closeBillUnderstand')));
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(confirm).onPressed, isNotNull);

    await tester.tap(find.byKey(const Key('closeBillKeepOpen')));
    await tester.pumpAndSettle();
    expect(find.text('Close this bill?'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('needs-review bill offers only the review action',
      (tester) async {
    final bill = MedicalBill()
      ..id = 3
      ..profileId = 1
      ..billedAmount = 10000
      ..patientSharePercent = 20
      ..currency = 'usd'
      ..yearMonth = '2026-03'
      ..needsReview = true;
    final history = MedicalReceiptHistory(
      bill: bill,
      expense: Expense(
        profileId: 1,
        yearMonth: '2026-03',
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
    await tester.pumpWidget(ProviderScope(
      overrides: [
        medicalBillProvider.overrideWith((ref, id) => Stream.value(bill)),
        medicalReceiptHistoryProvider
            .overrideWith((ref, id) => Stream.value(history)),
      ],
      child: const MaterialApp(
        home: MedicalManagementDetail(billId: 3),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Needs review'), findsOneWidget);
    expect(find.text('Review bill'), findsOneWidget);
    expect(find.text('Submit request'), findsNothing);
    expect(find.textContaining('before the new workflow can continue'),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('approved amounts prefill next salary month and stay editable',
      (tester) async {
    const billId = 99;
    addTearDown(
        () => MedicalManagementDrafts.clear(billId, 'reviewApprovedAmounts'));
    final bill = MedicalBill()
      ..id = billId
      ..profileId = 1
      ..billedAmount = 10000
      ..patientSharePercent = 20
      ..currency = 'usd'
      ..yearMonth = '2026-03'
      ..submissionDate = DateTime.utc(2026, 10, 15);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: MedicalApprovedAmountsSheet(bill: bill)),
    ));
    await tester.pumpAndSettle();

    final dropdowns = tester
        .widgetList<DropdownButtonFormField<int>>(
            find.byType(DropdownButtonFormField<int>))
        .toList();
    expect(dropdowns.first.initialValue, 11);
    expect(dropdowns.last.initialValue, 2026);
    expect(dropdowns.first.onChanged, isNotNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('check payslip prefills next bill month and the 1st',
      (tester) async {
    const billId = 100;
    addTearDown(
        () => MedicalManagementDrafts.clear(billId, 'recordSettlement'));
    final now = DateTime.now();
    final billMonth = DateTime(now.year, now.month + 1);
    final expected = DateTime(billMonth.year, billMonth.month + 1);
    final bill = MedicalBill()
      ..id = billId
      ..profileId = 1
      ..billedAmount = 10000
      ..patientSharePercent = 20
      ..currency = 'usd'
      ..yearMonth =
          '${billMonth.year.toString().padLeft(4, '0')}-${billMonth.month.toString().padLeft(2, '0')}'
      ..settlementAmountMinor = 8000;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: MedicalRefundSheet(bill: bill)),
    ));
    await tester.pumpAndSettle();

    final dropdowns = tester
        .widgetList<DropdownButtonFormField<int>>(
            find.byType(DropdownButtonFormField<int>))
        .toList();
    expect(dropdowns.first.initialValue, expected.month);
    expect(dropdowns.last.initialValue, expected.year);
    expect(find.text('Received date'), findsOneWidget);
    expect(find.textContaining('${expected.year}'), findsWidgets);
    expect(
        find.text(DateFormat.yMMMd()
            .format(DateTime(expected.year, expected.month, 1))),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
