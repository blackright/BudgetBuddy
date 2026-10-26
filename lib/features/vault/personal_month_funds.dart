import '../../core/services/fx_booking_service.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'package:isar/isar.dart';
import '../../core/models/budget_profile.dart';
import '../../core/models/direct_expense_profile.dart';
import '../../core/models/currency_code.dart';
import '../../core/models/expense.dart';
import '../../core/models/income_source.dart';
import '../../core/models/month_end_run.dart';
import '../../core/models/monthly_budget.dart';
import '../../core/models/money.dart';
import '../../core/models/user_profile.dart';
import '../../core/services/expense_profile_identity.dart';
import '../../core/services/free_funds.dart';
import '../../core/services/income_aggregation_service.dart';
import '../../core/services/month_end_report.dart';
import '../../core/services/profile_spending_service.dart';
import '../expenses/models/reimbursement.dart';
import '../engine/providers/rate_registry_provider.dart';
import 'vault_math.dart';
import 'vault_transfer_ledger.dart';

/// Caller owns the snapshot/transaction. No network work and no cached totals.
Future<Map<String, int>> readPersonalMonthFunds(
    Isar db, int actor, String month, RateTableRegistry registry) async {
  final owner = await db.userProfiles.get(actor);
  final budget = await db.monthlyBudgets
      .filter()
      .profileIdEqualTo(actor)
      .sharedSpaceIdIsNull()
      .yearMonthEqualTo(month)
      .findFirst();
  if (owner == null || budget == null || !budget.openingBalanceConfirmed) {
    throw const FormatException(
        'Confirm the month opening funds first. Zero is valid.');
  }
  final currency = owner.primaryCurrency.code;
  int convert(int value, CurrencyCode? from, [String? sourceMonth]) {
    if (!validVaultAmount(value) || from == null) {
      throw const FormatException('Source money needs review.');
    }
    final result = vaultConvert(
        Money(value, from), currency, registry.tableFor(sourceMonth ?? month));
    if (result == null) {
      throw const FormatException('A required exchange rate is unavailable.');
    }
    return result.minorUnits;
  }

  final budgets = await db.budgetProfiles
      .filter()
      .profileIdEqualTo(actor)
      .sharedSpaceIdIsNull()
      .yearMonthEqualTo(month)
      .findAll();
  final directs = await db.directExpenseProfiles
      .filter()
      .profileIdEqualTo(actor)
      .sharedSpaceIdIsNull()
      .yearMonthEqualTo(month)
      .findAll();
  final expenses = await db.expenses
      .filter()
      .profileIdEqualTo(actor)
      .sharedSpaceIdIsNull()
      .yearMonthEqualTo(month)
      .findAll();
  final returns = await db.reimbursements
      .filter()
      .profileIdEqualTo(actor)
      .sharedSpaceIdIsNull()
      .originYearMonthEqualTo(month)
      .findAll();
  for (final e in expenses) {
    if (!resolveExpenseProfileIdentity(e, budgets, directs)) {
      throw const FormatException(
          'Resolve ambiguous expense profile assignments first.');
    }
    final m = expenseAccountingMoney(e, expectedCurrency: currency);
    convert(m.minorUnits, m.currency);
  }
  var paid = 0, returned = 0, unused = 0, allocated = 0;
  for (final e in expenses) {
    if ({
      ExpenseStatus.paid,
      ExpenseStatus.reimbursed,
      ExpenseStatus.partiallyReimbursed
    }.contains(e.status)) {
      final m = expenseAccountingMoney(e, expectedCurrency: currency);
      paid = vaultSum(paid, convert(m.minorUnits, m.currency));
    }
  }
  for (final r in returns) {
    final m = reimbursementAccountingMoney(r, expectedCurrency: currency);
    returned = vaultSum(returned, convert(m.minorUnits, m.currency));
  }
  int spent(int? id, String? type) =>
      const ProfileSpendingService().spentInYearMonth(
          profileId: id,
          profileType: type,
          yearMonth: month,
          expenses: expenses,
          reimbursements: returns,
          convert: (e) {
            final m = expenseAccountingMoney(e, expectedCurrency: currency);
            return convert(m.minorUnits, m.currency);
          },
          convertReimbursement: (r) {
            final m =
                reimbursementAccountingMoney(r, expectedCurrency: currency);
            return convert(m.minorUnits, m.currency);
          });
  final unusedByGuid = <String, int>{};
  for (final p in budgets) {
    if (!validVaultAmount(p.allocation)) {
      throw const FormatException('An allocation needs review.');
    }
    final remainder =
        math.max(0, p.allocation - spent(p.id, FinancialProfileType.budget));
    allocated = vaultSum(allocated, p.allocation);
    unused = vaultSum(unused, remainder);
    unusedByGuid[p.syncGuid] = remainder;
  }
  final sources = await db.incomeSources
      .filter()
      .profileIdEqualTo(actor)
      .sharedSpaceIdIsNull()
      .findAll();
  var sourceIncome = 0;
  for (final source in sources) {
    if (!validVaultAmount(source.amount) ||
        CurrencyCode.tryParse(source.currency) != currency) {
      throw const FormatException(
          'Income source amounts/currencies need review.');
    }
    sourceIncome = vaultSum(
        sourceIncome,
        const IncomeAggregationService()
            .monthlyTotal([source], month, currency: currency));
  }
  final incomeAmount = budget.netSalaryOverride ??
      (sourceIncome > 0
          ? sourceIncome / currency.minorUnitsPerMajor
          : owner.defaultNetSalary);
  final incomeMoney = vaultOpening(incomeAmount, currency);
  final opening = vaultOpening(budget.baseAvailableAmount, currency);
  if (incomeMoney == null || incomeMoney.minorUnits < 0 || opening == null) {
    throw const FormatException('Income or opening funds need review.');
  }
  final income = budget.netSalaryOverride == null && sourceIncome > 0
      ? sourceIncome
      : incomeMoney.minorUnits;
  var incoming = 0, released = 0, carry = 0;
  final runs = await db.monthEndRuns
      .filter()
      .profileIdEqualTo(actor)
      .sharedSpaceIdIsNull()
      .findAll();
  for (final run in runs
      .where((r) => r.yearMonth == month || r.destinationMonth == month)) {
    if (!run.applied || run.hasConflict) {
      throw const FormatException('Month-End needs review.');
    }
    final report = jsonDecode(run.reportJson);
    if (report is! Map || report['lines'] is! List) {
      throw const FormatException('Month-End history needs review.');
    }
    var recordedCarry = 0, recordedRelease = 0;
    final seen = <String>{};
    for (final line in report['lines'] as List) {
      if (line is! Map ||
          line['sourceGuid'] is! String ||
          !seen.add(line['sourceGuid'] as String) ||
          line['carried'] is! int ||
          line['released'] is! int ||
          !validVaultAmount(line['carried'] as int) ||
          !validVaultAmount(line['released'] as int)) {
        throw const FormatException('Month-End history needs review.');
      }
      recordedCarry = vaultSum(recordedCarry, line['carried'] as int);
      recordedRelease = vaultSum(recordedRelease, line['released'] as int);
      if (run.yearMonth != month) continue;
      final reservation = MonthEndReservation(
          unused: unusedByGuid[line['sourceGuid']] ?? 0,
          carried: convert(line['carried'] as int,
              CurrencyCode.tryParse(run.currency), run.yearMonth),
          released: convert(line['released'] as int,
              CurrencyCode.tryParse(run.currency), run.yearMonth));
      released = vaultSum(released, reservation.releasedCredit);
      carry = vaultSum(carry, reservation.carryShortfall);
    }
    if (recordedCarry != run.carriedMinor ||
        recordedRelease != run.releasedMinor) {
      throw const FormatException('Month-End totals do not reconcile.');
    }
    if (run.destinationMonth == month) {
      incoming = vaultSum(
          incoming,
          convert(run.carriedMinor, CurrencyCode.tryParse(run.currency),
              run.yearMonth));
    }
  }
  final credit = await readMonthlyVaultCredit(db, actor, month, currency);
  var direct = spent(null, null);
  for (final p in directs) {
    direct = vaultSum(direct, spent(p.id, FinancialProfileType.direct));
  }
  final reserve = vaultSum(
      vaultSum(vaultSum(vaultSum(income, incoming), released), -carry),
      vaultSum(vaultSum(-allocated, -direct), credit));
  return {
    'income': income,
    'spent': paid,
    'returned': returned,
    'unused': unused,
    'carry': carry,
    'incoming': incoming,
    'released': released,
    'vaultTransfers': credit,
    'bank': vaultSum(
        vaultSum(
            vaultSum(vaultSum(opening.minorUnits, income), -paid), returned),
        credit),
    'reserve': reserve,
    'available': freeToSpend(
            income: income,
            paid: paid,
            returned: returned,
            unused: unused,
            carry: carry,
            incoming: incoming,
            released: released,
            transfers: credit)
        .toInt()
  };
}
