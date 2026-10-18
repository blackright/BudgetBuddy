import 'package:budget_buddy/core/models/change_record.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/features/spaces/domain/shared_member_key.dart';
import 'package:budget_buddy/features/sync/domain/codecs/shared_member_codec.dart';
import 'package:budget_buddy/features/sync/domain/codecs/shared_space_codec.dart';
import 'package:budget_buddy/features/sync/domain/sync_codec.dart';
import 'package:budget_buddy/features/sync/domain/sync_guid.dart';
import 'package:budget_buddy/features/sync/repositories/sync_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'support/change_factory.dart';
import 'support/fake_transport.dart';
import 'support/sync_harness.dart';

/// T070: a paired peer cannot plant a space this device was never added to. A
/// snapshot naming an unknown `contextSyncGuid` bootstraps an anchor, and the
/// T069 guard must discard it (and any membership rows) rather than let the peer
/// litter the database.
void main() {
  late SyncTestHarness harnessB;
  late SyncTestHarness attacker;
  late DeviceKeys keysB;
  late DeviceKeys keysBad;
  late SyncEngine engineB;
  late SyncEngine engineAttacker;

  setUp(() async {
    harnessB = await SyncTestHarness.create();
    attacker = await SyncTestHarness.create();
    keysB = await DeviceKeys.generate('idB');
    keysBad = await DeviceKeys.generate('idBad');

    engineB = SyncEngine(harnessB.isar,
        trustedKeys: {
          keysB.identityId: keysB.publicKey,
          keysBad.identityId: keysBad.publicKey,
        },
        selfIdentityId: keysB.identityId);
    engineAttacker = SyncEngine(attacker.isar,
        trustedKeys: {keysBad.identityId: keysBad.publicKey},
        selfIdentityId: keysBad.identityId);

    // B genuinely belongs to one real space.
    await harnessB.createSpaceAt(
        localId: 1, name: 'Real', syncGuid: newSyncGuid());
    await harnessB.addMember(
        spaceId: 1,
        profileId: sharedMemberKey(keysB.identityId),
        role: SharedMemberRole.owner);
  });

  tearDown(() async {
    await harnessB.close();
    await attacker.close();
  });

  test('a foreign GUID creates nothing on the receiving phone', () async {
    final foreignGuid = newSyncGuid();

    final spaceModel = SharedSpace()
      ..syncGuid = foreignGuid
      ..name = 'Junk'
      ..currency = PrimaryCurrency.usd
      ..createdByProfileId = 0
      ..createdAt = DateTime(2026);
    final spaceRec = await signedChange(
      keys: keysBad,
      deviceId: 'atk',
      hlcMillis: 1000,
      entityType: 'SharedSpace',
      entitySyncGuid: foreignGuid,
      contextSyncGuid: foreignGuid,
      contextLocalId: 1,
      payload: const SharedSpaceCodec().toPayload(spaceModel),
    );

    final memberModel = SharedMember()
      ..syncGuid = newSyncGuid()
      ..sharedSpaceId = 1
      ..profileId = sharedMemberKey(keysBad.identityId)
      ..role = SharedMemberRole.owner
      ..joinedAt = DateTime(2026)
      ..version = 1
      ..updatedAt = DateTime(2026)
      ..authorIdentityId = keysBad.identityId;
    final memberJson = const SharedMemberCodec().toJson(memberModel);
    memberJson['sharedSpaceSyncGuid'] = foreignGuid;
    final memberRec = await signedChange(
      keys: keysBad,
      deviceId: 'atk',
      hlcMillis: 1001,
      entityType: 'SharedMember',
      entitySyncGuid: memberModel.syncGuid,
      contextSyncGuid: foreignGuid,
      contextLocalId: 1,
      payload: canonicalJsonEncode(memberJson),
    );

    await attacker.isar.writeTxn(() async {
      await attacker.isar.changeRecords.put(spaceRec);
      await attacker.isar.changeRecords.put(memberRec);
    });

    // The attacker dials B and sends the junk snapshot over one shared hub.
    final hub = FakeTransportHub();
    final endpointBad = hub.endpoint('idBad', username: 'Bad');
    hub.endpoint('idB', username: 'B');
    final bAdv = hub.advertisements().firstWhere((a) => a.identityId == 'idB');
    final incoming = hub.nextIncoming('idB');
    final cBad = await endpointBad.connect(bAdv);
    final cB = await incoming;
    final aF =
        engineAttacker.exchange(cBad, contextLocalId: 1, initiator: true);
    final bF = engineB.exchange(cB, contextLocalId: 0);
    await Future.wait([aF, bF]);
    await cBad.close();
    await cB.close();

    // Only B's real space survives; the foreign one was discarded whole.
    final spaces = await harnessB.isar.sharedSpaces.where().findAll();
    expect(spaces.map((s) => s.syncGuid), isNot(contains(foreignGuid)));
    expect(spaces.length, 1);
    expect(spaces.single.name, 'Real');
    expect((await harnessB.isar.sharedMembers.where().findAll()).length, 1,
        reason: 'no attacker membership row survives');
  });
}
