import 'dart:convert';
import 'package:budget_buddy/core/database/schema_migrations.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/change_record.dart';
import 'package:budget_buddy/core/models/expense_evidence_chunk.dart';
import 'package:budget_buddy/core/models/paired_peer.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/core/services/expense_evidence.dart';
import 'package:budget_buddy/features/expenses/repositories/expense_evidence_repository.dart';
import 'package:budget_buddy/features/expenses/repositories/expense_repository.dart';
import 'package:budget_buddy/features/sync/domain/entity_applier.dart';
import 'package:budget_buddy/features/sync/domain/hlc.dart';
import 'package:budget_buddy/features/sync/repositories/change_signer.dart';
import 'package:budget_buddy/features/sync/repositories/sync_engine.dart';
import 'package:budget_buddy/features/sync/repositories/sync_recorder.dart';
import 'package:budget_buddy/features/sync/transport/transport.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'support/sync_harness.dart';
import 'support/change_factory.dart';

class _CaptureConnection implements TransportConnection {
  _CaptureConnection(this.inner,
      {this.interrupt = false, this.ignoreExtensions = false});
  final TransportConnection inner;
  final bool interrupt, ignoreExtensions;
  final messages = <String>[];
  int chunks = 0;
  @override
  String get peerIdentityId => inner.peerIdentityId;
  @override
  Stream<String> get incoming => ignoreExtensions
      ? inner.incoming.where((message) {
          final type = (jsonDecode(message) as Map)['type'];
          return type == 'snapshot' || type == 'ack';
        })
      : inner.incoming;
  @override
  Future<void> send(String message) async {
    final type = (jsonDecode(message) as Map)['type'];
    if (interrupt && type == 'evidence-chunk' && ++chunks == 2) {
      await inner.close();
      throw StateError('Injected connection interruption');
    }
    messages.add(message);
    await inner.send(message);
  }

  @override
  Future<void> close() => inner.close();
}

