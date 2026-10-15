import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/models/money.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/network/rate_types.dart';
import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/selected_month_provider.dart';
import 'package:budget_buddy/features/engine/currency_conversion.dart';
import 'package:budget_buddy/features/engine/providers/month_summary_provider.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/engine/providers/safe_to_spend_provider.dart';
import 'package:budget_buddy/features/engine/providers/true_available_provider.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import 'package:budget_buddy/features/finance/providers/finance_providers.dart';
import 'package:budget_buddy/features/finance/repositories/month_finance_repository.dart';
import 'package:budget_buddy/features/medical/providers/medical_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// T057 regression: one per-month RateTable governs the whole app.
///
/// The registry is the only rate source the runtime reads, so a divergent rate
/// can only appear if a consumer keys a different month than the selected one.
/// This test pins one month, seeds a single *distinctive* sealed table for it
/// (1 US$ = 300 Ft — deliberately NOT the bundled 345) and asserts every screen
/// resolves that same table: the dashboard summary, True Available /
/// Safe-to-Spend, the medical totals and the expense-detail conversion. Any one
/// of them falling back to the bundled table would surface a 345-derived number
/// and fail below.
void main() {
  const yearMonth = '2026-02';

  /// 1 US$ = 300 Ft (not the bundled 345), 1 US$ = 1.30 C$, 0.90 €. All
  /// conversion results below are exact for this table.
  RateTable table() => RateTable.tryCreate(
        usdRates: {
          CurrencyCode.usd: 1.0,
          CurrencyCode.huf: 300.0,
          CurrencyCode.cad: 1.30,
          CurrencyCode.eur: 0.90,
        },
        asOf: DateTime.utc(2026, 2, 1),
        fetchedAt: DateTime.utc(2026, 2, 1),
        source: RateSource.live,
      )!;

  UserProfile user() => UserProfile()
    ..id = 1
    ..name = 'Tester'
    ..primaryCurrency = PrimaryCurrency.huf
    ..monthlyAvailableAmount = 0
    ..defaultNetSalary = 0
    ..createdAt = DateTime(2026)
    ..updatedAt = DateTime(2026);

  /// Opening balance 3,000,000 Ft (= US$ 10,000 at the 300 table), displayed in
  /// USD via `currency = 'usd'`. The budget's own yearMonth matches the
  /// selected month, as production guarantees via `activeBudgetProvider`.
  MonthlyBudget month() => MonthlyBudget()
    ..id = 1
    ..yearMonth = yearMonth
    ..baseAvailableAmount = 3000000.0
    ..openingBalanceConfirmed = true
    ..currency = 'usd'
    ..createdAt = DateTime(2026)
    ..updatedAt = DateTime(2026);

  /// 69,000 Ft paid (= US$ 230 at the 300 table).
  Expense expense() => Expense(
        id: 1,
        profileId: 1,
        yearMonth: yearMonth,
        title: 'Dentist',
        amount: Money.fromMajor(69000, CurrencyCode.huf).minorUnits,
        currency: 'huf',
        categoryId: 'general',
        status: ExpenseStatus.paid,
        date: DateTime(2026, 2, 10),
        budgetId: 1,
      );

  /// 3,000 Ft returned to expense 1 (= US$ 10 at the 300 table).
  Reimbursement reimbursement() => Reimbursement(
        id: 99,
        profileId: 1,
        expenseId: 1,
        originYearMonth: yearMonth,
        amount: Money.fromMajor(3000, CurrencyCode.huf).minorUnits,
        currency: 'huf',
        date: DateTime(2026, 2, 20),
      );

  /// Self-paid, settled: 60,000 Ft charge, 50% patient share. At the 300
  /// table: billed US$ 200.00, patient share US$ 100.00, insurer US$ 100.00,
  /// US$ 30.00 reimbursed back, US$ 170.00 net out of pocket.
  MedicalBill bill() => MedicalBill()
    ..id = 7
    ..profileId = 1
    ..yearMonth = yearMonth
    ..linkedExpenseId = 1
    ..serviceDate = DateTime(2026, 2, 12)
    ..billedAmount = 60000
    ..patientSharePercent = 50
    ..currency = 'huf'
    ..reimbursedAmount = 9000
    ..paymentMethod = MedicalPaymentMethod.selfPaid
    ..state = MedicalBillState.paid;

  Future<ProviderContainer> build() async {
    final container = ProviderContainer(
      overrides: [
        selectedYearMonthProvider.overrideWith((ref) => yearMonth),
        activeProfileProvider.overrideWith((ref) => Stream.value(user())),
        activeBudgetProvider.overrideWith((ref) => Stream.value(month())),
        // The one table the whole app must agree on.
        rateRegistryProvider.overrideWithValue(
          RateTableRegistry(sealedTables: {yearMonth: table()}),
        ),
        // monthSummary reads both the finance row and the resolved income.
        monthFinanceProvider.overrideWith((ref) => Stream.value(month())),
        resolvedIncomeProvider.overrideWithValue(
          const ResolvedIncome(amount: 600000, usesOverride: false),
        ),
        monthlyExpensesProvider
            .overrideWith((ref) => Stream.value([expense()])),
        monthlyReimbursementsProvider
            .overrideWith((ref) => Stream.value([reimbursement()])),
        monthlyOriginReimbursementsProvider
            .overrideWith((ref) => Stream.value([reimbursement()])),
        medicalBillsProvider.overrideWith((ref) => Stream.value([bill()])),
        medicalExpenseStatusesProvider.overrideWith(
          (ref) => Stream.value({1: ExpenseStatus.paid}),
        ),
      ],
    );
    addTearDown(container.dispose);
    // Let every overridden StreamProvider deliver its single event before the
    // synchronous provider reads below, exactly like `await provider.future`.
    await container.read(activeProfileProvider.future);
    await container.read(activeBudgetProvider.future);
    await container.read(monthFinanceProvider.future);
    await container.read(monthlyExpensesProvider.future);
    await container.read(monthlyReimbursementsProvider.future);
    await container.read(monthlyOriginReimbursementsProvider.future);
    await container.read(medicalBillsProvider.future);
    await container.read(medicalExpenseStatusesProvider.future);
    return container;
  }

  test('one per-month table governs every screen — no divergent rate',
      () async {
    final container = await build();

    final registry = container.read(rateRegistryProvider);
    final table = registry.tableFor(yearMonth)!;

    // The seal really keys the month: the bundled 345 is still there for any
    // consumer that resolves a *different* month key.
    expect(table.usdRate(CurrencyCode.huf), 300.0);
    expect(
      identical(registry.tableFor('$yearMonth-other'), table),
      isFalse,
      reason: 'a table sealed for the month must not leak onto other months',
    );
    expect(registry.tableFor('1999-01')!.usdRate(CurrencyCode.huf), 345.0);

    // -- Dashboard summary + the True Available engine ---------------------
    // 3,000,000 Ft base (= 10,000 USD), 69,000 Ft paid (= 230), 3,000 Ft back
    // (= 10): True Available 9,780. Safe-to-Spend subtracts no planned rows.
    expect(container.read(trueAvailableProvider), closeTo(9780.0, 1e-9));
    expect(container.read(safeToSpendProvider), closeTo(9780.0, 1e-9));

    final summary = container.read(monthSummaryProvider);
    expect(summary.income, closeTo(2000.0, 1e-9)); // 600,000 Ft = 2,000 USD
    expect(summary.paymentsMade, closeTo(230.0, 1e-9));
    expect(summary.moneyReturned, closeTo(10.0, 1e-9));
    expect(summary.openingBalance, closeTo(10000.0, 1e-9));
    expect(summary.moneyInBank, closeTo(11780.0, 1e-9));
    expect(summary.planned, 0.0);

    // -- Medical totals: patient share + budget impact in minor USD (cents) --
    final shares = container.read(patientShareTotalsProvider);
    expect(shares.currency, CurrencyCode.usd);
    expect(shares.billedTotal, 20000); // 60,000 Ft = US$ 200.00
    expect(shares.patientShareTotal, 10000); // 30,000 Ft = US$ 100.00
    expect(shares.insurerPaidTotal, 10000);
    expect(shares.reimbursedTotal, 3000); // 9,000 Ft = US$ 30.00
    expect(shares.netPatientCost, 17000); // 51,000 Ft = US$ 170.00

    final impact = container.read(medicalBudgetImpactProvider);
    expect(impact.currency, CurrencyCode.usd);
    expect(impact.paidTotal, 20000); // fundsImpact = full charge, self-paid
    expect(impact.outOfPocketTotal, 10000);
    expect(impact.reimbursedTotal, 3000);
    expect(impact.netOutOfPocket, 17000);

    // -- The budget-scoped context resolves the identical table object ------
    final context = container.read(medicalBillContextProvider)!;
    expect(identical(context.rateTable, table), isTrue);

    // -- Expense-detail conversion, the exact call the tiles and hints make --
    final result = convert(
      const Money(69000, CurrencyCode.huf),
      CurrencyCode.usd,
      table,
    );
    expect(result.amount.majorValue, closeTo(230.0, 1e-9));
    expect(result.rate, closeTo(1 / 300, 1e-9));
    expect(result.isDegraded, isFalse);
    // The footnote line both list headers render:
    expect(table.crossRate(CurrencyCode.usd, CurrencyCode.huf), 300.0);

    // -- None of the above may reflect the bundled 345 Ft baseline ----------
    // The 345-derived equivalents: 69,000/345 = 200 paid, 3,000/345 back, so
    // True Available would be 9,808.70 instead of 9,780.00.
    expect(summary.paymentsMade, isNot(closeTo(200.0, 1e-9)));
    expect(10000.0 - 200.0 + 3000.0 / 345.0, isNot(9780.0));
    expect(container.read(medicalDisplayCurrencyProvider), CurrencyCode.usd);
  });
}
