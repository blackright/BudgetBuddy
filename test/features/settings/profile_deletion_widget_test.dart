import 'dart:async';

import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/features/settings/presentation/profile_switcher_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// T071 — the delete affordance and the typed-name gate in the switcher UI.
///
/// The whole flow runs against a stub controller so no real Isar I/O touches
/// the widget-test fake clock; the real cascade is owned by T070.
void main() {
  UserProfile profile(int id, String name) => UserProfile()
    ..id = id
    ..name = name
    ..avatar = '👤'
    ..createdAt = DateTime(2026)
    ..updatedAt = DateTime(2026);

  testWidgets('the last remaining profile offers no delete affordance',
      (tester) async {
    final only = profile(1, 'Solo');
    final container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith((ref) => Stream.value([only])),
        activeProfileProvider.overrideWith((ref) => Stream.value(only)),
        profileSwitcherControllerProvider.overrideWithValue(
          _StubProfileController(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: ProfileSwitcherSection()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('profileTile_1')), findsOneWidget);
    expect(find.byKey(const Key('profileMenuButton_1')), findsNothing,
        reason: 'you cannot delete your only profile');
  });

  testWidgets('typed name gates delete; success refreshes the switcher',
      (tester) async {
    final ava = profile(1, 'Ava');
    final bea = profile(2, 'Bea');
    final controller = _StubProfileController(
      fallbackProfileId: ava.id,
      wasActive: true,
    );

    final rows = <UserProfile>[ava, bea];
    final profileUpdates = StreamController<List<UserProfile>>.broadcast();
    addTearDown(profileUpdates.close);
    final container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(
          (ref) => _profilesStream(List.of(rows), profileUpdates.stream),
        ),
        activeProfileProvider.overrideWith((ref) {
          final id = ref.watch(activeProfileIdProvider) ?? bea.id;
          return Stream.value(
              rows.firstWhere((p) => p.id == id, orElse: () => bea));
        }),
        profileSwitcherControllerProvider.overrideWithValue(controller),
      ],
    );
    addTearDown(container.dispose);
    container.read(activeProfileIdProvider.notifier).state = bea.id;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: ProfileSwitcherSection()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Both tiles offer the overflow menu.
    expect(find.byKey(const Key('profileMenuButton_1')), findsOneWidget);
    expect(find.byKey(const Key('profileMenuButton_2')), findsOneWidget);

    // Open Bea's menu and choose delete.
    await tester.tap(find.byKey(const Key('profileMenuButton_2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('deleteProfileOption_2')));
    await tester.pumpAndSettle();

    // The typed-name confirmation is shown with the counts summary.
    expect(find.byKey(const Key('deleteProfileNameField')), findsOneWidget);
    FilledButton deleteButton() => tester.widget<FilledButton>(
        find.byKey(const Key('confirmDeleteProfileButton')));
    expect(deleteButton().onPressed, isNull,
        reason: 'empty input cannot delete');

    await tester.enterText(
        find.byKey(const Key('deleteProfileNameField')), 'Bea');
    await tester.pump();
    expect(deleteButton().onPressed, isNotNull,
        reason: 'the exact name unlocks the delete');

    // Delete: the stub removes Bea, and the switcher refreshes.
    rows.removeWhere((p) => p.id == bea.id);
    profileUpdates.add(List.of(rows));
    await tester.tap(find.byKey(const Key('confirmDeleteProfileButton')));
    await tester.pumpAndSettle();

    expect(controller.deletedProfileId, bea.id);
    expect(find.byKey(const Key('profileTile_2')), findsNothing,
        reason: 'the deleted profile disappears from the switcher');
    expect(find.byKey(const Key('profileTile_1')), findsOneWidget);
    expect(container.read(activeProfileIdProvider), ava.id,
        reason: 'the active marker falls back to a survivor');
    expect(container.read(activeSpaceIdProvider), isNull);
  });

  testWidgets('a refused delete surfaces a message and changes nothing',
      (tester) async {
    final ava = profile(1, 'Ava');
    final bea = profile(2, 'Bea');
    final controller = _StubProfileController(
      blockMessage: 'Transfer ownership of Home first, or delete that space.',
    );

    final container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith((ref) => Stream.value([ava, bea])),
        activeProfileProvider.overrideWith((ref) => Stream.value(ava)),
        profileSwitcherControllerProvider.overrideWithValue(controller),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: ProfileSwitcherSection()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('profileMenuButton_2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('deleteProfileOption_2')));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key('deleteProfileNameField')), 'Bea');
    await tester.pump();
    await tester.tap(find.byKey(const Key('confirmDeleteProfileButton')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Transfer ownership of Home'), findsOneWidget);
    expect(find.byKey(const Key('profileTile_2')), findsOneWidget,
        reason: 'a refused deletion never removes the tile');
  });
}

/// Mirrors the real `profilesProvider`: emit the current list once, then
/// forward live updates (the real Isar watcher cannot run under the fake clock).
Stream<List<UserProfile>> _profilesStream(
  List<UserProfile> initial,
  Stream<List<UserProfile>> updates,
) async* {
  yield List<UserProfile>.of(initial);
  await for (final value in updates) {
    yield value;
  }
}

/// Stub controller: skips all DB work so the widget flow is fake-clock-safe.
class _StubProfileController implements ProfileSwitcherController {
  _StubProfileController({
    this.fallbackProfileId,
    this.wasActive = false,
    this.blockMessage,
  });

  final int? fallbackProfileId;
  final bool wasActive;
  final String? blockMessage;

  int? deletedProfileId;

  @override
  Future<int> createProfile(String name) async => throw StateError('unused');

  @override
  Future<void> touchLastActiveAt(int profileId) async {}

  @override
  Future<ProfileDataSummary> summarizeProfile(int profileId) async =>
      const ProfileDataSummary(expenses: 2, hasVault: true);

  @override
  Future<ProfileDeletionResult> deleteProfile(
    int profileId, {
    required int? activeProfileId,
  }) async {
    if (blockMessage != null) {
      throw ProfileDeletionBlocked(blockMessage!);
    }
    deletedProfileId = profileId;
    return ProfileDeletionResult(
      wasActive: wasActive,
      fallbackProfileId: fallbackProfileId,
    );
  }
}
