import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/features/finance/repositories/month_finance_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:budget_buddy/core/database/isar_helper.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/models/app_settings.dart';
import 'package:budget_buddy/core/models/category.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/routing/app_router.dart';
import 'package:budget_buddy/features/expenses/repositories/category_repository.dart';
import 'package:budget_buddy/features/budget_setup/repositories/onboarding_repository.dart';
import 'package:budget_buddy/features/budget_setup/domain/onboarding_startup.dart';
import '../medical/repositories/medical_test_harness.dart';

void main() {
  test(
      'existing profile without a month goes to normal Dashboard, never a second-profile setup',
      () async {
    final h = await MedicalTestHarness.create();
    addTearDown(h.close);
    IsarHelper.instance = h.isar;
    await h.isar.writeTxn(() => h.isar.userProfiles.put(UserProfile()
      ..name = 'Jason'
      ..primaryCurrency = PrimaryCurrency.huf
      ..monthlyAvailableAmount = 0
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026)));
    final router = createAppRouter();
    addTearDown(router.dispose);
    expect(router.routeInformationProvider.value.uri.path, '/dashboard');
    expect((await OnboardingRepository(h.isar).readStartupState()).kind,
        StartupKind.establishedUser);
    expect(await h.isar.userProfiles.count(), 1);
    final profile = (await h.isar.userProfiles.where().findFirst())!;
    final context =
        ContextRef.personal(profileId: profile.id, yearMonth: '2026-10');
    await MonthFinanceRepository(h.isar).ensureMonthInContext(context);
    await MonthFinanceRepository(h.isar).ensureMonthInContext(context);
    expect(await h.isar.monthlyBudgets.count(), 1);
    expect(await h.isar.userProfiles.count(), 1);
    expect((await h.isar.monthlyBudgets.where().findFirst())!.profileId,
        profile.id);
  });
  test('unrelated shared budget does not prove a personal profile exists',
      () async {
    final h = await MedicalTestHarness.create();
    addTearDown(h.close);
    IsarHelper.instance = h.isar;
    await h.isar.writeTxn(() => h.isar.monthlyBudgets.put(MonthlyBudget()
      ..sharedSpaceId = 77
      ..yearMonth = '2026-10'
      ..baseAvailableAmount = 0
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026)));
    final router = createAppRouter();
    addTearDown(router.dispose);
    expect(router.routeInformationProvider.value.uri.path, '/setup');
  });
  for (final populated in [false, true]) {
    test(
        'preserved upgrade categories populated=$populated retain legacy behavior only',
        () async {
      final h = await MedicalTestHarness.create();
      addTearDown(h.close);
      await h.isar.writeTxn(() async {
        await h.isar.appSettings.put(AppSettings()
          ..id = 1
          ..starterCategoryPolicy = StarterCategoryPolicy.preserveExisting.name
          ..createdAt = DateTime(2026)
          ..updatedAt = DateTime(2026));
        if (populated) {
          await h.isar.categorys.put(Category(
              categoryId: 'food',
              name: 'My custom food',
              emoji: 'F',
              colorValue: 1,
              isDefault: true));
        }
      });
      final rows = await CategoryRepository(h.isar).getForUnifiedSetup();
      expect(rows.length, 7);
      expect(
          rows.any((c) => [
                'housing',
                'insurance',
                'subscriptions',
                'miscellaneous'
              ].contains(c.categoryId)),
          isFalse);
      if (populated) {
        expect(rows.singleWhere((c) => c.categoryId == 'food').name,
            'My custom food');
      }
    });
  }
}
