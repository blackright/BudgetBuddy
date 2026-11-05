import 'dart:async';
import 'setup_flow_provider.dart';
import '../domain/onboarding_progress.dart';
import '../domain/onboarding_startup.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_helper.dart';
import '../../../core/services/profile_name.dart';
import '../../../core/models/currency_code.dart';
import '../../../core/models/income_source.dart';
import '../../settings/providers/app_settings_providers.dart';
import '../../sync/domain/sync_guid.dart';
import '../domain/onboarding_state.dart';
import '../domain/onboarding_finance.dart';
import '../domain/onboarding_starting_position.dart';
import '../repositories/onboarding_repository.dart';

/// Owns the unified financial slice. It never reports whole-onboarding
/// completion; the security and finish stages do that.
class FinancialSetupView {
  FinancialSetupView(
      {required this.draft,
      this.page = 0,
      this.expandedSourceGuid,
      this.review,
      this.receipt,
      this.isSaving = false,
      this.saveStatus = 'Not saved yet',
      this.loading = false,
      this.needsReview = false,
      this.existingProfileIds = const {},
      Map<String, String> errors = const {},
      this.error})
      : errors = Map.unmodifiable(errors);
  final OnboardingState draft;
  final int page;
  final String? expandedSourceGuid;
  final OnboardingReview? review;
  final OnboardingCommitReference? receipt;
  final String saveStatus;
  final bool loading, needsReview;
  final Set<int> existingProfileIds;
  final bool isSaving;
  final Map<String, String> errors;
  final String? error;
}

class FinancialSetupController extends StateNotifier<FinancialSetupView> {
  FinancialSetupController(
      {OnboardingState? initial,
      this.repository,
      this.autoSave = false,
      AppSettingsRepository? settings})
      : settings = settings ??
            (repository == null
                ? null
                : AppSettingsRepository(repository.isar)),
        super(FinancialSetupView(draft: initial ?? _newDraft()));
  final OnboardingRepository? repository;
  final AppSettingsRepository? settings;
  OnboardingState? _persisted;
  final bool autoSave;
  Timer? _debounce;
  Future<bool>? _flushFlight;
  int _generation = 0, _savedGeneration = 0;
  bool _restoring = false, _navigating = false;
  OnboardingState? get savedProgress => _persisted;
  bool get currencyFixed => _persisted?.committed != null;
  bool get preparationReady =>
      _persisted?.categoriesReady == true && _persisted?.directoryReady == true;

  void _status(String value,
      {bool? loading,
      bool? needsReview,
      Set<int>? existingProfileIds,
      String? error}) {
    if (!mounted) return;
    final old = state;
    state = FinancialSetupView(
        draft: old.draft,
        page: old.page,
        expandedSourceGuid: old.expandedSourceGuid,
        review: old.review,
        receipt: old.receipt,
        isSaving: old.isSaving,
        errors: old.errors,
        error: error ?? old.error,
        saveStatus: value,
        loading: loading ?? old.loading,
        needsReview: needsReview ?? old.needsReview,
        existingProfileIds: existingProfileIds ?? old.existingProfileIds);
  }

