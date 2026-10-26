import 'dart:convert';
import 'package:budget_buddy/features/sync/domain/change_signing.dart';
import 'package:budget_buddy/features/sync/domain/sync_codec.dart';
import 'package:budget_buddy/core/models/context_kind.dart';
import 'package:budget_buddy/core/models/audit_event.dart';
import 'package:budget_buddy/core/models/change_record.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/services/audit_verify_service.dart';
import 'package:budget_buddy/features/finance/repositories/audit_repository.dart';
import 'package:budget_buddy/features/spaces/domain/shared_member_key.dart';
import 'package:budget_buddy/features/sync/repositories/change_signer.dart';
import 'package:budget_buddy/features/sync/repositories/sync_engine.dart';
import 'package:budget_buddy/features/sync/repositories/sync_recorder.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import '../../features/medical/repositories/medical_test_harness.dart';

void main() {
  test(
      'offline signed chains sync out of order without rewriting authors or duplicates',
      () async {
    final a = await MedicalTestHarness.create(),
        b = await MedicalTestHarness.create();
    addTearDown(a.close);
    addTearDown(b.close);
    final pair = await Ed25519().newKeyPair();
    final key = await pair.extractPublicKey();
    final signer =
        Ed25519ChangeSigner(authorIdentityId: 'alice', keyPair: pair);
    for (final db in [a.isar, b.isar]) {
      await db.writeTxn(() async {
        await db.sharedSpaces.put(SharedSpace()
          ..id = 1
          ..syncGuid = 'space'
          ..name = 'Space'
          ..currency = PrimaryCurrency.huf
          ..createdByProfileId = 1
          ..createdAt = DateTime(2026));
        await db.sharedMembers.put(SharedMember()
          ..sharedSpaceId = 1
          ..profileId = sharedMemberKey('alice')
          ..role = SharedMemberRole.owner
          ..authorIdentityId = 'alice'
          ..joinedAt = DateTime(2026));
      });
    }
    final recorder = SyncRecorder(a.isar, signer: signer);
    for (var i = 0; i < 2; i++) {
      await a.isar.writeTxn(() => AuditRepository(a.isar, recorder: recorder)
          .append(
              spaceId: 1,
              action: 'expense.create',
              objectType: 'Expense',
              objectGuid: 'expense-$i',
              after: {'amount': i + 1}));
    }
    final rows = await a.isar.auditEvents.where().findAll();
    const verifier = AuditVerifyService();
    expect((await verifier.verify(rows, trustedKeys: {'alice': key})).status,
        AuditStatus.verified);
    rows.first.signature = 'bad';
    expect((await verifier.verify(rows, trustedKeys: {'alice': key})).status,
        AuditStatus.failed);
    final changes = await a.isar.changeRecords.where().findAll();
    final engine = SyncEngine(b.isar, trustedKeys: {'alice': key});
    expect(await engine.applyIncoming(changes.last), ApplyOutcome.applied);
    expect(
        (await verifier.verify(await b.isar.auditEvents.where().findAll(),
                trustedKeys: {'alice': key}))
            .status,
        AuditStatus.incomplete);
    expect(await engine.applyIncoming(changes.first), ApplyOutcome.applied);
    expect(await engine.applyIncoming(changes.first), ApplyOutcome.duplicate);
    final imported = await b.isar.auditEvents.where().findAll();
    expect(imported.length, 2);
    expect(
        (await verifier.verify(imported, trustedKeys: {'alice': key})).status,
        AuditStatus.verified);
    expect(imported.map((e) => e.userIdentity).toSet(), {'alice'});
    await expectLater(
        b.isar.writeTxn(() => AuditRepository(b.isar).append(
            spaceId: 1,
            action: 'expense.update',
            objectType: 'Expense',
            objectGuid: 'x')),
        throwsStateError);
    expect(await b.isar.auditEvents.count(), 2);
    final altered = changes.last;
    final payload = canonicalJsonDecode(altered.payload)..['hash'] = 'changed';
    altered.payload = canonicalJsonEncode(payload);
    altered.signature = await signer.sign(changeCanonicalBytes(altered));
    expect(
        await engine.applyIncoming(altered), ApplyOutcome.droppedBadSignature);
    altered.contextKind = ContextKind.personal;
    altered.signature = await signer.sign(changeCanonicalBytes(altered));
    expect(
        await engine.applyIncoming(altered), ApplyOutcome.droppedUnauthorized);
    expect(await b.isar.auditEvents.count(), 2);
  });
  test('different authors and devices keep independent signed sequences',
      () async {
    final a = await MedicalTestHarness.create(),
        b = await MedicalTestHarness.create();
    addTearDown(a.close);
    addTearDown(b.close);
    final alice = await Ed25519().newKeyPair(),
        bob = await Ed25519().newKeyPair();
    for (final db in [a.isar, b.isar]) {
      await db.writeTxn(() => db.sharedSpaces.put(SharedSpace()
        ..id = 1
        ..syncGuid = 'space'
        ..name = 'Space'
        ..currency = PrimaryCurrency.huf
        ..createdByProfileId = 1
        ..createdAt = DateTime(2026)));
    }
    Future<AuditEvent> write(Isar db, String author, SimpleKeyPair key) =>
        db.writeTxn(() => AuditRepository(db,
                recorder: SyncRecorder(db,
                    signer: Ed25519ChangeSigner(
                        authorIdentityId: author, keyPair: key)))
            .append(
                spaceId: 1,
                action: 'expense.create',
                objectType: 'Expense',
                objectGuid: '$author-object'));
    final rows = await Future.wait([
      write(a.isar, 'alice', alice),
      write(a.isar, 'bob', bob),
      write(b.isar, 'alice', alice)
    ]);
    expect(
        rows
            .map((row) => (jsonDecode(row.evidenceJson!) as Map)['chain'])
            .toSet()
            .length,
        3);
    expect(
        rows
            .map((row) => (jsonDecode(row.evidenceJson!) as Map)['sequence'])
            .toSet(),
        {1});
    expect(
        (await const AuditVerifyService().verify(rows, trustedKeys: {
          'alice': await alice.extractPublicKey(),
          'bob': await bob.extractPublicKey()
        }))
            .status,
        AuditStatus.verified);
  });
}