void main() {
  late SyncTestHarness a, b;
  late DeviceKeys alice, bob;
  late Transport endpoint;
  late SyncEngine sender, receiver;
  late PreparedEvidence prepared;
  late SyncRecorder recorder;
  setUp(() async {
    a = await SyncTestHarness.create();
    b = await SyncTestHarness.create();
    alice = await DeviceKeys.generate('alice');
    bob = await DeviceKeys.generate('bob');
    await a.createSpaceAt(localId: 42);
    final guid = await a.spaceGuid(42);
    await b.createSpaceAt(localId: 7, syncGuid: guid);
    for (final pair in [(a, 42), (b, 7)]) {
      await pair.$1.addSignedMember(
          spaceId: pair.$2, keys: alice, role: SharedMemberRole.owner);
      await pair.$1.addSignedMember(
          spaceId: pair.$2, keys: bob, role: SharedMemberRole.editor);
    }
    await a.isar.writeTxn(() => a.isar.pairedPeers.put(PairedPeer()
      ..id = 8
      ..peerIdentityId = 'bob'
      ..pairedAt = DateTime(2026)));
    await b.isar.writeTxn(() => b.isar.pairedPeers.put(PairedPeer()
      ..id = 9
      ..peerIdentityId = 'alice'
      ..pairedAt = DateTime(2026)));
    await a.pairContext(peerId: 8, spaceId: 42);
    await b.pairContext(peerId: 9, spaceId: 7);
    recorder = SyncRecorder(a.isar,
        signer: Ed25519ChangeSigner(
            authorIdentityId: 'alice', keyPair: alice.keyPair),
        clock: HlcClock(deviceId: 'alice-phone'));
    final keys = {'alice': alice.publicKey, 'bob': bob.publicKey};
    sender = SyncEngine(a.isar,
        trustedKeys: keys, selfIdentityId: 'alice', recorder: recorder);
    receiver = SyncEngine(b.isar, trustedKeys: keys, selfIdentityId: 'bob');
    endpoint = a.transport.endpoint('alice');
    a.transport.endpoint('bob');
    final bytes = List<int>.filled(evidenceChunkBytes + 100, 32)
      ..setRange(0, 5, [37, 80, 68, 70, 45]);
    prepared = await prepareEvidence(
        bytes: bytes, name: 'Receipt.pdf', role: 'receipt');
    final expense = Expense(
        profileId: 0,
        sharedSpaceId: 42,
        yearMonth: '2026-10',
        title: 'Planned purchase',
        amount: 10000,
        currency: 'HUF',
        categoryId: 'food',
        merchantName: 'Market',
        paymentMethod: 'cash',
        date: DateTime(2026, 10, 24),
        budgetId: 0,
        status: ExpenseStatus.planned,
        paymentEvidenceJson:
            ExpenseEvidence(profileChosen: true, documents: [prepared.document])
                .encode());
    await a.isar.writeTxn(() async {
      await a.isar.expenses.put(expense);
      await recorder.recordExpense(expense);
      for (final chunk in ExpenseEvidenceRepository.chunks(expense, prepared)) {
        chunk.id = await a.isar.expenseEvidenceChunks.put(chunk);
        await recorder.recordEvidenceChunk(chunk);
      }
    });
  });
  tearDown(() async {
    await a.close();
    await b.close();
  });

  Future<List<String>> exchange(
      {bool interrupt = false,
      bool legacy = false,
      bool respond = true}) async {
    final incoming = a.transport.nextIncoming('bob');
    final rawA = await endpoint.connect(
        a.transport.advertisements().firstWhere((p) => p.identityId == 'bob'));
    final rawB = await incoming;
    final outgoing = _CaptureConnection(rawA, interrupt: interrupt);
    final answering = _CaptureConnection(rawB, ignoreExtensions: legacy);
    try {
      await Future.wait([
        sender.exchange(outgoing,
            contextLocalId: 42, initiator: true, peerId: 8),
        respond
            ? receiver.respond(answering, peerId: 9)
            : receiver.exchange(answering, contextLocalId: 7, peerId: 9),
      ]).timeout(const Duration(seconds: 15));
      return outgoing.messages;
    } finally {
      await rawA.close();
      await rawB.close();
    }
  }

  Future<int> acknowledgements() => a.isar.schemaMigrationStamps
      .filter()
      .keyStartsWith('evidence:sent:')
      .count();

  test(
      'bounded file messages are acknowledged once and excluded from later snapshots',
      () async {
    final first = await exchange();
    final chunks = first
        .where((m) => (jsonDecode(m) as Map)['type'] == 'evidence-chunk')
        .toList();
    expect(chunks, hasLength(2));
    expect(chunks.every((m) => utf8.encode(m).length < 100000), isTrue);
    expect(await acknowledgements(), 1);
    final row = (await b.isar.expenses.where().findAll()).single;
    expect(
        await ExpenseEvidenceRepository(b.isar)
            .readDocument(row, prepared.document),
        prepared.bytes);
    final second = await exchange(respond: false);
    expect(
        second.where((m) => (jsonDecode(m) as Map)['type'] == 'evidence-chunk'),
        isEmpty);
  });
  test(
      'interruption retains a pending document and retries missing content without duplicate rows',
      () async {
    await expectLater(exchange(interrupt: true), throwsStateError);
    expect(await acknowledgements(), 0);
    expect(await b.isar.expenseEvidenceChunks.count(), 1);
    final row = (await b.isar.expenses.where().findAll()).single;
    expect(
        await ExpenseEvidenceRepository(b.isar)
            .readDocument(row, prepared.document),
        isNull);
    await exchange();
    expect(await b.isar.expenseEvidenceChunks.count(), 2);
    expect(
        await ExpenseEvidenceRepository(b.isar)
            .readDocument(row, prepared.document),
        prepared.bytes);
  });
  test(
      'a legacy peer cannot falsely acknowledge files; upgrading permits their later delivery',
      () async {
    await exchange(legacy: true);
    expect(await acknowledgements(), 0);
    expect(await b.isar.expenseEvidenceChunks.count(), 0);
    await exchange();
    expect(await acknowledgements(), 1);
    expect(await b.isar.expenseEvidenceChunks.count(), 2);
  });
  test(
      'deleted-expense proof still transfers using retained audit evidence; whole-space deletion removes journal bytes',
      () async {
    final row = (await a.isar.expenses.where().findAll()).single;
    await ExpenseRepository(a.isar, syncRecorder: recorder)
        .deleteExpense(row.id);
    expect(await a.isar.expenseEvidenceChunks.count(), 2);
    await exchange();
    expect(await b.isar.expenses.count(), 0);
    expect(await b.isar.expenseEvidenceChunks.count(), 2);
    row.sharedSpaceId = 7;
    expect(
        await ExpenseEvidenceRepository(b.isar)
            .readDocument(row, prepared.document),
        prepared.bytes);
    await a.isar.writeTxn(() => const SharedSpaceApplier().delete(a.isar, 42));
    expect(await a.isar.expenseEvidenceChunks.count(), 0);
    expect(
        await a.isar.changeRecords
            .filter()
            .entityTypeEqualTo('ExpenseEvidenceChunk')
            .count(),
        0);
    expect(await acknowledgements(), 0);
    expect(await b.isar.expenseEvidenceChunks.count(), 2);
  });
}
