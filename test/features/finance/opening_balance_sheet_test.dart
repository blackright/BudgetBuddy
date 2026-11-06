import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/providers/selected_month_provider.dart';
import 'package:budget_buddy/features/finance/presentation/opening_balance_sheet.dart';
import 'package:budget_buddy/features/finance/repositories/month_finance_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

class _UnusedDb implements Isar {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _RecordingRepository extends MonthFinanceRepository {
  _RecordingRepository() : super(_UnusedDb());

  String? yearMonth;
  double? amount;

  @override
  Future<void> saveOpeningBalance(String yearMonth, double amount) async {
    this.yearMonth = yearMonth;
    this.amount = amount;
  }
}

void main() {
  Widget subject(_RecordingRepository repository, {MonthlyBudget? budget}) =>
      ProviderScope(
        overrides: [
          monthFinanceRepositoryProvider.overrideWithValue(repository),
          selectedYearMonthProvider.overrideWith((ref) => '2026-10'),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: OpeningBalanceSheet(initialBudget: budget),
          ),
        ),
      );

  testWidgets('shows the amount, validates it and saves exactly once',
      (tester) async {
    final repository = _RecordingRepository();
    await tester.pumpWidget(subject(repository));
    await tester.pumpAndSettle();

    expect(find.text('Opening Balance'), findsOneWidget);
    expect(find.text('Money in the bank at the start of this month.'),
        findsOneWidget);

    await tester.enterText(
        find.byKey(const Key('openingBalanceField')), '1,234.56');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(repository.yearMonth, '2026-10');
    expect(repository.amount, 1234.56);
  });

  testWidgets('rejects an invalid amount without saving', (tester) async {
    final repository = _RecordingRepository();
    await tester.pumpWidget(subject(repository));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('openingBalanceField')), '');
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(find.text('Required'), findsOneWidget);
    expect(repository.amount, isNull);
  });

  testWidgets('stays reachable at 320 wide and 200% text', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    final repository = _RecordingRepository();
    await tester.pumpWidget(subject(repository,
        budget: MonthlyBudget()
          ..yearMonth = '2026-10'
          ..baseAvailableAmount = 100
          ..openingBalanceConfirmed = true));
    await tester.pumpAndSettle();

    expect(find.text('Opening Balance'), findsOneWidget);
    expect(find.byKey(const Key('openingBalanceField')), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
