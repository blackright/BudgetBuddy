import 'package:isar/isar.dart';

import '../../../core/models/app_settings.dart';
import '../../../core/models/category.dart';
import '../../../core/models/currency_code.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/models/monthly_budget.dart';
import '../../../core/models/income_source.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/budget_profile.dart';
import '../../../core/models/direct_expense_profile.dart';
import '../../../core/models/medical_bill.dart';
import '../../../core/models/insurance_profile.dart';
import '../../../core/models/medical_service_type.dart';
import '../../../core/models/allocation.dart';
import '../../../core/models/transfer.dart';
import '../../../core/models/month_end_run.dart';
import '../../../core/models/audit_event.dart';
import '../../../core/models/identity.dart';
import '../../../core/models/lock_setting.dart';
import '../../expenses/models/reimbursement.dart';
import '../../vault/models/savings_vault.dart';
import '../../vault/models/vault_entry.dart';
import '../../expenses/repositories/category_repository.dart';
import '../../finance/repositories/audit_repository.dart';
import '../../finance/repositories/income_source_repository.dart';
import '../../settings/providers/app_settings_providers.dart';
import '../domain/onboarding_state.dart';
import '../domain/onboarding_finance.dart';
import '../domain/onboarding_startup.dart';
import '../domain/onboarding_progress.dart';
import '../domain/onboarding_automation_guard.dart';
import '../../medical/repositories/medical_repository.dart';
import '../../sync/domain/sync_codec.dart' show canonicalJsonEncode;
import '../../../core/database/schema_migrations.dart';
import '../../../core/models/month_rate_seal.dart';

class OnboardingCommitException implements Exception {
  const OnboardingCommitException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Financial core only. No owner activation, authentication, routing, directory
/// preparation, sweep or setup-completion side effects happen in this command.
class OnboardingRepository {
  OnboardingRepository(this.isar,
      {AuditRepository Function(int)? auditFactory,
      this.prepareDirectory,
      AppSettingsRepository? settings})
      : auditFactory =
            auditFactory ?? ((owner) => AuditRepository(isar, actorId: owner)),
        settings = settings ?? AppSettingsRepository(isar);
  final Isar isar;
  final AuditRepository Function(int) auditFactory;
  final AppSettingsRepository settings;
  final Future<void> Function(int owner)? prepareDirectory;

