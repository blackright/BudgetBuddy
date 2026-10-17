import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/features/settings/presentation/shared_save_setting_section.dart';
import 'package:budget_buddy/features/settings/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../medical/repositories/medical_test_harness.dart';

/// US6 (T051/T056): the shared-save confirmation is ON by default, is a
/// persisted profile setting, and the Settings toggle writes it through the
/// single controller.
void main() {
  UserProfile makeProfile({bool confirmSharedSave = true}) => UserProfile()
    ..name = 'Ava'
    ..primaryCurrency = PrimaryCurrency.huf
    ..monthlyAvailableAmount = 0
    ..confirmSharedSave = confirmSharedSave
    ..createdAt = DateTime(2026)
    ..updatedAt = DateTime(2026);

  group('confirmSharedSaveOnProvider', () {
    test('defaults to ON while no profile exists', () {
      final container = ProviderContainer(
        overrides: [
          activeProfileProvider.overrideWith((ref) => Stream.value(null)),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(confirmSharedSaveOnProvider), isTrue);
    });

    test('reflects the watched profile flag', () async {
      final container = ProviderContainer(
        overrides: [
          activeProfileProvider.overrideWith(
            (ref) => Stream.value(makeProfile(confirmSharedSave: false)),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(activeProfileProvider.future);

      expect(container.read(confirmSharedSaveOnProvider), isFalse);
    });
  });

  group('ConfirmSharedSaveController (real Isar write)', () {
    test('persists the choice on the active profile', () async {
      final harness = await MedicalTestHarness.create();
      addTearDown(harness.close);

      final profile = makeProfile();
      await harness.isar.writeTxn(() async {
        await harness.isar.userProfiles.put(profile);
      });

      await ConfirmSharedSaveController(harness.isar)
          .setConfirmSharedSave(false);

      final after = await harness.isar.userProfiles.get(profile.id);
      expect(after!.confirmSharedSave, isFalse);
    });
  });

  group('SharedSaveSettingSection', () {
    Widget wrap({
      required UserProfile? profile,
      ConfirmSharedSaveController? controller,
    }) {
      return ProviderScope(
        overrides: [
          activeProfileProvider.overrideWith(
            (ref) => Stream<UserProfile?>.value(profile),
          ),
          if (controller != null)
            confirmSharedSaveControllerProvider.overrideWithValue(controller),
        ],
        child:
            const MaterialApp(home: Scaffold(body: SharedSaveSettingSection())),
      );
    }

    testWidgets('renders the toggle and its default ON state', (tester) async {
      await tester.pumpWidget(wrap(profile: makeProfile()));
      await tester.pumpAndSettle();

      expect(
          find.text('Confirm before saving to a shared space'), findsOneWidget);
      final toggle = tester.widget<SwitchListTile>(
        find.byKey(const Key('confirmSharedSaveToggle')),
      );
      expect(toggle.value, isTrue);
    });

    testWidgets('toggling off persists to the real database', (tester) async {
      late MedicalTestHarness harness;
      await tester.runAsync(() async {
        harness = await MedicalTestHarness.create();
      });
      late UserProfile profile;
      await tester.runAsync(() async {
        profile = makeProfile();
        await harness.isar.writeTxn(() async {
          await harness.isar.userProfiles.put(profile);
        });
      });

      await tester.pumpWidget(
        wrap(
          profile: profile,
          controller: ConfirmSharedSaveController(harness.isar),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('confirmSharedSaveToggle')));
      await tester.pumpAndSettle();

      bool? stored;
      for (var i = 0; i < 60 && stored != false; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 30)),
        );
        await tester.pump();
        await tester.runAsync(() async {
          stored = (await harness.isar.userProfiles.get(profile.id))
              ?.confirmSharedSave;
        });
      }
      expect(stored, isFalse, reason: 'the real database row was updated');

      await tester.runAsync(harness.close);
    });
  });
}
