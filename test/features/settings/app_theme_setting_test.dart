import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/features/settings/presentation/theme_setting_section.dart';
import 'package:budget_buddy/features/settings/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../medical/repositories/medical_test_harness.dart';

/// Phase 9-E (T058): the theme choice is a persisted profile setting with
/// exactly three options, defaults to "Follow system", and a selection written
/// through the real database survives a rebuild of the section.
void main() {
  Future<MedicalTestHarness> openHarness(WidgetTester tester) async {
    late MedicalTestHarness harness;
    // Isar must not open beneath the widget-test fake clock; open it in the
    // real-async window instead (the month_convert_to_menu pattern).
    await tester.runAsync(() async {
      harness = await MedicalTestHarness.create();
    });
    return harness;
  }

  Future<UserProfile> seedProfile(
    MedicalTestHarness harness,
    AppThemeMode mode,
  ) async {
    final profile = UserProfile()
      ..name = 'ThemeTest'
      ..primaryCurrency = PrimaryCurrency.huf
      ..monthlyAvailableAmount = 0
      ..themeMode = mode
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);
    await harness.isar.writeTxn(() async {
      await harness.isar.userProfiles.put(profile);
    });
    return profile;
  }

  Widget wrap({required UserProfile? profile, AppThemeController? controller}) {
    return ProviderScope(
      overrides: [
        activeProfileProvider.overrideWith(
          (ref) => Stream<UserProfile?>.value(profile),
        ),
        if (controller != null)
          appThemeControllerProvider.overrideWithValue(controller),
      ],
      child: const MaterialApp(home: Scaffold(body: ThemeSettingSection())),
    );
  }

  group('appThemeModeProvider', () {
    test('defaults to system while no profile exists', () {
      final container = ProviderContainer(
        overrides: [
          activeProfileProvider.overrideWith((ref) => Stream.value(null)),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(appThemeModeProvider), AppThemeMode.system);
    });

    test('reflects the watched profile theme mode', () async {
      final profile = UserProfile()
        ..name = 'A'
        ..primaryCurrency = PrimaryCurrency.huf
        ..monthlyAvailableAmount = 0
        ..themeMode = AppThemeMode.dark
        ..createdAt = DateTime(2026)
        ..updatedAt = DateTime(2026);

      final container = ProviderContainer(
        overrides: [
          activeProfileProvider.overrideWith(
            (ref) => Stream.value(profile),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(activeProfileProvider.future);
      expect(container.read(appThemeModeProvider), AppThemeMode.dark);
    });
  });

  group('AppThemeController (real Isar write)', () {
    test('persists the theme on the active profile', () async {
      final harness = await MedicalTestHarness.create();
      addTearDown(harness.close);

      final profile = await seedProfile(harness, AppThemeMode.system);

      await AppThemeController(harness.isar).setThemeMode(AppThemeMode.dark);

      final after = await harness.isar.userProfiles.get(profile.id);
      expect(after, isNotNull);
      expect(after!.themeMode, AppThemeMode.dark);
    });

    test('leaves a second profile untouched', () async {
      final harness = await MedicalTestHarness.create();
      addTearDown(harness.close);

      final first = await seedProfile(harness, AppThemeMode.light);
      final second = await seedProfile(harness, AppThemeMode.system);

      await AppThemeController(harness.isar).setThemeMode(AppThemeMode.system);

      expect(
        (await harness.isar.userProfiles.get(first.id))!.themeMode,
        AppThemeMode.system,
        reason: 'the active profile is updated',
      );
      expect(
        (await harness.isar.userProfiles.get(second.id))!.themeMode,
        AppThemeMode.system,
        reason: 'a second profile keeps its own theme choice',
      );
    });
  });

  group('ThemeSettingSection', () {
    testWidgets('renders all three options and the cached selection',
        (tester) async {
      final profile = UserProfile()
        ..name = 'A'
        ..primaryCurrency = PrimaryCurrency.huf
        ..monthlyAvailableAmount = 0
        ..themeMode = AppThemeMode.light
        ..createdAt = DateTime(2026)
        ..updatedAt = DateTime(2026);

      await tester.pumpWidget(wrap(profile: profile));
      await tester.pumpAndSettle();

      expect(find.text('App Theme'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);

      await tester.tap(find.byType(DropdownButtonFormField<AppThemeMode>));
      await tester.pumpAndSettle();

      expect(find.text('Light'), findsAtLeastNWidgets(1));
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('Follow system'), findsOneWidget);
    });

    testWidgets('a selection persists to the real database across a rebuild',
        (tester) async {
      final harness = await openHarness(tester);
      late UserProfile profile;
      await tester.runAsync(() async {
        profile = await seedProfile(harness, AppThemeMode.system);
      });
      final controller = AppThemeController(harness.isar);

      await tester.pumpWidget(
        wrap(profile: profile, controller: controller),
      );
      await tester.pumpAndSettle();
      expect(find.text('Follow system'), findsOneWidget);

      await tester.tap(find.byType(DropdownButtonFormField<AppThemeMode>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      // The onChanged fires the write fire-and-forget inside the fake-async
      // zone, so its Isar reply only drains once the real event loop turns.
      AppThemeMode? stored;
      for (var i = 0; i < 60 && stored != AppThemeMode.dark; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 30)),
        );
        await tester.pump();
        await tester.runAsync(() async {
          stored = (await harness.isar.userProfiles.get(profile.id))?.themeMode;
        });
      }
      expect(stored, AppThemeMode.dark,
          reason: 'the real database row was updated');

      final updated = await tester.runAsync(
        () => harness.isar.userProfiles.get(profile.id),
      );

      // A fresh build of the section from the persisted row shows the choice.
      await tester.pumpWidget(
        wrap(profile: updated, controller: controller),
      );
      await tester.pumpAndSettle();
      expect(find.text('Dark'), findsOneWidget);

      await tester.runAsync(harness.close);
    });
  });
}
