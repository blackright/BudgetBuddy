import '../../../core/services/fx_booking_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'package:isar/isar.dart';
import '../../../core/database/isar_helper.dart';
import '../../../core/models/month_end_run.dart';
import '../../../core/models/currency_code.dart';
import '../../../core/models/money.dart';
import '../../settings/providers/settings_provider.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../../core/services/month_end_service.dart';
import '../../../core/services/month_end_report.dart';
import '../../../core/services/profile_spending_service.dart';
import '../../../core/models/expense.dart';
import 'profile_providers.dart';
import '../../engine/providers/true_available_provider.dart';
import '../../engine/providers/rate_registry_provider.dart';
import '../../sync/providers/sync_recorder_provider.dart';

final monthEndServiceProvider = Provider<MonthEndService>((ref) {
  final actor = ref.watch(actingProfileIdProvider);
  if (actor == null) {
    throw const MonthEndException('Choose an acting profile first.');
  }
  return MonthEndService(IsarHelper.instance,
      context: ref.watch(budgetContextProvider),
      actorId: actor,
      rates: ref.watch(rateRegistryProvider),
      recorder: ref.watch(syncRecorderProvider));
});

final monthEndRunsProvider = StreamProvider<List<MonthEndRun>>((ref) {
  final context = ref.watch(budgetContextProvider);
  final isar = IsarHelper.maybeInstance;
  if (isar == null) return Stream.value(const []);
  return isar.monthEndRuns.where().watch(fireImmediately: true).map((rows) =>
      rows
          .where((r) => context.isShared
              ? r.sharedSpaceId == context.spaceId
              : r.sharedSpaceId == null && r.profileId == context.profileId)
          .toList());
});

final monthEndPolicyHistoryProvider = Provider<Map<String, String>>((ref) {
  final result = <String, String>{};
  for (final run
      in ref.watch(monthEndRunsProvider).value ?? const <MonthEndRun>[]) {
    if (!run.applied) continue;
    for (final line in jsonDecode(run.reportJson)['lines'] as List) {
      result[line['sourceGuid'] as String] = line['rule'] as String;
    }
  }
  return result;
});

/// All values are context-currency minor units. Carry funds the next allocation
/// without becoming income. Source Reset releases the unused envelope once.
final monthEndBalanceProvider =
    Provider<({int incoming, int released, int carryShortfall})>((ref) {
  final month = ref.watch(budgetContextProvider).yearMonth;
  final runs = (ref.watch(monthEndRunsProvider).value ?? const <MonthEndRun>[])
      .where((r) => r.applied);
  final currency = ref.watch(mainCurrencyProvider);
  final rates = ref.watch(rateRegistryProvider);
  int value(MonthEndRun run, int minor) {
    final code = CurrencyCode.tryParse(run.currency);
    if (code == null) {
      throw const MonthEndException('Unsupported settlement currency.');
    }
    final result = rates.convert(
        amount: Money(minor, code), to: currency, yearMonth: run.yearMonth);
    if (result.isDegraded) {
      throw const MonthEndException('Settlement exchange rate missing.');
    }
    return result.amount.minorUnits;
  }

  var released = 0, carryShortfall = 0;
  final sourceRuns = runs.where((r) => r.yearMonth == month).toList();
  if (sourceRuns.isNotEmpty) {
    final profiles = ref.watch(budgetProfilesProvider).value ?? const [];
    final expenses = ref.watch(contextExpensesProvider);
    final returns = ref.watch(monthlyReimbursementsProvider).value ?? const [];
    int convert(int amount, CurrencyCode? code) {
      if (code == null) {
        throw const MonthEndException('Unsupported source currency.');
      }
      final result = rates.convert(
          amount: Money(amount, code), to: currency, yearMonth: month);
      if (result.isDegraded) {
        throw const MonthEndException('Source exchange rate missing.');
      }
      return result.amount.minorUnits;
    }

    for (final run in sourceRuns) {
      for (final line in jsonDecode(run.reportJson)['lines'] as List) {
        final profile =
            profiles.where((p) => p.syncGuid == line['sourceGuid']).firstOrNull;
        final unused = profile == null
            ? 0
            : math.max(
                0,
                profile.allocation -
                    const ProfileSpendingService().spentInYearMonth(
                        profileId: profile.id,
                        profileType: FinancialProfileType.budget,
                        yearMonth: month,
                        expenses: expenses,
                        reimbursements: returns,
                        convert: (e) {
                          final m = expenseAccountingMoney(e,
                              expectedCurrency: currency);
                          return convert(m.minorUnits, m.currency);
                        },
                        convertReimbursement: (r) => (() {
                              final m = reimbursementAccountingMoney(r,
                                  expectedCurrency: currency);
                              return convert(m.minorUnits, m.currency);
                            })()));
        final reservation = MonthEndReservation(
            unused: unused,
            carried: value(run, line['carried'] as int),
            released: value(run, line['released'] as int));
        released += reservation.releasedCredit;
        carryShortfall += reservation.carryShortfall;
      }
    }
  }
  return (
    incoming: runs
        .where((r) => r.destinationMonth == month)
        .fold<int>(0, (sum, r) => sum + value(r, r.carriedMinor)),
    released: released,
    carryShortfall: carryShortfall,
  );
});
