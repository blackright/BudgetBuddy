import 'package:budget_buddy/core/models/paired_context.dart';
import 'package:budget_buddy/core/models/paired_peer.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/core/models/sync_cursor.dart';
import 'package:budget_buddy/features/pairing/domain/pairing_protocol.dart';
import 'package:budget_buddy/features/pairing/repositories/pairing_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'support/pairing_harness.dart';

/// US7 (T058): the space-independent identity pairing.
///
/// Covers the identity payload round-trip (no space, no role), the mutual
/// `PairedPeer` persistence from an offline QR round-trip, and the refusals
/// that keep a stale or tampered code from creating a contact.
void main() {
  final t0 = DateTime.utc(2026, 3, 5, 12);

  group('identity payload round-trip (T059)', () {
    test('an identity code is discriminated from a space invite', () async {
      final alice = await PairingTestHarness.create();
      addTearDown(alice.close);

      final raw = alice.service.createIdentityInvite().payload.encode();

      expect(pairingCodeKindOf(raw), PairingCodeKind.identity);
      expect(pairingCodeKindOf('not json'), isNull);
    });

    test('encodes identity material with no space and no role', () async {
      final alice = await PairingTestHarness.create(username: 'Alice');
      addTearDown(alice.close);

      final invite = alice.service.createIdentityInvite(now: t0);
      final raw = invite.payload.encode();

      // It must be a *different* kind of code: no space and no role fields.
      expect(raw, contains('buddy.identity'));
      expect(raw, isNot(contains('spaceId')));
      expect(raw, isNot(contains('offeredRole')));

      final parsed = await alice.service.parseIdentityPayload(raw, now: t0);
      expect(parsed.identityId, alice.identity.fingerprint);
      expect(parsed.username, 'Alice');
      expect(parsed.fingerprint, alice.identity.fingerprint);
      expect(parsed.token, invite.token);
      expect(parsed.expiresAt, t0.add(PairingService.defaultTtl));
    });
  });

  group('identity code refusals (T059/T058)', () {
    test('an expired identity code is refused', () async {
      final alice = await PairingTestHarness.create();
      addTearDown(alice.close);

      final raw = alice.service.createIdentityInvite(now: t0).payload.encode();
      final afterTtl = t0.add(PairingService.defaultTtl);

      await expectLater(
        alice.service.parseIdentityPayload(raw, now: afterTtl),
        throwsA(
          isA<PairingException>()
              .having((e) => e.message, 'message', contains('expired')),
        ),
      );
    });

    test('a tampered identity code is refused', () async {
      final alice = await PairingTestHarness.create();
      addTearDown(alice.close);

      final invite = alice.service.createIdentityInvite(now: t0);
      final raw = invite.payload
          .encode()
          .replaceFirst(invite.payload.fingerprint, 'deadbeefdeadbeef');

      await expectLater(
        alice.service.parseIdentityPayload(raw, now: t0),
        throwsA(
          isA<PairingException>()
              .having((e) => e.message, 'message', contains('tampered')),
        ),
      );
    });

    test('a space invite is refused as an identity code', () async {
      final alice = await PairingTestHarness.create();
      addTearDown(alice.close);

      final spaceId = await alice.ownSpace();
      final invite = await alice.service.createInvite(
          spaceId: spaceId, offeredRole: SharedMemberRole.editor, now: t0);

      await expectLater(
        alice.service.parseIdentityPayload(invite.payload.encode(), now: t0),
        throwsA(
          isA<PairingException>()
              .having((e) => e.message, 'message', contains('unsupported')),
        ),
      );
    });

    test('a reply that is not a BudgetBuddy code is refused', () async {
      final alice = await PairingTestHarness.create();
      addTearDown(alice.close);

      expect(
        () => alice.service.parseIdentityClaim('hello'),
        throwsA(
          isA<PairingException>()
              .having((e) => e.message, 'message', contains('reply code')),
        ),
      );
    });
  });

  group('offline QR round-trip (T060)', () {
    test('scan-adds-contact: both sides persist each other', () async {
      final alice = await PairingTestHarness.create(username: 'Alice');
      final bob = await PairingTestHarness.create(username: 'Bob');
      addTearDown(alice.close);
      addTearDown(bob.close);

      // Presenter: Alice shows her code.
      final invite = alice.service.createIdentityInvite(now: t0);

      // Scanner: Bob scans it, confirms, and persists Alice.
      final scanned = await bob.service
          .parseIdentityPayload(invite.payload.encode(), now: t0);
      final addedAlice = await bob.service.acceptIdentityPayload(scanned);
      expect(addedAlice.peerUsername, 'Alice');

      // Bob replies with his own code.
      final reply = bob.service.identityClaimFrom(scanned);

      // Presenter: Alice scans the reply and persists Bob.
      final claim = alice.service.parseIdentityClaim(reply.encode());
      final addedBob = await alice.service.handleIdentityClaim(
        invite.payload,
        claim,
        now: t0,
      );
      expect(addedBob.peerUsername, 'Bob');

      // Mutual persistence on both sides.
      final alicePeers = await alice.sync.isar.pairedPeers.where().findAll();
      expect(alicePeers.map((p) => p.peerUsername), contains('Bob'));
      expect(alicePeers.first.peerIdentityId, bob.identity.fingerprint);

      final bobPeers = await bob.sync.isar.pairedPeers.where().findAll();
      expect(bobPeers.map((p) => p.peerUsername), contains('Alice'));
      expect(bobPeers.first.peerIdentityId, alice.identity.fingerprint);

      // An identity pairing shares no data: no spaces, contexts or members.
      expect(await alice.sync.isar.sharedMembers.where().findAll(), isEmpty);
      expect(await alice.sync.isar.pairedContexts.where().findAll(), isEmpty);
      expect(await alice.sync.isar.syncCursors.where().findAll(), isEmpty);
    });

    test('re-scanning the same code refreshes the contact, not a duplicate',
        () async {
      final alice = await PairingTestHarness.create(username: 'Alice');
      final bob = await PairingTestHarness.create(username: 'Bob');
      addTearDown(alice.close);
      addTearDown(bob.close);

      final invite = alice.service.createIdentityInvite(now: t0);
      final scanned = await bob.service
          .parseIdentityPayload(invite.payload.encode(), now: t0);

      await bob.service.acceptIdentityPayload(scanned);
      await bob.service.acceptIdentityPayload(scanned);

      final bobPeers = await bob.sync.isar.pairedPeers.where().findAll();
      expect(bobPeers, hasLength(1));
    });

    test('a reply for a different code is refused', () async {
      final alice = await PairingTestHarness.create(username: 'Alice');
      final bob = await PairingTestHarness.create(username: 'Bob');
      addTearDown(alice.close);
      addTearDown(bob.close);

      final first = alice.service.createIdentityInvite(now: t0);
      final second = alice.service.createIdentityInvite(now: t0);

      // Bob reads the *second* code, so his token does not match the first.
      final scanned = await bob.service
          .parseIdentityPayload(second.payload.encode(), now: t0);
      final reply = bob.service.identityClaimFrom(scanned);

      final claim = alice.service.parseIdentityClaim(reply.encode());
      await expectLater(
        alice.service.handleIdentityClaim(first.payload, claim, now: t0),
        throwsA(
          isA<PairingException>()
              .having((e) => e.message, 'message', contains('different code')),
        ),
      );
    });

    test('a reply whose key does not match its fingerprint is refused',
        () async {
      final alice = await PairingTestHarness.create(username: 'Alice');
      final bob = await PairingTestHarness.create(username: 'Bob');
      addTearDown(alice.close);
      addTearDown(bob.close);

      final invite = alice.service.createIdentityInvite(now: t0);
      final scanned = await bob.service
          .parseIdentityPayload(invite.payload.encode(), now: t0);

      final tampered = PairingClaim(
        token: invite.token,
        scannerIdentityId: 'deadbeefdeadbeef',
        scannerPublicKey:
            bob.service.identityClaimFrom(scanned).scannerPublicKey,
        scannerUsername: 'Bob',
      );

      await expectLater(
        alice.service.handleIdentityClaim(invite.payload, tampered, now: t0),
        throwsA(
          isA<PairingException>()
              .having((e) => e.message, 'message', contains('does not match')),
        ),
      );
    });
  });

  group('add a paired contact to a space (T064/T058)', () {
    test('grants membership, an active context and a sync cursor', () async {
      final alice = await PairingTestHarness.create(username: 'Alice');
      final bob = await PairingTestHarness.create(username: 'Bob');
      addTearDown(alice.close);
      addTearDown(bob.close);

      final spaceId = await alice.ownSpace();

      // Bob is already a contact: the offline QR round-trip happened earlier.
      final invite = bob.service.createIdentityInvite(now: t0);
      final peer =
          await alice.service.acceptIdentityPayload(invite.payload, now: t0);

      final member = await alice.service.addContactToSpace(
        spaceId: spaceId,
        peerIdentityId: peer.peerIdentityId,
        role: SharedMemberRole.editor,
        now: t0,
      );

      // Keyed by the deterministic remote id, so the signed membership
      // converges on every device (FR-016).
      expect(member.profileId, remoteProfileIdFor(peer.peerIdentityId));
      expect(member.role, SharedMemberRole.editor);
      expect(member.revokedAt, isNull);
      expect(member.signature, isNotNull);

      final contexts = await alice.sync.isar.pairedContexts.where().findAll();
      expect(contexts, hasLength(1));
      expect(contexts.single.contextLocalId, spaceId);
      expect(contexts.single.active, isTrue);
      expect(contexts.single.peerRole, SharedMemberRole.editor);

      final cursors = await alice.sync.isar.syncCursors.where().findAll();
      expect(cursors, hasLength(1));
      expect(cursors.single.contextLocalId, spaceId);
      expect(cursors.single.peerId, contexts.single.peerId);
    });

    test('refuses someone who is not a contact and writes nothing', () async {
      final alice = await PairingTestHarness.create(username: 'Alice');
      addTearDown(alice.close);
      final spaceId = await alice.ownSpace();

      await expectLater(
        alice.service.addContactToSpace(
          spaceId: spaceId,
          peerIdentityId: 'deadbeefdeadbeef',
          role: SharedMemberRole.viewer,
          now: t0,
        ),
        throwsA(
          isA<PairingException>().having((e) => e.message, 'message',
              contains('not one of your contacts')),
        ),
      );

      // Only the Owner's own membership remains.
      final members = await alice.sync.isar.sharedMembers.where().findAll();
      expect(members, hasLength(1));
      expect(await alice.sync.isar.syncCursors.where().findAll(), isEmpty);
    });

    test('refuses adding the same person twice (I2)', () async {
      final alice = await PairingTestHarness.create(username: 'Alice');
      final bob = await PairingTestHarness.create(username: 'Bob');
      addTearDown(alice.close);
      addTearDown(bob.close);
      final spaceId = await alice.ownSpace();
      final invite = bob.service.createIdentityInvite(now: t0);
      final peer =
          await alice.service.acceptIdentityPayload(invite.payload, now: t0);

      await alice.service.addContactToSpace(
        spaceId: spaceId,
        peerIdentityId: peer.peerIdentityId,
        role: SharedMemberRole.viewer,
        now: t0,
      );

      await expectLater(
        alice.service.addContactToSpace(
          spaceId: spaceId,
          peerIdentityId: peer.peerIdentityId,
          role: SharedMemberRole.editor,
          now: t0,
        ),
        throwsA(
          isA<PairingException>().having(
              (e) => e.message, 'message', contains('already in this space')),
        ),
      );
    });
  });
}
