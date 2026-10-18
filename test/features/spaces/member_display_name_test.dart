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
import 'package:budget_buddy/features/spaces/repositories/spaces_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../medical/repositories/medical_test_harness.dart';

/// 015: the Members list must show real names for every form a membership key
/// can take.
///
/// A membership row is keyed by the fingerprint-derived `sharedMemberKey` for
/// an identity-bearing local profile (T044a) and by `remoteProfileIdFor` of the
/// fingerprint for a paired contact — never by the raw `UserProfile.id` the
/// name map used to know, which is why every tile showed its `Profile`
/// fallback on a synced phone. These tests seed exactly those two shapes (an
/// Identity-backed Owner and a paired Editor) and drive the real settings
/// section against them, plus the two dialogs that share the same lookup.
///
/// Widget-test rule (see `space_creation_test.dart`): no real Isar watch
/// streams and no real Isar I/O under the fake clock — every Isar-backed
/// provider the section touches is overridden with in-memory streams built
/// from the fixture rows.
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

  /// Seeds the fixture: Ava owns an Identity (so her membership row is stored
  /// under the fingerprint-derived key), Sam is a paired peer (his row is
  /// stored under `remoteProfileIdFor` of his fingerprint).
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

    // Both rows carry identity-derived keys — the shape every synced phone
    // stores, and the one the old raw-id name map could never resolve.
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

  /// Overrides every Isar-backed provider the section reads with the fixture
  /// rows, acting as Ava (the Owner).
  ProviderContainer buildContainer() {
    final container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith((ref) => Stream.value([ava])),
        activeProfileProvider.overrideWith((ref) => Stream.value(ava)),
        activeSpaceIdProvider.overrideWith((ref) => spaceId),
        activeSpaceProvider.overrideWith((ref) => Stream.value(space)),
        mySpacesProvider.overrideWith((ref) => Stream.value([space])),
        activeSpaceMembersProvider
            .overrideWith((ref) => Stream.value([avaRow, samRow])),
        // The membership-key lookup behind this role source reads real Isar;
        // the fixture already carries the Owner row it would resolve to.
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
            .overrideWithValue(SpacesRepository(harness.isar)),
        profileSwitcherControllerProvider
            .overrideWithValue(const _StubProfileController()),
      ],
    );
    addTearDown(container.dispose);

    // The section never watches the active-profile stream itself (its role
    // source is stubbed above), but the manage handlers read its value — start
    // it now so those reads are not still AsyncLoading when they happen.
    container.read(activeProfileProvider);
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
      'the Members list shows real names for the identity-keyed Owner and '
      'the paired Editor', (WidgetTester tester) async {
    await tester.runAsync(buildFixture);
    await pumpSection(tester, buildContainer());

    expect(find.text('Members'), findsOneWidget);
    expect(
      find.text('Ava'),
      findsOneWidget,
      reason: 'the Owner row resolves the identity-keyed local profile',
    );
    expect(find.text('Owner'), findsOneWidget);
    expect(
      find.text('Sam'),
      findsOneWidget,
      reason: 'the Editor row resolves the paired peer\'s username',
    );
    expect(find.text('Editor'), findsOneWidget);
    expect(
      find.text('Profile'),
      findsNothing,
      reason: 'no row falls back to the placeholder name',
    );

    await tester.runAsync(harness.close);
  });

  testWidgets('the remove confirmation names the member being removed',
      (WidgetTester tester) async {
    await tester.runAsync(buildFixture);
    final container = buildContainer();
    await pumpSection(tester, container);

    await tester.ensureVisible(find.byTooltip('Manage member'));
    await tester.tap(find.byTooltip('Manage member'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('removeMember_${samRow.profileId}')));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Sam loses access to Home'),
      findsOneWidget,
      reason: 'the confirmation names the member instead of "This member"',
    );

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    await tester.runAsync(harness.close);
  });

  testWidgets('the transfer-ownership dialog lists members by real name',
      (WidgetTester tester) async {
    await tester.runAsync(buildFixture);
    final container = buildContainer();
    await pumpSection(tester, container);

    final transferButton = find.byKey(const Key('transferOwnershipButton'));
    await tester.ensureVisible(transferButton);
    await tester.tap(transferButton);
    await tester.pumpAndSettle();

    expect(
      find.byKey(Key('transferOwnership_${samRow.profileId}')),
      findsOneWidget,
      reason: 'the dialog is open and offers the paired member',
    );
    expect(
      find.descendant(
        of: find.byKey(Key('transferOwnership_${samRow.profileId}')),
        matching: find.text('Sam'),
      ),
      findsOneWidget,
      reason: 'the transfer list resolves the paired peer\'s username',
    );
    expect(
      find.descendant(
        of: find.byKey(Key('transferOwnership_${avaRow.profileId}')),
        matching: find.text('Ava'),
      ),
      findsOneWidget,
      reason: 'the local profile resolves under its identity key',
    );
    expect(
      find.text('Profile'),
      findsNothing,
      reason: 'no row falls back to the placeholder name',
    );

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

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
