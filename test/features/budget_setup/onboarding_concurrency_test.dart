import 'dart:async';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/features/budget_setup/providers/budget_setup_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_buddy/features/budget_setup/domain/onboarding_finance.dart';
import 'package:budget_buddy/features/budget_setup/repositories/onboarding_repository.dart';
import 'package:budget_buddy/features/settings/providers/app_settings_providers.dart';
import '../medical/repositories/medical_test_harness.dart';
import 'support/financial_drafts.dart';

void main() {
  test('concurrent draft revisions have one winner and preserve settings',
      () async {
    final h = await MedicalTestHarness.create();
    addTearDown(h.close);
    final repo = OnboardingRepository(h.isar);
    final saved =
        await repo.saveDraft(financialDraft(), expectedRevision: null);
    var successes = 0, failures = 0;
    Future<void> write(String name) async {
      try {
        await repo.saveDraft(replaceOnboardingDraft(saved, yearMonth: name),
            expectedRevision: saved.revision);
        successes++;
      } on StaleOnboardingRevisionException {
        failures++;
      }
    }

    await Future.wait([
      write('2026-11'),
      write('2026-12'),
      AppSettingsRepository(h.isar).setTransferToggle(true)
    ]);
    expect(successes, 1);
    expect(failures, 1);
    expect((await AppSettingsRepository(h.isar).getOrCreate()).transferToggle,
        isTrue);
  });
  test(
      'automatic saves coalesce edits, flush navigation and restore the last saved values',
      () async {
    final h = await MedicalTestHarness.create();
    addTearDown(h.close);
    final repo = OnboardingRepository(h.isar);
    var c = FinancialSetupController(
        initial: financialDraft(), repository: repo, autoSave: true);
    c.setProfileName('Ja');
    c.setProfileName('Jason Updated');
    c.updateSource('salary-1', amountText: '600,000');
    expect(await c.flush(), isTrue);
    expect(c.state.saveStatus, 'Saved on this device');
    await c.next();
    expect(c.state.page, 1);
    c.dispose();
    c = FinancialSetupController(repository: repo, autoSave: true);
    addTearDown(c.dispose);
    await c.restore();
    expect(c.state.page, 1);
    expect(c.state.draft.profile.name, 'Jason Updated');
    expect(c.state.draft.sources.single.amountText, '600,000');
    await c.next();
    await c.save();
    expect(c.state.receipt, isNotNull);
    c.beginCorrection();
    c.updateSource('salary-1', amountText: '700,000');
    expect(await c.flush(), isTrue);
    final restored = FinancialSetupController(repository: repo, autoSave: true);
    addTearDown(restored.dispose);
    await restored.restore();
    expect(restored.state.receipt, isNull);
    expect(restored.state.draft.sources.single.amountText, '700,000');
    expect(restored.currencyFixed, isTrue);
    expect(
        restored.changeCurrency(CurrencyCode.eur,
            discardAmountsConfirmed: true),
        isFalse);
  });
  test(
      'stale automatic save keeps visible edits and refuses to overwrite newer progress',
      () async {
    final h = await MedicalTestHarness.create();
    addTearDown(h.close);
    final repo = OnboardingRepository(h.isar);
    final d = await repo.saveDraft(financialDraft(), expectedRevision: null);
    final c = FinancialSetupController(repository: repo, autoSave: true);
    addTearDown(c.dispose);
    await c.restore();
    await repo.saveDraft(replaceOnboardingDraft(d, yearMonth: '2027-02'),
        expectedRevision: d.revision);
    c.setProfileName('Unsaved correction');
    expect(await c.flush(), isFalse);
    expect(c.state.draft.profile.name, 'Unsaved correction');
    expect(c.state.saveStatus, startsWith('Could not save'));
    expect((await repo.readStartupState()).state!.yearMonth, '2027-02');
  });
  test(
      'incomplete date edits are saved as drafts but cannot become financial records',
      () async {
    final h = await MedicalTestHarness.create();
    addTearDown(h.close);
    final repo = OnboardingRepository(h.isar);
    final c = FinancialSetupController(
        initial: financialDraft(), repository: repo, autoSave: true);
    addTearDown(c.dispose);
    c.updateSource('salary-1',
        startDate: DateTime(2026, 10, 20), endDate: DateTime(2026, 10, 1));
    expect(await c.flush(), isTrue);
    final restored = (await repo.readStartupState()).state!;
    expect(restored.sources.single.endDate, DateTime(2026, 10, 1));
    await c.next();
    await c.next();
    expect(c.state.page, 1);
    expect(c.state.errors, contains('source:salary-1:dates'));
    expect(restored.committed, isNull);
  });

  test(
      'debounce automatically persists the latest edit without a navigation tap',
      () async {
    final h = await MedicalTestHarness.create();
    addTearDown(h.close);
    final repo = OnboardingRepository(h.isar);
    final c = FinancialSetupController(
        initial: financialDraft(), repository: repo, autoSave: true);
    addTearDown(c.dispose);
    final saved = Completer<void>();
    final statuses = <String>[];
    final stop = c.addListener((view) {
      statuses.add(view.saveStatus);
      if (view.saveStatus == 'Saved on this device' && !saved.isCompleted) {
        saved.complete();
      }
    }, fireImmediately: false);
    addTearDown(stop);
    c.setProfileName('First edit');
    c.setProfileName('Final name');
    await saved.future.timeout(const Duration(seconds: 5));
    expect(statuses, contains('Saving...'));
    final state = (await repo.readStartupState()).state!;
    expect(state.profile.name, 'Final name');
    expect(state.revision, 0);
  });
}