  Future<OnboardingCommitReference> commitCore(OnboardingState reviewed,
          {required String reviewedDigest,
          required int expectedRevision,
          bool Function()? isAuthorized}) =>
      isar.writeTxn(() async {
        if (isAuthorized != null && !isAuthorized()) {
          throw const OnboardingCommitException(
              'Phone verification changed. Verify again before confirming.');
        }
        final review = OnboardingFinance.review(reviewed);
        if (review.digest != reviewedDigest ||
            reviewed.revision != expectedRevision) {
          throw const OnboardingCommitException(
              'Setup changed. Review your amounts again.');
        }
        final raw = (await isar.appSettings.get(1))?.onboardingStateJson;
        if (raw == null) {
          throw const OnboardingCommitException(
              'Save and review this draft before confirming.');
        }
        final current = OnboardingState.decode(raw);
        if (current.flowId != reviewed.flowId) {
          throw const OnboardingCommitException(
              'Another setup draft is active. Reload it first.');
        }
        if (current.committed != null) {
          final ref = current.committed!;
          if (ref.digest != reviewedDigest ||
              ref.revision != expectedRevision) {
            throw const OnboardingCommitException(
                'Saved setup differs. Use the reviewed correction flow.');
          }
          await _validateRetry(ref, review);
          return ref; // Lost-response retry returns BEFORE all financial/audit writes.
        }
        if (current.revision != expectedRevision ||
            OnboardingFinance.review(current).digest != reviewedDigest) {
          throw const OnboardingCommitException(
              'Setup changed. Reload and review before saving.');
        }
        if (await isar.userProfiles.count() != 0) {
          throw const OnboardingCommitException(
              'A personal profile already exists. Use its existing setup.');
        }
        await _refuseOrphanedPersonalData();
        for (final source in review.normalized.sources) {
          if (await isar.incomeSources
                  .filter()
                  .syncGuidEqualTo(source.sourceGuid)
                  .count() !=
              0) {
            throw const OnboardingCommitException(
                'An income identity is already in use. Reload this setup.');
          }
        }
        final draft = review.normalized;
        final now = DateTime.now().toUtc();
        final profile = UserProfile()
          ..name = draft.profile.name
          ..avatar = ''
          ..primaryCurrency = review.currency.primary
          ..monthlyAvailableAmount = review.openingMajor
          ..defaultNetSalary = 0
          ..createdAt = now
          ..updatedAt = now
          ..lastActiveAt = now;
        profile.id = await isar.userProfiles.put(profile);
        await isar.schemaMigrationStamps.put(SchemaMigrationStamp()
          ..key = 'onboarding_pending_owner:${profile.id}'
          ..value = draft.flowId);
        await CategoryRepository(isar).seedUnifiedStarterInTxn();
        final audit = auditFactory(profile.id);
        final month = MonthlyBudget()
          ..profileId = profile.id
          ..sharedSpaceId = null
          ..yearMonth = draft.yearMonth!
          ..baseAvailableAmount = review.openingMajor
          ..openingBalanceConfirmed =
              (draft.opening.choice == OnboardingOpeningChoice.known)
          ..netSalaryOverride = null
          ..currency = null
          ..createdAt = now
          ..updatedAt = now;
        month.id = await audit.put(isar.monthlyBudgets, month,
            id: month.id, type: 'MonthlyBudget');
        final income = _SetupIncomeRepository(isar, audit);
        final ids = <String, int>{};
        for (final source in draft.sources) {
          final row = OnboardingFinance.sourceRecord(source,
              profileId: profile.id, at: now);
          await income.saveInTxn(row);
          ids[row.syncGuid] = row.id;
        }
        final ref = OnboardingCommitReference(
            profileId: profile.id,
            budgetId: month.id,
            budgetSyncGuid: month.syncGuid,
            yearMonth: month.yearMonth,
            revision: expectedRevision,
            digest: reviewedDigest,
            sourceIds: ids);
        final seeded = (await isar.appSettings.get(1))?.starterCategoryPolicy ==
            StarterCategoryPolicy.unifiedSeeded.name;
        final committed = OnboardingState(
            flowId: draft.flowId,
            revision: current.revision + 1,
            createdAt: current.createdAt,
            updatedAt: now,
            stage: OnboardingStage.coreCommitted,
            step: OnboardingStep.security,
            yearMonth: draft.yearMonth,
            profile: draft.profile,
            opening: draft.opening,
            incomeChoice: draft.incomeChoice,
            sources: draft.sources,
            committed: ref,
            categoriesReady: seeded);
        if (isAuthorized != null && !isAuthorized()) {
          throw const OnboardingCommitException(
              'Phone verification changed. No financial changes were saved.');
        }
        await settings.saveOnboardingStateInTxn(committed,
            expectedFlowId: current.flowId, expectedRevision: current.revision);
        return ref;
      });

