import 'dart:convert';
import 'package:isar/isar.dart';
import '../models/financial_report.dart';
import '../models/user_profile.dart';
import '../models/currency_code.dart';
import '../models/shared_space.dart';
import '../models/monthly_budget.dart';
import '../models/expense.dart';
import '../models/budget_profile.dart';
import '../models/direct_expense_profile.dart';
import '../models/income_source.dart';
import '../models/month_end_run.dart';
import '../models/month_rate_seal.dart';
import '../models/live_rate_set.dart';
import '../models/category.dart';
import '../models/audit_event.dart';
import '../models/allocation.dart';
import '../models/transfer.dart';
import '../../features/expenses/models/reimbursement.dart';
import '../../features/engine/providers/rate_registry_provider.dart';
import '../../features/vault/models/vault_entry.dart';
import '../../features/vault/models/savings_vault.dart';
import 'report_access.dart';
import 'report_calculation.dart';
import 'free_funds.dart';

/// Read-only report snapshot. Never provisions months or invokes write services.
class ReportService {
  ReportService(this.db, {required this.access, DateTime Function()? clock})
      : clock = clock ?? DateTime.now;
  final Isar db;
  final ReportAccess access;
  final DateTime Function() clock;
  Future<void> authorizeExport(FinancialReport report) async {
    report.requireExportable();
    await access.authorize(report.request, report.actorId, exporting: true);
  }

