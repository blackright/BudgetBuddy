import 'package:budget_buddy/core/models/paired_context.dart';
import 'package:budget_buddy/core/models/paired_peer.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/features/pairing/domain/pairing_protocol.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import '../sync/support/change_factory.dart';
import 'support/pairing_harness.dart';

/// T078: removing a person must actually be a removal.
///
/// `unpair` only deactivated the paired contexts, so an unpaired person lingered
/// in People forever with no way to get rid of them. `forgetPeer` deactivates
/// the contexts **and** drops the peer row, while leaving every row of local
/// data (and the membership the Owner can still revoke) untouched: removing a
/// person never destroys money.
void main() {
  late PairingTestHarness harness;

  setUp(() async {
    harness = await PairingTestHarness.create();
  });

  tearDown(() async => harness.close());

  test('forgetPeer drops the peer row and deactivates every context', () async {
    final spaceId = await harness.ownSpace();
    final scanner = await DeviceKeys.generate('__scanner__');
    final fingerprint = await fingerprintOfKey(scanner);

    final invite = await harness.service.createInvite(
      spaceId: spaceId,
      offeredRole: SharedMemberRole.viewer,
    );
    await harness.service
        .handleClaim(await scannerClaim(invite.token, scanner: scanner));

    final isar = harness.sync.isar;
    final peer = await isar.pairedPeers
        .filter()
        .peerIdentityIdEqualTo(fingerprint)
        .findFirst();
    expect(peer, isNotNull, reason: 'the pairing was recorded');
    final memberKey = remoteProfileIdFor(fingerprint);

    await harness.service.forgetPeer(peerIdentityId: fingerprint);

    expect(
      await isar.pairedPeers
          .filter()
          .peerIdentityIdEqualTo(fingerprint)
          .findFirst(),
      isNull,
      reason: 'the person leaves the People list',
    );

    final contexts =
        await isar.pairedContexts.filter().peerIdEqualTo(peer!.id).findAll();
    expect(contexts, isNotEmpty);
    expect(contexts.any((context) => context.active), isFalse,
        reason: 'nothing is exchanged with a removed person any more');

    // The granted membership is still there — the Owner revokes it explicitly,
    // and the money the pair already shared must survive the removal.
    final membership = await isar.sharedMembers
        .filter()
        .sharedSpaceIdEqualTo(spaceId)
        .and()
        .profileIdEqualTo(memberKey)
        .findFirst();
    expect(membership, isNotNull);
  });

  test('forgetPeer ignores an identity that was never paired', () async {
    await expectLater(
      harness.service.forgetPeer(peerIdentityId: 'never-paired'),
      completes,
    );
  });
}