  Future<void> _validateRetry(
      OnboardingCommitReference ref, OnboardingReview review) async {
    final profile = await isar.userProfiles.get(ref.profileId);
    final month = await isar.monthlyBudgets.get(ref.budgetId);
    if (profile == null ||
        month == null ||
        profile.name != review.normalized.profile.name ||
        profile.primaryCurrency != review.currency.primary ||
        profile.defaultNetSalary != 0 ||
        profile.monthlyAvailableAmount != review.openingMajor ||
        month.profileId != ref.profileId ||
        month.sharedSpaceId != null ||
        month.yearMonth != ref.yearMonth ||
        month.syncGuid != ref.budgetSyncGuid ||
        month.baseAvailableAmount != review.openingMajor ||
        month.openingBalanceConfirmed !=
            (review.normalized.opening.choice ==
                OnboardingOpeningChoice.known) ||
        month.netSalaryOverride != null ||
        month.currency != null) {
      throw const OnboardingCommitException(
          'Saved setup records are missing or changed. Review them without recreating money.');
    }
    final rows = await isar.incomeSources
        .filter()
        .profileIdEqualTo(ref.profileId)
        .findAll();
    if (rows.length != ref.sourceIds.length) {
      throw const OnboardingCommitException(
          'Saved income changed. Review the existing records.');
    }
    for (final source in review.normalized.sources) {
      final row =
          await isar.incomeSources.get(ref.sourceIds[source.sourceGuid] ?? -1);
      if (row == null ||
          row.profileId != ref.profileId ||
          row.sharedSpaceId != null ||
          row.syncGuid != source.sourceGuid ||
          row.name != source.name ||
          row.currency != review.currency.code ||
          row.amount != source.minorUnits ||
          row.type != source.type ||
          row.frequency != source.frequency ||
          _day(row.startDate) != _day(source.startDate) ||
          _day(row.endDate) != _day(source.endDate) ||
          row.notes != source.notes) {
        throw const OnboardingCommitException(
            'Saved income is missing or changed. Review it without creating a replacement.');
      }
    }
  }

  /// No absent personal owner is guessed/recreated from orphaned finance,
  /// identity, PIN settings or medical-directory rows. Shared data is retained.
  Future<void> _refuseOrphanedPersonalData() async {
    final scoped = <IsarCollection<dynamic>>[
      isar.monthlyBudgets,
      isar.incomeSources,
      isar.expenses,
      isar.budgetProfiles,
      isar.directExpenseProfiles,
      isar.medicalBills,
      isar.reimbursements,
      isar.allocations,
      isar.transfers,
      isar.monthEndRuns,
      isar.auditEvents
    ];
    for (final collection in scoped) {
      if (await collection
              .buildQuery<dynamic>(
                  filter:
                      const FilterCondition.isNull(property: 'sharedSpaceId'),
                  limit: 1)
              .findFirst() !=
          null) {
        throw const OnboardingCommitException(
            'Existing personal records need review before creating a new owner.');
      }
    }
    if (await isar.savingsVaults.count() != 0 ||
        await isar.vaultEntrys.count() != 0 ||
        (await isar.identitys.where().findAll())
            .any((i) => i.localProfileId > 0) ||
        (await isar.lockSettings.where().findAll())
            .any((s) => s.subjectKey.startsWith('p'))) {
      throw const OnboardingCommitException(
          'Existing personal ownership needs review before setup.');
    }
    for (final collection in <IsarCollection<dynamic>>[
      isar.insuranceProfiles,
      isar.familyMembers,
      isar.medicalProviders,
      isar.medicalServiceTypes
    ]) {
      if (await collection
              .buildQuery<dynamic>(
                  filter: const FilterCondition.greaterThan(
                      property: 'profileId', value: 0),
                  limit: 1)
              .findFirst() !=
          null) {
        throw const OnboardingCommitException(
            'Existing personal directory records need review.');
      }
    }
  }

  static String? _day(DateTime? d) =>
      d == null ? null : '${d.year}-${d.month}-${d.day}';
}

class _SetupIncomeRepository extends IncomeSourceRepository {
  _SetupIncomeRepository(super.isar, this.setupAudit);
  final AuditRepository setupAudit;
  @override
  AuditRepository get audit => setupAudit;
}

/// Recovery commands share the original repository, explicit owner and CAS.
extension OnboardingRecoveryCommands on OnboardingRepository {
  /// Local navigation checkpoint. It never creates money or grants access.
  Future<OnboardingState> checkpointStep(
          String flow, int expectedRevision, OnboardingStep step) =>
      isar.writeTxn(() async {
        final current = await _current(flow);
        if (current.revision != expectedRevision ||
            current.stage == OnboardingStage.completed) {
          throw const StaleOnboardingRevisionException();
        }
        await _checkRecorded(current);
        if (step.index >= OnboardingStep.security.index &&
            current.committed == null) {
          throw const OnboardingCommitException(
              'Confirm the financial review first.');
        }
        if (step.index >= OnboardingStep.overview.index &&
            (current.securityChoice == OnboardingSecurityChoice.pending ||
                !current.directoryReady ||
                !current.categoriesReady ||
                current.amendmentDraftJson != null)) {
          throw const OnboardingCommitException(
              'Complete preparation and protection choices first.');
        }
        final next = progressCopy(current,
            revision: current.revision + 1,
            updatedAt: _nextTime(current),
            step: step);
        await settings.saveOnboardingStateInTxn(next,
            expectedFlowId: flow, expectedRevision: current.revision);
        return next;
      });

