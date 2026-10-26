import 'fx_booking_service.dart';
import 'free_funds.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'package:isar/isar.dart';
import '../models/budget_profile.dart';
import '../models/direct_expense_profile.dart';
import '../models/expense.dart';
import '../models/income_source.dart';
import '../models/monthly_budget.dart';
import '../models/month_end_run.dart';
import '../models/user_profile.dart';
import '../models/shared_space.dart';
import '../models/money.dart';
import '../models/currency_code.dart';
import '../models/month_rate_seal.dart';
import '../models/live_rate_set.dart';
import '../../features/expenses/models/reimbursement.dart';
import '../../features/engine/providers/rate_registry_provider.dart';
import '../../features/vault/models/vault_entry.dart';
import '../../features/vault/vault_transfer_ledger.dart';
import 'borrowing_service.dart';
import 'income_aggregation_service.dart';
import 'profile_spending_service.dart';
import 'expense_profile_identity.dart';
import 'month_end_report.dart';

/// Uses the same live spending, reserve and borrowing rules as the dashboard.
/// Missing/ambiguous data is evidence of an unavailable projection, never zero.
class AuditFinancialScope {
  const AuditFinancialScope(this.profile, this.space, this.month);
  final int? profile, space;
  final String? month;
  static AuditFinancialScope? of(Object? value) => switch (value) {
        Expense e => AuditFinancialScope(e.profileId, e.sharedSpaceId, null),
        BudgetProfile p =>
          AuditFinancialScope(p.profileId, p.sharedSpaceId, p.yearMonth),
        DirectExpenseProfile p =>
          AuditFinancialScope(p.profileId, p.sharedSpaceId, p.yearMonth),
        MonthlyBudget m =>
          AuditFinancialScope(m.profileId, m.sharedSpaceId, m.yearMonth),
        IncomeSource s =>
          AuditFinancialScope(s.profileId, s.sharedSpaceId, null),
        Reimbursement r =>
          AuditFinancialScope(r.profileId, r.sharedSpaceId, r.originYearMonth),
        VaultEntry e => AuditFinancialScope(e.profileId, null, e.yearMonth),
        _ => null,
      };
  bool owns(int? p, int? s) =>
      space != null ? s == space : s == null && p == profile;
}

