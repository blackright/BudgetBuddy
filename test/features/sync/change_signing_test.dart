import 'package:budget_buddy/core/models/change_record.dart';
import 'package:budget_buddy/core/models/context_kind.dart';
import 'package:budget_buddy/features/sync/domain/change_signing.dart';
import 'package:flutter_test/flutter_test.dart';

/// Builds a fully-populated record; everything except the named overrides is
/// held constant so a difference in the bytes is caused only by the override.
ChangeRecord _record({
  int contextLocalId = 1,
  int entityLocalId = 1,
  String contextSyncGuid = 'space-guid',
  String entitySyncGuid = 'expense-guid',
  String payload = '{"amount":100}',
}) =>
    ChangeRecord()
      ..contextKind = ContextKind.shared
      ..contextSyncGuid = contextSyncGuid
      ..contextLocalId = contextLocalId
      ..entityType = 'Expense'
      ..entitySyncGuid = entitySyncGuid
      ..entityLocalId = entityLocalId
      ..op = 'upsert'
      ..payload = payload
      ..hlcMillis = 1000
      ..hlcCounter = 0
      ..deviceId = 'device-a'
      ..authorIdentityId = 'fingerprint'
      ..signature = ''
      ..createdAt = DateTime(2026, 1, 1);

void main() {
  group('changeCanonicalString', () {
    test('signs the GUID identity, not the device-local row ids', () {
      final a = _record(contextLocalId: 1, entityLocalId: 10);
      final b = _record(contextLocalId: 7, entityLocalId: 42);

      expect(changeCanonicalBytes(a), changeCanonicalBytes(b),
          reason: 'two devices store the same row under different local ids, '
              'so the signed bytes must not mention the local ids');
    });

    test('a different entity GUID produces different bytes', () {
      expect(
        changeCanonicalBytes(_record(entitySyncGuid: 'g1')),
        isNot(changeCanonicalBytes(_record(entitySyncGuid: 'g2'))),
      );
    });

    test('a different context GUID produces different bytes', () {
      expect(
        changeCanonicalBytes(_record(contextSyncGuid: 's1')),
        isNot(changeCanonicalBytes(_record(contextSyncGuid: 's2'))),
      );
    });

    test('tampering with the payload changes the bytes', () {
      expect(
        changeCanonicalBytes(_record(payload: '{"amount":100}')),
        isNot(changeCanonicalBytes(_record(payload: '{"amount":999}'))),
      );
    });
  });
}