  /// Revalidates real targets and configuration. Native/secure-store work is
  /// outside the transaction; the transient session is checked again inside it.
  Future<OnboardingState> finishSetup(String flow,
      {required int expectedRevision,
      required Future<bool> Function(String) verifierIsSet,
      required bool Function() isAuthorized}) async {
    final observed = await _current(flow);
    if (observed.committed == null || !isAuthorized()) {
      throw const OnboardingCommitException(
          'Verify the saved personal profile before finishing.');
    }
    final hasPin = await verifierIsSet('p${observed.committed!.profileId}');
    return isar.writeTxn(() async {
      final current = await _current(flow);
      await _checkRecorded(current);
      if (!isAuthorized()) {
        throw const OnboardingCommitException(
            'Protection changed. Verify again.');
      }
      if (current.stage == OnboardingStage.completed) return current;
      if (current.revision != expectedRevision) {
        throw const StaleOnboardingRevisionException();
      }
      if (current.amendmentDraftJson != null ||
          !current.categoriesReady ||
          !current.directoryReady ||
          current.securityChoice == OnboardingSecurityChoice.pending) {
        throw const OnboardingCommitException('Required setup is not ready.');
      }
      final owner = current.committed!.profileId;
      final row = await isar.lockSettings
          .filter()
          .subjectKeyEqualTo('p$owner')
          .findFirst();
      final enabled = row?.lockEnabled ?? false;
      if (enabled != hasPin ||
          (current.securityChoice == OnboardingSecurityChoice.configured) !=
              enabled) {
        throw const OnboardingCommitException(
            'Actual protection differs. Review it before finishing.');
      }
      if (await isar.categorys.count() == 0 ||
          await isar.medicalServiceTypes
                  .filter()
                  .profileIdEqualTo(owner)
                  .sharedSpaceIdIsNull()
                  .count() ==
              0) {
        throw const OnboardingCommitException(
            'Required records are unavailable. Retry preparation.');
      }
      final now = _nextTime(current);
      final complete = OnboardingState(
          flowId: current.flowId,
          revision: current.revision + 1,
          createdAt: current.createdAt,
          updatedAt: now,
          stage: OnboardingStage.completed,
          step: OnboardingStep.finish,
          yearMonth: current.yearMonth,
          committed: current.committed,
          categoriesReady: true,
          directoryReady: true,
          securityChoice: current.securityChoice,
          completedAt: now);
      await settings.saveOnboardingStateInTxn(complete,
          expectedFlowId: flow, expectedRevision: current.revision);
      final marker = await isar.schemaMigrationStamps
          .filter()
          .keyEqualTo('onboarding_pending_owner:$owner')
          .findFirst();
      if (marker != null && marker.value == flow) {
        await isar.schemaMigrationStamps.delete(marker.id);
      }
      return complete;
    });
  }

