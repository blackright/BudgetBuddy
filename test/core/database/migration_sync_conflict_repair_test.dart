import 'package:budget_buddy/core/database/schema_migrations.dart';
import 'package:budget_buddy/core/models/sync_cursor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../features/medical/repositories/medical_test_harness.dart';

/// Step 18 (015-wire-device-sync, US3) — one-time repair of the inflated
/// per-space conflict tally.
///
/// Before the fix, every **refusal** (a sealed month frozen after the edit, a
/// demoted author's stale change) added +1 to `SyncCursor.conflictCount`, and
/// the coordinator re-offered the same change on every discovery round — so a
/// badge that should read "Up to date" grew to "967 conflicts" while the data
/// stayed correct. The counter is no longer bumped on a refusal; this step
/// resets the already-inflated numbers once and then leaves them alone.
void main() {
  late MedicalTestHarness harness;

  tearDown(() async {
    await harness.close();
  });

  /// Seeds a cursor exactly as the buggy build left it: a real peer/context with
  /// live watermarks, but an inflated conflict tally.
  Future<int> seedStaleCursor({int conflictCount = 967}) async {
    final cursor = SyncCursor()
      ..peerId = 2
      ..contextLocalId = 1
      ..lastSentHlcMillis = 123456
      ..lastSentCounter = 3
      ..lastSentDeviceId = 'devA'
      ..lastReceivedHlcMillis = 999
      ..lastReceivedCounter = 0
      ..lastReceivedDeviceId = 'devB'
      ..conflictCount = conflictCount
      ..updatedAt = DateTime.utc(2026, 3, 5, 10);
    return harness.isar.writeTxn(() => harness.isar.syncCursors.put(cursor));
  }

  group('migration step 18 - repair the inflated sync conflict tally', () {
    test('zeroes the snowballed tally and keeps every other field', () async {
      harness = await MedicalTestHarness.createPreMigration();
      final id = await seedStaleCursor(conflictCount: 967);

      await harness.runMigrations();

      final after = (await harness.isar.syncCursors.get(id))!;
      expect(after.conflictCount, 0,
          reason: 'the refusal snowball is repaired to a true zero');
      // Only the tally is written: the watermarks and identity stay put.
      expect(after.peerId, 2);
      expect(after.contextLocalId, 1);
      expect(after.lastSentHlcMillis, 123456);
      expect(after.lastSentCounter, 3);
      expect(after.lastSentDeviceId, 'devA');
      expect(after.lastReceivedHlcMillis, 999);
      expect(after.lastReceivedDeviceId, 'devB');
      expect(after.updatedAt.millisecondsSinceEpoch,
          DateTime.utc(2026, 3, 5, 10).millisecondsSinceEpoch);
      expect(await readSchemaVersion(harness.isar), schemaVersion);
      expect(schemaVersion, 18);
    });

    test('a conflict recorded after the repair still counts', () async {
      harness = await MedicalTestHarness.createPreMigration();
      final id = await seedStaleCursor(conflictCount: 25);
      await harness.runMigrations();

      // A genuine losing merge arrives later; it must bump from the repaired
      // zero, so real conflicts are still surfaced (FR-007).
      await harness.isar.writeTxn(() async {
        final cursor = (await harness.isar.syncCursors.get(id))!;
        cursor.conflictCount += 1;
        await harness.isar.syncCursors.put(cursor);
      });

      expect((await harness.isar.syncCursors.get(id))!.conflictCount, 1);
    });

    test('is idempotent: a later count is not wiped by a second run', () async {
      harness = await MedicalTestHarness.createPreMigration();
      final id = await seedStaleCursor(conflictCount: 967);
      await harness.runMigrations();

      await harness.isar.writeTxn(() async {
        final cursor = (await harness.isar.syncCursors.get(id))!;
        cursor.conflictCount = 5;
        await harness.isar.syncCursors.put(cursor);
      });

      // Re-running migrations short-circuits on the version stamp, so the fresh
      // count survives.
      await harness.runMigrations();

      expect((await harness.isar.syncCursors.get(id))!.conflictCount, 5);
      expect(await harness.schemaStamps(), hasLength(1));
    });
  });
}
