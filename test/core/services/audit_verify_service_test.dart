import 'dart:convert';
import 'package:budget_buddy/core/models/audit_event.dart';
import 'package:budget_buddy/core/services/audit_verify_service.dart';
import 'package:budget_buddy/features/finance/repositories/audit_repository.dart';
import 'package:isar/isar.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../features/medical/repositories/medical_test_harness.dart';

void main() {
  late MedicalTestHarness h;
  setUp(() async {
    h = await MedicalTestHarness.create();
  });
  tearDown(() => h.close());
  Future<AuditEvent> append(String id) =>
      h.isar.writeTxn(() => AuditRepository(h.isar).append(
          profileId: 1,
          action: 'income.update',
          objectType: 'IncomeSource',
          objectGuid: 'source',
          requestId: id,
          before: {'amount': 100},
          after: {'amount': 200}));
  test('append links, duplicate requests, tampering and missing record',
      () async {
    final first = await append('first');
    final second = await append('second');
    expect(second.previousHash, first.hash);
    expect((await append('second')).id, second.id);
    expect(await h.isar.auditEvents.count(), 2);
    const verifier = AuditVerifyService();
    expect(
        (await verifier.verify([second, first])).status, AuditStatus.verified);
    expect((await verifier.verify([second])).status, AuditStatus.incomplete);
    first.newValue = '{"amount":300}';
    expect((await verifier.verify([first, second])).status, AuditStatus.failed);
  });
  test('audit failure rolls back financial transaction', () async {
    await expectLater(h.isar.writeTxn(() async {
      await AuditRepository(h.isar).append(
          profileId: 1,
          action: 'test',
          objectType: 'Expense',
          objectGuid: 'expense');
      throw StateError('injected failure');
    }), throwsStateError);
    expect(await h.isar.auditEvents.count(), 0);
    expect((await append('retry')).previousHash, isEmpty);
  });
  test('legacy evidence retained and labeled rather than rewritten', () async {
    final old = AuditEvent()
      ..timestamp = DateTime(2020)
      ..createdAt = DateTime(2020)
      ..profileId = 1
      ..userIdentity = 'local-user'
      ..action = 'income.create'
      ..objectType = 'IncomeSource'
      ..hash = ''
      ..previousHash = '';
    await h.isar.writeTxn(() => h.isar.auditEvents.put(old));
    final fresh = await append('new');
    expect((await const AuditVerifyService().verify([old, fresh])).status,
        AuditStatus.legacy);
    expect((await h.isar.auditEvents.get(old.id))!.hash, isEmpty);
  });
  test(
      'concurrent appends serialize one chain and detect a missing retained tip',
      () async {
    final rows =
        await Future.wait([for (var i = 0; i < 12; i++) append('request-$i')]);
    expect(await h.isar.auditEvents.count(), 12);
    final data = rows.map((r) => jsonDecode(r.evidenceJson!) as Map).toList();
    expect(data.map((d) => d['sequence']).toSet(),
        {for (var i = 1; i <= 12; i++) i});
    const verifier = AuditVerifyService();
    expect((await verifier.verify(rows)).status, AuditStatus.verified);
    final tip = rows.singleWhere(
        (r) => (jsonDecode(r.evidenceJson!) as Map)['sequence'] == 12);
    final chain = (jsonDecode(tip.evidenceJson!) as Map)['chain'] as String;
    expect(
        (await verifier.verify(rows.where((r) => r != tip).toList(),
                expectedHeads: {chain: tip.hash}))
            .status,
        AuditStatus.incomplete);
    expect((await verifier.verify([], expectedHeads: {chain: tip.hash})).status,
        AuditStatus.incomplete);
    await h.isar.writeTxn(() => h.isar.auditEvents.delete(tip.id));
    await expectLater(append('after-deletion'), throwsStateError);
    await h.isar.writeTxn(() => AuditRepository(h.isar).append(
        profileId: 2,
        action: 'income.create',
        objectType: 'IncomeSource',
        objectGuid: 'other'));
    expect(await h.isar.auditEvents.filter().profileIdEqualTo(2).count(), 1);
  });
  test('conflicting request is rejected and canonical map order is stable',
      () async {
    final first = await h.isar.writeTxn(() => AuditRepository(h.isar).append(
        profileId: 1,
        action: 'income.update',
        objectType: 'IncomeSource',
        objectGuid: 'source',
        requestId: 'same',
        after: {'a': 1, 'b': 2}));
    final repeat = await h.isar.writeTxn(() => AuditRepository(h.isar).append(
        profileId: 1,
        action: 'income.update',
        objectType: 'IncomeSource',
        objectGuid: 'source',
        requestId: 'same',
        after: {'b': 2, 'a': 1}));
    expect(repeat.id, first.id);
    await expectLater(
        h.isar.writeTxn(() => AuditRepository(h.isar).append(
            profileId: 1,
            action: 'income.update',
            objectType: 'IncomeSource',
            objectGuid: 'source',
            requestId: 'same',
            after: {'a': 3})),
        throwsStateError);
    expect(await h.isar.auditEvents.count(), 1);
  });
}