  /// A checkpoint of actual configuration, never an authentication grant.
  Future<OnboardingState> recordSecurityChoice(
      String flow,
      int owner,
      OnboardingSecurityChoice choice,
      Future<bool> Function(String) verifierIsSet) async {
    final verifier = await verifierIsSet('p$owner');
    return isar.writeTxn(() async {
      final current = await _current(flow);
      await _checkRecorded(current);
      if (current.committed?.profileId != owner ||
          current.amendmentDraftJson != null ||
          current.stage == OnboardingStage.completed) {
        throw const OnboardingCommitException(
            'Review the exact saved profile before choosing protection.');
      }
      final row = await isar.lockSettings
          .filter()
          .subjectKeyEqualTo('p$owner')
          .findFirst();
      final enabled = row?.lockEnabled ?? false;
      if (choice == OnboardingSecurityChoice.pending ||
          (choice == OnboardingSecurityChoice.configured &&
              (!enabled || !verifier)) ||
          (choice == OnboardingSecurityChoice.notNow &&
              (enabled || verifier))) {
        throw const OnboardingCommitException(
            'Saved protection is incomplete or differs. Review it before continuing.');
      }
      final next = progressCopy(current,
          revision: current.revision + 1,
          updatedAt: _nextTime(current),
          securityChoice: choice,
          stage: current.directoryReady && current.categoriesReady
              ? OnboardingStage.readyToFinish
              : OnboardingStage.preparing,
          step: OnboardingStep.security);
      await settings.saveOnboardingStateInTxn(next,
          expectedFlowId: flow, expectedRevision: current.revision);
      return next;
    });
  }

  Future<OnboardingStartup> readStartupState() => isar.txn(() async {
        final ids = (await isar.userProfiles.where().findAll())
            .map((p) => p.id)
            .toSet();
        final safeIds = <int>{};
        for (final id in ids) {
          if (!await isPendingSetupOwner(isar, id)) safeIds.add(id);
        }
        final raw = (await isar.appSettings.get(1))?.onboardingStateJson;
        if (raw == null) return resolveOnboardingStartup(profileIds: ids);
        try {
          final state = OnboardingState.decode(raw);
          await _checkRecorded(state);
          return resolveOnboardingStartup(profileIds: ids, state: state);
        } on OnboardingStateException {
          return resolveOnboardingStartup(profileIds: safeIds, invalid: true);
        } on OnboardingCommitException {
          return resolveOnboardingStartup(profileIds: safeIds, invalid: true);
        } on OnboardingFinanceException {
          return resolveOnboardingStartup(profileIds: safeIds, invalid: true);
        }
      });

  Future<void> _checkRecorded(OnboardingState state) async {
    final ref = state.committed;
    if (ref == null) return;
    if (state.stage == OnboardingStage.completed) {
      final owner = await isar.userProfiles.get(ref.profileId);
      final month = await isar.monthlyBudgets.get(ref.budgetId);
      if (owner == null ||
          month == null ||
          month.profileId != ref.profileId ||
          month.sharedSpaceId != null ||
          month.syncGuid != ref.budgetSyncGuid ||
          month.yearMonth != ref.yearMonth) {
        throw const OnboardingCommitException(
            'Saved setup targets are unavailable.');
      }
      return;
    }
    final review = OnboardingFinance.review(
        financialDraftOf(state, revision: ref.revision));
    if (review.digest != ref.digest) {
      throw const OnboardingCommitException('Saved review evidence differs.');
    }
    await _validateRetry(ref, review);
  }

  Future<OnboardingState> saveDraft(OnboardingState draft,
          {required int? expectedRevision}) =>
      isar.writeTxn(() async {
        if (draft.stage != OnboardingStage.draft) {
          throw const OnboardingCommitException(
              'Save draft details separately from their financial receipt.');
        }
        final raw = (await isar.appSettings.get(1))?.onboardingStateJson;
        final current = raw == null ? null : OnboardingState.decode(raw);
        if (current?.revision != expectedRevision ||
            (current != null && current.flowId != draft.flowId)) {
          throw const StaleOnboardingRevisionException();
        }
        final now = DateTime.now().toUtc();
        final edit = progressCopy(draft,
            revision: current == null ? 0 : current.revision + 1,
            updatedAt: now.isBefore(draft.updatedAt) ? draft.updatedAt : now);
        late OnboardingState next;
        if (current?.committed != null) {
          if (current!.stage == OnboardingStage.completed ||
              current.profile.currency != edit.profile.currency) {
            throw const OnboardingCommitException(
                'Accounting currency is fixed after confirmation.');
          }
          await _checkRecorded(current);
          next = progressCopy(current,
              revision: edit.revision,
              updatedAt: edit.updatedAt,
              stage: OnboardingStage.coreCommitted,
              amendmentDraftJson: edit.encode());
        } else {
          next = edit;
        }
        await settings.saveOnboardingStateInTxn(next,
            expectedFlowId: current?.flowId,
            expectedRevision: current?.revision);
        return next;
      });

