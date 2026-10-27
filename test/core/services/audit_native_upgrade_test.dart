import 'package:budget_buddy/core/models/app_settings.dart';
import 'dart:io';
import 'package:budget_buddy/core/database/schema_migrations.dart';
import 'package:budget_buddy/core/models/audit_event.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'support/previous_audit_event.dart';

void main() {
  test(
      'real pre-evidence audit schema reopens without rewriting legacy evidence',
      () async {
    await Isar.initializeIsarCore(download: false);
    final dir = await Directory.systemTemp.createTemp('audit_native_upgrade_');
    var db = await Isar.open(
        [PreviousAuditEventSchema, SchemaMigrationStampSchema],
        directory: dir.path, name: 'audit-native-upgrade');
    final old = PreviousAuditEvent()
      ..profileId = 1
      ..timestamp = DateTime.utc(2020)
      ..createdAt = DateTime.utc(2020)
      ..userIdentity = 'legacy-author'
      ..action = 'income.create'
      ..objectType = 'IncomeSource'
      ..hash = 'legacy-hash'
      ..previousHash = 'legacy-previous'
      ..signature = 'legacy-signature'
      ..newValue = 'Salary';
    await db.writeTxn(() async {
      await db.previousAuditEvents.put(old);
      await db.schemaMigrationStamps.put(SchemaMigrationStamp()
        ..key = schemaVersionKey
        ..value = '26');
    });
    await db.close();
    db = await Isar.open(
        [AppSettingsSchema, AuditEventSchema, SchemaMigrationStampSchema],
        directory: dir.path, name: 'audit-native-upgrade');
    try {
      await runSchemaMigrations(db);
      final row = (await db.auditEvents.where().findAll()).single;
      expect(row.evidenceJson, isNull);
      expect(row.hash, 'legacy-hash');
      expect(row.previousHash, 'legacy-previous');
      expect(row.signature, 'legacy-signature');
      expect(row.newValue, 'Salary');
      expect(row.timestamp.toUtc(), DateTime.utc(2020));
      expect(await readSchemaVersion(db), schemaVersion);
      expect(
          await db.schemaMigrationStamps
              .filter()
              .keyEqualTo('audit:upgrade-boundary')
              .count(),
          1);
      await runSchemaMigrations(db);
      expect(await db.auditEvents.count(), 1);
    } finally {
      await db.close();
      await dir.delete(recursive: true);
    }
  });
}
