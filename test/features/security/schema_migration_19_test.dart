import 'package:budget_buddy/core/database/schema_migrations.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/features/security/domain/lock_subject.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'support/security_test_harness.dart';

/// T010: the `schemaVersion` 18 -> 19 upgrade (data-model §§2, 4).
///
/// Step 19 is additive: the `LockSetting` collection appears and `SharedSpace`
/// gains three non-secret policy columns. Nothing is rewritten, so every
/// existing row — and in particular every money row and month seal 011 protects
/// (SC-003) — must come through the upgrade untouched. The one thing that must
/// **not** happen is a hidden default: a space whose Owner set no requirement
/// reads back `awayTime == null`, never a two-minute lock the Owner never asked
/// for.
void main() {
  group('T010: schemaVersion 19', () {
    late SecurityTestHarness harness;

    setUp(() async {
      harness = await SecurityTestHarness.createPreMigration();
    });

    tearDown(() => harness.dispose());

    test('the stamp advances to 19', () async {
      expect(await readSchemaVersion(harness.isar), lessThan(schemaVersion));

      await runSchemaMigrations(harness.isar);

      expect(await readSchemaVersion(harness.isar), schemaVersion);
      expect(schemaVersion, greaterThanOrEqualTo(19));
    });

    test('existing money rows and memberships survive', () async {
      final profile = await harness.seedProfile(available: 4321);
      final space = await harness.createSpace(
        syncGuid: 'guid-old',
        ownerId: profile.id,
      );

      await runSchemaMigrations(harness.isar);

      final budget = await harness.isar.monthlyBudgets.where().findFirst();
      expect(budget, isNotNull);
      expect(budget!.baseAvailableAmount, 4321);
      expect(budget.profileId, profile.id);

      final member = await harness.isar.sharedMembers
          .filter()
          .sharedSpaceIdEqualTo(space.id)
          .findFirst();
      expect(member, isNotNull);
      expect(member!.role, SharedMemberRole.owner);
    });

    test('the lock is absent after the upgrade: no row means no lock',
        () async {
      await runSchemaMigrations(harness.isar);

      expect(await harness.settings.all(), isEmpty);
    });

    test(
        'a pre-existing space reads back with no Owner requirement, not a '
        'default', () async {
      final profile = await harness.seedProfile();
      final space = await harness.createSpace(
        syncGuid: 'guid-old',
        ownerId: profile.id,
      );

      await runSchemaMigrations(harness.isar);

      final reloaded = await harness.isar.sharedSpaces.get(space.id);
      expect(reloaded, isNotNull);
      expect(reloaded!.requirePin, isFalse);
      expect(reloaded.forbidBiometrics, isFalse);
      expect(reloaded.awayTime, isNull);
    });

    test('the new LockSetting row can be written and read after the upgrade',
        () async {
      await runSchemaMigrations(harness.isar);

      await harness.enableLock(
        LockSubject.profile(id: 1, name: 'Ann'),
        biometrics: true,
      );

      final rows = await harness.settings.all();
      expect(rows, hasLength(1));
      expect(rows.single.subjectKey, 'p1');
      expect(rows.single.lockEnabled, isTrue);
      expect(rows.single.biometricsEnabled, isTrue);
    });
  });
}
