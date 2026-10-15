import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/features/pairing/domain/pairing_protocol.dart';
import 'package:flutter_test/flutter_test.dart';

import '../sync/support/change_factory.dart';
import 'support/pairing_harness.dart';

/// FR-005 / SC-006: pairings are single-use, expirable, cancellable and never
/// duplicated.
void main() {
  late PairingTestHarness harness;

  setUp(() async {
    harness = await PairingTestHarness.create();
  });

  tearDown(() async => harness.close());

  Future<int> space() => harness.ownSpace();

  test('a token is single-use: a second claim with the same token is refused',
      () async {
    final invite = await harness.service.createInvite(
      spaceId: await space(),
      offeredRole: SharedMemberRole.editor,
    );
    final claim = await scannerClaim(invite.token);

    await harness.service.handleClaim(claim);

    expect(
      () => harness.service.handleClaim(claim),
      throwsA(isA<PairingException>().having(
        (e) => e.message,
        'message',
        contains('already used'),
      )),
    );
  });

  test('an expired token is refused and the Owner must show a new QR',
      () async {
    final invite = await harness.service.createInvite(
      spaceId: await space(),
      offeredRole: SharedMemberRole.editor,
      ttl: const Duration(seconds: 120),
    );
    final claim = await scannerClaim(invite.token);
    final afterExpiry =
        invite.payload.expiresAt.add(const Duration(seconds: 1));

    expect(
      () => harness.service.handleClaim(claim, now: afterExpiry),
      throwsA(isA<PairingException>().having(
        (e) => e.message,
        'message',
        contains('expired'),
      )),
    );
  });

  test('cancelling an invite invalidates the outstanding token', () async {
    final invite = await harness.service.createInvite(
      spaceId: await space(),
      offeredRole: SharedMemberRole.viewer,
    );
    await harness.service.cancelInvite(token: invite.token);
    final claim = await scannerClaim(invite.token);

    expect(
      () => harness.service.handleClaim(claim),
      throwsA(isA<PairingException>().having(
        (e) => e.message,
        'message',
        contains('cancelled'),
      )),
    );
  });

  test('showing a new QR invalidates the previous one (remake)', () async {
    final first = await harness.service.createInvite(
      spaceId: await space(),
      offeredRole: SharedMemberRole.editor,
    );
    await harness.service.createInvite(
      spaceId: first.payload.spaceId,
      offeredRole: SharedMemberRole.editor,
    );
    final staleClaim = await scannerClaim(first.token);

    expect(
      () => harness.service.handleClaim(staleClaim),
      throwsA(isA<PairingException>()),
    );
  });

  test('a completed pairing makes a second pairing of the same peer refused',
      () async {
    final spaceId = await space();
    final scanner = await DeviceKeys.generate('__scanner__');

    final first = await harness.service
        .createInvite(spaceId: spaceId, offeredRole: SharedMemberRole.editor);
    await harness.service
        .handleClaim(await scannerClaim(first.token, scanner: scanner));

    final second = await harness.service
        .createInvite(spaceId: spaceId, offeredRole: SharedMemberRole.viewer);
    final secondClaim = await scannerClaim(second.token, scanner: scanner);

    expect(
      () => harness.service.handleClaim(secondClaim),
      throwsA(isA<PairingException>().having(
        (e) => e.message,
        'message',
        contains('already paired'),
      )),
    );
  });
}
