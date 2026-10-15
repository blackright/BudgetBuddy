import 'dart:async';

import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/core/providers/selected_month_provider.dart';
import 'package:budget_buddy/features/spaces/models/bring_in_past.dart';
import 'package:budget_buddy/features/settings/presentation/profile_switcher_section.dart';
import 'package:budget_buddy/features/spaces/presentation/space_settings_section.dart';
import 'package:budget_buddy/features/spaces/presentation/space_switcher.dart';
import 'package:budget_buddy/features/spaces/providers/spaces_providers.dart';
import 'package:budget_buddy/features/spaces/repositories/spaces_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import '../medical/repositories/medical_test_harness.dart';

/// Mutation/stream overrides keep every read fake-clock-safe: real Isar watch
/// streams cannot run under the widget-test fake clock, so the membership and
/// space streams are driven by controllers that the test updates by hand, while
/// the *writes* go through the real [SpacesRepository] inside `runAsync`.
void main() {
  testWidgets(
      'creating a space makes it active; Owner edits it and invites a '
      'Viewer (US2 AC1-AC2, US2 Independent Test)',
      (WidgetTester tester) async {
    late MedicalTestHarness harness;
    late UserProfile ava;
    late UserProfile bea;
    late _FakeSpacesRepository repo;
    final now = DateTime(2026, 1, 1);

    await tester.runAsync(() async {
      harness = await MedicalTestHarness.create();
      ava = UserProfile()
        ..name = 'Ava'
        ..avatar = '👩'
        ..primaryCurrency = PrimaryCurrency.usd
        ..monthlyAvailableAmount = 0
        ..defaultNetSalary = 3000
        ..createdAt = now
        ..updatedAt = now;
      bea = UserProfile()
        ..name = 'Bea'
        ..avatar = '🧑'
        ..primaryCurrency = PrimaryCurrency.eur
        ..monthlyAvailableAmount = 0
        ..defaultNetSalary = 5000
        ..createdAt = now
        ..updatedAt = now;
      ava.id = await harness.isar.writeTxn(
        () => harness.isar.userProfiles.put(ava),
      );
      bea.id = await harness.isar.writeTxn(
        () => harness.isar.userProfiles.put(bea),
      );
    });
    repo = _FakeSpacesRepository(harness.isar);

    final spacesController = StreamController<List<SharedSpace>>.broadcast();
    final spacesById = <int, SharedSpace>{};
    final membersController = StreamController<List<SharedMember>>.broadcast();
    final membersById = <int, SharedMember>{};
    addTearDown(spacesController.close);
    addTearDown(membersController.close);
    void rebroadcast(List<SharedSpace> spaces, List<SharedMember> members) {
      spacesById.clear();
      for (final s in spaces) {
        spacesById[s.id] = s;
      }
      membersById.clear();
      for (final m in members) {
        membersById[m.id] = m;
      }
      spacesController.add(List.of(spaces));
      membersController.add(List.of(members));
    }

    final container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith((ref) => Stream.value([ava, bea])),
        activeProfileProvider.overrideWith((ref) {
          final id = ref.watch(activeProfileIdProvider);
          final row = id == null
              ? ava
              : ([ava, bea].firstWhere((p) => p.id == id, orElse: () => ava));
          return Stream.value(row);
        }),
        budgetContextProvider.overrideWith((ref) {
          final design = ref.watch(activeSpaceIdProvider);
          return design != null
              ? ContextRef.shared(
                  spaceId: design,
                  yearMonth: ref.watch(selectedYearMonthProvider),
                )
              : ContextRef.personal(
                  profileId: ref.watch(activeProfileIdProvider) ?? ava.id,
                  yearMonth: ref.watch(selectedYearMonthProvider),
                );
        }),
        activeSpaceProvider.overrideWith((ref) {
          final id = ref.watch(activeSpaceIdProvider);
          if (id == null) return Stream.value(null);
          return spacesController.stream.map((spaces) {
            for (final s in spaces) {
              if (s.id == id) return s;
            }
            return null;
          });
        }),
        mySpacesProvider.overrideWith((ref) => spacesController.stream),
        activeSpaceMembersProvider
            .overrideWith((ref) => membersController.stream),
        activeBudgetProvider.overrideWith((ref) => Stream.value(null)),
        selectedYearMonthProvider.overrideWith((ref) => '2026-01'),
        // The UI only runs stubbed, fixed-clock-safe repository calls in this
        // test: real Isar I/O must not start under the widget-test fake clock
        // (same rule the profile-switcher suite follows). The real-repository
        // role/persistence matrix is owned by T031 (spaces_repository_test).
        spacesRepositoryProvider.overrideWithValue(repo),
        profileSwitcherControllerProvider
            .overrideWithValue(const _StubProfileController()),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SpaceSwitcher(),
                  SpaceSettingsSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Personal context: the switcher shows the active personal profile.
    expect(find.byKey(const Key('spaceSwitcher')), findsOneWidget);
    expect(find.textContaining('Ava'), findsOneWidget);
    expect(find.byType(SpaceSettingsSection), findsOneWidget);

    // Open the switcher menu and choose "New space".
    await tester.tap(find.byKey(const Key('spaceSwitcher')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('newSpaceOption')));
    await tester.pumpAndSettle();

    // The create sheet appears (US2 AC1: name, avatar, currency, income).
    expect(find.byKey(const Key('spaceNameField')), findsOneWidget);
    expect(find.byKey(const Key('spaceCurrencyDropdown')), findsOneWidget);
    expect(find.byKey(const Key('spaceIncomeField')), findsOneWidget);

    await tester.enterText(find.byKey(const Key('spaceNameField')), 'Home');
    await tester.tap(find.byKey(const Key('spaceAvatar_🏠')));
    await tester.pumpAndSettle();

    // Pick the Euro as the shared currency.
    await tester.tap(find.byKey(const Key('spaceCurrencyDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Euro').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('spaceIncomeField')), '1000');
    await tester.pump();

    // US1: the shared field groups while typing; the draft still carries the
    // exact number (asserted below as 1000 * 100 minor units).
    expect(
      tester
          .widget<TextField>(find.descendant(
            of: find.byKey(const Key('spaceIncomeField')),
            matching: find.byType(TextField),
          ))
          .controller!
          .text,
      '1,000',
    );

    // The create button pops the sheet and runs the stubbed repository call —
    // both complete under the fake clock (routing stays on the fake clock).
    await tester.ensureVisible(find.byKey(const Key('createSpaceButton')));
    await tester.tap(find.byKey(const Key('createSpaceButton')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('createSpaceButton')), findsNothing);

    // The stub recorded the sheet's draft exactly and the marker moved.
    final created = repo.spaces.values.single;
    expect(created.name, 'Home');
    expect(created.avatar, '🏠');
    expect(created.currency, PrimaryCurrency.eur,
        reason: 'the shared currency is independent of members (FR-002)');
    expect(created.defaultIncome, 1000 * 100,
        reason: '"Our income" is stored in whole minor units (FR-009)');
    expect(created.createdByProfileId, ava.id);
    expect(repo.members.single.profileId, ava.id);
    expect(repo.members.single.role, SharedMemberRole.owner,
        reason: 'the creator becomes Owner (FR-006)');
    expect(container.read(activeSpaceIdProvider), created.id,
        reason: 'creating a space switches into it');

    // Feed the created space back into the UI-facing stream overrides.
    rebroadcast([created], List.of(repo.members));
    await tester.pumpAndSettle();
    // The section only subscribes to the members stream once the space emits,
    // so the first members emission arrived with zero listeners and was
    // dropped by the broadcast controller — re-emit now that it is live.
    membersController.add(List.of(repo.members));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsWidgets);

    // Owner edits the space identity (US2 Independent Test: the Owner can).
    await tester.tap(find.byKey(const Key('editSpaceNameButton')));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const Key('spaceNameEditField')), 'Family');
    await tester.tap(find.byKey(const Key('saveEditSpaceNameButton')));
    await tester.pumpAndSettle();
    expect(repo.spaces.values.single.name, 'Family',
        reason: 'the rename reached the repository');
    final renamed = spacesById[created.id]!..name = 'Family';
    rebroadcast([renamed], List.of(repo.members));
    await tester.pumpAndSettle();
    expect(find.text('Family'), findsWidgets);

    // Owner invites Bea as a Viewer (US2 AC2, invite-only).
    await tester.tap(find.byKey(const Key('inviteMemberButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('inviteProfile_${bea.id}')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('confirmInviteButton')));
    await tester.tap(find.byKey(const Key('confirmInviteButton')));
    await tester.pumpAndSettle();
    expect(
      repo.members.firstWhere((m) => m.profileId == bea.id).role,
      SharedMemberRole.viewer,
      reason: 'the invite reached the repository with the chosen role',
    );
    rebroadcast([renamed], List.of(repo.members));
    await tester.pumpAndSettle();
    expect(find.text('Members'), findsOneWidget);
    expect(find.text('Bea'), findsOneWidget);
    expect(find.text('Viewer'), findsOneWidget);

    await tester.runAsync(harness.close);
  });

  testWidgets(
      'a Viewer sees the space read-only: no manage control is offered '
      '(US2 AC4 + Independent Test)', (WidgetTester tester) async {
    late MedicalTestHarness harness;
    late UserProfile ava;
    late UserProfile bea;
    late int spaceId;
    final now = DateTime(2026, 1, 1);

    await tester.runAsync(() async {
      harness = await MedicalTestHarness.create();
      ava = UserProfile()
        ..name = 'Ava'
        ..avatar = '👩'
        ..primaryCurrency = PrimaryCurrency.usd
        ..monthlyAvailableAmount = 0
        ..createdAt = now
        ..updatedAt = now;
      bea = UserProfile()
        ..name = 'Bea'
        ..avatar = '🧑'
        ..primaryCurrency = PrimaryCurrency.eur
        ..monthlyAvailableAmount = 0
        ..createdAt = now
        ..updatedAt = now;
      ava.id = await harness.isar.writeTxn(
        () => harness.isar.userProfiles.put(ava),
      );
      bea.id = await harness.isar.writeTxn(
        () => harness.isar.userProfiles.put(bea),
      );
      final space = SharedSpace()
        ..name = 'Home'
        ..avatar = '🏠'
        ..currency = PrimaryCurrency.usd
        ..defaultIncome = 300000
        ..createdByProfileId = ava.id
        ..createdAt = now;
      spaceId = await harness.isar.writeTxn(
        () => harness.isar.sharedSpaces.put(space),
      );
      final avaMember = SharedMember()
        ..sharedSpaceId = spaceId
        ..profileId = ava.id
        ..role = SharedMemberRole.owner
        ..joinedAt = now;
      final beaMember = SharedMember()
        ..sharedSpaceId = spaceId
        ..profileId = bea.id
        ..role = SharedMemberRole.viewer
        ..joinedAt = now;
      await harness.isar.writeTxn(
        () => harness.isar.sharedMembers.putAll([avaMember, beaMember]),
      );
    });

    late SharedSpace seeded;
    late List<SharedMember> seededMembers;
    await tester.runAsync(() async {
      seeded = (await harness.isar.sharedSpaces.get(spaceId))!;
      seededMembers = await harness.isar.sharedMembers
          .filter()
          .sharedSpaceIdEqualTo(spaceId)
          .findAll();
    });

    final spacesController = StreamController<List<SharedSpace>>.broadcast();
    final membersController = StreamController<List<SharedMember>>.broadcast();
    addTearDown(spacesController.close);
    addTearDown(membersController.close);

    final container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith((ref) => Stream.value([ava, bea])),
        // Bea is the acting profile; she is a Viewer in the active space.
        activeProfileProvider.overrideWith((ref) => Stream.value(bea)),
        activeSpaceIdProvider.overrideWith((ref) => spaceId),
        activeSpaceProvider.overrideWith((ref) => Stream.value(seeded)),
        mySpacesProvider.overrideWith((ref) => Stream.value([seeded])),
        activeSpaceMembersProvider
            .overrideWith((ref) => Stream.value(seededMembers)),
        activeBudgetProvider.overrideWith((ref) => Stream.value(null)),
        budgetContextProvider.overrideWith((ref) => ContextRef.shared(
              spaceId: spaceId,
              yearMonth: ref.watch(selectedYearMonthProvider),
            )),
        selectedYearMonthProvider.overrideWith((ref) => '2026-01'),
        spacesRepositoryProvider
            .overrideWithValue(SpacesRepository(harness.isar)),
        profileSwitcherControllerProvider
            .overrideWithValue(const _StubProfileController()),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SpaceSettingsSection(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Read-only: the space identity, its income, the members and their roles
    // are visible...
    expect(find.text('Home'), findsOneWidget);
    expect(find.textContaining('Our income'), findsOneWidget);
    expect(find.text('Members'), findsOneWidget);
    expect(find.text('Ava'), findsOneWidget);
    expect(find.text('Owner'), findsOneWidget);
    expect(find.text('Bea'), findsOneWidget);
    expect(find.text('Viewer'), findsOneWidget);

    // ...but every Owner-only management control is absent for a Viewer.
    expect(find.byKey(const Key('editSpaceNameButton')), findsNothing);
    expect(find.byKey(const Key('inviteMemberButton')), findsNothing);
    expect(find.byKey(const Key('transferOwnershipButton')), findsNothing);
    expect(find.byKey(const Key('deleteSpaceButton')), findsNothing);
    expect(find.byKey(Key('removeMember_${ava.id}')), findsNothing);
    expect(find.byKey(Key('removeMember_${bea.id}')), findsNothing);

    await tester.runAsync(harness.close);
  });
}

class _StubProfileController implements ProfileSwitcherController {
  const _StubProfileController();

  @override
  Future<int> createProfile(String name, {double startingSalary = 0}) async =>
      throw StateError('unused');

  @override
  Future<void> touchLastActiveAt(int profileId) async {}

  @override
  Future<ProfileDataSummary> summarizeProfile(int profileId) async =>
      const ProfileDataSummary();

  @override
  Future<ProfileDeletionResult> deleteProfile(
    int profileId, {
    required int? activeProfileId,
  }) async =>
      const ProfileDeletionResult(wasActive: false, fallbackProfileId: null);
}

/// In-memory stand-in for `SpacesRepository` so the widget flow runs entirely
/// under the fake clock. Real Isar I/O must NOT start under the widget-test
/// fake clock (a write transaction begun there never completes — the same rule
/// the profile-switcher suite documents), so the UI-to-repository seam is
/// exercised here while the real repository's persistence/role matrix is owned
/// by T031.
class _FakeSpacesRepository extends SpacesRepository {
  _FakeSpacesRepository(super.isar);

  final Map<int, SharedSpace> spaces = {};
  final List<SharedMember> members = [];
  int _nextId = 100;

  @override
  Future<SharedSpace> createSpace({
    required int createdByProfileId,
    required String name,
    String avatar = '👨‍👩‍👧',
    required PrimaryCurrency currency,
    int defaultIncome = 0,
    BringInPast bringIn = BringInPast.thisMonth,
    DateTime? now,
  }) async {
    final space = SharedSpace()
      ..id = _nextId++
      ..name = name.trim()
      ..avatar = avatar
      ..currency = currency
      ..defaultIncome = defaultIncome
      ..createdByProfileId = createdByProfileId
      ..createdAt = DateTime(2026, 1, 1);
    spaces[space.id] = space;
    members.add(
      SharedMember()
        ..sharedSpaceId = space.id
        ..profileId = createdByProfileId
        ..role = SharedMemberRole.owner
        ..joinedAt = DateTime(2026, 1, 1),
    );
    return space;
  }

  @override
  Future<void> updateSpace({
    required int actingProfileId,
    required int spaceId,
    String? name,
    String? avatar,
    PrimaryCurrency? currency,
    int? defaultIncome,
  }) async {
    final space = spaces[spaceId]!;
    if (name != null) space.name = name.trim();
    if (avatar != null) space.avatar = avatar;
    if (currency != null) space.currency = currency;
    if (defaultIncome != null) space.defaultIncome = defaultIncome;
  }

  @override
  Future<void> invite({
    required int actingProfileId,
    required int spaceId,
    required int profileId,
    required SharedMemberRole role,
  }) async {
    members.add(
      SharedMember()
        ..sharedSpaceId = spaceId
        ..profileId = profileId
        ..role = role
        ..joinedAt = DateTime(2026, 1, 1),
    );
  }
}
