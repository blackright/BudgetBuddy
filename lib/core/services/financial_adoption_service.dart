import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:isar/isar.dart';

import '../models/currency_code.dart';
import '../models/financial_adoption.dart';
import '../models/fx_revision.dart' show fxMoneyBound;
import '../models/income_source.dart';
import '../models/monthly_budget.dart';
import '../models/reconciliation_snapshot.dart';
import '../models/shared_member.dart';
import '../models/shared_space.dart';
import '../models/user_profile.dart';
import '../providers/budget_context_provider.dart';
import '../../features/spaces/repositories/space_write_guard.dart';
import 'income_aggregation_service.dart';
import 'receipt_snapshot_repository.dart';
import 'receipt_write_guard.dart';

/// Immutable review data constructed only from one consistent database read.
class AdoptionPreview {
  AdoptionPreview._(
      {required this.source,
      required this.ownerName,
      required this.defaultIncomeMinor,
      required this.overrideMinor,
      required this.sourcesMinor,
      required this.currentIncomeMinor,
      required this.sourceLabels,
      required this.blockers,
      required this.fundingJson,
      required this.previousGuid,
      required this.revision,
      required this.inputFingerprint});

  final ReceiptSourceSnapshot source;
  final String ownerName;
  final int? defaultIncomeMinor;
  final int? overrideMinor;
  final int? sourcesMinor;
  final int? currentIncomeMinor;
  final List<String> sourceLabels;
  final List<String> blockers;
  final String fundingJson;
  final String? previousGuid;
  final int revision;
  final String inputFingerprint;
  bool get canConfirm => blockers.isEmpty;
}

/// Owner-reviewed start boundary; preserves every existing financial row.
/// Phase 1a deliberately prepares policy 2 without enabling money readers.
class FinancialAdoptionService {
  FinancialAdoptionService(this.db, {DateTime Function()? clock})
      : clock = clock ?? DateTime.now;
  final Isar db;
  final DateTime Function() clock;

  String _owner(ContextRef context) => context.isShared
      ? 'shared:${context.spaceId}:2'
      : 'personal:${context.profileId}:2';

  Future<AdoptionPreview> preview(
          {required ContextRef context,
          required int actorId,
          required bool Function() isAccessCurrent}) =>
      db.txn(() => _preview(context, actorId, isAccessCurrent));

