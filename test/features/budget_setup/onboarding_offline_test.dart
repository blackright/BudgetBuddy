import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:budget_buddy/core/models/income_source.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/features/budget_setup/domain/onboarding_state.dart';
import 'package:budget_buddy/features/budget_setup/domain/onboarding_startup.dart';
import 'package:budget_buddy/features/budget_setup/domain/onboarding_finance.dart';
import 'package:budget_buddy/features/budget_setup/repositories/onboarding_repository.dart';
import '../medical/repositories/medical_test_harness.dart';
import 'support/financial_drafts.dart';

void main() {
  for (final noIncome in [false, true]) {
    test(
        'network denied: source=$noIncome saves, restarts and finishes without duplicates',
        () async {
      final h = await MedicalTestHarness.create();
      var db = h.isar;
      var networkAttempts = 0;
      try {
        await HttpOverrides.runZoned(() async {
          var repo = OnboardingRepository(db);
          final draft = await repo.saveDraft(
              financialDraft(
                  incomeChoice: noIncome
                      ? OnboardingIncomeChoice.none
                      : OnboardingIncomeChoice.sources),
              expectedRevision: null);
          final review = OnboardingFinance.review(draft);
          await db.close();
          db = await Isar.open(MedicalTestHarness.schemas,
              directory: h.directory.path, name: h.isar.name);
          repo = OnboardingRepository(db);
          expect((await repo.readStartupState()).state!.incomeChoice,
              draft.incomeChoice);
          final receipt = await repo.commitCore(draft,
              reviewedDigest: review.digest, expectedRevision: 0);
          await repo.prepareCommittedSetup(draft.flowId);
          final chosen = await repo.recordSecurityChoice(
              draft.flowId,
              receipt.profileId,
              OnboardingSecurityChoice.notNow,
              (_) async => false);
          await repo.finishSetup(draft.flowId,
              expectedRevision: chosen.revision,
              verifierIsSet: (_) async => false,
              isAuthorized: () => true);
          await db.close();
          db = await Isar.open(MedicalTestHarness.schemas,
              directory: h.directory.path, name: h.isar.name);
          repo = OnboardingRepository(db);
          final restored = await repo.readStartupState();
          expect(restored.kind, StartupKind.establishedUser);
          expect(restored.state!.stage, OnboardingStage.completed);
          expect(restored.state!.committed!.profileId, receipt.profileId);
          expect(restored.state!.committed!.yearMonth, draft.yearMonth);
          expect(await db.userProfiles.count(), 1);
          expect(await db.monthlyBudgets.count(), 1);
          final sources = await db.incomeSources.where().findAll();
          expect(sources.length, noIncome ? 0 : 1);
          if (!noIncome) expect(sources.single.amount, 500000);
          expect(
              (await db.monthlyBudgets.get(receipt.budgetId))!
                  .baseAvailableAmount,
              100000);
          expect(networkAttempts, 0);
        }, createHttpClient: (_) {
          networkAttempts++;
          throw StateError('Network forbidden in offline test');
        });
      } finally {
        await db.close(deleteFromDisk: true);
        final target = h.directory.resolveSymbolicLinksSync();
        final prefix =
            '${Directory.systemTemp.resolveSymbolicLinksSync()}${Platform.pathSeparator}budget_buddy_medical_';
        expect(target.toLowerCase().startsWith(prefix.toLowerCase()), isTrue);
        h.directory.deleteSync(recursive: true);
      }
    });
  }
}
