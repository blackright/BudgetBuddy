import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/models/medical_approval.dart';
import 'package:budget_buddy/core/providers/selected_month_provider.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/core/services/medical_receipt_service.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/expenses/presentation/widgets/medical_expense_link.dart';
import 'package:budget_buddy/features/expenses/presentation/widgets/reimbursement_entry_sheet.dart';
import 'package:budget_buddy/features/medical/presentation/medical_detail_screen.dart';
import 'package:budget_buddy/features/medical/providers/medical_providers.dart';
import 'package:budget_buddy/features/medical/providers/medical_receipt_provider.dart';
import 'package:budget_buddy/features/spaces/providers/spaces_providers.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/features/identity/providers/device_auth_session.dart';
import 'package:budget_buddy/features/security/providers/lock_providers.dart';

class _DetailSession extends DeviceAuthSession {
  @override
  bool isCurrent(int generation) =>
      state.authenticated && state.generation == generation;
  @override
  NativeAuthSnapshot build() => const NativeAuthSnapshot(
      generation: 1,
      binding: NativeAccessBinding(key: 'cleanup-fixture'),
      authenticated: true);
}

class _DetailLock extends LockController {
  @override
  LockSnapshot build() => const LockSnapshot();
}

void main() {
  Expense expense() => Expense(
      profileId: 1,
      yearMonth: '2026-10',
      budgetId: 1,
      title: 'Dentist',
      amount: 10000,
      currency: 'huf',
      categoryId: 'medical',
      date: DateTime(2026, 10, 20),
      type: ExpenseType.medical);
  MedicalBill bill() => MedicalBill()
    ..id = 42
    ..profileId = 1
    ..yearMonth = '2026-10'
    ..billedAmount = 10000
    ..currency = 'huf'
    ..state = MedicalBillState.paid
    ..linkedExpenseId = 1;

  testWidgets(
      'personal claim has one history and retains bill payment controls after approval',
      (tester) async {
    final claim = bill();
    final history = MedicalReceiptHistory(
        bill: claim,
        expense: expense(),
        approvals: [
          MedicalApproval()
            ..approvedMinor = 8000
            ..currency = 'huf'
            ..decisionDate = DateTime(2026, 10, 22)
        ],
        returns: [],
        revisions: [],
        receivedMinor: 0,
        closure: null);
    await tester.pumpWidget(ProviderScope(overrides: [
      budgetContextProvider.overrideWithValue(
          ContextRef.personal(profileId: 1, yearMonth: '2026-10')),
      actingProfileIdProvider.overrideWithValue(1),
      deviceAuthSessionProvider.overrideWith(_DetailSession.new),
      lockControllerProvider.overrideWith(_DetailLock.new),
      medicalBillMonthBlockersProvider.overrideWith((ref, id) async => []),
      medicalBillProvider.overrideWith((ref, id) => Stream.value(claim)),
      medicalReceiptHistoryProvider
          .overrideWith((ref, id) => Stream.value(history)),
      medicalDirectoryProvider.overrideWithValue(
          const MedicalDirectory(members: [], providers: [])),
      medicalDisplayCurrencyProvider.overrideWithValue(CurrencyCode.huf),
      activeContextCanEditProvider.overrideWithValue(true),
      selectedYearMonthProvider.overrideWith((ref) => '2026-10'),
      rateRegistryProvider.overrideWithValue(RateTableRegistry()),
    ], child: const MaterialApp(home: MedicalDetailScreen(billId: 42))));
    await tester.pumpAndSettle();
    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Money'), findsOneWidget);
    expect(find.text('Activity'), findsOneWidget);
    expect(find.byKey(const Key('state-waiting')), findsNothing);
    expect(find.byKey(const Key('state-finished')), findsNothing);
    expect(find.text('Log Reimbursement'), findsNothing);
    expect(find.text('Activity history'), findsNothing);
    expect(find.text('Bill actions'), findsNothing);
    expect(find.text('Record insurance reply'), findsNothing);
    expect(find.text('Claim history'), findsNothing);
    expect(find.text('Reimbursement History'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  for (final owner in [1, 2]) {
    testWidgets('Medical expense link checks the current owner $owner',
        (tester) async {
      final router = GoRouter(routes: [
        GoRoute(
            path: '/',
            builder: (_, __) =>
                const Scaffold(body: MedicalExpenseLink(expenseId: 1))),
        GoRoute(
            path: '/medical_detail',
            builder: (_, state) =>
                Scaffold(body: Text('Opened bill ${state.extra}'))),
      ]);
      addTearDown(router.dispose);
      await tester.pumpWidget(ProviderScope(overrides: [
        budgetContextProvider.overrideWithValue(
            ContextRef.personal(profileId: owner, yearMonth: '2026-10')),
        medicalBillForExpenseProvider
            .overrideWith((ref, id) => Stream.value(bill())),
      ], child: MaterialApp.router(routerConfig: router)));
      await tester.pumpAndSettle();
      expect(find.text('Medical expense'), findsOneWidget);
      await tester.tap(find.text('View Medical claim'));
      await tester.pumpAndSettle();
      expect(find.text('Opened bill 42'),
          owner == 1 ? findsOneWidget : findsNothing);
      if (owner != 1) expect(find.text('Medical expense'), findsOneWidget);
    });
  }
  testWidgets('missing Medical link does not guess or expose another bill',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
        overrides: [
          budgetContextProvider.overrideWithValue(
              ContextRef.personal(profileId: 1, yearMonth: '2026-10')),
          medicalBillForExpenseProvider
              .overrideWith((ref, id) => Stream.value(null)),
        ],
        child: const MaterialApp(
            home: Scaffold(body: MedicalExpenseLink(expenseId: 1)))));
    await tester.pumpAndSettle();
    expect(find.text('View Medical claim'), findsNothing);
    expect(find.textContaining('No linked bill'), findsOneWidget);
  });
  testWidgets(
      'an already-open old personal Medical form has no cash save action',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
            home:
                Scaffold(body: ReimbursementEntrySheet(expense: expense())))));
    await tester.pumpAndSettle();
    expect(find.textContaining('Record insurance refunds'), findsOneWidget);
    expect(find.text('Save Reimbursement'), findsNothing);
    expect(find.byKey(const Key('reimbursementAmountField')), findsNothing);
  });
}
