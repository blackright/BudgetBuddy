import 'fx_booking_service.dart';
import 'audit_financial_state.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'package:crypto/crypto.dart';
import 'package:isar/isar.dart';
import '../models/budget_profile.dart';
import '../models/allocation.dart';
import '../models/direct_expense_profile.dart';
import '../models/expense.dart';
import '../models/currency_code.dart';
import '../models/money.dart';
import '../models/monthly_budget.dart';
import '../models/month_end_run.dart';
import '../models/identity.dart';
import '../models/income_source.dart';
import '../models/shared_space.dart';
import '../models/user_profile.dart';
import '../providers/budget_context_provider.dart';
import '../../features/expenses/models/reimbursement.dart';
import '../../features/engine/providers/rate_registry_provider.dart';
import '../../features/finance/repositories/audit_repository.dart';
import '../../features/spaces/repositories/space_write_guard.dart';
import '../../features/sync/repositories/sync_recorder.dart';
import '../../features/sync/domain/sync_codec.dart';
import '../../features/vault/models/savings_vault.dart';
import 'expense_profile_identity.dart';
import 'profile_spending_service.dart';
import 'month_end_report.dart';
import 'income_aggregation_service.dart';
import '../../features/vault/vault_transfer_ledger.dart';

class MonthEndException implements Exception {
  const MonthEndException(this.message);
  final String message;
  @override
  String toString() => message;
}

String monthEndDigest(Object? value) =>
    sha256.convert(utf8.encode(canonicalJsonEncode(value))).toString();

/// Local confirmation and remote projection use the same settlement semantics.
/// No caller may apply carry as an incremental operation more than once.
class MonthEndService {
  MonthEndService(this.isar,
      {required this.context,
      required this.actorId,
      required this.rates,
      DateTime Function()? clock,
      this.recorder,
      AuditRepository? audit})
      : clock = clock ?? DateTime.now,
        audit = audit ??
            AuditRepository(isar, recorder: recorder, actorId: actorId);
  final Isar isar;
  final ContextRef context;
  final int actorId;
  final RateTableRegistry rates;
  final DateTime Function() clock;
  final SyncRecorder? recorder;
  final AuditRepository audit;
  bool owns(int? profile, int? space) => context.isShared
      ? space == context.spaceId
      : space == null && profile == context.profileId;

  Future<String> _contextGuid() async {
    if (context.isShared) {
      final space = await isar.sharedSpaces.get(context.spaceId!);
      if (space == null) {
        throw const MonthEndException('Space no longer exists.');
      }
      final member = await SpaceWriteGuard(isar).memberOf(space.id, actorId);
      if (member == null || member.revokedAt != null) {
        throw const MonthEndException('Space membership is required.');
      }
      return space.syncGuid;
    }
    if (context.profileId != actorId) {
      throw const MonthEndException(
          'Another personal profile cannot be closed.');
    }
    final user = await isar.userProfiles.get(actorId);
    if (user == null) {
      throw const MonthEndException('Profile no longer exists.');
    }
    return 'personal:${user.id}';
  }

  Future<CurrencyCode> _currency() async => context.isShared
      ? (await isar.sharedSpaces.get(context.spaceId!))!.currency.code
      : (await isar.userProfiles.get(actorId))!.primaryCurrency.code;

  Future<MonthEndReport> preview(String month,
          {List<MonthEndChoice> choices = const []}) =>
      isar.txn(() => _preview(month, choices));

  Future<({List<BudgetProfile> profiles, List<String> months, CurrencyCode currency})>
      inputs() => isar.txn(() async {
            await _contextGuid();
            final rows = (await isar.budgetProfiles.where().findAll())
                .where((p) => owns(p.profileId, p.sharedSpaceId))
                .toList();
            final months = (await isar.monthlyBudgets.where().findAll())
                .where((m) => owns(m.profileId, m.sharedSpaceId))
                .map((m) => m.yearMonth)
                .toSet()
                .toList()
              ..sort();
            return (
              profiles: rows,
              months: months,
              currency: await _currency()
            );
          });

