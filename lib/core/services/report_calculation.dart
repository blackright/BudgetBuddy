import 'dart:convert';
import 'fx_booking_service.dart';
import '../models/fx_revision.dart';
import 'dart:math' as math;
import '../models/financial_report.dart';
import '../models/currency_code.dart';
import '../models/money.dart';
import '../models/expense.dart';
import '../models/monthly_budget.dart';
import '../models/budget_profile.dart';
import '../models/direct_expense_profile.dart';
import '../models/income_source.dart';
import '../models/month_end_run.dart';
import '../../features/expenses/models/reimbursement.dart';
import '../../features/engine/providers/rate_registry_provider.dart';
import '../../features/vault/models/vault_entry.dart';
import '../../features/vault/vault_transfer_ledger.dart';
import 'expense_evidence.dart';
import 'expense_profile_identity.dart';
import 'profile_spending_service.dart';
import 'income_aggregation_service.dart';
import 'borrowing_service.dart';
import 'month_end_report.dart';
import 'free_funds.dart';

int reportConvert(int amount, CurrencyCode from, CurrencyCode to, String month,
    RateTableRegistry rates) {
  sumFinancialMinor([amount]);
  if (from == to) return amount;
  final rate = rates.tableFor(month)?.crossRate(from, to);
  if (rate == null || !rate.isFinite || rate <= 0) {
    throw const FormatException('An exchange rate is missing or invalid.');
  }
  final raw = amount * rate * to.minorUnitsPerMajor / from.minorUnitsPerMajor;
  if (!raw.isFinite || raw.abs() > 9007199254740991) {
    throw const FormatException(
        'A converted amount exceeds the exact money range.');
  }
  final converted =
      rates.convert(amount: Money(amount, from), to: to, yearMonth: month);
  if (converted.isDegraded) {
    throw const FormatException('Exchange rate unavailable.');
  }
  return sumFinancialMinor([converted.amount.minorUnits]);
}

int reportMajor(double amount, CurrencyCode code) {
  if (!amount.isFinite ||
      (amount * code.minorUnitsPerMajor).abs() > 9007199254740991) {
    throw const FormatException(
        'A stored opening balance or income needs review.');
  }
  return sumFinancialMinor([Money.fromMajor(amount, code).minorUnits]);
}

String reportProfileKey(Expense e, List<BudgetProfile> budgets) {
  if (e.budgetProfileId == null && e.financialProfileSyncGuid == null) {
    return 'main';
  }
  if (e.financialProfileType == FinancialProfileType.budget) {
    final p = budgets
        .where((p) => p.syncGuid == e.financialProfileSyncGuid)
        .firstOrNull;
    return 'budget:${p?.familyGuid.isNotEmpty == true ? p!.familyGuid : e.financialProfileSyncGuid}';
  }
  return 'direct:${e.financialProfileSyncGuid}';
}

class ReportMonthInput {
  ReportMonthInput(
      {required this.owner,
      required this.name,
      required this.currency,
      required this.month,
      required this.defaultIncome,
      required this.expenses,
      required this.refunds,
      required this.budgets,
      required this.directs,
      required this.sources,
      required this.settlements,
      required this.vault,
      required this.categories,
      required this.recorded});
  final ReportOwner owner;
  final String name;
  final CurrencyCode currency;
  final MonthlyBudget month;
  final int defaultIncome;
  final List<Expense> expenses;
  final List<Reimbursement> refunds;
  final List<BudgetProfile> budgets;
  final List<DirectExpenseProfile> directs;
  final List<IncomeSource> sources;
  final List<MonthEndRun> settlements;
  final List<VaultEntry> vault;
  final Map<String, String> categories;
  final Map<int, DateTime> recorded;
}

class CalculatedReportMonth {
  CalculatedReportMonth(this.statement, this.rows, this.profiles);
  final ReportStatement statement;
  final List<ReportTransaction> rows;
  final List<ReportBreakdown> profiles;
}

