import 'dart:convert';

import 'package:budget_buddy/core/models/context_kind.dart';
import 'package:budget_buddy/core/models/paired_context.dart';
import 'package:budget_buddy/core/models/paired_peer.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/core/models/sync_cursor.dart';
import 'package:budget_buddy/features/pairing/domain/pairing_protocol.dart';
import 'package:budget_buddy/features/sync/domain/change_signing.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import '../sync/support/change_factory.dart';
import 'support/pairing_harness.dart';

/// FR-004 / FR-005: a claim binds the peer's username to its key, persists the
/// pairing, and grants a signed membership with the offered role; a tampered
/// fingerprint is refused with nothing written.
void main() {
  late PairingTestHarness harness;

  setUp(() async {
    harness = await PairingTestHarness.create();
  });

  tearDown(() async => harness.close());

  test('a confirmed claim creates PairedPeer, PairedContext and a cursor',
      () async {
    final spaceId = await harness.ownSpace();
    final scanner = await DeviceKeys.generate('__scanner__');
    final scannerFingerprint = await fingerprintOfKey(scanner);

    final invite = await harness.service
        .createInvite(spaceId: spaceId, offeredRole: SharedMemberRole.editor);
    final result = await harness.service
        .handleClaim(await scannerClaim(invite.token, scanner: scanner));

    final isar = harness.sync.isar;
    final peer = await isar.pairedPeers
        .filter()
        .peerIdentityIdEqualTo(scannerFingerprint)
        .findFirst();
    expect(peer, isNotNull);
    expect(peer!.peerPublicKey, base64Encode(scanner.publicKey.bytes));
    expect(peer.peerUsername, 'Bob');

    final context = await isar.pairedContexts
        .filter()
        .peerIdEqualTo(peer.id)
        .contextKindEqualTo(ContextKind.shared)
        .findFirst();
    expect(context, isNotNull);
    expect(context!.contextLocalId, spaceId);
    expect(context.peerRole, SharedMemberRole.editor);
    expect(context.active, isTrue);

    final cursor = await isar.syncCursors
        .filter()
        .peerIdEqualTo(peer.id)
        .contextLocalIdEqualTo(spaceId)
        .findFirst();
    expect(cursor, isNotNull);

    expect(result.membership, isNotNull);
  });

  test(
      'the granted membership carries the offered role and is signed by the '
      'Owner (FR-008)', () async {
    final spaceId = await harness.ownSpace();
    final scanner = await DeviceKeys.generate('__scanner__');
    final scannerFingerprint = await fingerprintOfKey(scanner);

    final invite = await harness.service
        .createInvite(spaceId: spaceId, offeredRole: SharedMemberRole.viewer);
    await harness.service
        .handleClaim(await scannerClaim(invite.token, scanner: scanner));

    final member = await harness.sync.isar.sharedMembers
        .filter()
        .sharedSpaceIdEqualTo(spaceId)
        .profileIdEqualTo(remoteProfileIdFor(scannerFingerprint))
        .findFirst();

    expect(member, isNotNull);
    expect(member!.role, SharedMemberRole.viewer);
    expect(member.authorIdentityId, harness.identity.fingerprint);
    expect(member.version, greaterThan(0));
    expect(member.signature, isNotNull);

    final verified = await Ed25519().verify(
      membershipCanonicalBytes(member),
      signature: Signature(
        base64Decode(member.signature!),
        publicKey: harness.keys.publicKey,
      ),
    );
    expect(verified, isTrue,
        reason: 'membership must verify against the Owner');
  });

  test(
      'a claim whose key disagrees with its fingerprint is refused, nothing '
      'is written (FR-004)', () async {
    final spaceId = await harness.ownSpace();
    final scanner = await DeviceKeys.generate('__scanner__');

    final invite = await harness.service
        .createInvite(spaceId: spaceId, offeredRole: SharedMemberRole.editor);

    final tampered = PairingClaim(
      token: invite.token,
      scannerIdentityId: 'deadbeefdeadbeef',
      scannerPublicKey: base64Encode(scanner.publicKey.bytes),
      scannerUsername: 'Mallory',
    );

    expect(
      () => harness.service.handleClaim(tampered),
      throwsA(isA<PairingException>()),
    );
    expect(await harness.sync.isar.pairedPeers.count(), 0);
    final memberCount = await harness.sync.isar.sharedMembers
        .filter()
        .sharedSpaceIdEqualTo(spaceId)
        .count();
    expect(memberCount, 1, reason: 'only the Owner membership remains');
  });

  test('a tampered QR is refused when the key and fingerprint disagree',
      () async {
    final scanner = await DeviceKeys.generate('__scanner__');
    final honest = PairingPayload(
      identityId: harness.identity.fingerprint,
      username: harness.identity.username,
      publicKey: harness.identity.publicKey,
      fingerprint: harness.identity.fingerprint,
      spaceId: 1,
      offeredRole: SharedMemberRole.editor,
      token: 'tok',
      expiresAt: DateTime.utc(2030),
    );

    final tampered = honest.encode().replaceFirst(
          harness.identity.fingerprint,
          '0123456789abcdef',
        );
    expect(
      () => harness.service.parsePayload(tampered),
      throwsA(isA<PairingException>()),
    );

    final valid = await harness.service.parsePayload(honest.encode());
    expect(valid.username, harness.identity.username);
    expect(scanner.publicKey, isNotNull);
  });

  test('an expired QR is refused at scan time', () async {
    final payload = PairingPayload(
      identityId: harness.identity.fingerprint,
      username: harness.identity.username,
      publicKey: harness.identity.publicKey,
      fingerprint: harness.identity.fingerprint,
      spaceId: 1,
      offeredRole: SharedMemberRole.editor,
      token: 'tok',
      expiresAt: DateTime.utc(2026, 1, 1),
    );

    expect(
      () => harness.service.parsePayload(
        payload.encode(),
        now: DateTime.utc(2026, 6, 1),
      ),
      throwsA(isA<PairingException>().having(
        (e) => e.message,
        'message',
        contains('expired'),
      )),
    );
  });
}
