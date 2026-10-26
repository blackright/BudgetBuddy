import 'package:budget_buddy/features/dashboard/providers/dashboard_providers.dart';
import 'package:budget_buddy/features/dashboard/presentation/widgets/budget_profile_cards.dart';
import 'dart:async';
import 'package:budget_buddy/core/models/budget_profile.dart';
import 'package:budget_buddy/core/models/direct_expense_profile.dart';
import 'package:budget_buddy/features/finance/providers/profile_providers.dart';
import 'package:budget_buddy/features/expenses/presentation/profile_picker_sheet.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/core/services/refund_service.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import 'package:budget_buddy/features/expenses/presentation/refund_dialog.dart';
import 'package:budget_buddy/features/expenses/presentation/widgets/refund_summary_card.dart';
import 'package:budget_buddy/features/expenses/providers/refund_provider.dart';
import 'package:budget_buddy/features/expenses/providers/reimbursement_provider.dart';
import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/features/settings/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

class _UnusedDatabase implements Isar {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _RecordingService extends RefundService {
  _RecordingService()
      : super(_UnusedDatabase(),
            context: ContextRef.personal(profileId: 1, yearMonth: '2026-10'),
            actingProfileId: 1,
            rates: RateTableRegistry());
  final operations = <String>[];
  final amounts = <int>[];
  Completer<void>? pending;
  bool failOnce = false;
  @override
  Future<Reimbursement> record(
      {required int expenseId,
      required int amount,
      required String operationId,
      String? note}) async {
    operations.add(operationId);
    amounts.add(amount);
    if (failOnce) {
      failOnce = false;
      throw StateError('disk error');
    }
    await pending?.future;
    return Reimbursement(
        profileId: 1,
        expenseId: expenseId,
        originYearMonth: '2026-10',
        amount: amount,
        currency: 'huf',
        date: DateTime(2026));
  }
}

Expense expense({String currency = 'huf', int amount = 130000}) => Expense(
    id: 1,
    profileId: 1,
    yearMonth: '2026-10',
    title: 'Purchase',
    amount: amount,
    currency: currency,
    categoryId: 'food',
    date: DateTime(2026),
    budgetId: 1);

void main() {
  Future<_RecordingService> open(WidgetTester tester,
      {bool failOnce = false, Completer<void>? pending}) async {
    final service = _RecordingService()
      ..failOnce = failOnce
      ..pending = pending;
    final quote = RefundQuote(
        expense: expense(),
        returnedMinor: 0,
        currency: CurrencyCode.huf,
        contextCurrency: CurrencyCode.huf,
        spent: 130000,
        allocation: 100000,
        reserve: 10000,
        direct: false,
        rates: RateTableRegistry());
    await tester.pumpWidget(ProviderScope(
        overrides: [
          refundServiceProvider.overrideWithValue(service),
          refundQuoteProvider(1).overrideWith((ref) async => quote),
        ],
        child: MaterialApp(
            home: Builder(
                builder: (context) => Scaffold(
                      body: TextButton(
                          onPressed: () => showDialog<bool>(
                              context: context,
                              builder: (_) => const RefundDialog(expenseId: 1)),
                          child: const Text('Open')),
                    )))));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    return service;
  }

  Finder amountField() => find.descendant(
      of: find.byKey(const Key('refundAmount')),
      matching: find.byType(TextFormField));

  testWidgets('preview explains the deficit and borrowing reductions',
      (tester) async {
    await open(tester);
    await tester.enterText(amountField(), '25000');
    await tester.pump();
    expect(find.text('Net spending: Ft 130,000 → Ft 105,000'), findsOneWidget);
    expect(find.text('Deficit reduced by Ft 20,000'), findsOneWidget);
    expect(find.text('Borrowing reduced by Ft 5,000'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('remaining shortcut fills the exact maximum and saves',
      (tester) async {
    final service = await open(tester);
    await tester.tap(find.text('Refund remaining amount'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('confirmRefund')));
    await tester.pumpAndSettle();
    expect(service.amounts, [130000]);
    expect(find.byType(RefundDialog), findsNothing);
  });
  testWidgets('an excessive amount cannot be confirmed', (tester) async {
    final service = await open(tester);
    await tester.enterText(amountField(), '130001');
    await tester.pump();
    expect(find.text('Amount exceeds the remaining refundable amount.'),
        findsOneWidget);
    expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('confirmRefund')))
            .onPressed,
        isNull);
    expect(service.operations, isEmpty);
  });
  testWidgets('cancel does not submit a refund', (tester) async {
    final service = await open(tester);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(service.operations, isEmpty);
    expect(find.byType(RefundDialog), findsNothing);
  });
  testWidgets('double taps submit once while a save is pending',
      (tester) async {
    final pending = Completer<void>();
    final service = await open(tester, pending: pending);
    await tester.enterText(amountField(), '25000');
    await tester.pump();
    await tester.tap(find.byKey(const Key('confirmRefund')));
    await tester.tap(find.byKey(const Key('confirmRefund')));
    await tester.pump();
    expect(service.operations, hasLength(1));
    expect(find.text('Saving…'), findsOneWidget);
    pending.complete();
    await tester.pumpAndSettle();
    expect(find.byType(RefundDialog), findsNothing);
  });
  testWidgets('save error is visible and retry retains the operation identity',
      (tester) async {
    final service = await open(tester, failOnce: true);
    await tester.enterText(amountField(), '25000');
    await tester.pump();
    await tester.tap(find.byKey(const Key('confirmRefund')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('refundError')), findsOneWidget);
    await tester.tap(find.byKey(const Key('confirmRefund')));
    await tester.pumpAndSettle();
    expect(service.operations, hasLength(2));
    expect(service.operations.first, service.operations.last);
    expect(find.byType(RefundDialog), findsNothing);
  });
  testWidgets(
      'summary card shows original, returned and remaining with history',
      (tester) async {
    final e = expense(currency: 'usd', amount: 10000);
    final row = Reimbursement(
        profileId: 1,
        expenseId: 1,
        originYearMonth: '2026-10',
        amount: 2500,
        currency: 'usd',
        date: DateTime(2026, 10, 23),
        note: 'Returned item');
    await tester.pumpWidget(ProviderScope(
        overrides: [
          reimbursementsByExpenseProvider(1)
              .overrideWith((ref) => Stream.value([row])),
          rateRegistryProvider.overrideWithValue(RateTableRegistry()),
          activeBudgetProvider.overrideWith((ref) => Stream.value(null)),
          mainCurrencyProvider.overrideWithValue(CurrencyCode.usd),
        ],
        child: MaterialApp(
            home: Scaffold(
                body: SingleChildScrollView(
                    child: RefundSummaryCard(expense: e))))));
    await tester.pumpAndSettle();
    expect(find.text(r'Originally paid: $ 100.00'), findsOneWidget);
    expect(find.text(r'Returned so far: $ 25.00'), findsOneWidget);
    expect(find.text(r'Still refundable: $ 75.00'), findsOneWidget);
    expect(find.text('Return history'), findsOneWidget);
    expect(find.text('Returned item'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  for (final direct in [false, true]) {
    testWidgets('profile picker distinguishes colliding IDs: direct=$direct',
        (tester) async {
      final now = DateTime(2026);
      ProfilePickerResult? choice;
      await tester.pumpWidget(ProviderScope(
          overrides: [
            budgetProfilesProvider.overrideWith((ref) => Stream.value([
                  BudgetProfile()
                    ..id = 1
                    ..profileId = 1
                    ..yearMonth = '2026-10'
                    ..name = 'Budget one'
                    ..createdAt = now
                    ..updatedAt = now,
                ])),
            directExpenseProfilesProvider.overrideWith((ref) => Stream.value([
                  DirectExpenseProfile()
                    ..id = 1
                    ..profileId = 1
                    ..yearMonth = '2026-10'
                    ..name = 'Direct one'
                    ..createdAt = now
                    ..updatedAt = now,
                ])),
          ],
          child: MaterialApp(
              home: Scaffold(
                  body: Builder(
                      builder: (context) => TextButton(
                          onPressed: () async {
                            choice = await ProfilePickerSheet.show(context);
                          },
                          child: const Text('Pick')))))));
      await tester.tap(find.text('Pick'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(direct ? 'Direct one' : 'Budget one'));
      await tester.pumpAndSettle();
      expect(choice!.profileId, 1);
      expect(choice!.profileType,
          direct ? FinancialProfileType.direct : FinancialProfileType.budget);
      expect(choice!.syncGuid, isNotEmpty);
    });
  }

  testWidgets('colliding profile pills expand the correct collection',
      (tester) async {
    DashboardProfileState state(bool direct) => DashboardProfileState(
        id: 1,
        name: direct ? 'Direct one' : 'Budget one',
        isDirect: direct,
        allocation: direct ? 0 : 10000,
        spent: 1000,
        expenseCount: 0,
        availableReserve: 10000,
        recentExpenses: const []);
    await tester.pumpWidget(ProviderScope(
        overrides: [
          dashboardProfilesProvider
              .overrideWithValue([state(false), state(true)]),
          dashboardCurrencyProvider.overrideWithValue(CurrencyCode.huf),
        ],
        child: const MaterialApp(
            home: Scaffold(
                body: SingleChildScrollView(child: BudgetProfileCards())))));
    await tester.tap(find.text('Direct one'));
    await tester.pumpAndSettle();
    expect(find.text('Direct one'), findsNWidgets(2));
    expect(find.text('Budget one'), findsOneWidget);
    await tester.tap(find.text('Budget one'));
    await tester.pumpAndSettle();
    expect(find.text('Budget one'), findsNWidgets(2));
    expect(find.text('Direct one'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