CalculatedReportMonth calculateReportMonth(
    ReportMonthInput input, ReportRequest request, RateTableRegistry rates) {
  final key = input.month.yearMonth, contextCurrency = input.currency;
  final errors = <String>[];
  final rows = <ReportTransaction>[];
  final profiles = <ReportBreakdown>[];
  final metrics = <String, int?>{};
  final table = rates.tableFor(key);
  final basis =
      '${rates.isSealedMonth(key) ? 'Month seal' : table?.source.name ?? 'Unavailable'}; rates as of ${table?.asOf.toIso8601String() ?? 'unavailable'}; units per USD: ${table?.usdRates.entries.map((e) => '${e.key.code.toUpperCase()} ${e.value}').join(', ') ?? 'unavailable'}; original → ${contextCurrency.code.toUpperCase()} → ${request.currency.code.toUpperCase()} with accounting rounding';
  final expenses = input.expenses.where((e) => e.yearMonth == key).toList();
  final returns = input.refunds.where((r) => r.originYearMonth == key).toList();
  final budgets = input.budgets.where((p) => p.yearMonth == key).toList();
  final directs = input.directs.where((p) => p.yearMonth == key).toList();
  int toContext(int amount, String code, [String? month]) {
    final from = CurrencyCode.tryParse(code);
    if (from == null) throw FormatException('Unsupported currency: $code.');
    return reportConvert(amount, from, contextCurrency, month ?? key, rates);
  }

  int display(int amount) =>
      reportConvert(amount, contextCurrency, request.currency, key, rates);
  int expenseContext(Expense e) {
    final m = expenseAccountingMoney(e);
    if (e.fxHistoryJson != null &&
        fxPaid(e.status) &&
        m.currency != contextCurrency) {
      throw const FormatException('Booked accounting currency needs review.');
    }
    return toContext(m.minorUnits, m.currency.code);
  }

  int refundContext(Reimbursement r) {
    final m = reimbursementAccountingMoney(r);
    if (r.fxHistoryJson != null && m.currency != contextCurrency) {
      throw const FormatException('Booked refund currency needs review.');
    }
    return toContext(m.minorUnits, m.currency.code);
  }

  int? bookedDisplay(int Function() value) {
    try {
      return display(value());
    } on FormatException catch (e) {
      errors.add(e.message.toString());
      return null;
    }
  }

  String fxBasis(String? json) {
    try {
      final fx = FxHistory.decode(json)?.current;
      return fx == null
          ? 'Legacy FX — original rate not recorded; $basis'
          : 'Booked ${fx.baseCurrency} ${fx.baseMinor} minor units; rate ${fx.numerator}/${fx.denominator}; ${fx.source}; captured ${fx.capturedAt}; display: $basis';
    } on FormatException {
      return 'Booked FX needs review';
    }
  }

  int? converted(int amount, String code) {
    try {
      return display(toContext(amount, code));
    } on FormatException catch (e) {
      errors.add(e.message.toString());
      return null;
    }
  }

  String profileName(Expense e) {
    if (e.budgetProfileId == null && e.financialProfileSyncGuid == null) {
      return 'Main';
    }
    return e.financialProfileType == FinancialProfileType.budget
        ? input.budgets
                .where((p) => p.syncGuid == e.financialProfileSyncGuid)
                .firstOrNull
                ?.name ??
            'Unresolved Budget profile'
        : input.directs
                .where((p) => p.syncGuid == e.financialProfileSyncGuid)
                .firstOrNull
                ?.name ??
            'Unresolved Direct profile';
  }

  bool selected(Expense e) =>
      request.scope != ReportScope.financialProfile ||
      reportProfileKey(e, input.budgets) == request.financialProfile;
  for (final e in expenses) {
    if (!resolveExpenseProfileIdentity(e, input.budgets, input.directs)) {
      errors.add('An expense has an unresolved financial profile.');
    }
    if (!selected(e)) continue;
    if (e.amount < 0 || (e.amount == 0 && e.type != ExpenseType.medical)) {
      errors.add('An expense has an invalid amount.');
    }
    if (e.status == ExpenseStatus.reimbursed &&
        !input.refunds.any((r) => r.expenseId == e.id)) {
      errors.add('A legacy fully reimbursed expense has no recorded refund.');
    }
    String evidence = 'Not recorded';
    try {
      final manifest = ExpenseEvidence.decode(e.paymentEvidenceJson);
      evidence = manifest == null
          ? (e.type == ExpenseType.medical
              ? 'Medical workflow'
              : 'Legacy / missing evidence')
          : e.type == ExpenseType.medical
              ? 'Medical workflow'
              : expenseEvidenceProblems(e).isEmpty
                  ? 'Recorded'
                  : 'Needs review';
    } on FormatException {
      evidence = 'Needs review';
    }
    rows.add(ReportTransaction(
        owner: input.owner,
        context: input.name,
        month: key,
        kind: e.type == ExpenseType.medical ? 'Medical expense' : 'Expense',
        name: e.title,
        date: e.date,
        recordedAt: input.recorded[e.id],
        paidAt: e.paidAt,
        amount: e.amount,
        currency: e.currency.toUpperCase(),
        converted: bookedDisplay(() => expenseContext(e)),
        rateBasis: fxPaid(e.status)
            ? fxBasis(e.fxHistoryJson)
            : 'Planned estimate; $basis',
        profile: profileName(e),
        profileKey: reportProfileKey(e, input.budgets),
        category: input.categories[e.categoryId] ?? 'Not recorded',
        merchant: e.merchantName?.trim().isNotEmpty == true
            ? e.merchantName!
            : 'Not recorded',
        payment: e.paymentMethod ?? 'Not recorded',
        status: e.status.name,
        evidence: evidence,
        notes: e.notes,
        effect: isPaidExpenseStatus(e.status) ? 1 : 0));
  }
  for (final r in returns) {
    final target = input.expenses.where((e) => e.id == r.expenseId).firstOrNull;
    if (r.amount < 0) errors.add('A refund has a negative amount.');
    if (target == null || r.orphaned) {
      errors.add('A refund has no resolved expense target.');
    }
    if (request.scope == ReportScope.financialProfile &&
        (target == null || !selected(target))) {
      continue;
    }
    rows.add(ReportTransaction(
        owner: input.owner,
        context: input.name,
        month: key,
        kind: 'Refund',
        name: target?.title ?? 'Unlinked refund',
        date: r.date,
        recordedAt: r.date,
        amount: r.amount,
        currency: r.currency.toUpperCase(),
        converted: bookedDisplay(() => refundContext(r)),
        rateBasis: fxBasis(r.fxHistoryJson),
        profile: target == null ? 'Unresolved' : profileName(target),
        profileKey: target == null
            ? 'unresolved'
            : reportProfileKey(target, input.budgets),
        category: target == null
            ? 'Not recorded'
            : input.categories[target.categoryId] ?? 'Not recorded',
        merchant: target?.merchantName ?? 'Not recorded',
        notes: r.note,
        status: 'Recorded',
        effect: -1));
  }
  try {
    int spent(int? id, String? type) => sumFinancialMinor([
          const ProfileSpendingService().spentInYearMonth(
              profileId: id,
              profileType: type,
              yearMonth: key,
              expenses: input.expenses,
              reimbursements: input.refunds,
              convert: expenseContext,
              convertReimbursement: refundContext)
        ]);
    for (final s in input.sources) {
      if (s.amount < 0 ||
          s.amount > 9007199254740991 ||
          CurrencyCode.tryParse(s.currency) != contextCurrency) {
        throw const FormatException(
            'Income source amounts/currencies need review.');
      }
    }
    sumFinancialMinor(input.sources.map((s) => s.amount * 4));
    final incomeTotal = const IncomeAggregationService()
        .monthlyTotal(input.sources, key, currency: contextCurrency);
    sumFinancialMinor([incomeTotal]);
    final income = input.owner.shared
        ? input.month.sharedIncomeOverride ??
            (incomeTotal > 0 ? incomeTotal : input.defaultIncome)
        : input.month.netSalaryOverride != null
            ? reportMajor(input.month.netSalaryOverride!, contextCurrency)
            : incomeTotal > 0
                ? incomeTotal
                : input.defaultIncome;
    if (income < 0) throw const FormatException('Income must not be negative.');
    for (final p in budgets) {
      if (p.allocation < 0) {
        throw const FormatException('An allocation is negative.');
      }
    }
    final allocation = sumFinancialMinor(budgets.map((p) => p.allocation));
    final unused = sumFinancialMinor(budgets.map((p) =>
        math.max(0, p.allocation - spent(p.id, FinancialProfileType.budget))));
    var carryIn = 0, released = 0, protection = 0;
    for (final run in input.settlements.where((r) => r.applied)) {
      if (run.carriedMinor < 0 || run.releasedMinor < 0) {
        throw const FormatException(
            'Month-End settlement amounts need review.');
      }
      if (run.destinationMonth == key) {
        carryIn = sumFinancialMinor([
          carryIn,
          toContext(run.carriedMinor, run.currency, run.yearMonth)
        ]);
      }
      if (run.yearMonth != key) continue;
      for (final line in (jsonDecode(run.reportJson) as Map)['lines'] as List) {
        if ((line['carried'] as int) < 0 || (line['released'] as int) < 0) {
          throw const FormatException('Month-End line amounts need review.');
        }
        final p =
            budgets.where((p) => p.syncGuid == line['sourceGuid']).firstOrNull;
        final reservation = MonthEndReservation(
            unused: p == null
                ? 0
                : math.max(
                    0, p.allocation - spent(p.id, FinancialProfileType.budget)),
            carried:
                toContext(line['carried'] as int, run.currency, run.yearMonth),
            released: toContext(
                line['released'] as int, run.currency, run.yearMonth));
        released = sumFinancialMinor([released, reservation.releasedCredit]);
        protection =
            sumFinancialMinor([protection, reservation.carryShortfall]);
      }
    }
    final credit = input.owner.shared
        ? 0
        : monthlyVaultCredit(input.vault, key, contextCurrency);
    final reserve = sumFinancialMinor([
      income,
      carryIn,
      released,
      -protection,
      credit,
      -allocation,
      -spent(null, null),
      -sumFinancialMinor(
          directs.map((p) => spent(p.id, FinancialProfileType.direct)))
    ]);
    var borrowed = 0, deficit = math.max(0, -reserve), totalOverspend = 0;
    for (final p in budgets) {
      final net = spent(p.id, FinancialProfileType.budget);
      final state = const BorrowingService().state(
          allocation: p.allocation, spent: net, availableReserve: reserve);
      totalOverspend = sumFinancialMinor([totalOverspend, state.overspend]);
      final profileKey =
          'budget:${p.familyGuid.isEmpty ? p.syncGuid : p.familyGuid}';
      if (request.scope != ReportScope.financialProfile ||
          request.financialProfile == profileKey) {
        profiles.add(ReportBreakdown(
            context: input.name,
            month: key,
            name: p.name,
            type: 'Budget',
            paid: null,
            returned: null,
            net: display(net),
            planned: null,
            allocation: display(p.allocation),
            borrowed: display(state.borrowed),
            deficit: display(state.deficit)));
      }
    }
    final overall = const BorrowingService()
        .state(allocation: 0, spent: totalOverspend, availableReserve: reserve);
    borrowed = overall.borrowed;
    deficit = sumFinancialMinor([deficit, overall.deficit]);
    for (final p in directs) {
      if (request.scope != ReportScope.financialProfile ||
          request.financialProfile == 'direct:${p.syncGuid}') {
        profiles.add(ReportBreakdown(
            context: input.name,
            month: key,
            name: p.name,
            type: 'Direct',
            paid: null,
            returned: null,
            net: display(spent(p.id, FinancialProfileType.direct)),
            planned: null,
            borrowed: 0,
            deficit: display(math.max(
                0,
                spent(p.id, FinancialProfileType.direct) -
                    math.max(0,
                        reserve + spent(p.id, FinancialProfileType.direct))))));
      }
    }
    if (request.scope != ReportScope.financialProfile ||
        request.financialProfile == 'main') {
      profiles.add(ReportBreakdown(
          context: input.name,
          month: key,
          name: 'Main',
          type: 'Main',
          paid: null,
          returned: null,
          net: display(spent(null, null)),
          planned: null,
          borrowed: 0,
          deficit: display(math.max(0,
              spent(null, null) - math.max(0, reserve + spent(null, null))))));
    }
    final paid = sumFinancialMinor(
        rows.where((r) => r.effect == 1).map((r) => r.converted ?? 0));
    final returned = sumFinancialMinor(
        rows.where((r) => r.effect == -1).map((r) => r.converted ?? 0));
    metrics.addAll({
      'paid': paid,
      'refunds': returned,
      'legacyReturns': 0,
      'net': sumFinancialMinor([paid, -returned]),
      'planned': sumFinancialMinor(
          rows.where((r) => r.status == 'planned').map((r) => r.converted ?? 0))
    });
    if (request.scope == ReportScope.financialProfile) {
      metrics['allocated'] = request.financialProfile == 'main'
          ? null
          : profiles.where((p) => p.type == 'Budget').firstOrNull?.allocation;
      metrics['borrowed'] =
          sumFinancialMinor(profiles.map((p) => p.borrowed ?? 0));
      metrics['deficit'] = profiles.firstOrNull?.deficit;
    } else {
      final gross = sumFinancialMinor(expenses
          .where((e) => isPaidExpenseStatus(e.status))
          .map(expenseContext));
      final refunds = sumFinancialMinor(returns.map(refundContext));
      final free = freeToSpend(
              income: income,
              paid: gross,
              returned: refunds,
              unused: unused,
              carry: protection,
              incoming: carryIn,
              released: released,
              transfers: credit)
          .toInt();
      metrics.addAll({
        'income': display(income),
        'allocated': display(allocation),
        'unused': display(unused),
        'carryIn': display(carryIn),
        'released': display(released),
        'carryProtection': display(protection),
        'vaultCredit': display(credit),
        'reserve': display(reserve),
        'borrowed': display(borrowed),
        'deficit': display(deficit),
        'free': display(free),
        'opening': input.month.openingBalanceConfirmed
            ? display(
                reportMajor(input.month.baseAvailableAmount, contextCurrency))
            : null,
        'bank': input.month.openingBalanceConfirmed
            ? display(sumFinancialMinor([
                reportMajor(input.month.baseAvailableAmount, contextCurrency),
                -gross,
                refunds,
                credit
              ]))
            : null
      });
      metrics['rounding'] = sumFinancialMinor([
        metrics['free']!,
        -metrics['income']!,
        paid,
        -returned,
        metrics['unused']!,
        metrics['carryProtection']!,
        -metrics['carryIn']!,
        -metrics['released']!,
        -metrics['vaultCredit']!
      ]);
    }
    var added = 0, removed = 0;
    if (request.scope != ReportScope.financialProfile) {
      for (final entry in input.vault
          .where((e) => (e.yearMonth ?? reportMonth(e.createdAt)) == key)) {
        if (!entry.hasValidAmounts) {
          throw const FormatException('Savings Vault history needs review.');
        }
        final value = converted(entry.amountMinor, entry.currency);
        if (entry.kind != 'opening') {
          if (entry.amountMinor >= 0) {
            added = sumFinancialMinor([added, value ?? 0]);
          } else {
            removed = sumFinancialMinor([removed, -(value ?? 0)]);
          }
        }
        rows.add(ReportTransaction(
            owner: input.owner,
            context: input.name,
            month: key,
            kind: 'Vault ${entry.kind}',
            name: entry.reason ?? 'Savings Vault movement',
            date: entry.createdAt,
            recordedAt: entry.createdAt,
            amount: entry.amountMinor,
            currency: entry.currency.toUpperCase(),
            converted: value,
            rateBasis: basis,
            notes: entry.reason,
            status: 'Recorded'));
      }
    }
    metrics['savingsAdded'] = added;
    metrics['savingsRemoved'] = removed;
  } on FormatException catch (e) {
    errors.add(e.message.toString());
  } on ArgumentError {
    errors.add('Stored financial values need review.');
  } on TypeError {
    errors.add('Month-End evidence is incomplete.');
  }
  if (errors.isNotEmpty) {
    for (final key in metrics.keys.toList()) {
      metrics[key] = null;
    }
  }
  return CalculatedReportMonth(
      ReportStatement(
          owner: input.owner,
          context: input.name,
          month: key,
          amounts: metrics,
          rateBasis: basis,
          issues: errors.toSet()),
      rows,
      profiles);
}