  Future<FinancialReport> generate(ReportRequest request, int actor) =>
      db.txn(() async {
        final canExport = await access.authorize(request, actor);
        final generated = clock().toUtc();
        final rates = RateTableRegistry(
            sealedTables: {
              for (final seal in await db.monthRateSeals.where().findAll())
                if (seal.toRateTable() != null)
                  seal.yearMonth: seal.toRateTable()!
            },
            liveTable:
                (await db.liveRateSets.where().findFirst())?.toRateTable());
        final categories = {
          for (final c in await db.categorys.where().findAll())
            c.categoryId: c.name
        };
        final statements = <ReportStatement>[], previous = <ReportStatement>[];
        final transactions = <ReportTransaction>[],
            profileLines = <ReportBreakdown>[],
            balances = <ReportBalance>[];
        final issues = <String>[], warnings = <String>[];
        for (final owner in request.owners) {
          final user =
              owner.shared ? null : (await db.userProfiles.get(owner.id))!;
          final space =
              owner.shared ? (await db.sharedSpaces.get(owner.id))! : null;
          final name = user?.name ?? '${space!.name} (full shared amounts)';
          final currency = user?.primaryCurrency.code ?? space!.currency.code;
          final months = await db.monthlyBudgets
              .filter()
              .group((q) => owner.shared
                  ? q.sharedSpaceIdEqualTo(owner.id)
                  : q.sharedSpaceIdIsNull().profileIdEqualTo(owner.id))
              .findAll();
          final expenses = await db.expenses
              .filter()
              .group((q) => owner.shared
                  ? q.sharedSpaceIdEqualTo(owner.id)
                  : q.sharedSpaceIdIsNull().profileIdEqualTo(owner.id))
              .findAll();
          final refunds = await db.reimbursements
              .filter()
              .group((q) => owner.shared
                  ? q.sharedSpaceIdEqualTo(owner.id)
                  : q.sharedSpaceIdIsNull().profileIdEqualTo(owner.id))
              .findAll();
          final budgets = await db.budgetProfiles
              .filter()
              .group((q) => owner.shared
                  ? q.sharedSpaceIdEqualTo(owner.id)
                  : q.sharedSpaceIdIsNull().profileIdEqualTo(owner.id))
              .findAll();
          final directs = await db.directExpenseProfiles
              .filter()
              .group((q) => owner.shared
                  ? q.sharedSpaceIdEqualTo(owner.id)
                  : q.sharedSpaceIdIsNull().profileIdEqualTo(owner.id))
              .findAll();
          final sources = await db.incomeSources
              .filter()
              .group((q) => owner.shared
                  ? q.sharedSpaceIdEqualTo(owner.id)
                  : q.sharedSpaceIdIsNull().profileIdEqualTo(owner.id))
              .findAll();
          final settlements = await db.monthEndRuns
              .filter()
              .group((q) => owner.shared
                  ? q.sharedSpaceIdEqualTo(owner.id)
                  : q.sharedSpaceIdIsNull().profileIdEqualTo(owner.id))
              .findAll();
          final vault = owner.shared
              ? <VaultEntry>[]
              : await db.vaultEntrys
                  .filter()
                  .profileIdEqualTo(owner.id)
                  .findAll();
          final events = await db.auditEvents
              .filter()
              .group((q) => owner.shared
                  ? q.sharedSpaceIdEqualTo(owner.id)
                  : q.sharedSpaceIdIsNull().profileIdEqualTo(owner.id))
              .objectTypeEqualTo('Expense')
              .findAll();
          final recorded = <int, DateTime>{};
          for (final event
              in events.where((e) => e.action == 'expense.create')) {
            try {
              final data = jsonDecode(event.newValue ?? 'null');
              if (data is! Map || data['syncGuid'] is! String) continue;
              final row = expenses
                  .where((e) => e.syncGuid == data['syncGuid'])
                  .firstOrNull;
              if (row != null &&
                  (recorded[row.id] == null ||
                      event.timestamp.isBefore(recorded[row.id]!))) {
                recorded[row.id] = event.timestamp;
              }
            } on FormatException {
              /* Legacy evidence cannot establish recording time. */
            }
          }
          if (!owner.shared && request.scope != ReportScope.financialProfile) {
            final savings = (await db.savingsVaults
                .filter()
                .profileIdEqualTo(owner.id)
                .findFirst());
            if (savings != null) {
              final problem = vaultEntriesProblem(savings, vault);
              if (problem != null) issues.add('$name: $problem');
            }
            final end = DateTime(int.parse(request.lastMonth.substring(0, 4)),
                int.parse(request.lastMonth.substring(5)) + 1);
            final candidates = vault
                .where((v) =>
                    v.createdAt.toLocal().isBefore(end) &&
                    !v.createdAt.isAfter(generated))
                .toList()
              ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
            if (candidates.isNotEmpty) {
              final last = candidates.last;
              int? display;
              try {
                final original = CurrencyCode.tryParse(last.currency);
                if (original == null) {
                  throw const FormatException('Vault currency needs review.');
                }
                display = reportConvert(last.balanceAfterMinor, original,
                    request.currency, request.lastMonth, rates);
              } on FormatException catch (e) {
                issues.add('$name: ${e.message}');
              }
              balances.add(ReportBalance(
                  context: name,
                  label:
                      'Vault balance at latest recorded event before period end',
                  date: last.createdAt,
                  currency: last.currency.toUpperCase(),
                  amount: last.balanceAfterMinor,
                  converted: display));
            } else if (savings != null) {
              warnings.add(
                  '$name: no vault balance record exists before the period end.');
            }
          }
          if (request.scope == ReportScope.financialProfile &&
              request.financialProfile != 'main') {
            final valid = budgets.any((p) =>
                    request.includes(p.yearMonth) &&
                    'budget:${p.familyGuid.isEmpty ? p.syncGuid : p.familyGuid}' ==
                        request.financialProfile) ||
                directs.any((p) =>
                    request.includes(p.yearMonth) &&
                    'direct:${p.syncGuid}' == request.financialProfile);
            if (!valid) {
              issues.add(
                  '$name: the selected financial profile is unavailable in this period.');
            }
          }
          for (final month in [
            ...reportMonths(request.previousFirst, request.previousLast),
            ...request.months
          ]) {
            final selected = request.includes(month);
            final found = months.where((m) => m.yearMonth == month).toList();
            if (found.length != 1) {
              final problem = found.isEmpty &&
                      !expenses.any((e) => e.yearMonth == month) &&
                      !refunds.any((r) => r.originYearMonth == month)
                  ? null
                  : 'The monthly funds record is missing or duplicated.';
              final statement = ReportStatement(
                  owner: owner,
                  context: name,
                  month: month,
                  amounts: {},
                  rateBasis: 'Not recorded',
                  issues: problem == null ? [] : [problem]);
              (selected ? statements : previous).add(statement);
              if (selected) {
                warnings.add(
                    '$name $month: no recorded monthly statement. Period totals are unavailable when a selected month is missing.');
              }
              continue;
            }
            CalculatedReportMonth result;
            try {
              final defaults = owner.shared
                  ? space!.defaultIncome
                  : reportMajor(user!.defaultNetSalary, currency);
              result = calculateReportMonth(
                  ReportMonthInput(
                      owner: owner,
                      name: name,
                      currency: currency,
                      month: found.single,
                      defaultIncome: defaults,
                      expenses: expenses,
                      refunds: refunds,
                      budgets: budgets,
                      directs: directs,
                      sources: sources,
                      settlements: settlements,
                      vault: vault,
                      categories: categories,
                      recorded: recorded),
                  request,
                  rates);
            } on FormatException catch (e) {
              result = CalculatedReportMonth(
                  ReportStatement(
                      owner: owner,
                      context: name,
                      month: month,
                      amounts: {},
                      rateBasis: 'Unavailable',
                      issues: [(e.message)]),
                  [],
                  []);
            }
            (selected ? statements : previous).add(result.statement);
            if (selected) {
              transactions.addAll(result.rows);
              profileLines.addAll(result.profiles);
              if (!found.single.openingBalanceConfirmed) {
                warnings.add(
                    '$name $month: opening funds are not confirmed; bank availability is unavailable.');
                if (request.scope != ReportScope.financialProfile) {
                  issues.add(
                      '$name $month: confirm opening funds before exporting a full monthly statement.');
                }
              }
            }
            final table = rates.tableFor(month);
            if (selected &&
                (table?.isStale == true || table?.source.name == 'bundled')) {
              warnings.add(
                  '$name $month: ${table!.source.name} exchange-rate basis${table.isStale ? ' (stale)' : ''}.');
            }
          }
          if (request.scope != ReportScope.financialProfile) {
            final allocations = await db.allocations
                .filter()
                .group((q) => owner.shared
                    ? q.sharedSpaceIdEqualTo(owner.id)
                    : q.sharedSpaceIdIsNull().profileIdEqualTo(owner.id))
                .findAll();
            final transfers = await db.transfers
                .filter()
                .group((q) => owner.shared
                    ? q.sharedSpaceIdEqualTo(owner.id)
                    : q.sharedSpaceIdIsNull().profileIdEqualTo(owner.id))
                .findAll();
            for (final item
                in allocations.where((a) => request.includes(a.yearMonth))) {
              int? converted;
              try {
                final original = CurrencyCode.tryParse(item.currency);
                if (original == null) {
                  throw const FormatException(
                      'Allocation currency needs review.');
                }
                converted = reportConvert(item.amount, original,
                    request.currency, item.yearMonth, rates);
              } on FormatException catch (e) {
                issues.add('$name: ${e.message}');
              }
              transactions.add(ReportTransaction(
                  owner: owner,
                  context: name,
                  month: item.yearMonth,
                  kind: 'Allocation change',
                  name: budgets
                          .where((p) => p.id == item.budgetProfileId)
                          .firstOrNull
                          ?.name ??
                      'Deleted Budget profile',
                  date: item.date,
                  recordedAt: item.createdAt,
                  amount: item.amount,
                  currency: item.currency.toUpperCase(),
                  converted: converted,
                  rateBasis: 'Monthly context rates',
                  status: 'Recorded'));
            }
            for (final item
                in transfers.where((a) => request.includes(a.yearMonth))) {
              int? converted;
              try {
                final original = CurrencyCode.tryParse(item.currency);
                if (original == null) {
                  throw const FormatException(
                      'Transfer currency needs review.');
                }
                converted = reportConvert(item.amount, original,
                    request.currency, item.yearMonth, rates);
              } on FormatException catch (e) {
                issues.add('$name: ${e.message}');
              }
              final from = budgets
                      .where((p) => p.id == item.sourceProfileId)
                      .firstOrNull
                      ?.name ??
                  'Deleted profile';
              final to = budgets
                      .where((p) => p.id == item.destinationProfileId)
                      .firstOrNull
                      ?.name ??
                  'Deleted profile';
              transactions.add(ReportTransaction(
                  owner: owner,
                  context: name,
                  month: item.yearMonth,
                  kind: 'Allocation transfer',
                  name: '$from → $to',
                  date: item.date,
                  recordedAt: item.createdAt,
                  amount: item.amount,
                  currency: item.currency.toUpperCase(),
                  converted: converted,
                  rateBasis: 'Monthly context rates',
                  notes: item.reason,
                  status: 'Recorded'));
            }
          }
        }
        transactions.sort((a, b) {
          final cmp = b.date.compareTo(a.date);
          return cmp != 0 ? cmp : a.name.compareTo(b.name);
        });
        for (final s in statements) {
          issues.addAll(s.issues.map((i) => '${s.context} ${s.month}: $i'));
        }
        // Individual months may be valid while a long-range aggregate is too large.
        // Refuse that export before a breakdown or renderer can overflow.
        try {
          for (final metric in reportFlowMetrics) {
            final values = statements.map((s) => s.amounts[metric]);
            if (values.every((v) => v != null)) {
              sumFinancialMinor(values.cast<int>());
            }
          }
          final groups = <String, int>{};
          for (final row in transactions) {
            for (final group in [
              'original:${row.currency}:${row.kind}:${row.status}',
              if (row.effect != 0) 'merchant:${row.merchant}',
              if (row.effect != 0) 'category:${row.category}',
              if (row.effect != 0) 'context:${row.owner.key}'
            ]) {
              final amount = group.startsWith('original:')
                  ? row.amount
                  : (row.converted ?? 0) * row.effect;
              groups[group] = sumFinancialMinor([groups[group] ?? 0, amount]);
            }
          }
        } on FormatException {
          issues.add(
              'Period totals exceed the supported exact money range. Choose a shorter period.');
        }
        int? previousNet;
        if (previous.isNotEmpty &&
            previous.every((s) => s.complete && s.amounts['net'] != null)) {
          try {
            previousNet =
                sumFinancialMinor(previous.map((s) => s.amounts['net']!));
          } on FormatException {
            warnings.add('Previous-period total exceeds the supported range.');
          }
        } else {
          warnings.add(
              'Previous-period comparison unavailable: some months have no complete recorded statement.');
        }
        await access.authorize(request, actor);
        return FinancialReport(
            request: request,
            generatedAt: generated,
            actorId: actor,
            statements: statements,
            transactions: transactions,
            profiles: profileLines,
            balances: balances,
            issues: issues.toSet(),
            warnings: warnings.toSet(),
            canExport: canExport,
            previousNet: previousNet);
      });
}