  void _queueSave() {
    if (!autoSave || repository == null || _restoring) return;
    _generation++;
    _status('Changes not saved yet');
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      unawaited(flush());
    });
  }

  Future<bool> flush() {
    _debounce?.cancel();
    return _flushFlight ??= _drain().whenComplete(() => _flushFlight = null);
  }

  Future<bool> _drain() async {
    if (!autoSave || repository == null) return true;
    try {
      while (mounted && _savedGeneration != _generation) {
        final generation = _generation;
        final snapshot = progressCopy(state.draft,
            step: state.page == 0
                ? OnboardingStep.profile
                : OnboardingStep.firstMonth);
        _status('Saving...');
        final saved = await repository!
            .saveDraft(snapshot, expectedRevision: _persisted?.revision);
        _persisted = saved;
        _savedGeneration = generation;
        if (mounted) {
          final current = state;
          _show(
              draft: replaceOnboardingDraft(current.draft,
                  revision: saved.revision, updatedAt: saved.updatedAt),
              page: current.page,
              review: current.review,
              errors: current.errors,
              error: current.error,
              persistenceUpdate: true);
        }
      }
      _status('Saved on this device');
      return true;
    } on OnboardingStateException {
      try {
        OnboardingFinance.review(state.draft);
      } on OnboardingFinanceException catch (e) {
        if (mounted) _show(errors: e.fields, persistenceUpdate: true);
      }
      _status('Could not save. Correct the highlighted details.');
      return false;
    } on StaleOnboardingRevisionException {
      _status(
          'Could not save. Saved setup changed elsewhere. Review the saved version.');
      return false;
    } on OnboardingCommitException {
      _status(
          'Could not save. Saved records need review. Review the saved version.');
      return false;
    } catch (_) {
      _status('Could not save. Retry before leaving.');
      return false;
    }
  }

  Future<void> restore() async {
    if (repository == null) return;
    _debounce?.cancel();
    await _flushFlight;
    _restoring = true;
    _status('Loading saved setup...', loading: true);
    try {
      final result = await repository!.readStartupState();
      if (!mounted) return;
      if (result.kind == StartupKind.needsReview ||
          result.kind == StartupKind.establishedUser) {
        _status('Setup needs review',
            loading: false,
            needsReview: true,
            existingProfileIds: result.existingProfileIds);
        return;
      }
      final saved = result.state;
      if (saved != null) {
        _persisted = saved;
        final edit = saved.amendmentDraftJson == null
            ? financialDraftOf(saved)
            : OnboardingState.decode(saved.amendmentDraftJson!);
        final page = saved.committed != null && saved.amendmentDraftJson == null
            ? 2
            : edit.step.index <= OnboardingStep.profile.index
                ? 0
                : 1;
        _show(
            draft: replaceOnboardingDraft(edit, revision: saved.revision),
            page: page,
            receipt: saved.amendmentDraftJson == null ? saved.committed : null,
            clearReceipt: true,
            persistenceUpdate: true);
      } else {
        _persisted = null;
        _show(
            draft: _newDraft(flowId: state.draft.flowId),
            page: 0,
            clearReceipt: true,
            persistenceUpdate: true);
      }
      _generation = 0;
      _savedGeneration = 0;
      _status(saved == null ? 'Not saved yet' : 'Saved on this device',
          loading: false, needsReview: false);
    } catch (_) {
      _status('Saved setup could not be read. Retry safely.',
          loading: false, needsReview: true);
    } finally {
      _restoring = false;
    }
  }

  Future<void> checkpoint(OnboardingStep step) async {
    if (!await flush()) {
      throw StateError('Save the current entries before continuing.');
    }
    if (repository == null) return;
    if (_persisted == null) {
      _generation++;
      if (!await flush()) throw StateError('Save setup first.');
    }
    final next = await repository!
        .checkpointStep(_persisted!.flowId, _persisted!.revision, step);
    _persisted = next;
    if (mounted) {
      _show(
          draft: progressCopy(state.draft,
              revision: next.revision, updatedAt: next.updatedAt, step: step),
          receipt: next.committed,
          persistenceUpdate: true);
    }
  }

  Future<OnboardingState> finish(
      {required Future<bool> Function(String) verifierIsSet,
      required bool Function() isAuthorized}) async {
    if (!await flush() || repository == null || _persisted == null) {
      throw StateError('Saved setup is unavailable.');
    }
    final next = await repository!.finishSetup(_persisted!.flowId,
        expectedRevision: _persisted!.revision,
        verifierIsSet: verifierIsSet,
        isAuthorized: isAuthorized);
    _persisted = next;
    return next;
  }

  void beginCorrection() {
    if (_persisted?.committed == null || state.isSaving) return;
    _show(draft: financialDraftOf(_persisted!), page: 0, clearReceipt: true);
  }

  /// Reconcile the security checkpoint with this coordinator's CAS revision.
  /// The repository independently checks the real setting and verifier.
  Future<void> confirmProtection(OnboardingSecurityChoice choice,
      Future<bool> Function(String) verifierIsSet) async {
    if (!await flush() || repository == null || _persisted?.committed == null) {
      throw StateError('Saved setup is not ready for protection confirmation.');
    }
    final saved = await repository!.recordSecurityChoice(_persisted!.flowId,
        _persisted!.committed!.profileId, choice, verifierIsSet);
    _persisted = saved;
    if (mounted) {
      _show(
          draft: replaceOnboardingDraft(state.draft,
              revision: saved.revision, updatedAt: saved.updatedAt),
          receipt: saved.committed,
          persistenceUpdate: true);
    }
  }

  Future<void> prepare() async {
    if (repository == null || _persisted?.committed == null || state.isSaving) {
      return;
    }
    _show(saving: true);
    try {
      final prepared =
          await repository!.prepareCommittedSetup(_persisted!.flowId);
      _persisted = prepared;
      if (mounted) _show(receipt: prepared.committed, error: null);
    } catch (_) {
      if (mounted) {
        _show(
            error:
                'Financial details are saved. Preparation could not finish. Retry preparation safely.');
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  bool get canSave => repository != null && settings != null;
  bool get _editable =>
      !state.isSaving &&
      !state.loading &&
      !state.needsReview &&
      state.receipt == null;
  static OnboardingState _newDraft({String? flowId}) {
    final now = DateTime.now();
    return OnboardingState(
        flowId: flowId ?? newSyncGuid(),
        revision: 0,
        createdAt: now,
        updatedAt: now,
        yearMonth: '${now.year}-${now.month.toString().padLeft(2, '0')}');
  }

  void _show(
      {OnboardingState? draft,
      int? page,
      String? expanded,
      bool clearExpanded = false,
      OnboardingReview? review,
      OnboardingCommitReference? receipt,
      bool saving = false,
      bool persistenceUpdate = false,
      bool clearReceipt = false,
      Map<String, String> errors = const {},
      String? error}) {
    state = FinancialSetupView(
        draft: draft ?? state.draft,
        page: page ?? state.page,
        expandedSourceGuid:
            clearExpanded ? null : expanded ?? state.expandedSourceGuid,
        review: review,
        receipt: receipt ?? (clearReceipt ? null : state.receipt),
        saveStatus: state.saveStatus,
        loading: state.loading,
        needsReview: state.needsReview,
        existingProfileIds: state.existingProfileIds,
        isSaving: saving,
        errors: errors,
        error: error);
    if (!persistenceUpdate &&
        !saving &&
        state.receipt == null &&
        (draft != null || page != null)) {
      _queueSave();
    }
  }

  void setProfileName(String name) {
    if (!_editable) return;
    _show(
        draft: replaceOnboardingDraft(state.draft,
            profile: OnboardingProfileDraft(
                name: name, currency: state.draft.profile.currency)));
  }

  bool changeCurrency(CurrencyCode currency,
      {bool discardAmountsConfirmed = false}) {
    if (!_editable || currencyFixed) return false;
    final d = state.draft;
    if (d.profile.currency == currency) return true;
    if ((d.opening.amountText.isNotEmpty ||
            d.sources.any((s) => s.amountText.isNotEmpty)) &&
        !discardAmountsConfirmed) {
      return false;
    }
    _show(
        draft: replaceOnboardingDraft(d,
            profile: OnboardingProfileDraft(
                name: d.profile.name, currency: currency),
            opening: OnboardingOpeningDraft(
                choice: d.opening.choice,
                currency: d.opening.choice == OnboardingOpeningChoice.known
                    ? currency
                    : null),
            sources: d.sources
                .map((s) => OnboardingSourceDraft(
                    sourceGuid: s.sourceGuid,
                    name: s.name,
                    type: s.type,
                    frequency: s.frequency,
                    currency: currency,
                    startDate: s.startDate,
                    endDate: s.endDate,
                    nominalDay: s.nominalDay,
                    notes: s.notes))
                .toList()));
    return true;
  }

  void setMonth(String month) {
    if (_editable) {
      _show(draft: replaceOnboardingDraft(state.draft, yearMonth: month));
    }
  }

  void setOpening(OnboardingOpeningChoice choice, {String? amountText}) {
    if (!_editable) return;
    _show(
        draft: replaceOnboardingDraft(state.draft,
            opening: OnboardingOpeningDraft(
                choice: choice,
                amountText: choice == OnboardingOpeningChoice.known
                    ? (amountText ?? state.draft.opening.amountText)
                    : '',
                currency: choice == OnboardingOpeningChoice.known
                    ? state.draft.profile.currency
                    : null)));
  }

  void addSource() {
    if (!_editable) return;
    final id = newSyncGuid();
    final parts = state.draft.yearMonth!.split('-');
    final source = OnboardingSourceDraft(
        sourceGuid: id,
        currency: state.draft.profile.currency,
        startDate: DateTime(int.parse(parts[0]), int.parse(parts[1])),
        nominalDay: 25);
    _show(
        draft: replaceOnboardingDraft(state.draft,
            incomeChoice: OnboardingIncomeChoice.sources,
            sources: [...state.draft.sources, source]),
        expanded: id);
  }

  void toggleSource(String id) {
    if (_editable) {
      _show(expanded: id, clearExpanded: state.expandedSourceGuid == id);
    }
  }

  void updateSource(String id,
      {String? name,
      String? amountText,
      IncomeSourceType? type,
      IncomeFrequency? frequency,
      DateTime? startDate,
      DateTime? endDate,
      int? nominalDay,
      bool clearEnd = false,
      String? notes}) {
    if (!_editable) return;
    _show(
        draft: replaceOnboardingDraft(state.draft,
            sources: state.draft.sources
                .map((s) => s.sourceGuid != id
                    ? s
                    : OnboardingSourceDraft(
                        sourceGuid: id,
                        name: name ?? s.name,
                        amountText: amountText ?? s.amountText,
                        // Editing invalidates reviewed evidence. Raw drafts can
                        // retain incomplete dates/amounts; commit revalidates.
                        minorUnits: null,
                        currency: s.currency,
                        type: type ?? s.type,
                        frequency: frequency ?? s.frequency,
                        startDate: startDate ?? s.startDate,
                        endDate: clearEnd ? null : endDate ?? s.endDate,
                        nominalDay: nominalDay ?? s.nominalDay,
                        notes: notes ?? s.notes))
                .toList()));
  }

  void removeSource(String id) {
    if (_editable) {
      _show(
          draft: replaceOnboardingDraft(state.draft,
              sources: state.draft.sources
                  .where((s) => s.sourceGuid != id)
                  .toList()),
          clearExpanded: state.expandedSourceGuid == id);
    }
  }

  bool chooseNoIncome({bool discardSourcesConfirmed = false}) {
    if (!_editable) return false;
    if (state.draft.sources.isNotEmpty && !discardSourcesConfirmed) {
      return false;
    }
    _show(
        draft: replaceOnboardingDraft(state.draft,
            incomeChoice: OnboardingIncomeChoice.none, sources: []),
        clearExpanded: true);
    return true;
  }

  Future<void> goTo(int page) async {
    if (!_editable || _navigating) return;
    _navigating = true;
    try {
      if (autoSave && !await flush()) return;
      if (mounted && _editable && page >= 0 && page <= state.page) {
        _show(page: page);
        if (autoSave) await flush();
      }
    } finally {
      _navigating = false;
    }
  }

  Future<void> next() async {
    if (!_editable || _navigating) return;
    _navigating = true;
    try {
      if (autoSave && !await flush()) return;
      if (!mounted) return;
      if (state.page == 0) {
        final errors = <String, String>{};
        final problem = profileNameProblem(state.draft.profile.name);
        if (problem != null) errors['name'] = problem;
        if (state.draft.profile.currency == null) {
          errors['currency'] = 'Choose your accounting currency.';
        }
        _show(page: errors.isEmpty ? 1 : 0, errors: errors);
        return;
      }
      if (state.page == 1) {
        try {
          final review = OnboardingFinance.review(state.draft);
          _show(draft: review.normalized, page: 2, review: review);
        } on OnboardingFinanceException catch (e) {
          // Reveal the first invalid source before the view focuses its field.
          final source = state.draft.sources
              .where((source) => e.fields.keys
                  .any((key) => key.startsWith('source:${source.sourceGuid}:')))
              .firstOrNull;
          _show(errors: e.fields, expanded: source?.sourceGuid);
        }
      }
    } finally {
      _navigating = false;
      if (autoSave && mounted) await flush();
    }
  }

  Future<void> save(
      {bool Function()? isAuthorized, String timezone = 'UTC'}) async {
    if (!_editable || state.page != 2) return;
    if (autoSave && !await flush()) return;
    if (!mounted || !_editable) return;
    if (!canSave) {
      throw StateError(
          'Financial setup repositories must be configured before saving.');
    }
    _show(review: state.review, saving: true);
    try {
      var review = OnboardingFinance.review(state.draft);
      if (autoSave && _persisted?.committed != null) {
        final saved = await repository!.amendCore(review.normalized,
            expectedRevision: _persisted!.revision,
            reviewedDigest: review.digest,
            isAuthorized: isAuthorized,
            timezone: timezone);
        _persisted = saved;
        if (mounted) {
          _show(draft: financialDraftOf(saved), receipt: saved.committed);
        }
        _status('Saved on this device');
        return;
      }
      if (_persisted == null) {
        await settings!.saveOnboardingState(review.normalized,
            expectedFlowId: null, expectedRevision: null);
        _persisted = review.normalized;
      } else if (OnboardingFinance.review(_persisted!).digest !=
          review.digest) {
        final next = replaceOnboardingDraft(review.normalized,
            revision: _persisted!.revision + 1, updatedAt: DateTime.now());
        review = OnboardingFinance.review(next);
        await settings!.saveOnboardingState(review.normalized,
            expectedFlowId: _persisted!.flowId,
            expectedRevision: _persisted!.revision);
        _persisted = review.normalized;
      }
      final result = await repository!.commitCore(review.normalized,
          reviewedDigest: review.digest,
          expectedRevision: review.normalized.revision,
          isAuthorized: isAuthorized,
          timezone: timezone);
      if (autoSave) {
        _persisted = (await repository!.readStartupState()).state;
      }
      if (mounted) {
        _show(draft: review.normalized, review: review, receipt: result);
        _status('Saved on this device');
      }
    } on OnboardingFinanceException catch (e) {
      if (mounted) _show(page: 1, errors: e.fields);
    } on OnboardingCommitException catch (e) {
      if (mounted) _show(review: state.review, error: e.message);
    } on StaleOnboardingRevisionException {
      if (mounted) {
        _show(
            review: state.review,
            error: 'Setup changed. Reload and review it before saving.');
      }
    } catch (_) {
      if (mounted) {
        _show(
            review: state.review,
            error:
                'We could not confirm the save. Your entries are still here. Try again safely.');
      }
    }
  }
}

final financialSetupProvider =
    StateNotifierProvider<FinancialSetupController, FinancialSetupView>((ref) =>
        FinancialSetupController(
            initial: FinancialSetupController._newDraft(
                flowId: ref.read(setupFlowProvider)),
            autoSave: true,
            repository: OnboardingRepository(IsarHelper.instance))
          ..restore());

typedef OnboardingStartingPositionArgs = ({
  int profileId,
  String month,
  OnboardingOpeningDraft opening,
  CurrencyCode currency,
});

final onboardingStartingPositionProvider = FutureProvider.autoDispose
    .family<OnboardingStartingPosition, OnboardingStartingPositionArgs>(
        (ref, args) => OnboardingStartingPosition.load(
              IsarHelper.instance,
              profileId: args.profileId,
              month: args.month,
              opening: args.opening,
              currency: args.currency,
            ));
