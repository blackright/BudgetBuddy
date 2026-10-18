import 'package:budget_buddy/core/models/identity.dart';
import 'package:budget_buddy/core/models/paired_peer.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/identity_provider.dart';
import 'package:budget_buddy/features/identity/domain/identity_profile_key.dart';
import 'package:budget_buddy/features/pairing/presentation/people_screen.dart';
import 'package:budget_buddy/features/pairing/providers/pairing_providers.dart';
import 'package:budget_buddy/features/pairing/repositories/pairing_service.dart';
import 'package:budget_buddy/features/spaces/repositories/space_role_guard.dart';
import 'package:budget_buddy/features/spaces/repositories/spaces_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../medical/repositories/medical_test_harness.dart';

/// The widget half of T078 — the **guard rails** around removal, not the data
/// layer itself (the real `forgetPeer`/`removeMember` writes are covered by
/// `forget_peer_test.dart` and `create_space_with_identity_test.dart`).
///
/// Reads and writes are fakes on purpose: real Isar I/O cannot run under the
/// widget-test fake clock, so the screen is driven against recorded doubles and
/// we assert on what it *asked* the repositories to do.
const String _peerIdentityId = 'PEER';
const String _peerName = 'Bob';

class _RecordingPairingService extends PairingService {
  _RecordingPairingService(super.isar, {required super.identity});

  final List<String> forgotten = [];

  @override
  Future<void> forgetPeer({required String peerIdentityId}) async {
    forgotten.add(peerIdentityId);
  }
}

class _RecordingSpacesRepository extends SpacesRepository {
  _RecordingSpacesRepository(super.isar);

  /// Space ids where the acting profile is **not** the Owner.
  final Set<int> refuses = {};

  final List<({int spaceId, int profileId})> revoked = [];

  /// Every call the screen made, refused or not — so a test can tell "the
  /// refusal was reported" apart from "no authority was resolved at all".
  final List<({int spaceId, int profileId})> attempted = [];

  @override
  Future<void> removeMember({
    required int actingProfileId,
    required int spaceId,
    required int profileId,
  }) async {
    attempted.add((spaceId: spaceId, profileId: profileId));
    if (refuses.contains(spaceId)) {
      throw const UnauthorizedSpaceAction(
        'a space must always have at least one Owner; transfer ownership '
        'first (FR-006/FR-014)',
      );
    }
    revoked.add((spaceId: spaceId, profileId: profileId));
  }
}

void main() {
  late MedicalTestHarness harness;
  late Identity identity;
  late UserProfile profile;
  late PairedPeer peer;
  late _RecordingPairingService pairingService;
  late _RecordingSpacesRepository spacesRepository;

  const spaceId = 7;
  final now = DateTime(2026, 3, 5, 12);

  setUp(() async {
    harness = await MedicalTestHarness.create();

    profile = UserProfile()
      ..name = 'Me'
      ..primaryCurrency = PrimaryCurrency.usd
      ..monthlyAvailableAmount = 0
      ..createdAt = now
      ..updatedAt = now;
    profile.id = await harness.isar.writeTxn(
      () => harness.isar.userProfiles.put(profile),
    );

    identity = Identity()
      ..username = 'Alice'
      ..publicKey = 'pk'
      ..fingerprint = 'OWNER_FINGERPRINT'
      ..localProfileId = profile.id
      ..createdAt = now
      ..updatedAt = now;

    peer = PairedPeer()
      ..peerIdentityId = _peerIdentityId
      ..peerUsername = _peerName
      ..peerPublicKey = 'pk'
      ..peerFingerprint = 'BOBFINGER'
      ..pairedAt = now;

    pairingService = _RecordingPairingService(harness.isar, identity: identity);
    spacesRepository = _RecordingSpacesRepository(harness.isar);
  });

  tearDown(() => harness.close());

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          identityProvider.overrideWith((ref) => Stream.value(identity)),
          activeProfileProvider.overrideWith((ref) => Stream.value(profile)),
          contactsProvider.overrideWith(
            (ref) => Stream.value([
              Contact(
                peer: peer,
                sharedSpaceNames: const ['Home'],
                sharedSpaceIds: const [spaceId],
              ),
            ]),
          ),
          pairingServiceProvider.overrideWithValue(pairingService),
          spacesRepositoryProvider.overrideWithValue(spacesRepository),
        ],
        child: const MaterialApp(home: PeopleScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openRemoveDialog(WidgetTester tester) async {
    await tester
        .tap(find.byKey(const Key('peopleContactMenu_$_peerIdentityId')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('removePerson_$_peerIdentityId')));
    await tester.pumpAndSettle();
  }

  testWidgets('the contact offers a Remove person action', (tester) async {
    await pump(tester);

    expect(find.text('$_peerName (BOBFINGER)'), findsOneWidget);
    await tester
        .tap(find.byKey(const Key('peopleContactMenu_$_peerIdentityId')));
    await tester.pumpAndSettle();

    expect(find.text('Remove person'), findsOneWidget);
  });

  testWidgets('removal asks first, and cancelling changes nothing',
      (tester) async {
    await pump(tester);
    await openRemoveDialog(tester);

    expect(find.text('Remove this person?'), findsOneWidget,
        reason: 'a stray tap must never drop somebody');
    expect(find.textContaining('Home'), findsWidgets,
        reason: 'the dialog says which spaces it will act on');

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(spacesRepository.revoked, isEmpty);
    expect(pairingService.forgotten, isEmpty);
  });

  testWidgets(
      'confirming revokes the membership, then forgets the peer and reports it',
      (tester) async {
    await pump(tester);
    await openRemoveDialog(tester);

    await tester.tap(find.byKey(const Key('confirmRemovePersonButton')));
    await tester.pumpAndSettle();

    expect(
      spacesRepository.revoked,
      [(spaceId: spaceId, profileId: remoteProfileIdFor(_peerIdentityId))],
      reason: 'the Owner revokes them from the shared space',
    );
    expect(pairingService.forgotten, [_peerIdentityId],
        reason: 'and the person leaves the People list');
    expect(find.text('Removed $_peerName.'), findsOneWidget);
  });

  testWidgets(
      'a space the acting profile does not own is left alone and said so',
      (tester) async {
    spacesRepository.refuses.add(spaceId);
    await pump(tester);
    await openRemoveDialog(tester);

    await tester.tap(find.byKey(const Key('confirmRemovePersonButton')));
    await tester.pumpAndSettle();

    expect(spacesRepository.revoked, isEmpty,
        reason: 'we have no authority to change that membership');
    expect(
      spacesRepository.attempted,
      [(spaceId: spaceId, profileId: remoteProfileIdFor(_peerIdentityId))],
      reason: 'we did try, and were refused — not "never asked"',
    );
    expect(pairingService.forgotten, [_peerIdentityId],
        reason: 'but we still stop syncing with them here');
    expect(
      find.textContaining('not the Owner of Home'),
      findsOneWidget,
      reason: 'the outcome is never silently over-stated',
    );
  });
}
