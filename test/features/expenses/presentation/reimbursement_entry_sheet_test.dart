import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import 'package:budget_buddy/features/expenses/presentation/widgets/reimbursement_entry_sheet.dart';
import 'package:budget_buddy/features/expenses/providers/reimbursement_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Defect-batch walkthrough: the medical detail "Log Reimbursement" button
/// crashed the sheet on its first frame for every self-paid bill saved by the
/// current form, because the linked expense stores a lowercase code (`huf`)
/// while the sheet's currency dropdown only lists uppercase items.
void main() {
  Expense makeExpense() => Expense(
        profileId: 1,
        yearMonth: '2026-01',
        budgetId: 1,
        title: 'Dentist',
        amount: 100000,
        currency: 'huf',
        categoryId: Expense.defaultCategoryId,
        date: DateTime(2026, 1, 15),
        status: ExpenseStatus.paid,
      );

  MedicalBill makeBill() => MedicalBill()
    ..id = 1
    ..billedAmount = 100000
    ..patientSharePercent = 20
    ..currency = 'huf'
    ..linkedExpenseId = 1;

  testWidgets('a lowercase bill currency seeds the dropdown without asserting',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          reimbursementsByExpenseProvider.overrideWith(
            (ref, expenseId) => Stream.value(const <Reimbursement>[]),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: ReimbursementEntrySheet(
              expense: makeExpense(),
              medicalBill: makeBill(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull,
        reason: 'the seeded dropdown value must match an uppercase item');
    expect(find.text('HUF'), findsOneWidget);
    expect(find.text('HUF'), findsNWidgets(1));
    expect(
        find.text('This expense is already fully reimbursed.'), findsNothing);
  });
}