Future<Map<String, Object?>> auditFinancialState(
    Isar db, AuditFinancialScope scope) async {
  try {
    final months = (await db.monthlyBudgets.where().findAll()).where((m) =>
        scope.owns(m.profileId, m.sharedSpaceId) &&
        (scope.month == null || scope.month == m.yearMonth));
    final user =
        scope.space == null ? await db.userProfiles.get(scope.profile!) : null;
    final space =
        scope.space == null ? null : await db.sharedSpaces.get(scope.space!);
    if (user == null && space == null) {
      return {'status': 'Unavailable: context missing'};
    }
    final currency = user?.primaryCurrency.code ?? space!.currency.code;
    final registry = RateTableRegistry(sealedTables: {
      for (final row in await db.monthRateSeals.where().findAll())
        if (row.toRateTable() != null) row.yearMonth: row.toRateTable()!
    }, liveTable: (await db.liveRateSets.where().findFirst())?.toRateTable());
    final allExpenses = (await db.expenses.where().findAll())
        .where((e) => scope.owns(e.profileId, e.sharedSpaceId))
        .toList();
    final returns = (await db.reimbursements.where().findAll())
        .where((r) => scope.owns(r.profileId, r.sharedSpaceId))
        .toList();
    final sources = (await db.incomeSources.where().findAll())
        .where((s) => scope.owns(s.profileId, s.sharedSpaceId))
        .toList();
    final settlements = (await db.monthEndRuns.where().findAll())
        .where((r) => r.applied && scope.owns(r.profileId, r.sharedSpaceId))
        .toList();
    final allBudgets = (await db.budgetProfiles.where().findAll())
        .where((p) => scope.owns(p.profileId, p.sharedSpaceId))
        .toList();
    final allDirects = (await db.directExpenseProfiles.where().findAll())
        .where((p) => scope.owns(p.profileId, p.sharedSpaceId))
        .toList();
    final result = <String, Object?>{};
    for (final month in months) {
      final key = month.yearMonth;
      final budgets = allBudgets.where((p) => p.yearMonth == key).toList();
      final directs = allDirects.where((p) => p.yearMonth == key).toList();
      final expenses = allExpenses.where((e) => e.yearMonth == key).toList();
      if (expenses
          .any((e) => !resolveExpenseProfileIdentity(e, budgets, directs))) {
        throw const FormatException('Ambiguous expense profile');
      }
      int convert(int amount, String code, [String? sourceMonth]) {
        final c = CurrencyCode.tryParse(code);
        if (c == null) throw const FormatException('Unsupported currency');
        final converted = registry.convert(
            amount: Money(amount, c),
            to: currency,
            yearMonth: sourceMonth ?? key);
        if (converted.isDegraded) {
          throw const FormatException('Rate unavailable');
        }
        return converted.amount.minorUnits;
      }

      int spent(int? id, String? type) =>
          const ProfileSpendingService().spentInYearMonth(
              profileId: id,
              profileType: type,
              yearMonth: key,
              expenses: expenses,
              reimbursements: returns,
              convert: (e) {
                final m = expenseAccountingMoney(e, expectedCurrency: currency);
                return convert(m.minorUnits, m.currency.code);
              },
              convertReimbursement: (r) {
                final m =
                    reimbursementAccountingMoney(r, expectedCurrency: currency);
                return convert(m.minorUnits, m.currency.code);
              });
      if (sources.any((s) => CurrencyCode.tryParse(s.currency) != currency)) {
        throw const FormatException('Income currencies need review');
      }
      sumFinancialMinor(expenses.map((e) => e.amount));
      sumFinancialMinor(
          returns.where((r) => r.originYearMonth == key).map((r) => r.amount));
      if (sources.any((s) => s.amount < 0)) {
        throw const FormatException('Invalid income amount');
      }
      sumFinancialMinor(sources.map((s) => s.amount));
      sumFinancialMinor(sources.map((s) => s.amount * 4));
      final income = const IncomeAggregationService()
          .monthlyTotal(sources, key, currency: currency);
      final resolved = scope.space != null
          ? month.sharedIncomeOverride ??
              (income > 0 ? income : space!.defaultIncome)
          : month.netSalaryOverride != null
              ? Money.fromMajor(month.netSalaryOverride!, currency).minorUnits
              : income > 0
                  ? income
                  : Money.fromMajor(user!.defaultNetSalary, currency)
                      .minorUnits;
      var settlement = 0;
      for (final run in settlements) {
        if (run.destinationMonth == key) {
          settlement += convert(run.carriedMinor, run.currency, run.yearMonth);
        }
        if (run.yearMonth != key) continue;
        for (final line
            in (jsonDecode(run.reportJson) as Map)['lines'] as List) {
          final p = budgets
              .where((p) => p.syncGuid == line['sourceGuid'])
              .firstOrNull;
          final r = MonthEndReservation(
              unused: p == null
                  ? 0
                  : math.max(0,
                      p.allocation - spent(p.id, FinancialProfileType.budget)),
              carried:
                  convert(line['carried'] as int, run.currency, run.yearMonth),
              released: convert(
                  line['released'] as int, run.currency, run.yearMonth));
          settlement += r.releasedCredit - r.carryShortfall;
        }
      }
      final vault = scope.space == null
          ? await readMonthlyVaultCredit(db, scope.profile!, key, currency)
          : 0;
      final reserve = sumFinancialMinor([
        resolved,
        settlement,
        vault,
        -sumFinancialMinor(budgets.map((p) => p.allocation)),
        -sumFinancialMinor(
            directs.map((p) => spent(p.id, FinancialProfileType.direct))),
        -spent(null, null)
      ]);
      final states = <String, Object?>{};
      for (final p in budgets) {
        final state = const BorrowingService().stateFor(
            profile: p,
            spent: spent(p.id, FinancialProfileType.budget),
            availableReserve: reserve);
        states[p.syncGuid] = {
          'name': p.name,
          'borrowed': state.borrowed,
          'deficit': state.deficit
        };
      }
      for (final p in directs) {
        final direct = spent(p.id, FinancialProfileType.direct);
        states['direct:${p.id}'] = {
          'name': p.name,
          'borrowed': 0,
          'deficit': math.max(0, direct - math.max(0, reserve + direct))
        };
      }
      result[key] = {'currency': currency.code, 'profiles': states};
    }
    return result;
  } on FormatException catch (error) {
    return {'status': 'Unavailable: ${error.message}'};
  }
}