  Future<OnboardingState> prepareCommittedSetup(String flowId) async {
    final before = await isar.writeTxn(() async {
      final current = await _current(flowId);
      await _checkRecorded(current);
      if (current.committed == null || current.amendmentDraftJson != null) {
        throw const OnboardingCommitException(
            'Review saved financial corrections before preparation.');
      }
      if (current.stage == OnboardingStage.completed) return current;
      if (current.directoryReady && current.categoriesReady) {
        if (current.securityChoice == OnboardingSecurityChoice.pending ||
            current.stage == OnboardingStage.readyToFinish) {
          return current;
        }
        final ready = progressCopy(current,
            revision: current.revision + 1,
            updatedAt: _nextTime(current),
            stage: OnboardingStage.readyToFinish);
        await settings.saveOnboardingStateInTxn(ready,
            expectedFlowId: flowId, expectedRevision: current.revision);
        return ready;
      }
      if (current.stage == OnboardingStage.preparing) return current;
      final next = progressCopy(current,
          revision: current.revision + 1,
          updatedAt: _nextTime(current),
          stage: OnboardingStage.preparing);
      await settings.saveOnboardingStateInTxn(next,
          expectedFlowId: flowId, expectedRevision: current.revision);
      return next;
    });
    if (before.stage == OnboardingStage.completed ||
        (before.directoryReady && before.categoriesReady)) {
      return before;
    }
    // Directory preparation owns its own short transaction, never nested in core.
    await (prepareDirectory?.call(before.committed!.profileId) ??
        MedicalRepository(isar)
            .ensureDefaultServiceTypes(before.committed!.profileId));
    await CategoryRepository(isar).getForUnifiedSetup();
    return isar.writeTxn(() async {
      final current = await _current(flowId);
      if (current.directoryReady && current.categoriesReady) {
        await _checkRecorded(current);
        return current;
      }
      if (current.revision != before.revision) {
        throw const StaleOnboardingRevisionException();
      }
      await _checkRecorded(current);
      final count = await isar.medicalServiceTypes
          .filter()
          .profileIdEqualTo(current.committed!.profileId)
          .sharedSpaceIdIsNull()
          .count();
      if (count == 0) {
        throw const OnboardingCommitException(
            'Required directory preparation is incomplete. Retry safely.');
      }
      await CategoryRepository(isar).seedUnifiedStarterInTxn();
      final marker = (await isar.appSettings.get(1))?.starterCategoryPolicy;
      if (marker != StarterCategoryPolicy.unifiedSeeded.name &&
          marker != StarterCategoryPolicy.preserveExisting.name &&
          marker != null) {
        throw const OnboardingCommitException('Category policy needs review.');
      }
      if (await isar.categorys.count() == 0) {
        throw const OnboardingCommitException(
            'Required categories are unavailable.');
      }
      final next = progressCopy(current,
          revision: current.revision + 1,
          updatedAt: _nextTime(current),
          directoryReady: true,
          categoriesReady: true,
          stage: current.securityChoice == OnboardingSecurityChoice.pending
              ? OnboardingStage.preparing
              : OnboardingStage.readyToFinish);
      await settings.saveOnboardingStateInTxn(next,
          expectedFlowId: flowId, expectedRevision: current.revision);
      return next;
    });
  }

  Future<OnboardingState> _current(String flow) async {
    final raw = (await isar.appSettings.get(1))?.onboardingStateJson;
    if (raw == null) {
      throw const OnboardingCommitException('Saved setup is unavailable.');
    }
    final state = OnboardingState.decode(raw);
    if (state.flowId != flow) throw const StaleOnboardingRevisionException();
    return state;
  }

