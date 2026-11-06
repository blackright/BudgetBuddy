import 'package:budget_buddy/core/database/isar_helper.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/services/quantity_math.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/expenses/providers/expenses_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/quantity_fixtures.dart';
import '../medical/repositories/medical_test_harness.dart';

/// US1 neutrality: quantity is additive metadata. Existing expenses stay at
/// quantity 1 with their recorded amount untouched, and the write boundary
/// rejects quantities outside the supported range.
void main() {
  test('a new expense defaults to quantity 1', () {
    final expense = Expense(
      profileId: 1,
      yearMonth: '2026-10',
      title: 'Coffee',
      amount: 1234,
      currency: 'HUF',
      categoryId: 'food',
      date: DateTime(2026, 10, 5),
      budgetId: 1,
    );
    expect(expense.quantity, 1);
    expect(expense.amount, 1234);
    expect(expense.unitAmountMinor, 1234);
  });

  group('medical, reimbursable, planned and cancelled expenses stay neutral',
      () {
    final cases = <String, Expense Function()>{
      'medical': () => quantityExpense(
          type: ExpenseType.medical,
          quantity: 1,
          amount: 4321,
          status: ExpenseStatus.paid),
      'reimbursable': () =>
          quantityExpense(quantity: 1, amount: 2500, status: ExpenseStatus.paid)
            ..isReimbursable = true,
      'planned': () => quantityExpense(
          quantity: 1, amount: 900, status: ExpenseStatus.planned),
      'cancelled': () => quantityExpense(
          quantity: 1, amount: 700, status: ExpenseStatus.cancelled),
    };

    for (final entry in cases.entries) {
      test(entry.key, () {
        final expense = entry.value();
        expect(expense.quantity, 1);
        expect(expense.amount, inInclusiveRange(1, maximumMinorAmount));
        expect(expense.unitAmountMinor, expense.amount);
        expect(
            quantityLineTotalMinor(
                unitMinor: expense.unitAmountMinor!,
                quantity: expense.quantity),
            expense.amount);
      });
    }
  });

  test('copying for edit preserves quantity but no other quantity is inferred',
      () {
    final expense = quantityExpense(amount: 1500, quantity: 3);
    final copy = expense.copyForEditing();
    expect(copy.quantity, 3);
    expect(copy.amount, 1500);
    expect(copy.unitAmountMinor, 500);
  });

  group('write boundary', () {
    late MedicalTestHarness h;
    setUp(() async {
      h = await MedicalTestHarness.create();
      IsarHelper.instance = h.isar;
    });
    tearDown(() => h.close());

    ExpensesNotifier notifier() => ExpensesNotifier(
          null,
          (_) => 0,
          initialState: const AsyncValue.data([]),
          rateRegistry: RateTableRegistry(),
        );

    test('addExpense rejects unsupported quantities before writing', () async {
      for (final quantity in [0, -1, 1000]) {
        await expectLater(
            notifier().addExpense(quantityExpense(quantity: quantity)),
            throwsArgumentError);
      }
      expect(await h.isar.expenses.count(), 0);
    });

    test('updateExpense rejects unsupported quantities before reading',
        () async {
      for (final quantity in [0, -1, 1000]) {
        await expectLater(
            notifier().updateExpense(quantityExpense(quantity: quantity)),
            throwsArgumentError);
      }
    });
  });
}
