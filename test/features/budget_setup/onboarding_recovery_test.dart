import 'dart:io';
import 'dart:convert';
import 'package:budget_buddy/features/settings/providers/app_settings_providers.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/audit_event.dart';
import 'package:isar/isar.dart';
import 'package:budget_buddy/core/models/app_settings.dart';
import 'package:budget_buddy/core/models/medical_service_type.dart';
import 'package:budget_buddy/features/budget_setup/domain/onboarding_progress.dart';
import 'package:budget_buddy/features/finance/repositories/income_source_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_buddy/core/models/income_source.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/features/budget_setup/domain/onboarding_state.dart';
import 'package:budget_buddy/features/budget_setup/domain/onboarding_finance.dart';
import 'package:budget_buddy/features/budget_setup/domain/onboarding_startup.dart';
import 'package:budget_buddy/features/budget_setup/repositories/onboarding_repository.dart';
import '../medical/repositories/medical_test_harness.dart';
import 'support/financial_drafts.dart';

class _RejectAmendmentCheckpoint extends AppSettingsRepository {
  _RejectAmendmentCheckpoint(super.isar);
  @override
  Future<void> saveReviewedAmendmentInTxn(OnboardingState next,
          {required String expectedFlowId,
          required int expectedRevision}) async =>
      throw StateError('injected amendment checkpoint failure');
}

