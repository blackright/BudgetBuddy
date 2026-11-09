import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/features/identity/presentation/identity_onboarding_screen.dart';
import 'package:budget_buddy/features/identity/presentation/identity_section.dart';
import 'package:budget_buddy/features/settings/presentation/profile_switcher_section.dart';
import 'package:budget_buddy/features/settings/presentation/settings_copy.dart';
import 'package:budget_buddy/features/settings/presentation/settings_profile_space_screen.dart';
import 'package:budget_buddy/features/settings/presentation/settings_screen.dart';
import 'package:budget_buddy/features/spaces/presentation/spaces_list_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/settings_test_harness.dart';

void main() {
  SettingsTestHarness harness({
    _StubProfileController? controller,
    List<UserProfile>? profiles,
    List<SharedSpace>? spaces,
    bool isShared = false,
    bool hasIdentity = true,
  }) {
    return SettingsTestHarness(
      profiles: profiles,
      spaces: spaces,
      isShared: isShared,
      hasIdentity: hasIdentity,
      extraOverrides: [
        profileSwitcherControllerProvider.overrideWithValue(
          controller ?? _StubProfileController(),
        ),
      ],
    );
  }

  Future<void> pumpScreen(
    WidgetTester tester,
    SettingsTestHarness harness, {
    Size size = const Size(360, 800),
    double textScale = 1,
  }) {
    return harness.pump(
      tester,
      const SettingsProfileSpaceScreen(),
      size: size,
      textScale: textScale,
    );
  }

  testWidgets('shows profile, identity and spaces sections', (tester) async {
    await pumpScreen(tester, harness());

    expect(find.byType(SettingsProfileSpaceScreen), findsOneWidget);
    expect(find.text(SettingsCopy.profileSpace), findsOneWidget);
    expect(find.byType(ProfileSwitcherSection), findsOneWidget);
    expect(find.byType(IdentitySection), findsOneWidget);
    expect(find.byType(SpacesListSection), findsOneWidget);

    expect(find.byKey(const Key('profileTile_1')), findsOneWidget);
    expect(find.byKey(const Key('profileTile_2')), findsOneWidget);
    expect(find.byKey(const Key('addProfileButton')), findsOneWidget);
    expect(find.byKey(const Key('identityFingerprint')), findsOneWidget);
    expect(find.byKey(const Key('wipeIdentityButton')), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('New space'), findsOneWidget);
    expect(find.text('Identity'), findsOneWidget);
    expect(find.text('Identity & privacy'), findsNothing);
  });

  testWidgets('switching profile updates the Settings header', (tester) async {
    await harness().pump(tester, const SettingsScreen());

    await tester.tap(find.byKey(const Key('settingsContextHeader')));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsProfileSpaceScreen), findsOneWidget);

    await tester.tap(find.byKey(const Key('profileTile_2')));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Bea'), findsOneWidget);
    expect(find.text('Alex'), findsNothing);
  });

  testWidgets('switching space updates the Settings header', (tester) async {
    final spaces = [
      settingsTestSpace(),
      settingsTestSpace(id: 11, name: 'Work', avatar: '💼'),
    ];
    await harness(spaces: spaces, isShared: true)
        .pump(tester, const SettingsScreen());

    expect(find.text('Home · HUF'), findsOneWidget);

    await tester.tap(find.byKey(const Key('settingsContextHeader')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Work'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Work'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Work · HUF'), findsOneWidget);
  });

  testWidgets('adds a profile through the existing dialog', (tester) async {
    final controller = _StubProfileController();
    await pumpScreen(tester, harness(controller: controller));

    await tester.tap(find.byKey(const Key('addProfileButton')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('profileNameField')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('profileNameField')),
      'Cara',
    );
    await tester.tap(find.byKey(const Key('saveProfileButton')));
    await tester.pumpAndSettle();

    expect(controller.createdName, 'Cara');
    expect(find.byKey(const Key('profileNameField')), findsNothing);
  });

  testWidgets('the last profile has no delete affordance', (tester) async {
    await pumpScreen(
      tester,
      harness(profiles: [settingsTestProfile()]),
    );

    expect(find.byKey(const Key('profileTile_1')), findsOneWidget);
    expect(find.byKey(const Key('profileMenuButton_1')), findsNothing);
  });

  testWidgets('delete opens the typed-name gate', (tester) async {
    await pumpScreen(tester, harness());

    await tester.tap(find.byKey(const Key('profileMenuButton_2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('deleteProfileOption_2')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('deleteProfileNameField')), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('deleteProfileNameField')), findsNothing);
  });

  testWidgets('identity shows the fingerprint and removal confirmation',
      (tester) async {
    await pumpScreen(tester, harness());

    expect(find.byKey(const Key('identityFingerprint')), findsOneWidget);
    expect(find.text('Fingerprint: fp-1'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('wipeIdentityButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('wipeIdentityButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('confirmWipeIdentityButton')), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('confirmWipeIdentityButton')), findsNothing);
  });

  testWidgets('identity setup opens the existing onboarding screen',
      (tester) async {
    await pumpScreen(tester, harness(hasIdentity: false));

    await tester.ensureVisible(find.byKey(const Key('setupIdentityButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('setupIdentityButton')));
    await tester.pumpAndSettle();

    expect(find.byType(IdentityOnboardingScreen), findsOneWidget);
    expect(find.byKey(const Key('identityUsernameField')), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
  });

  testWidgets('New space opens the existing create sheet', (tester) async {
    await pumpScreen(tester, harness());

    await tester.ensureVisible(find.text('New space'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New space'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('spaceNameField')), findsOneWidget);

    await tester.tap(find.byKey(const Key('appSheetClose')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('spaceNameField')), findsNothing);
  });

  testWidgets('stays usable at 320 dp and 200% text', (tester) async {
    await pumpScreen(
      tester,
      harness(),
      size: const Size(320, 1600),
      textScale: 2,
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(ProfileSwitcherSection), findsOneWidget);
    expect(find.byType(IdentitySection), findsOneWidget);
    expect(find.byType(SpacesListSection), findsOneWidget);
  });
}

/// A fake-clock-safe controller for the profile dialogs.
class _StubProfileController implements ProfileSwitcherController {
  String? createdName;
  int? deletedProfileId;

  @override
  Future<int> createProfile(String name, {double startingSalary = 0}) async {
    createdName = name;
    return 99;
  }

  @override
  Future<void> touchLastActiveAt(int profileId) async {}

  @override
  Future<ProfileDataSummary> summarizeProfile(int profileId) async =>
      const ProfileDataSummary(expenses: 1);

  @override
  Future<ProfileDeletionResult> deleteProfile(
    int profileId, {
    required int? activeProfileId,
  }) async {
    deletedProfileId = profileId;
    return const ProfileDeletionResult(
      wasActive: false,
      fallbackProfileId: 1,
    );
  }
}