  Future<MonthEndReport> _preview(
      String month, List<MonthEndChoice> choices) async {
    final destination = nextFinancialMonth(month);
    final guid = await _contextGuid();
    final currency = await _currency();
    final blockers = <String>[];
    final current =
        '${clock().year.toString().padLeft(4, '0')}-${clock().month.toString().padLeft(2, '0')}';
    if (month.compareTo(current) >= 0) {
      blockers.add('Only completed calendar months can be finished.');
    }
    final runs = (await isar.monthEndRuns.where().findAll())
        .where((r) => owns(r.profileId, r.sharedSpaceId))
        .toList();
    final completed = runs.where((r) => r.yearMonth == month).firstOrNull;
    if (runs.any((r) => r.hasConflict)) {
      blockers.add(
          'A conflicting month-end run needs review before further processing.');
    }
    final months = (await isar.monthlyBudgets.where().findAll())
        .where((m) => owns(m.profileId, m.sharedSpaceId))
        .toList();
    if (!months.any((m) => m.yearMonth == month)) {
      blockers.add('Open the source month before finishing it.');
    }
    final budgets = (await isar.budgetProfiles.where().findAll())
        .where((p) => owns(p.profileId, p.sharedSpaceId))
        .toList();
    final directs = (await isar.directExpenseProfiles.where().findAll())
        .where((p) => owns(p.profileId, p.sharedSpaceId))
        .toList();
    final earlier = budgets
        .where((p) =>
            p.yearMonth.compareTo(month) < 0 &&
            !runs.any((r) => r.yearMonth == p.yearMonth))
        .map((p) => p.yearMonth)
        .toList()
      ..sort();
    if (earlier.isNotEmpty) {
      blockers.add('Finish ${earlier.first} first (chronological order).');
    }
    if (await SpaceWriteGuard(isar).monthIsSealed(destination)) {
      blockers.add(
          'Destination $destination is closed. Its allocations cannot be changed.');
    }
    final expenses =
        (await isar.expenses.filter().yearMonthEqualTo(month).findAll())
            .where((e) => owns(e.profileId, e.sharedSpaceId))
            .toList();
    final returns = (await isar.reimbursements
            .filter()
            .originYearMonthEqualTo(month)
            .findAll())
        .where((r) => owns(r.profileId, r.sharedSpaceId))
        .toList();
    for (final e in expenses) {
      if (!resolveExpenseProfileIdentity(e, budgets, directs)) {
        blockers.add('Resolve the profile assignment for "${e.title}" first.');
      }
    }
    int convert(int amount, CurrencyCode? from) {
      if (from == null || amount < 0) {
        throw const MonthEndException(
            'Unsupported currency or invalid stored money.');
      }
      final result = rates.convert(
          amount: Money(amount, from), to: currency, yearMonth: month);
      if (result.isDegraded) {
        throw const MonthEndException('A required exchange rate is missing.');
      }
      return result.amount.minorUnits;
    }

    // Validate every money row, including unassigned/direct expenses.
    try {
      for (final e in expenses) {
        final m = expenseAccountingMoney(e, expectedCurrency: currency);
        convert(m.minorUnits, m.currency);
      }
      for (final r in returns) {
        final m = reimbursementAccountingMoney(r, expectedCurrency: currency);
        convert(m.minorUnits, m.currency);
      }
    } on FormatException catch (error) {
      throw MonthEndException(error.message);
    }
    final source = budgets.where((p) => p.yearMonth == month).toList()
      ..sort((a, b) => a.syncGuid.compareTo(b.syncGuid));
    final sources = (await isar.incomeSources.where().findAll())
        .where((s) => owns(s.profileId, s.sharedSpaceId))
        .toList();
    final sourceIncome = const IncomeAggregationService()
        .monthlyTotal(sources, month, currency: currency);
    final sourceMonth = months.where((m) => m.yearMonth == month).firstOrNull;
    final income = context.isShared
        ? sourceMonth?.sharedIncomeOverride ??
            (sourceIncome > 0
                ? sourceIncome
                : (await isar.sharedSpaces.get(context.spaceId!))!
                    .defaultIncome)
        : sourceMonth?.netSalaryOverride != null
            ? Money.fromMajor(sourceMonth!.netSalaryOverride!, currency)
                .minorUnits
            : sourceIncome > 0
                ? sourceIncome
                : Money.fromMajor(
                        (await isar.userProfiles.get(actorId))!
                            .defaultNetSalary,
                        currency)
                    .minorUnits;
    int spent(int? id, String? type) =>
        const ProfileSpendingService().spentInYearMonth(
            profileId: id,
            profileType: type,
            yearMonth: month,
            expenses: expenses,
            reimbursements: returns,
            convert: (e) {
              final m = expenseAccountingMoney(e);
              return convert(m.minorUnits, m.currency);
            },
            convertReimbursement: (r) {
              final m = reimbursementAccountingMoney(r);
              return convert(m.minorUnits, m.currency);
            });
    final incoming = runs
        .where((r) => r.applied && r.destinationMonth == month)
        .fold<int>(
            0,
            (sum, r) =>
                sum +
                convert(r.carriedMinor, CurrencyCode.tryParse(r.currency)));
    final capacity = math.max(
        0,
        income +
            (context.isShared
                ? 0
                : await readMonthlyVaultCredit(
                    isar, actorId, month, currency)) +
            incoming -
            source.fold<int>(0, (sum, p) => sum + p.allocation) -
            directs.where((p) => p.yearMonth == month).fold<int>(
                0, (sum, p) => sum + spent(p.id, FinancialProfileType.direct)) -
            spent(null, null));
    final targets = budgets.where((p) => p.yearMonth == destination).toList();
    final lines = <MonthEndLine>[];
    final used = <String>{};
    for (final p in source) {
      final choice =
          choices.where((c) => c.sourceGuid == p.syncGuid).firstOrNull;
      final family = p.familyGuid.isEmpty ? p.syncGuid : p.familyGuid;
      final automatic = targets
          .where((d) => d.familyGuid == family && family.isNotEmpty)
          .toList();
      if (automatic.length > 1) {
        blockers.add(
            'Multiple destination profiles share the identity of ${p.name}.');
      }
      final target = choice?.destinationGuid == null
          ? automatic.firstOrNull
          : targets
              .where((d) => d.syncGuid == choice!.destinationGuid)
              .firstOrNull;
      if (choice?.destinationGuid != null && target == null) {
        blockers.add('Destination for ${p.name} no longer exists.');
      }
      // Unlinked legacy destinations must be reviewed, not silently duplicated.
      if (choice == null &&
          target == null &&
          targets.any((d) => d.familyGuid.isEmpty)) {
        blockers.add('Review the destination link for ${p.name}.');
      }
      if (target != null &&
          target.familyGuid.isNotEmpty &&
          target.familyGuid != family) {
        blockers.add(
            'Destination ${target.name} belongs to another profile identity.');
      }
      if (target != null && !used.add(target.syncGuid)) {
        blockers.add('A destination cannot receive two source profiles.');
      }
      final base = choice?.defaultAllocation ?? p.defaultAllocationMinor;
      if (base == null) {
        blockers.add('Confirm the default allocation for ${p.name}.');
      }
      final spent = const ProfileSpendingService().spentInYearMonth(
          profileId: p.id,
          profileType: FinancialProfileType.budget,
          yearMonth: month,
          expenses: expenses,
          reimbursements: returns,
          convert: (e) {
            final m = expenseAccountingMoney(e);
            return convert(m.minorUnits, m.currency);
          },
          convertReimbursement: (r) {
            final m = reimbursementAccountingMoney(r);
            return convert(m.minorUnits, m.currency);
          });
      final amounts = MonthEndAmounts(
          allocation: p.allocation,
          spent: spent,
          defaultAllocation: base ?? 0,
          rule: choice?.rule ?? p.monthEndRule,
          destinationAllocation: target?.allocation);
      lines.add(MonthEndLine(
          sourceGuid: p.syncGuid,
          familyGuid: family,
          destinationGuid: target?.syncGuid ??
              'budget:${monthEndDigest([
                    context.isShared ? 'shared' : 'personal',
                    guid,
                    family,
                    destination
                  ])}',
          name: target?.name ?? p.name,
          amounts: amounts,
          existingDestination: target != null,
          borrowed: math.min(amounts.overspent, capacity),
          deficit: math.max(0, amounts.overspent - capacity)));
    }
    final vaults = context.isShared
        ? <SavingsVault>[]
        : (await isar.savingsVaults.where().findAll())
            .where((v) => v.profileId == actorId)
            .toList();
    if (source.isNotEmpty &&
        vaults.any((v) => v.lastSweepYearMonth.compareTo(month) > 0) &&
        completed == null) {
      blockers.add(
          'The vault has already passed this month. Review the existing sweep before settlement.');
    }
    var canConfirm = true;
    if (context.isShared) {
      final member =
          await SpaceWriteGuard(isar).memberOf(context.spaceId!, actorId);
      canConfirm = member?.role.name == 'owner' && member?.revokedAt == null;
    }
    final fingerprint = monthEndDigest({
      'context': guid,
      'contextKind': context.isShared ? 'shared' : 'personal',
      'currency': currency.code,
      'month': month,
      'lines': lines.map((l) => l.toJson()).toList(),
      'expenses': expenses
          .map((e) => [
                e.syncGuid,
                e.amount,
                e.currency,
                e.fxHistoryJson,
                e.status.name,
                e.financialProfileType,
                e.financialProfileSyncGuid
              ])
          .toList()
        ..sort((a, b) => a.first.toString().compareTo(b.first.toString())),
      'returns': returns
          .map((r) => [
                r.syncGuid,
                r.amount,
                r.currency,
                r.fxHistoryJson,
                expenses.where((e) => e.id == r.expenseId).firstOrNull?.syncGuid
              ])
          .toList()
        ..sort((a, b) => a.first.toString().compareTo(b.first.toString())),
      'capacity': capacity,
      'targets': targets
          .map((p) => [
                p.syncGuid,
                p.familyGuid,
                p.allocation,
                p.defaultAllocationMinor,
                p.monthEndRule.name,
                p.updatedAt.toIso8601String()
              ])
          .toList(),
      'rates': rates
          .tableFor(month)
          ?.usdRates
          .map((key, value) => MapEntry(key.code, value)),
      'vaults':
          vaults.map((v) => [v.totalMinor, v.lastSweepYearMonth]).toList(),
    });
    return MonthEndReport(
        yearMonth: month,
        destinationMonth: destination,
        currency: currency,
        lines: List.unmodifiable(lines),
        blockers: List.unmodifiable(blockers),
        fingerprint: fingerprint,
        canConfirm: canConfirm,
        completed: completed);
  }

  Future<MonthEndRun> confirm(MonthEndReport preview,
          {List<MonthEndChoice> choices = const []}) =>
      isar.writeTxn(() async {
        final fresh = await _preview(preview.yearMonth, choices);
        if (fresh.completed != null) {
          throw const MonthEndException(
              'This month is already finished. No changes were applied.');
        }
        if (!fresh.ready) {
          throw MonthEndException(fresh.blockers.isEmpty
              ? 'Only the shared-space Owner can confirm.'
              : fresh.blockers.join('\n'));
        }
        if (fresh.fingerprint != preview.fingerprint) {
          throw const MonthEndException(
              'Data changed after preview. Generate a fresh preview.');
        }
        final guid = await _contextGuid();
        final identities = await isar.identitys.where().findAll();
        final actor = recorder?.signer?.authorIdentityId ??
            identities
                .where((i) => i.localProfileId == actorId)
                .firstOrNull
                ?.fingerprint ??
            'profile:$actorId';
        final run = MonthEndRun()
          ..syncGuid = 'month-end:${monthEndDigest([
                context.isShared ? 'shared' : 'personal',
                guid,
                fresh.yearMonth
              ])}'
          ..profileId = context.profileId
          ..sharedSpaceId = context.spaceId
          ..contextGuid = guid
          ..yearMonth = fresh.yearMonth
          ..destinationMonth = fresh.destinationMonth
          ..currency = fresh.currency.code
          ..fingerprint = fresh.fingerprint
          ..actor = actor
          ..createdAt = clock().toUtc()
          ..carriedMinor = fresh.carried
          ..releasedMinor = fresh.released
          ..reportJson = canonicalJsonEncode(
              {'lines': fresh.lines.map((l) => l.toJson()).toList()});
        final scope =
            AuditFinancialScope(context.profileId, context.spaceId, null);
        final financialBefore = await auditFinancialState(isar, scope);
        await projectMonthEnd(isar, run);
        await audit.appendMonthEnd(run);
        await audit.recordDerived(
            scope, financialBefore, await auditFinancialState(isar, scope));
        await recorder?.recordMonthEnd(run);
        return run;
      });
}

