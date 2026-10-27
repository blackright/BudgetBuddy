import 'package:isar/isar.dart';
import 'package:budget_buddy/core/database/isar_helper.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/month_rate_seal.dart';
import 'package:budget_buddy/core/models/app_settings.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/features/engine/providers/sweep_provider.dart';
import 'package:budget_buddy/features/engine/seal_coordinator.dart';
import 'package:budget_buddy/features/budget_setup/domain/onboarding_finance.dart';
import 'package:budget_buddy/features/budget_setup/domain/onboarding_automation_guard.dart';
import 'package:budget_buddy/features/budget_setup/repositories/onboarding_repository.dart';
import 'package:budget_buddy/features/vault/models/savings_vault.dart';
import 'package:budget_buddy/features/vault/models/vault_entry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../medical/repositories/medical_test_harness.dart';
import '../engine/rate_test_support.dart';
import 'support/financial_drafts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_buddy/features/budget_setup/domain/onboarding_startup.dart';

void main() {
  test('month pin applies only to the pending personal owner', () {
    expect(
        shouldPreserveSetupMonth(
            pendingProfileId: 4, activeProfileId: 4, isShared: false),
        isTrue);
    expect(
        shouldPreserveSetupMonth(
            pendingProfileId: 4, activeProfileId: 8, isShared: false),
        isFalse);
    expect(
        shouldPreserveSetupMonth(
            pendingProfileId: 4, activeProfileId: 4, isShared: true),
        isFalse);
  });
  test(
      'pending owner has no sweep writes or pending-only seals; established owners still work',
      () async {
    final h = await MedicalTestHarness.create();
    addTearDown(h.close);
    IsarHelper.instance = h.isar;
    final repo = OnboardingRepository(h.isar);
    final d = await repo.saveDraft(financialDraft(month: '2026-09'),
        expectedRevision: null);
    expect(
        await preserveAutomaticSetupMonth(h.isar,
            profileId: null, isShared: false, allowDraft: true),
        isTrue);
    expect(
        await preserveAutomaticSetupMonth(h.isar,
            profileId: null, isShared: false, allowDraft: false),
        isFalse);
    final receipt = await repo.commitCore(d,
        reviewedDigest: OnboardingFinance.review(d).digest,
        expectedRevision: 0);
    final owner = (await h.isar.userProfiles.get(receipt.profileId))!;
    final c = ProviderContainer(overrides: [
      activeProfileProvider.overrideWith((ref) => Stream.value(owner)),
      budgetContextProvider.overrideWithValue(
          ContextRef.personal(profileId: owner.id, yearMonth: '2026-09'))
    ]);
    addTearDown(c.dispose);
    await c.read(activeProfileProvider.future);
    final result = await c.read(sweepServiceProvider).executeSweepCheck();
    expect(result.outcome, SweepOutcome.paused);
    expect(await h.isar.savingsVaults.count(), 0);
    expect(await h.isar.vaultEntrys.count(), 0);
    final client = FakeRateClient(failLatest: true, failHistorical: true);
    final seals = SealCoordinator(isar: h.isar, client: client);
    await seals.runSealPass(DateTime(2026, 10, 27));
    expect(await h.isar.monthRateSeals.count(), 0);
    expect(client.historicalCalls, isEmpty);
    final now = DateTime(2026);
    final other = UserProfile()
      ..name = 'Established'
      ..primaryCurrency = PrimaryCurrency.huf
      ..monthlyAvailableAmount = 0
      ..createdAt = now
      ..updatedAt = now;
    await h.isar.writeTxn(() async {
      other.id = await h.isar.userProfiles.put(other);
      await h.isar.monthlyBudgets.put(MonthlyBudget()
        ..profileId = other.id
        ..yearMonth = '2026-09'
        ..baseAvailableAmount = 0
        ..createdAt = now
        ..updatedAt = now);
    });
    await seals.runSealPass(DateTime(2026, 10, 27));
    expect(await h.isar.monthRateSeals.count(), 1);
    final existing = ProviderContainer(overrides: [
      activeProfileProvider.overrideWith((ref) => Stream.value(other)),
      budgetContextProvider.overrideWithValue(
          ContextRef.personal(profileId: other.id, yearMonth: '2026-09'))
    ]);
    addTearDown(existing.dispose);
    await existing.read(activeProfileProvider.future);
    await existing.read(sweepServiceProvider).executeSweepCheck();
    expect(
        await h.isar.savingsVaults.filter().profileIdEqualTo(other.id).count(),
        1);
    await h.isar.writeTxn(() async {
      final settings = (await h.isar.appSettings.get(1))!;
      settings.onboardingStateJson = '{broken';
      await h.isar.appSettings.put(settings);
    });
    expect(await isPendingSetupOwner(h.isar, owner.id), isTrue);
    expect(await isPendingSetupOwner(h.isar, other.id), isFalse);
    expect(
        await preserveAutomaticSetupMonth(h.isar,
            profileId: owner.id, isShared: false, allowDraft: false),
        isTrue);
    expect(
        await preserveAutomaticSetupMonth(h.isar,
            profileId: other.id, isShared: false, allowDraft: true),
        isFalse);
    expect(
        await preserveAutomaticSetupMonth(h.isar,
            profileId: owner.id, isShared: true, allowDraft: true),
        isFalse);
    expect((await repo.readStartupState()).existingProfileIds, {other.id});
  });
}