  Future<AdoptionPreview> _preview(
      ContextRef context, int actorId, bool Function() access) async {
    final source = await ReceiptSnapshotRepository(db, clock: clock)
        .readInTransaction(
            context: context, actorId: actorId, isAccessCurrent: access);
    final blockers = source.blockers.map((b) => b.name).toSet();
    if (context.isShared) {
      final member =
          await SpaceWriteGuard(db).memberOf(context.spaceId!, actorId);
      if (member?.role != SharedMemberRole.owner || member?.revokedAt != null) {
        // Review includes private funding settings, so reject before returning
        // any display data to an Editor or Viewer.
        throw const ReceiptGuardException('ownerRequired');
      }
    }
    final months = await db.monthlyBudgets
        .buildQuery<MonthlyBudget>(
            filter: FilterGroup.and([
          FilterCondition.equalTo(
              property: 'profileId', value: context.profileId),
          FilterCondition.equalTo(
              property: 'sharedSpaceId', value: context.spaceId),
          FilterCondition.equalTo(
              property: 'yearMonth', value: context.yearMonth),
        ]))
        .findAll();
    final month = months.length == 1 ? months.single : null;
    final profile =
        context.isShared ? null : await db.userProfiles.get(context.profileId!);
    final space =
        context.isShared ? await db.sharedSpaces.get(context.spaceId!) : null;
    final currency = source.currency;
    int? major(double value) {
      final scaled = value * currency.minorUnitsPerMajor;
      if (!scaled.isFinite || scaled < 0 || scaled > fxMoneyBound) {
        blockers.add('invalidMoney');
        return null;
      }
      return scaled.round();
    }

    int? minor(int value) {
      if (value < 0 || value > fxMoneyBound) {
        blockers.add('invalidMoney');
        return null;
      }
      return value;
    }

    final defaultMinor = context.isShared
        ? minor(space!.defaultIncome)
        : major(profile!.defaultNetSalary);
    final overrideMinor = context.isShared
        ? (month?.sharedIncomeOverride == null
            ? null
            : minor(month!.sharedIncomeOverride!))
        : (month?.netSalaryOverride == null
            ? null
            : major(month!.netSalaryOverride!));
    if (month != null) major(month.baseAvailableAmount);
    final sources = await db.incomeSources
        .buildQuery<IncomeSource>(
            filter: FilterGroup.and([
          if (context.isShared)
            FilterCondition.equalTo(
                property: 'sharedSpaceId', value: context.spaceId)
          else
            FilterCondition.equalTo(
                property: 'profileId', value: context.profileId),
        ]))
        .findAll();
    sources.sort((a, b) => a.id.compareTo(b.id));
    const aggregation = IncomeAggregationService();
    for (final item in sources) {
      if (item.profileId != null && item.sharedSpaceId != null) {
        blockers.add('ambiguousIncomeOwner');
      }
      if (!aggregation.isValid(item) ||
          minor(item.amount) == null ||
          (item.endDate != null &&
              item.startDate != null &&
              item.endDate!.isBefore(item.startDate!))) {
        blockers.add('invalidIncomeSource');
      }
      if (CurrencyCode.tryParse(item.currency) != currency) {
        blockers.add('foreignIncomeNeedsReview');
      }
      if (item.frequency == IncomeFrequency.oneTime && item.startDate == null) {
        blockers.add('invalidIncomeSource');
      }
    }
    // Bound every contribution before adding; an overflowing integer aggregate
    // must never wrap into an apparently valid income amount.
    int? aggregate = 0;
    for (final item in sources) {
      final maximum = item.frequency == IncomeFrequency.weekly
          ? fxMoneyBound ~/ 4
          : fxMoneyBound;
      if (minor(item.amount) == null || item.amount > maximum) {
        blockers.add('invalidIncomeSource');
        aggregate = null;
        break;
      }
      final contribution = aggregation
          .monthlyTotal([item], context.yearMonth, currency: currency);
      if (contribution < 0 || contribution > fxMoneyBound - aggregate!) {
        blockers.add('invalidMoney');
        aggregate = null;
        break;
      }
      aggregate += contribution;
    }
    final current =
        overrideMinor ?? ((aggregate ?? 0) > 0 ? aggregate : defaultMinor);
    final previous = await db.financialAdoptions
        .filter()
        .ownerKeyEqualTo(_owner(context))
        .sortByRevisionDesc()
        .findFirst();
    if (previous != null && previous.effectiveYearMonth != context.yearMonth) {
      blockers.add('differentStartMonth');
    }
    if (previous != null &&
        (previous.status != 'reviewed' ||
            previous.enabledCapabilities.isNotEmpty)) {
      blockers.add('alreadyActivated');
    }
    final funding = jsonEncode({
      'defaultMinor': defaultMinor,
      'overrideMinor': overrideMinor,
      'sourcesMinor': aggregate,
      'currentIncomeMinor': current,
      'currency': currency.code,
      'sourceIds': sources.map((s) => s.syncGuid).toList(),
      'selection': overrideMinor != null
          ? 'override'
          : (aggregate ?? 0) > 0
              ? 'sources'
              : 'default',
      'financialEffect': 'unchanged',
      'capabilities': <String>[],
    });
    final input = sha256
        .convert(utf8.encode(jsonEncode([
          source.fingerprint,
          funding,
          previous?.guid,
          2,
          context.yearMonth,
        ])))
        .toString();
    if (!access()) throw const ReceiptGuardException('accessChanged');
    return AdoptionPreview._(
        source: source,
        ownerName: profile?.name ?? space!.name,
        defaultIncomeMinor: defaultMinor,
        overrideMinor: overrideMinor,
        sourcesMinor: aggregate,
        currentIncomeMinor: current,
        sourceLabels: List.unmodifiable(sources.map((s) => s.name)),
        blockers: List.unmodifiable(blockers),
        fundingJson: funding,
        previousGuid: previous?.guid,
        revision: (previous?.revision ?? 0) + 1,
        inputFingerprint: input);
  }

  Future<FinancialAdoption> confirm(
      {required AdoptionPreview preview,
      required String operationKey,
      required bool Function() isAccessCurrent}) {
    if (operationKey.trim().isEmpty || operationKey.length > 128) {
      throw const ReceiptGuardException('invalidOperation');
    }
    final source = preview.source;
    final owner = _owner(source.context);
    final operation = '$owner:$operationKey';
    return ReceiptWriteGuard(ReceiptSnapshotRepository(db)).run(
        previews: [source],
        actorId: source.actorId,
        isAccessCurrent: isAccessCurrent,
        write: () async {
          final fresh =
              await _preview(source.context, source.actorId, isAccessCurrent);
          final existing = await db.financialAdoptions
              .filter()
              .operationIdentityEqualTo(operation)
              .findFirst();
          if (existing != null) {
            if (existing.inputFingerprint != preview.inputFingerprint) {
              throw const ReceiptGuardException('duplicateMismatch');
            }
            return existing;
          }
          if (!preview.canConfirm || !fresh.canConfirm) {
            throw ReceiptGuardException(fresh.blockers.isNotEmpty
                ? fresh.blockers.first
                : 'needsReview');
          }
          if (fresh.inputFingerprint != preview.inputFingerprint) {
            throw const ReceiptGuardException('stalePreview');
          }
          final record = FinancialAdoption()
            ..ownerKey = owner
            ..profileId = source.context.profileId
            ..sharedSpaceId = source.context.spaceId
            ..effectiveYearMonth = source.context.yearMonth
            ..chosenAccountingCurrency = source.currency.code
            ..operationIdentity = operation
            ..inputFingerprint = preview.inputFingerprint
            ..legacySourceFingerprint = source.fingerprint
            ..reviewedFundingJson = preview.fundingJson
            ..actorId = source.actorId
            ..confirmedAt = clock().toUtc()
            ..revision = preview.revision
            ..previousRevisionGuid = preview.previousGuid;
          record.id = await db.financialAdoptions.put(record);
          return record;
        });
  }
}