/// Inside caller transaction. Carries the full plan as one atomic sync unit,
/// rather than separate incremental allocation records that could be replayed.
Future<void> projectMonthEnd(Isar isar, MonthEndRun run,
    {bool remote = false}) async {
  final existing = await isar.monthEndRuns
      .filter()
      .syncGuidEqualTo(run.syncGuid)
      .findFirst();
  if (existing != null) {
    if (existing.profileId != run.profileId ||
        existing.sharedSpaceId != run.sharedSpaceId ||
        existing.contextGuid != run.contextGuid ||
        existing.yearMonth != run.yearMonth) {
      throw const FormatException(
          'Settlement identity crosses context or month');
    }
    if (existing.fingerprint != run.fingerprint) {
      existing.hasConflict = true;
      await isar.monthEndRuns.put(existing);
    }
    run.id = existing.id;
    return;
  }
  final json = canonicalJsonDecode(run.reportJson);
  final lines = (json['lines'] as List).cast<Map>();
  var carried = 0, released = 0;
  final destinations = <String>{};
  final sourceGuids = <String>{};
  // Validate the whole projection before writing any destination profile.
  var destinationConflict = false;
  for (final line in lines) {
    if (!sourceGuids.add(line['sourceGuid'] as String) ||
        (line['familyGuid'] as String).isEmpty) {
      throw const FormatException('Invalid source identity');
    }
    if (!destinations.add(line['destinationGuid'] as String)) {
      throw const FormatException('Duplicate month-end destination');
    }
    final amounts = MonthEndAmounts(
        allocation: line['allocation'] as int,
        spent: line['spent'] as int,
        defaultAllocation: line['defaultAllocation'] as int,
        destinationAllocation: line['destinationAllocation'] as int?,
        rule: MonthEndRule.values.byName(line['rule'] as String));
    if (line['nextAllocation'] != amounts.nextAllocation ||
        line['carried'] != amounts.carried ||
        line['released'] != amounts.released) {
      throw const FormatException('Invalid month-end arithmetic');
    }
    carried += amounts.carried;
    released += amounts.released;
    final target = await isar.budgetProfiles
        .filter()
        .syncGuidEqualTo(line['destinationGuid'] as String)
        .findFirst();
    if (target != null &&
        (target.sharedSpaceId != run.sharedSpaceId ||
            target.profileId != run.profileId ||
            target.yearMonth != run.destinationMonth)) {
      throw const FormatException('Destination crosses context/month');
    }
    if (target?.monthEndOriginGuid == run.syncGuid) {
      if (target?.monthEndFingerprint != run.fingerprint) {
        destinationConflict = true;
      }
      continue;
    }
    final expected = line['destinationAllocation'] as int?;
    if ((!remote && target == null && expected != null) ||
        (target != null &&
            target.allocation != (expected ?? line['defaultAllocation']))) {
      destinationConflict = true;
    }
  }
  if (carried != run.carriedMinor || released != run.releasedMinor) {
    throw const FormatException('Invalid month-end totals');
  }
  if (destinationConflict && remote) {
    run
      ..hasConflict = true
      ..applied = false;
    await isar.monthEndRuns.put(run);
    return;
  }
  if (destinationConflict) {
    throw const MonthEndException(
        'Destination changed. Generate a fresh preview.');
  }
  for (final line in lines) {
    final guid = line['destinationGuid'] as String;
    final target =
        await isar.budgetProfiles.filter().syncGuidEqualTo(guid).findFirst();
    if (target != null &&
        (target.sharedSpaceId != run.sharedSpaceId ||
            target.profileId != run.profileId ||
            target.yearMonth != run.destinationMonth)) {
      throw const MonthEndException(
          'Destination identity belongs to a different context or month.');
    }
    if (target?.monthEndOriginGuid == run.syncGuid) continue;
    final expected = line['destinationAllocation'] as int?;
    if ((!remote && target == null && expected != null) ||
        (target != null &&
            target.allocation != (expected ?? line['defaultAllocation']))) {
      throw const MonthEndException(
          'Destination changed. Review the month-end conflict.');
    }
    final profile = target ??
        (BudgetProfile()
          ..syncGuid = guid
          ..profileId = run.profileId
          ..sharedSpaceId = run.sharedSpaceId
          ..yearMonth = run.destinationMonth
          ..name = line['name'] as String
          ..createdAt = run.createdAt);
    profile
      ..monthEndOriginGuid = run.syncGuid
      ..monthEndFingerprint = run.fingerprint
      ..familyGuid = line['familyGuid'] as String
      ..defaultAllocationMinor = line['defaultAllocation'] as int
      ..monthEndRule = MonthEndRule.values.byName(line['rule'] as String)
      ..allocation = line['nextAllocation'] as int
      ..updatedAt = run.createdAt;
    await isar.budgetProfiles.put(profile);
    final delta = profile.allocation - (expected ?? 0);
    if (delta > 0) {
      await isar.allocations.put(Allocation()
        ..syncGuid = '${run.syncGuid}:allocation:$guid'
        ..profileId = run.profileId
        ..sharedSpaceId = run.sharedSpaceId
        ..yearMonth = run.destinationMonth
        ..budgetProfileId = profile.id
        ..amount = delta
        ..currency = run.currency
        ..date = run.createdAt
        ..createdAt = run.createdAt);
    }
  }
  final months = await isar.monthlyBudgets
      .filter()
      .yearMonthEqualTo(run.destinationMonth)
      .findAll();
  if (!months.any((m) =>
      m.profileId == run.profileId && m.sharedSpaceId == run.sharedSpaceId)) {
    await isar.monthlyBudgets.put(MonthlyBudget()
      ..profileId = run.profileId
      ..sharedSpaceId = run.sharedSpaceId
      ..yearMonth = run.destinationMonth
      ..baseAvailableAmount = 0
      ..createdAt = run.createdAt
      ..updatedAt = run.createdAt);
  }
  await isar.monthEndRuns.put(run);
}