  DateTime _nextTime(OnboardingState s) {
    final now = DateTime.now().toUtc();
    return now.isBefore(s.updatedAt) ? s.updatedAt : now;
  }

  Future<OnboardingState> amendCore(OnboardingState edited,
          {required int expectedRevision,
          required String reviewedDigest,
          bool Function()? isAuthorized}) =>
      isar.writeTxn(() async {
        if (isAuthorized != null && !isAuthorized()) {
          throw const OnboardingCommitException(
              'Phone verification changed. Verify again before correcting.');
        }
        final review = OnboardingFinance.review(edited);
        if (review.digest != reviewedDigest ||
            edited.revision != expectedRevision) {
          throw const OnboardingCommitException(
              'Review the latest financial details.');
        }
        final current = await _current(edited.flowId);
        if (current.revision != expectedRevision) {
          if (current.committed?.revision == expectedRevision &&
              current.committed?.digest == reviewedDigest) {
            await _checkRecorded(current);
            return current;
          }
          throw const StaleOnboardingRevisionException();
        }
        if (current.stage == OnboardingStage.completed ||
            current.committed == null) {
          throw const OnboardingCommitException(
              'This setup cannot be amended.');
        }
        await _checkRecorded(current);
        if (current.profile.currency != edited.profile.currency) {
          throw const OnboardingCommitException(
              'Accounting currency is fixed after confirmation.');
        }
        final prior = OnboardingFinance.review(
            financialDraftOf(current, revision: expectedRevision));
        if (prior.digest == review.digest) {
          if (current.amendmentDraftJson == null) return current;
          final unchanged = progressCopy(current,
              revision: current.revision + 1,
              updatedAt: _nextTime(current),
              clearAmendment: true);
          await settings.saveOnboardingStateInTxn(unchanged,
              expectedFlowId: current.flowId,
              expectedRevision: current.revision);
          return unchanged;
        }
        await _assertAmendable(current, edited.yearMonth!);
        final ref = current.committed!;
        final owner = (await isar.userProfiles.get(ref.profileId))!;
        final month = (await isar.monthlyBudgets.get(ref.budgetId))!;
        final audit = auditFactory(owner.id);
        if (owner.name != review.normalized.profile.name) {
          await audit.change(
              type: 'UserProfile',
              before: {
                'id': owner.id,
                'profileId': owner.id,
                'name': owner.name
              },
              after: {
                'id': owner.id,
                'profileId': owner.id,
                'name': review.normalized.profile.name
              },
              action: 'profile.rename');
        }
        owner
          ..name = review.normalized.profile.name
          ..monthlyAvailableAmount = review.openingMajor
          ..updatedAt = _nextTime(current);
        await isar.userProfiles.put(owner);
        final monthChanged = month.yearMonth != edited.yearMonth ||
            month.baseAvailableAmount != review.openingMajor ||
            month.openingBalanceConfirmed !=
                (edited.opening.choice == OnboardingOpeningChoice.known);
        if (monthChanged) {
          month
            ..yearMonth = edited.yearMonth!
            ..baseAvailableAmount = review.openingMajor
            ..openingBalanceConfirmed =
                edited.opening.choice == OnboardingOpeningChoice.known
            ..updatedAt = _nextTime(current);
          await audit.put(isar.monthlyBudgets, month,
              id: month.id, type: 'MonthlyBudget');
        }
        final income = _SetupIncomeRepository(isar, audit);
        final ids = <String, int>{};
        final retained =
            review.normalized.sources.map((s) => s.sourceGuid).toSet();
        for (final old in ref.sourceIds.entries) {
          if (!retained.contains(old.key)) await income.deleteInTxn(old.value);
        }
        final previousAmounts = {
          for (final s in current.sources) s.sourceGuid: s.minorUnits!
        };
        final ordered = [
          ...review.normalized.sources
        ]..sort((a, b) => (a.minorUnits! - (previousAmounts[a.sourceGuid] ?? 0))
            .compareTo(b.minorUnits! - (previousAmounts[b.sourceGuid] ?? 0)));
        for (final source in ordered) {
          final existingId = ref.sourceIds[source.sourceGuid];
          if (existingId == null &&
              await isar.incomeSources
                      .filter()
                      .syncGuidEqualTo(source.sourceGuid)
                      .count() >
                  0) {
            throw const OnboardingCommitException(
                'Income identity is already in use.');
          }
          final row = OnboardingFinance.sourceRecord(source,
              profileId: owner.id, at: _nextTime(current));
          if (existingId != null) {
            final old = (await isar.incomeSources.get(existingId))!;
            row
              ..id = old.id
              ..createdAt = old.createdAt;
            final priorSource = current.sources
                .firstWhere((s) => s.sourceGuid == source.sourceGuid);
            if (canonicalJsonEncode(
                    {...priorSource.toJson()}..remove('amountText')) ==
                canonicalJsonEncode(
                    {...source.toJson()}..remove('amountText'))) {
              ids[source.sourceGuid] = old.id;
              continue;
            }
          }
          await income.saveInTxn(row);
          ids[source.sourceGuid] = row.id;
        }
        final receipt = OnboardingCommitReference(
            profileId: ref.profileId,
            budgetId: ref.budgetId,
            budgetSyncGuid: ref.budgetSyncGuid,
            yearMonth: edited.yearMonth!,
            revision: expectedRevision,
            digest: reviewedDigest,
            sourceIds: ids);
        final d = review.normalized;
        final next = OnboardingState(
            flowId: d.flowId,
            revision: current.revision + 1,
            createdAt: current.createdAt,
            updatedAt: _nextTime(current),
            stage: OnboardingStage.coreCommitted,
            step: OnboardingStep.security,
            yearMonth: d.yearMonth,
            profile: d.profile,
            opening: d.opening,
            incomeChoice: d.incomeChoice,
            sources: d.sources,
            committed: receipt,
            categoriesReady: current.categoriesReady,
            directoryReady: current.directoryReady,
            securityChoice: current.securityChoice);
        if (isAuthorized != null && !isAuthorized()) {
          throw const OnboardingCommitException(
              'Phone verification changed. No financial corrections were saved.');
        }
        await settings.saveReviewedAmendmentInTxn(next,
            expectedFlowId: current.flowId, expectedRevision: current.revision);
        return next;
      });

