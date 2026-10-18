import 'package:budget_buddy/core/models/paired_peer.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/features/pairing/domain/pairing_protocol.dart';
import 'package:budget_buddy/features/pairing/presentation/widgets/scan_error_panel.dart';
import 'package:budget_buddy/features/pairing/providers/pairing_providers.dart';
import 'package:budget_buddy/features/pairing/repositories/pairing_service.dart';
import 'package:budget_buddy/features/spaces/presentation/scan_contact_into_space_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Doubles the signing service as "the identity stayed locked", which is the
/// refusal path this screen must latch (T073: a locked identity is retryable,
/// so the latch is what stops the camera rather than a sticky provider state).
class _LockedSigningService implements SigningPairingService {
  const _LockedSigningService();

  @override
  Future<PairingService?> call({required String reason}) async => null;
}

/// Wraps a hand-rolled [PairingService] double as the signing service.
class _FakeSigningService implements SigningPairingService {
  const _FakeSigningService(this.service);

  final PairingService service;

  @override
  Future<PairingService?> call({required String reason}) async => service;
}

/// A [PairingService] that never touches Isar, so a widget test can drive the
/// whole "scan an identity code, add them to the space" flow under the fake
/// clock. Only the four members the screen calls are real; anything else falls
/// through to `noSuchMethod`.
class _FakePairingService implements PairingService {
  _FakePairingService(this.payload);

  final PairingIdentityPayload payload;

  bool addedToSpace = false;
  bool replyRequested = false;

  @override
  Future<PairingIdentityPayload> parseIdentityPayload(
    String raw, {
    DateTime? now,
  }) async =>
      payload;

  @override
  Future<PairedPeer> acceptIdentityPayload(
    PairingIdentityPayload payload, {
    DateTime? now,
  }) async =>
      PairedPeer()
        ..peerIdentityId = payload.identityId
        ..peerUsername = payload.username
        ..peerPublicKey = payload.publicKey
        ..peerFingerprint = payload.fingerprint
        ..pairedAt = DateTime.utc(2026, 3, 5);

  @override
  Future<SharedMember> addContactToSpace({
    required int spaceId,
    required String peerIdentityId,
    required SharedMemberRole role,
    DateTime? now,
  }) async {
    addedToSpace = true;
    return SharedMember()
      ..sharedSpaceId = spaceId
      ..profileId = 1
      ..role = role
      ..joinedAt = DateTime.utc(2026, 3, 5);
  }

  @override
  PairingClaim identityClaimFrom(PairingIdentityPayload payload) {
    replyRequested = true;
    return PairingClaim(
      token: payload.token,
      scannerIdentityId: 'me',
      scannerPublicKey: 'me',
      scannerUsername: 'Me',
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// US7 (T064): scanning a person into a space reuses the **latched** refusal
/// introduced for the People flow, so a wrong code cannot flood the screen.
void main() {
  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // The refusal path never unlocks the identity, so nothing Isar-backed
          // is touched here.
          signingPairingServiceProvider
              .overrideWith((ref) => const _LockedSigningService()),
        ],
        child: const MaterialApp(
          home: ScanContactIntoSpaceScreen(spaceId: 1, spaceName: 'Home'),
        ),
      ),
    );
    await tester.pump();
  }

  ScanContactIntoSpaceScreenState stateOf(WidgetTester tester) =>
      tester.state<ScanContactIntoSpaceScreenState>(
        find.byType(ScanContactIntoSpaceScreen),
      );

  testWidgets('a wrong code latches, stops the camera and can be retried',
      (tester) async {
    await pumpScreen(tester);
    expect(find.byKey(const Key('addToSpaceScanner')), findsOneWidget);

    final state = stateOf(tester);
    await state.handleScanned('not json at all');
    await tester.pump();

    expect(find.byType(ScanErrorPanel), findsOneWidget);
    expect(find.byKey(const Key('scanErrorMessage')), findsOneWidget);
    expect(find.byKey(const Key('addToSpaceScanner')), findsNothing);

    // Repeating the bad scan must not stack a second message.
    await state.handleScanned('still not json');
    await tester.pump();
    expect(find.byType(ScanErrorPanel), findsOneWidget);
    expect(find.byKey(const Key('scanErrorMessage')), findsOneWidget);

    // Scan again brings the camera back.
    await tester.tap(find.byKey(const Key('scanAgainButton')));
    await tester.pump();
    expect(find.byType(ScanErrorPanel), findsNothing);
    expect(find.byKey(const Key('addToSpaceScanner')), findsOneWidget);
  });

  testWidgets(
      'a successful scan shows a reply code so the other phone can become a contact too',
      (tester) async {
    final payload = PairingIdentityPayload(
      identityId: 'bob',
      username: 'Bob',
      publicKey: 'pk',
      fingerprint: 'bob',
      token: 'tok',
      expiresAt: DateTime.utc(2026, 3, 5, 12, 5),
    );
    final service = _FakePairingService(payload);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          signingPairingServiceProvider
              .overrideWith((ref) => _FakeSigningService(service)),
        ],
        child: const MaterialApp(
          home: ScanContactIntoSpaceScreen(spaceId: 1, spaceName: 'Home'),
        ),
      ),
    );
    await tester.pump();

    final state = stateOf(tester);
    final done = state.handleScanned(payload.encode());
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.byKey(const Key('confirmAddToSpaceButton')));
    await tester.pump();
    for (var i = 0; i < 10 && !service.replyRequested; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await done;

    expect(service.addedToSpace, isTrue, reason: 'the membership is granted');
    // The bug this guards: the scan used to be one-way — the other phone never
    // learned about us. A reply code is what makes the pairing mutual.
    expect(service.replyRequested, isTrue);
    expect(find.byKey(const Key('addToSpaceSuccess')), findsOneWidget);
    expect(find.byKey(const Key('addToSpaceReplyQr')), findsOneWidget);
  });
}
