import 'dart:convert';
import 'dart:io';

import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/financial_report.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/services/export_csv_service.dart';
import 'package:budget_buddy/core/services/export_pdf_service.dart';
import 'package:budget_buddy/core/services/report_calculation.dart';
import 'package:budget_buddy/core/services/report_format.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import 'package:flutter_test/flutter_test.dart';

/// US1: reports carry the optional quantity and derived unit price, and the
/// CSV/PDF exports expose them without changing the recorded totals.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const owner = ReportOwner.personal(1);
  ReportRequest request() => ReportRequest(
      scope: ReportScope.personal,
      personalProfileId: 1,
      owners: [owner],
      firstMonth: '2026-10',
      lastMonth: '2026-10',
      currency: CurrencyCode.huf);

  ReportMonthInput input(List<Expense> expenses,
          {List<Reimbursement> refunds = const []}) =>
      ReportMonthInput(
          owner: owner,
          name: 'Personal',
          currency: CurrencyCode.huf,
          month: MonthlyBudget()
            ..id = 1
            ..profileId = 1
            ..yearMonth = '2026-10'
            ..baseAvailableAmount = 100000
            ..openingBalanceConfirmed = true
            ..createdAt = DateTime(2026)
            ..updatedAt = DateTime(2026),
          defaultIncome: 100000,
          expenses: expenses,
          refunds: refunds,
          budgets: const [],
          directs: const [],
          sources: const [],
          settlements: const [],
          vault: const [],
          categories: const {'food': 'Food'},
          recorded: const {});

  Expense expense(int id, int amount, ExpenseStatus status,
          {int quantity = 1}) =>
      Expense(
          id: id,
          profileId: 1,
          yearMonth: '2026-10',
          title: 'Item $id',
          amount: amount,
          quantity: quantity,
          currency: 'HUF',
          categoryId: 'food',
          date: DateTime(2026, 10, 20),
          budgetId: 1,
          status: status);

  FinancialReport reportWith(CalculatedReportMonth result) => FinancialReport(
        request: request(),
        generatedAt: DateTime.utc(2026, 10, 26, 12),
        actorId: 1,
        statements: [result.statement],
        transactions: result.rows,
        profiles: result.profiles,
        balances: const [],
        issues: const [],
        warnings: const [],
        canExport: true,
        previousNet: null,
      );

  test('report rows expose quantity and the exact derived unit price', () {
    final result = calculateReportMonth(
        input([
          expense(1, 10000, ExpenseStatus.paid, quantity: 2),
          expense(2, 500, ExpenseStatus.paid),
        ], refunds: [
          Reimbursement(
              profileId: 1,
              expenseId: 1,
              originYearMonth: '2026-10',
              amount: 1000,
              currency: 'HUF',
              date: DateTime(2026, 10, 21)),
        ]),
        request(),
        RateTableRegistry());

    final item = result.rows
        .singleWhere((r) => r.kind == 'Expense' && r.name == 'Item 1');
    expect(item.amount, 10000);
    expect(item.quantity, 2);
    expect(item.unitAmountMinor, 5000);

    final single = result.rows
        .singleWhere((r) => r.kind == 'Expense' && r.name == 'Item 2');
    expect(single.quantity, 1);
    expect(single.unitAmountMinor, 500);

    final refund = result.rows.singleWhere((r) => r.kind == 'Refund');
    expect(refund.quantity, isNull);
    expect(refund.unitAmountMinor, isNull);
  });

  test('CSV exports the quantity and unit-price columns', () {
    final result = calculateReportMonth(
        input([expense(1, 10000, ExpenseStatus.paid, quantity: 2)]),
        request(),
        RateTableRegistry());
    final report = reportWith(result);
    final csv = utf8.decode(const ExportCsvService().transactions(report));

    expect(csv, contains('"Quantity","Unit price"'));
    // HUF has no minor-to-major scaling, so 10,000 total and 5,000 each.
    expect(csv, contains(',10000,10000,2,5000,'));
    expect(report.transactions.single.unitAmountMinor, 5000);
  });

  test('PDF renders with the quantity appendix without changing the totals',
      () async {
    final normal =
        await File('assets/fonts/reports/NotoSans-Regular.ttf').readAsBytes();
    final bold =
        await File('assets/fonts/reports/NotoSans-Bold.ttf').readAsBytes();
    final result = calculateReportMonth(
        input([expense(1, 10000, ExpenseStatus.paid, quantity: 2)]),
        request(),
        RateTableRegistry());
    final bytes = await renderFinancialReportPdf(ReportPdfJob(
        reportWith(result),
        normal,
        bold,
        const ReportExportOptions(appendix: true)));

    expect(ascii.decode(bytes.take(5).toList()), '%PDF-');
    expect(latin1.decode(bytes), contains('%%EOF'));
    expect(result.statement.amounts['paid'], 10000,
        reason: 'quantity metadata never multiplies a recorded total twice');
  });
}
