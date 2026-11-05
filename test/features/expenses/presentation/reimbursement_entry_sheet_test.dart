import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/features/expenses/presentation/widgets/reimbursement_entry_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Expense makeExpense() => Expense(
        profileId: 1,
        sharedSpaceId: 7,
        type: ExpenseType.medical,
        yearMonth: '2026-01',
        budgetId: 1,
        title: 'Dentist',
        amount: 100000,
        currency: 'huf',
        categoryId: Expense.defaultCategoryId,
        date: DateTime(2026, 1, 15),
        status: ExpenseStatus.paid,
      );

  testWidgets('medical expenses are redirected to the Medical bill',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ReimbursementEntrySheet(expense: makeExpense()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.textContaining('Record insurance refunds'), findsOneWidget);
    expect(find.text('Record Reimbursement'), findsNothing);
  });
}