void main() {
  test('draft and committed state recover through new repository instances',
      () async {
    final h = await MedicalTestHarness.create();
    addTearDown(h.close);
    var repo = OnboardingRepository(h.isar);
    final draft =
        await repo.saveDraft(financialDraft(), expectedRevision: null);
    repo = OnboardingRepository(h.isar);
    expect((await repo.readStartupState()).state!.sources.single.amountText,
        '500,000');
    final review = OnboardingFinance.review(draft);
    final ref = await repo.commitCore(draft,
        reviewedDigest: review.digest, expectedRevision: draft.revision);
    final state =
        (await OnboardingRepository(h.isar).readStartupState()).state!;
    expect(state.committed!.profileId, ref.profileId);
    final prepared = await repo.prepareCommittedSetup(state.flowId);
    expect(prepared.directoryReady, isTrue);
    expect(prepared.completedAt, isNull);
    await repo.prepareCommittedSetup(state.flowId);
    expect(await h.isar.userProfiles.count(), 1);
    expect(await h.isar.monthlyBudgets.count(), 1);
    expect(await h.isar.incomeSources.count(), 1);
    await h.isar.writeTxn(() => h.isar.monthlyBudgets.delete(ref.budgetId));
    expect((await repo.readStartupState()).kind, StartupKind.needsReview);
    expect(await h.isar.monthlyBudgets.count(), 0);
  });
  test('native close/reopen preserves draft, committed IDs and retry evidence',
      () async {
    final h = await MedicalTestHarness.create();
    final path = h.directory.path, name = h.isar.name;
    final draft = await OnboardingRepository(h.isar)
        .saveDraft(financialDraft(month: '2025-02'), expectedRevision: null);
    await h.isar.close();
    var db = await Isar.open(MedicalTestHarness.schemas,
        directory: path, name: name);
    try {
      var repo = OnboardingRepository(db);
      expect((await repo.readStartupState()).state!.yearMonth, '2025-02');
      final review = OnboardingFinance.review(draft);
      final ref = await repo.commitCore(draft,
          reviewedDigest: review.digest, expectedRevision: 0);
      await db.close();
      db = await Isar.open(MedicalTestHarness.schemas,
          directory: path, name: name);
      repo = OnboardingRepository(db);
      expect((await repo.readStartupState()).state!.committed!.sourceIds,
          ref.sourceIds);
      final retry = await repo.commitCore(draft,
          reviewedDigest: review.digest, expectedRevision: 0);
      expect(retry.budgetId, ref.budgetId);
      expect(await db.incomeSources.count(), 1);
    } finally {
      await db.close(deleteFromDisk: true);
      if (h.directory.existsSync()) {
        final target = h.directory.resolveSymbolicLinksSync();
        final prefix =
            '${Directory.systemTemp.resolveSymbolicLinksSync()}${Platform.pathSeparator}budget_buddy_medical_';
        expect(target.toLowerCase().startsWith(prefix.toLowerCase()), isTrue);
        Directory(target).deleteSync(recursive: true);
      }
    }
  });
  test(
      'failed and concurrent preparation retries never duplicate finance or directory',
      () async {
    final h = await MedicalTestHarness.create();
    addTearDown(h.close);
    final plain = OnboardingRepository(h.isar);
    final d = await plain.saveDraft(financialDraft(), expectedRevision: null);
    await plain.commitCore(d,
        reviewedDigest: OnboardingFinance.review(d).digest,
        expectedRevision: 0);
    final broken = OnboardingRepository(h.isar,
        prepareDirectory: (_) =>
            throw StateError('injected directory failure'));
    await expectLater(broken.prepareCommittedSetup(d.flowId), throwsStateError);
    expect((await plain.readStartupState()).state!.stage,
        OnboardingStage.preparing);
    await Future.wait([
      plain.prepareCommittedSetup(d.flowId),
      plain.prepareCommittedSetup(d.flowId)
    ]);
    final state = (await plain.readStartupState()).state!;
    expect(state.directoryReady, isTrue);
    expect(state.completedAt, isNull);
    final count = await h.isar.medicalServiceTypes.count();
    await plain.prepareCommittedSetup(d.flowId);
    expect(await h.isar.medicalServiceTypes.count(), count);
    expect(count, 6);
    expect(await h.isar.userProfiles.count(), 1);
    expect(await h.isar.incomeSources.count(), 1);
  });
  test(
      'reviewed corrections retain owner, month identity and existing source IDs',
      () async {
    final h = await MedicalTestHarness.create();
    addTearDown(h.close);
    final repo = OnboardingRepository(h.isar);
    final d = await repo.saveDraft(financialDraft(), expectedRevision: null);
    final ref = await repo.commitCore(d,
        reviewedDigest: OnboardingFinance.review(d).digest,
        expectedRevision: 0);
    var state = (await repo.readStartupState()).state!;
    final edit = replaceOnboardingDraft(financialDraftOf(state),
        yearMonth: '2026-11',
        opening: const OnboardingOpeningDraft(
            choice: OnboardingOpeningChoice.known,
            amountText: '200,000',
            currency: CurrencyCode.huf));
    final pending =
        await repo.saveDraft(edit, expectedRevision: state.revision);
    expect(pending.amendmentDraftJson, isNotNull);
    // The real financial month is untouched while its correction is a draft.
    expect(
        (await h.isar.monthlyBudgets.get(ref.budgetId))!.yearMonth, '2026-10');
    final proposal = replaceOnboardingDraft(edit, revision: pending.revision);
    final review = OnboardingFinance.review(proposal);
    state = await repo.amendCore(proposal,
        expectedRevision: pending.revision, reviewedDigest: review.digest);
    expect(state.committed!.budgetId, ref.budgetId);
    expect(state.committed!.profileId, ref.profileId);
    expect(state.committed!.sourceIds, ref.sourceIds);
    expect(state.amendmentDraftJson, isNull);
    expect((await h.isar.monthlyBudgets.get(ref.budgetId))!.baseAvailableAmount,
        200000);
    final audits = await h.isar.auditEvents.count();
    await repo.amendCore(proposal,
        expectedRevision: pending.revision, reviewedDigest: review.digest);
    expect(await h.isar.auditEvents.count(), audits);
    await expectLater(
        repo.amendCore(replaceOnboardingDraft(proposal, yearMonth: '2026-12'),
            expectedRevision: pending.revision, reviewedDigest: review.digest),
        throwsA(isA<OnboardingCommitException>()));
    expect((await repo.readStartupState()).kind, StartupKind.resumeSetup);
  });
  test('changed sources require review and cannot be silently recreated',
      () async {
    final h = await MedicalTestHarness.create();
    addTearDown(h.close);
    final repo = OnboardingRepository(h.isar);
    final d = await repo.saveDraft(financialDraft(), expectedRevision: null);
    final ref = await repo.commitCore(d,
        reviewedDigest: OnboardingFinance.review(d).digest,
        expectedRevision: 0);
    final source =
        (await h.isar.incomeSources.get(ref.sourceIds.values.single))!;
    source.amount = 900000;
    await IncomeSourceRepository(h.isar, actorId: ref.profileId).save(source);
    expect((await repo.readStartupState()).kind, StartupKind.needsReview);
    expect((await repo.readStartupState()).existingProfileIds,
        isNot(contains(ref.profileId)));
    expect((await h.isar.incomeSources.get(source.id))!.amount, 900000);
  });
  for (final raw in [
    '{broken',
    '{"version":99}',
    'x' * (OnboardingState.maxEncodedBytes + 1)
  ]) {
    test(
        'malformed/future/oversized progress is retained and classified for review (${raw.length})',
        () async {
      final h = await MedicalTestHarness.create();
      addTearDown(h.close);
      final repo = OnboardingRepository(h.isar);
      await repo.settings.getOrCreate();
      await h.isar.writeTxn(() async {
        final settings = (await h.isar.appSettings.get(1))!;
        settings.onboardingStateJson = raw;
        await h.isar.appSettings.put(settings);
      });
      expect((await repo.readStartupState()).kind, StartupKind.needsReview);
      expect((await h.isar.appSettings.get(1))!.onboardingStateJson, raw);
      expect(await h.isar.userProfiles.count(), 0);
    });
  }

  test(
      'adding/removing income is audited once; checkpoint failure rolls back every financial edit',
      () async {
    final h = await MedicalTestHarness.create();
    addTearDown(h.close);
    final repo = OnboardingRepository(h.isar);
    final d = await repo.saveDraft(financialDraft(), expectedRevision: null);
    final first = await repo.commitCore(d,
        reviewedDigest: OnboardingFinance.review(d).digest,
        expectedRevision: 0);
    var state = (await repo.readStartupState()).state!;
    final edit = replaceOnboardingDraft(financialDraftOf(state), sources: [
      const OnboardingSourceDraft(
          sourceGuid: 'new-income',
          name: 'New work',
          amountText: '250,000',
          currency: CurrencyCode.huf)
    ]);
    final review = OnboardingFinance.review(edit);
    final before = (await h.isar.appSettings.get(1))!.onboardingStateJson;
    final audits = await h.isar.auditEvents.count();
    final broken = OnboardingRepository(h.isar,
        settings: _RejectAmendmentCheckpoint(h.isar));
    await expectLater(
        broken.amendCore(edit,
            expectedRevision: state.revision, reviewedDigest: review.digest),
        throwsStateError);
    expect((await h.isar.appSettings.get(1))!.onboardingStateJson, before);
    expect(await h.isar.auditEvents.count(), audits);
    expect(
        (await h.isar.incomeSources.get(first.sourceIds.values.single))!.amount,
        500000);
    state = await repo.amendCore(edit,
        expectedRevision: state.revision, reviewedDigest: review.digest);
    expect(await h.isar.incomeSources.count(), 1);
    expect(state.committed!.sourceIds.keys, {'new-income'});
    expect(
        await h.isar.incomeSources.get(first.sourceIds.values.single), isNull);
    final events = await h.isar.auditEvents.where().findAll();
    expect(events.where((e) => e.action == 'income.delete'), hasLength(1));
  });
  for (final unsafe in ['occupied month', 'expense']) {
    test('unsafe corrections are refused: $unsafe', () async {
      final h = await MedicalTestHarness.create();
      addTearDown(h.close);
      final repo = OnboardingRepository(h.isar);
      final d = await repo.saveDraft(financialDraft(), expectedRevision: null);
      final first = await repo.commitCore(d,
          reviewedDigest: OnboardingFinance.review(d).digest,
          expectedRevision: 0);
      final state = (await repo.readStartupState()).state!;
      await h.isar.writeTxn(() async {
        if (unsafe == 'occupied month') {
          await h.isar.monthlyBudgets.put(MonthlyBudget()
            ..profileId = first.profileId
            ..yearMonth = '2026-11'
            ..baseAvailableAmount = 55
            ..createdAt = DateTime(2026)
            ..updatedAt = DateTime(2026));
        } else {
          await h.isar.expenses.put(Expense(
              profileId: first.profileId,
              yearMonth: '2026-10',
              title: 'Existing spending',
              categoryId: Expense.defaultCategoryId,
              budgetId: first.budgetId,
              amount: 50,
              currency: 'huf',
              date: DateTime(2026, 10, 1)));
        }
      });
      final edit =
          replaceOnboardingDraft(financialDraftOf(state), yearMonth: '2026-11');
      await expectLater(
          repo.amendCore(edit,
              expectedRevision: state.revision,
              reviewedDigest: OnboardingFinance.review(edit).digest),
          throwsA(isA<OnboardingCommitException>()));
      expect((await h.isar.monthlyBudgets.get(first.budgetId))!.yearMonth,
          '2026-10');
    });
  }
  test(
      'readiness recognizes an explicit security choice without completing setup or invoking authentication',
      () async {
    final h = await MedicalTestHarness.create();
    addTearDown(h.close);
    final repo = OnboardingRepository(h.isar);
    final d = await repo.saveDraft(financialDraft(), expectedRevision: null);
    await repo.commitCore(d,
        reviewedDigest: OnboardingFinance.review(d).digest,
        expectedRevision: 0);
    final prepared = await repo.prepareCommittedSetup(d.flowId);
    final data = jsonDecode(prepared.encode()) as Map<String, dynamic>;
    data['securityChoice'] = 'notNow';
    data['revision'] = prepared.revision + 1;
    final chosen = OnboardingState.decode(jsonEncode(data));
    await repo.settings.saveOnboardingState(chosen,
        expectedFlowId: prepared.flowId, expectedRevision: prepared.revision);
    final ready = await repo.prepareCommittedSetup(d.flowId);
    expect(ready.stage, OnboardingStage.readyToFinish);
    expect(ready.completedAt, isNull);
    expect((await repo.readStartupState()).kind, StartupKind.resumeSetup);
  });
  test(
      'preparation, readiness and unfinished corrections survive native close/reopen',
      () async {
    final h = await MedicalTestHarness.create();
    var db = h.isar;
    final path = h.directory.path, name = db.name;
    Future<void> reopen() async {
      await db.close();
      db = await Isar.open(MedicalTestHarness.schemas,
          directory: path, name: name);
    }

    try {
      var repo = OnboardingRepository(db);
      final draft =
          await repo.saveDraft(financialDraft(), expectedRevision: null);
      final receipt = await repo.commitCore(draft,
          reviewedDigest: OnboardingFinance.review(draft).digest,
          expectedRevision: 0);
      var saved = await repo.prepareCommittedSetup(draft.flowId);
      await reopen();
      repo = OnboardingRepository(db);
      expect((await repo.readStartupState()).state!.directoryReady, isTrue);
      final data = jsonDecode(saved.encode()) as Map<String, dynamic>;
      data['securityChoice'] = 'notNow';
      data['revision'] = saved.revision + 1;
      await repo.settings.saveOnboardingState(
          OnboardingState.decode(jsonEncode(data)),
          expectedFlowId: saved.flowId,
          expectedRevision: saved.revision);
      saved = await repo.prepareCommittedSetup(draft.flowId);
      await reopen();
      repo = OnboardingRepository(db);
      expect((await repo.readStartupState()).state!.stage,
          OnboardingStage.readyToFinish);
      final edit = replaceOnboardingDraft(financialDraftOf(saved), sources: [
        const OnboardingSourceDraft(
            sourceGuid: 'salary-1',
            name: 'Salary',
            amountText: '700,000',
            currency: CurrencyCode.huf)
      ]);
      await repo.saveDraft(edit, expectedRevision: saved.revision);
      await reopen();
      repo = OnboardingRepository(db);
      saved = (await repo.readStartupState()).state!;
      expect(saved.stage, OnboardingStage.coreCommitted);
      expect(
          OnboardingState.decode(saved.amendmentDraftJson!)
              .sources
              .single
              .amountText,
          '700,000');
      expect(
          (await db.incomeSources.get(receipt.sourceIds.values.single))!.amount,
          500000);
      expect(saved.completedAt, isNull);
    } finally {
      await db.close(deleteFromDisk: true);
      if (h.directory.existsSync()) {
        final target = h.directory.resolveSymbolicLinksSync();
        final prefix =
            '${Directory.systemTemp.resolveSymbolicLinksSync()}${Platform.pathSeparator}budget_buddy_medical_';
        expect(target.toLowerCase().startsWith(prefix.toLowerCase()), isTrue);
        Directory(target).deleteSync(recursive: true);
      }
    }
  });
}
