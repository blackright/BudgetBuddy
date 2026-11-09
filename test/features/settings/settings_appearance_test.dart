import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/features/settings/presentation/font_setting_section.dart';
import 'package:budget_buddy/features/settings/presentation/settings_appearance_sheet.dart';
import 'package:budget_buddy/features/settings/presentation/settings_copy.dart';
import 'package:budget_buddy/features/settings/presentation/settings_screen.dart';
import 'package:budget_buddy/features/settings/presentation/theme_setting_section.dart';
import 'package:budget_buddy/features/settings/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../medical/repositories/medical_test_harness.dart';
import 'support/settings_test_harness.dart';

/// US5 (FR-033, FR-034): Appearance is one summary row opening a sheet with
/// three theme chips and the existing four-font list. Both choices persist
/// immediately through their controllers, and the hub summary follows the
/// profile.
void main() {
  Widget sheetBody() => const Scaffold(body: SettingsAppearanceSheet());

  testWidgets('opens with the saved theme and font selected', (tester) async {
    final harness = SettingsTestHarness(
      profiles: [
        settingsTestProfile(
          themeMode: AppThemeMode.dark,
          fontFamily: AppFontFamily.roboto,
        ),
      ],
    );

    await harness.pump(tester, sheetBody(), size: const Size(360, 900));

    expect(find.byKey(const Key('settingsAppearanceSheet')), findsOneWidget);
    expect(find.text(SettingsCopy.appearance), findsOneWidget);
    expect(find.text(SettingsCopy.theme), findsOneWidget);
    expect(find.text(SettingsCopy.font), findsOneWidget);

    expect(find.byType(ChoiceChip), findsNWidgets(3));
    for (final mode in AppThemeMode.values) {
      expect(
        find.byKey(ThemeSettingSection.keyFor(mode)),
        findsOneWidget,
        reason: mode.name,
      );
    }
    expect(
      tester
          .widget<ChoiceChip>(
            find.byKey(ThemeSettingSection.keyFor(AppThemeMode.dark)),
          )
          .selected,
      isTrue,
    );
    expect(
      tester
          .widget<ChoiceChip>(
            find.byKey(ThemeSettingSection.keyFor(AppThemeMode.system)),
          )
          .selected,
      isFalse,
    );

    expect(find.byType(RadioListTile<AppFontFamily>), findsNWidgets(4));
    for (final font in AppFontFamily.values) {
      expect(
        find.byKey(FontSettingSection.keyFor(font)),
        findsOneWidget,
        reason: font.name,
      );
    }
    expect(
      tester
          .widget<RadioGroup<AppFontFamily>>(
            find.byType(RadioGroup<AppFontFamily>),
          )
          .groupValue,
      AppFontFamily.roboto,
    );

    // The old dropdown vocabulary must not come back.
    expect(find.byType(DropdownButtonFormField<dynamic>), findsNothing);
    for (final banned in const [
      'App Theme',
      'App Font Style',
      'Select Theme',
      'Select Font',
      'Follow system',
    ]) {
      expect(find.text(banned), findsNothing, reason: banned);
    }
  });

  testWidgets('theme and font write immediately to the real database',
      (tester) async {
    late MedicalTestHarness isar;
    late UserProfile profile;
    await tester.runAsync(() async {
      isar = await MedicalTestHarness.create();
      profile = settingsTestProfile(id: 1);
      await isar.isar.writeTxn(() async {
        await isar.isar.userProfiles.put(profile);
      });
    });

    final harness = SettingsTestHarness(
      profiles: [profile],
      extraOverrides: [
        appThemeControllerProvider
            .overrideWithValue(AppThemeController(isar.isar)),
        appFontControllerProvider
            .overrideWithValue(AppFontController(isar.isar)),
      ],
    );

    await harness.pump(tester, sheetBody(), size: const Size(360, 900));

    await tester.tap(
      find.byKey(ThemeSettingSection.keyFor(AppThemeMode.dark)),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(FontSettingSection.keyFor(AppFontFamily.openSans)),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(FontSettingSection.keyFor(AppFontFamily.openSans)),
    );
    await tester.pumpAndSettle();

    // Both writes fire inside the fake-async zone, so their Isar replies only
    // drain once the real event loop turns.
    UserProfile? stored;
    for (var i = 0;
        i < 80 &&
            (stored?.themeMode != AppThemeMode.dark ||
                stored?.fontFamily != AppFontFamily.openSans);
        i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)),
      );
      await tester.pump();
      await tester.runAsync(() async {
        stored = await isar.isar.userProfiles.get(profile.id);
      });
    }

    expect(stored?.themeMode, AppThemeMode.dark,
        reason: 'the theme was written without a Save button');
    expect(stored?.fontFamily, AppFontFamily.openSans,
        reason: 'the font was written without a Save button');

    await tester.runAsync(isar.close);
  });

  testWidgets('the hub summary follows the saved theme and font',
      (tester) async {
    await SettingsTestHarness(
      profiles: [
        settingsTestProfile(
          themeMode: AppThemeMode.dark,
          fontFamily: AppFontFamily.roboto,
        ),
      ],
    ).pump(tester, const SettingsScreen());

    expect(find.text('Dark · Roboto'), findsOneWidget);

    await tester.tap(find.byKey(const Key('settingsAppearanceRow')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('settingsAppearanceSheet')), findsOneWidget);
  });

  testWidgets('stays usable at 320 dp and 200% text', (tester) async {
    await SettingsTestHarness(
      profiles: [
        settingsTestProfile(
          themeMode: AppThemeMode.system,
          fontFamily: AppFontFamily.openSans,
        ),
      ],
    ).pump(
      tester,
      sheetBody(),
      size: const Size(320, 1600),
      textScale: 2,
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(ChoiceChip), findsNWidgets(3));
    expect(find.byType(RadioListTile<AppFontFamily>), findsNWidgets(4));
  });
}
