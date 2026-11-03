import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:budget_buddy/core/services/medical_receipt_service.dart';
import 'package:budget_buddy/features/medical/presentation/medical_management_detail.dart';
import 'package:budget_buddy/features/medical/providers/medical_providers.dart';
import 'package:budget_buddy/features/medical/providers/medical_receipt_provider.dart';

import 'fixtures.dart';

void main() {
  testWidgets('planned bill stays usable at 320px with 200% text',
      (tester) async {
    final bill = plannedUserPaidBill(profileId: 1)..id = 1;
    final history = MedicalReceiptHistory(
      bill: bill,
      expense: buildLinkedMedicalExpense(bill, budgetId: 1),
      approvals: const [],
      returns: const [],
      revisions: const [],
      receivedMinor: 0,
      closure: null,
    );
    final semantics = tester.ensureSemantics();

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

    expect(find.text('Planned'), findsOneWidget);
    expect(find.text('Submit request'), findsOneWidget);
    expect(tester.takeException(), isNull);

    final action = find.byKey(const Key('managementPrimaryAction'));
    final node = tester.getSemantics(action);
    expect(node.label, contains('Submit request'));
    expect(node.flagsCollection.isButton, isTrue);

    await tester.tap(action);
    await tester.pumpAndSettle();
    expect(find.text('Amount paid to provider'), findsOneWidget);
    expect(find.text('Insurance reference (optional)'), findsOneWidget);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('money labels pair label and value at large text',
      (tester) async {
    final bill = plannedUserPaidBill(profileId: 1)..id = 1;
    final history = MedicalReceiptHistory(
      bill: bill,
      expense: buildLinkedMedicalExpense(bill, budgetId: 1),
      approvals: const [],
      returns: const [],
      revisions: const [],
      receivedMinor: 0,
      closure: null,
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

    expect(find.text('Bill total'), findsWidgets);
    expect(find.text('Your share'), findsWidgets);
    expect(find.text('Expected insurance refund'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