  Future<void> _assertAmendable(OnboardingState state, String newMonth) async {
    final ref = state.committed!;
    for (final c in <IsarCollection<dynamic>>[
      isar.expenses,
      isar.budgetProfiles,
      isar.directExpenseProfiles,
      isar.medicalBills,
      isar.reimbursements,
      isar.allocations,
      isar.transfers,
      isar.monthEndRuns
    ]) {
      if (await c
              .buildQuery<dynamic>(
                  filter: FilterGroup.and([
                    FilterCondition.equalTo(
                        property: 'profileId', value: ref.profileId),
                    const FilterCondition.isNull(property: 'sharedSpaceId')
                  ]),
                  limit: 1)
              .findFirst() !=
          null) {
        throw const OnboardingCommitException(
            'Financial activity already exists. Use the normal correction screens.');
      }
    }
    if (await isar.savingsVaults
                .filter()
                .profileIdEqualTo(ref.profileId)
                .count() >
            0 ||
        await isar.vaultEntrys
                .filter()
                .profileIdEqualTo(ref.profileId)
                .count() >
            0) {
      throw const OnboardingCommitException(
          'Savings activity prevents setup corrections.');
    }
    for (final ym in {ref.yearMonth, newMonth}) {
      if (await isar.monthRateSeals.filter().yearMonthEqualTo(ym).count() > 0) {
        throw const OnboardingCommitException(
            'A rate seal protects this month. Use normal correction screens.');
      }
    }
    final budgets = await isar.monthlyBudgets
        .filter()
        .profileIdEqualTo(ref.profileId)
        .sharedSpaceIdIsNull()
        .findAll();
    if (budgets.any((b) => b.id != ref.budgetId)) {
      throw const OnboardingCommitException(
          'Other months already exist for this owner. Use normal correction screens.');
    }
  }
}
