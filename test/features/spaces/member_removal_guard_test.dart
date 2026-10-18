import 'package:budget_buddy/core/models/identity.dart';
import 'package:budget_buddy/core/models/paired_peer.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/core/providers/identity_provider.dart';
import 'package:budget_buddy/core/providers/selected_month_provider.dart';
import 'package:budget_buddy/features/identity/domain/identity_profile_key.dart';
import 'package:budget_buddy/features/pairing/providers/pairing_providers.dart';
import 'package:budget_buddy/features/settings/presentation/profile_switcher_section.dart';
import 'package:budget_buddy/features/spaces/domain/shared_member_key.dart';
import 'package:budget_buddy/features/spaces/presentation/space_settings_section.dart';
import 'package:budget_buddy/features/spaces/providers/spaces_providers.dart';
import 'package:budget_buddy/features/spaces/repositories/space_role_guard.dart';
import 'package:budget_buddy/features/spaces/repositories/spaces_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../medical/repositories/medical_test_harness.dart';

/// T063 (I1/I2): member removal is honest and cannot be mis-tapped.
///
/// Two things must hold in the real settings section:
/// 1. When the repository **refuses** a removal, the SnackBar shows the message
///    the repository threw, verbatim — never the old guessed text
///    ("Cannot remove the only Owner."), which misreported every other rule.
/// 2. The acting profile offers **no** Remove affordance. In this fixture the
///    acting profile is the space's **last Owner**, so that single check covers
///    both halves of the rule: you can neither remove yourself nor remove the
///    last Owner.
///
/// Widget-test rule (see `space_creation_test.dart`): no real Isar watch streams
/// and no real Isar I/O under the fake clock — every Isar-backed provider the
/// section touches is overridden with in-memory streams built from the fixture
/// rows.
void main() {
  final now = DateTime(2026, 1, 1);

  late MedicalTestHarness harness;
  late UserProfile ava;
  late Identity identity;
  late PairedPeer sam;
  late SharedSpace space;
  late SharedMember avaRow;
  late SharedMember samRow;
  late int spaceId;

  /// Ava owns the space (her row carries the identity-derived key) and Sam is a
  /// paired Editor, so his row carries `remoteProfileIdFor` of his fingerprint.
  Future<void> buildFixture() async {
    harness = await MedicalTestHarness.create();

    ava = UserProfile()
      ..name = 'Ava'
      ..avatar = '👩'
      ..primaryCurrency = PrimaryCurrency.usd
      ..monthlyAvailableAmount = 0
      ..defaultNetSalary = 0
      ..createdAt = now
      ..updatedAt = now;
    ava.id = await harness.isar.writeTxn(
      () => harness.isar.userProfiles.put(ava),
    );

    identity = Identity()
      ..username = 'Ava'
      ..publicKey = 'pk-ava'
      ..fingerprint = 'aabbccddeeff001122334455'
      ..localProfileId = ava.id
      ..createdAt = now
      ..updatedAt = now;
    await harness.isar.writeTxn(() => harness.isar.identitys.put(identity));

    sam = PairedPeer()
      ..peerIdentityId = '1122334455667788'
      ..peerUsername = 'Sam'
      ..peerPublicKey = 'pk-sam'
      ..peerFingerprint = '112233'
      ..pairedAt = now;
    await harness.isar.writeTxn(() => harness.isar.pairedPeers.put(sam));

    space = SharedSpace()
      ..name = 'Home'
      ..avatar = '🏠'
      ..currency = PrimaryCurrency.usd
      ..defaultIncome = 0
      ..createdByProfileId = ava.id
      ..createdAt = now;
    spaceId = await harness.isar.writeTxn(
      () => harness.isar.sharedSpaces.put(space),
    );

    avaRow = SharedMember()
      ..sharedSpaceId = spaceId
      ..profileId = sharedMemberKey(identity.fingerprint)
      ..role = SharedMemberRole.owner
      ..joinedAt = now
      ..updatedAt = now;
    samRow = SharedMember()
      ..sharedSpaceId = spaceId
      ..profileId = remoteProfileIdFor(sam.peerIdentityId)
      ..role = SharedMemberRole.editor
      ..joinedAt = now
      ..updatedAt = now;
    await harness.isar.writeTxn(
      () => harness.isar.sharedMembers.putAll([avaRow, samRow]),
    );
  }

  /// Overrides every Isar-backed provider the section reads, acting as Ava.
  /// [repository] replaces the repository seam so a refusal can be staged
  /// without real Isar I/O.
  ProviderContainer buildContainer({SpacesRepository? repository}) {
    final container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith((ref) => Stream.value([ava])),
        activeProfileProvider.overrideWith((ref) => Stream.value(ava)),
        activeSpaceIdProvider.overrideWith((ref) => spaceId),
        activeSpaceProvider.overrideWith((ref) => Stream.value(space)),
        mySpacesProvider.overrideWith((ref) => Stream.value([space])),
        activeSpaceMembersProvider
            .overrideWith((ref) => Stream.value([avaRow, samRow])),
        activeSpaceMyRoleProvider.overrideWithValue(avaRow),
        identityProvider.overrideWith((ref) => Stream.value(identity)),
        pairedPeersProvider.overrideWith((ref) => Stream.value([sam])),
        activeBudgetProvider.overrideWith((ref) => Stream.value(null)),
        budgetContextProvider.overrideWith((ref) {
          return ContextRef.shared(
            spaceId: spaceId,
            yearMonth: ref.watch(selectedYearMonthProvider),
          );
        }),
        selectedYearMonthProvider.overrideWith((ref) => '2026-01'),
        spacesRepositoryProvider
            .overrideWithValue(repository ?? SpacesRepository(harness.isar)),
        profileSwitcherControllerProvider
            .overrideWithValue(const _StubProfileController()),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Future<void> pumpSection(
    WidgetTester tester,
    ProviderContainer container,
  ) async {
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
  }

  testWidgets(
      'a refused removal shows the message the repository threw, verbatim',
      (WidgetTester tester) async {
    await tester.runAsync(buildFixture);
    // The message the real repository throws when the last Owner is at stake.
    const refusal = 'a space must always have at least one Owner; transfer '
        'ownership first (FR-006/FR-014)';
    final container = buildContainer(
      repository: _RefusingSpacesRepository(harness.isar, message: refusal),
    );
    await pumpSection(tester, container);

    await tester.ensureVisible(find.byTooltip('Manage member'));
    await tester.tap(find.byTooltip('Manage member'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('removeMember_${samRow.profileId}')));
    await tester.pumpAndSettle();

    // The confirmation stands in front of the action; confirm it.
    await tester.tap(find.byKey(const Key('confirmRemoveMemberButton')));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(
      find.text(refusal),
      findsOneWidget,
      reason: 'the SnackBar shows the rule that fired, exactly as thrown',
    );
    expect(
      find.textContaining('Cannot remove the only Owner'),
      findsNothing,
      reason: 'the old guessed text must never come back',
    );

    await tester.runAsync(harness.close);
  });

  testWidgets('the acting profile — the space\'s last Owner — offers no Remove',
      (WidgetTester tester) async {
    await tester.runAsync(buildFixture);
    await pumpSection(tester, buildContainer());

    // The acting profile's own row carries no menu at all, so it can neither
    // remove itself nor remove the last Owner.
    expect(
      find.descendant(
        of: find.byKey(Key('memberTile_${avaRow.profileId}')),
        matching: find.byTooltip('Manage member'),
      ),
      findsNothing,
      reason: 'the last Owner must not be offered a Remove affordance',
    );

    // The other member's row does offer one, so the absence above is real and
    // not just "the section renders no menus at all".
    final samMenu = find.descendant(
      of: find.byKey(Key('memberTile_${samRow.profileId}')),
      matching: find.byTooltip('Manage member'),
    );
    expect(samMenu, findsOneWidget);

    // And the menu it opens really carries the Remove action.
    await tester.ensureVisible(samMenu);
    await tester.tap(samMenu);
    await tester.pumpAndSettle();
    expect(find.byKey(Key('removeMember_${samRow.profileId}')), findsOneWidget);

    await tester.runAsync(harness.close);
  });
}

/// The repository seam, stubbed so the refusal path runs under the fake clock.
///
/// It throws exactly what `SpacesRepository.removeMember` throws when the rule
/// fires, so the UI's job — forwarding the message untouched — is what is under
/// test (real Isar I/O must not start under the widget-test fake clock).
class _RefusingSpacesRepository extends SpacesRepository {
  _RefusingSpacesRepository(super.isar, {required this.message});

  final String message;

  @override
  Future<void> removeMember({
    required int actingProfileId,
    required int spaceId,
    required int profileId,
  }) async {
    throw UnauthorizedSpaceAction(message);
  }
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
