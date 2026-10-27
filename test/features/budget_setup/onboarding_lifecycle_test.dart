import 'package:budget_buddy/features/security/repositories/lock_setting_janitor.dart';
import 'package:budget_buddy/features/security/repositories/lock_setting_repository.dart';
import 'package:budget_buddy/core/database/money_integrity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:budget_buddy/core/models/app_settings.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/database/schema_migrations.dart';
import 'package:budget_buddy/features/settings/presentation/profile_switcher_section.dart';
import 'package:budget_buddy/features/budget_setup/domain/onboarding_state.dart';
import 'package:budget_buddy/features/budget_setup/domain/onboarding_finance.dart';
import 'package:budget_buddy/features/budget_setup/repositories/onboarding_repository.dart';
import '../medical/repositories/medical_test_harness.dart';
import 'support/financial_drafts.dart';

class _FailingJanitor extends LockSettingJanitor {
  _FailingJanitor(super.repository);
  @override
  Future<void> deleteRowInTxn(String key) async =>
      throw StateError('simulated late deletion failure');
}

void main() {
  test(
      'late deletion failure rolls back reference cleanup with profile removal',
      () async {
    final h = await MedicalTestHarness.create();
    addTearDown(h.close);
    final repo = OnboardingRepository(h.isar);
    final d = await repo.saveDraft(financialDraft(), expectedRevision: null);
    final review = OnboardingFinance.review(d);
    final receipt = await repo.commitCore(d,
        reviewedDigest: review.digest, expectedRevision: d.revision);
    await h.isar.writeTxn(() => h.isar.userProfiles.put(UserProfile()
      ..name = 'Keep'
      ..primaryCurrency = PrimaryCurrency.huf
      ..monthlyAvailableAmount = 0
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026)));
    final before = (await h.isar.appSettings.get(1))!.onboardingStateJson;
    await expectLater(
        ProfileSwitcherController(h.isar,
                lockJanitor: _FailingJanitor(LockSettingRepository(h.isar)))
            .deleteProfile(receipt.profileId, activeProfileId: null),
        throwsStateError);
    expect(await h.isar.userProfiles.get(receipt.profileId), isNotNull);
    expect((await h.isar.appSettings.get(1))!.onboardingStateJson, before);
    expect(
        await h.isar.schemaMigrationStamps
            .filter()
            .keyEqualTo('onboarding_pending_owner:${receipt.profileId}')
            .count(),
        1);
  });

  for (final kind in ['pending', 'completed', 'malformed', 'other-owner']) {
    test(
        'confirmed deletion handles $kind progress without touching unrelated settings',
        () async {
      final h = await MedicalTestHarness.create();
      addTearDown(h.close);
      final repo = OnboardingRepository(h.isar);
      final draft =
          await repo.saveDraft(financialDraft(), expectedRevision: null);
      final review = OnboardingFinance.review(draft);
      final receipt = await repo.commitCore(draft,
          reviewedDigest: review.digest, expectedRevision: draft.revision);
      if (kind == 'completed') {
        await repo.prepareCommittedSetup(draft.flowId);
        final ready = await repo.recordSecurityChoice(
            draft.flowId,
            receipt.profileId,
            OnboardingSecurityChoice.notNow,
            (_) async => false);
        await repo.finishSetup(draft.flowId,
            expectedRevision: ready.revision,
            verifierIsSet: (_) async => false,
            isAuthorized: () => true);
      }
      final keep = UserProfile()
        ..name = 'Other owner'
        ..primaryCurrency = PrimaryCurrency.huf
        ..monthlyAvailableAmount = 0
        ..createdAt = DateTime(2026)
        ..updatedAt = DateTime(2026);
      late String original;
      await h.isar.writeTxn(() async {
        await h.isar.userProfiles.put(keep);
        final settings = (await h.isar.appSettings.get(1))!;
        settings.transferToggle = true;
        settings.decimalPreferences = 'retained-preference';
        settings.starterCategoryPolicy =
            StarterCategoryPolicy.preserveExisting.name;
        if (kind == 'malformed') {
          settings.onboardingStateJson = '{unreadable progress';
        }
        original = settings.onboardingStateJson!;
        await h.isar.appSettings.put(settings);
        await h.isar.schemaMigrationStamps.put(SchemaMigrationStamp()
          ..key = 'onboarding_pending_owner:${receipt.profileId}'
          ..value = draft.flowId);
        await h.isar.schemaMigrationStamps.put(SchemaMigrationStamp()
          ..key = 'onboarding_pending_owner:999'
          ..value = 'unrelated-flow');
      });
      final deleted = kind == 'other-owner' ? keep.id : receipt.profileId;
      await ProfileSwitcherController(h.isar).deleteProfile(deleted,
          activeProfileId: kind == 'other-owner' ? receipt.profileId : keep.id);
      final saved = (await h.isar.appSettings.get(1))!;
      expect(saved.onboardingStateJson,
          (kind == 'pending' || kind == 'completed') ? isNull : original);
      expect(saved.transferToggle, isTrue);
      expect(saved.decimalPreferences, 'retained-preference');
      expect(saved.starterCategoryPolicy,
          StarterCategoryPolicy.preserveExisting.name);
      expect(
          await h.isar.schemaMigrationStamps
              .filter()
              .keyEqualTo('onboarding_pending_owner:$deleted')
              .count(),
          0);
      expect(
          await h.isar.schemaMigrationStamps
              .filter()
              .keyEqualTo('onboarding_pending_owner:999')
              .count(),
          1);
    });
  }
  test(
      'existing explicit database reset clears local progress without adding a replay reset',
      () async {
    final h = await MedicalTestHarness.create();
    addTearDown(h.close);
    await OnboardingRepository(h.isar)
        .saveDraft(financialDraft(), expectedRevision: null);
    await resetLocalDatabase(h.isar);
    expect((await h.isar.appSettings.get(1))?.onboardingStateJson, isNull);
    expect(await h.isar.userProfiles.count(), 0);
  });
}
