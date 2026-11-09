import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/features/settings/presentation/settings_sharing_screen.dart';
import 'package:budget_buddy/features/settings/providers/settings_provider.dart';
import 'package:budget_buddy/features/spaces/providers/spaces_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/settings_test_harness.dart';

void main() {
  Future<void> pumpSharing(
    WidgetTester tester,
    SettingsTestHarness harness, {
    Size size = const Size(360, 1200),
    double textScale = 1,
  }) {
    return harness.pump(
      tester,
      const SettingsSharingScreen(),
      size: size,
      textScale: textScale,
    );
  }

  testWidgets('shows shared space, owner controls and the shared save switch',
      (tester) async {
    await pumpSharing(tester, SettingsTestHarness(isShared: true));

    expect(find.byKey(const Key('settingsSharingScreen')), findsOneWidget);
    expect(find.text('Shared space'), findsOneWidget);
    expect(find.text('Members'), findsOneWidget);
    expect(find.byKey(const Key('memberTile_1')), findsOneWidget);

    for (final key in const [
      'editSpaceNameButton',
      'editIncomeButton',
      'transferOwnershipButton',
      'pairDeviceFromSpaceButton',
      'deleteSpaceButton',
    ]) {
      expect(find.byKey(Key(key)), findsOneWidget, reason: key);
    }

    expect(find.textContaining('Space income'), findsWidgets);
    expect(find.text('Our income'), findsNothing);
    expect(find.text('Privacy & security'), findsNothing);
    expect(find.text('People'), findsNothing);
    expect(find.text('Paired devices'), findsNothing);

    final switchTile = tester.widget<SwitchListTile>(
      find.byKey(const Key('confirmSharedSaveToggle')),
    );
    expect(switchTile.value, isTrue);
  });

  testWidgets('a Viewer sees no owner-only controls', (tester) async {
    final viewer = SharedMember()
      ..id = 1
      ..sharedSpaceId = 10
      ..profileId = 1
      ..role = SharedMemberRole.viewer
      ..joinedAt = DateTime(2026);

    await pumpSharing(
      tester,
      SettingsTestHarness(
        isShared: true,
        extraOverrides: [
          activeSpaceMyRoleProvider.overrideWithValue(viewer),
        ],
      ),
    );

    expect(find.byKey(const Key('memberTile_1')), findsOneWidget);
    expect(find.byKey(const Key('editSpaceNameButton')), findsNothing);
    expect(find.byKey(const Key('editIncomeButton')), findsNothing);
    expect(find.byKey(const Key('transferOwnershipButton')), findsNothing);
    expect(find.byKey(const Key('deleteSpaceButton')), findsNothing);
  });

  testWidgets('personal context hides the shared-space block', (tester) async {
    await pumpSharing(tester, SettingsTestHarness());

    expect(find.text('Shared space'), findsNothing);
    expect(find.byKey(const Key('editSpaceNameButton')), findsNothing);
    expect(find.byKey(const Key('confirmSharedSaveToggle')), findsOneWidget);
    expect(find.text('People'), findsNothing);
    expect(find.text('Paired devices'), findsNothing);
  });

  testWidgets('confirm-shared-save switch calls the existing controller',
      (tester) async {
    final stub = _StubConfirmSharedSaveController();
    await pumpSharing(
      tester,
      SettingsTestHarness(
        isShared: true,
        extraOverrides: [
          confirmSharedSaveControllerProvider.overrideWithValue(stub),
        ],
      ),
    );

    await tester.ensureVisible(
      find.byKey(const Key('confirmSharedSaveToggle')),
    );
    await tester.pumpAndSettle();

    final switchTile = tester.widget<SwitchListTile>(
      find.byKey(const Key('confirmSharedSaveToggle')),
    );
    expect(switchTile.value, isTrue);

    await tester.tap(find.byKey(const Key('confirmSharedSaveToggle')));
    await tester.pumpAndSettle();
    expect(stub.saved, isFalse);
  });

  testWidgets('stays usable at 320 dp and 200% text', (tester) async {
    await pumpSharing(
      tester,
      SettingsTestHarness(isShared: true),
      size: const Size(320, 1600),
      textScale: 2,
    );

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('settingsSharingScreen')), findsOneWidget);
    expect(find.text('Shared space'), findsOneWidget);
  });
}

class _StubConfirmSharedSaveController implements ConfirmSharedSaveController {
  bool? saved;

  @override
  Future<void> setConfirmSharedSave(bool enabled, {int? profileId}) async {
    saved = enabled;
  }
}
