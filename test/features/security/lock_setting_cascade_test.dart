import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/features/identity/repositories/secret_store.dart';
import 'package:budget_buddy/features/security/domain/lock_secret_keys.dart';
import 'package:budget_buddy/features/security/domain/lock_subject.dart';
import 'package:budget_buddy/features/settings/presentation/profile_switcher_section.dart';
import 'package:budget_buddy/features/spaces/repositories/space_role_guard.dart';
import 'package:budget_buddy/features/spaces/repositories/spaces_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import '../../support/audit_test_support.dart';

import 'support/security_test_harness.dart';

/// T012: FR-034 — a removed subject takes its security setting with it.
///
/// Both halves are asserted, because half a cascade is worse than none. A row
/// left behind shows a stale "lock is on"; a verifier left behind can be
/// inherited by a later profile or space that reuses the key. The secrets are
/// written into an [InMemorySecretStore], so the test proves the deletes reach
/// the store rather than only the Isar half.
void main() {
  group('T012: the FR-034 cascade', () {
    late SecurityTestHarness harness;
    late InMemorySecretStore secrets;

    setUp(() async {
      harness = await SecurityTestHarness.create();
      secrets = InMemorySecretStore();
    });

    tearDown(() => harness.dispose());

    Future<void> seedSecrets(String subjectKey, {String pin = 'pin-record'}) =>
        secrets.write(LockSecretKeys.pin(subjectKey), pin).then(
            (_) => secrets.write(LockSecretKeys.lockout(subjectKey), '1:123'));

    test('deleting a profile removes its row and both secure records',
        () async {
      final doomed = await harness.seedProfile(name: 'Doomed');
      final kept = await harness.seedProfile(name: 'Kept');
      final doomedSubject = LockSubject.profile(id: doomed.id, name: 'Doomed');
      final keptSubject = LockSubject.profile(id: kept.id, name: 'Kept');

      await harness.enableLock(doomedSubject);
      await harness.enableLock(keptSubject);
      await seedSecrets(doomedSubject.key);
      await seedSecrets(keptSubject.key);

      final controller = ProfileSwitcherController(
        harness.isar,
        lockJanitor: harness.janitor(secrets),
      );
      await controller.deleteProfile(doomed.id, activeProfileId: null);

      expect(await harness.settings.find(doomedSubject.key), isNull);
      expect(await secrets.read(LockSecretKeys.pin(doomedSubject.key)), isNull);
      expect(await secrets.read(LockSecretKeys.lockout(doomedSubject.key)),
          isNull);

      // A different subject is never collateral damage.
      expect(await harness.settings.find(keptSubject.key), isNotNull);
      expect(
          await secrets.read(LockSecretKeys.pin(keptSubject.key)), isNotNull);
    });

    test('deleting a space removes its row and both secure records', () async {
      final owner = await harness.seedProfile();
      final space = await harness.createSpace(
        syncGuid: 'guid-doomed',
        ownerId: owner.id,
      );
      final subject = LockSubject.space(
        localId: space.id,
        syncGuid: space.syncGuid,
        name: space.name,
      );
      await harness.enableLock(subject);
      await seedSecrets(subject.key);

      final repository = SpacesRepository(
        harness.isar,
        syncRecorder: await auditTestRecorder(harness.isar),
        lockJanitor: harness.janitor(secrets),
      );
      await repository.deleteSpace(
        actingProfileId: owner.id,
        spaceId: space.id,
      );

      expect(await harness.isar.sharedSpaces.get(space.id), isNull);
      expect(await harness.settings.find(subject.key), isNull);
      expect(await secrets.read(LockSecretKeys.pin(subject.key)), isNull);
      expect(await secrets.read(LockSecretKeys.lockout(subject.key)), isNull);
    });

    test('leaving a space removes that phone\'s row and secure records',
        () async {
      final owner = await harness.seedProfile(name: 'Owner');
      final leaver = await harness.seedProfile(name: 'Leaver');
      final space = await harness.createSpace(
        syncGuid: 'guid-shared',
        ownerId: owner.id,
      );
      await harness.addEditor(space.id, leaver.id);
      final subject = LockSubject.space(
        localId: space.id,
        syncGuid: space.syncGuid,
        name: space.name,
      );
      await harness.enableLock(subject);
      await seedSecrets(subject.key);

      final repository = SpacesRepository(
        harness.isar,
        syncRecorder: await auditTestRecorder(harness.isar),
        lockJanitor: harness.janitor(secrets),
      );
      await repository.leaveSpace(profileId: leaver.id, spaceId: space.id);

      expect(
        await harness.isar.sharedMembers
            .filter()
            .sharedSpaceIdEqualTo(space.id)
            .count(),
        1,
        reason: 'only the leaver left',
      );
      expect(await harness.settings.find(subject.key), isNull);
      expect(await secrets.read(LockSecretKeys.pin(subject.key)), isNull);
    });

    test('a refused removal cascades nothing: the last Owner may not leave',
        () async {
      final owner = await harness.seedProfile();
      final space = await harness.createSpace(
        syncGuid: 'guid-last-owner',
        ownerId: owner.id,
      );
      final subject = LockSubject.space(
        localId: space.id,
        syncGuid: space.syncGuid,
        name: space.name,
      );
      await harness.enableLock(subject);
      await seedSecrets(subject.key);

      final repository = SpacesRepository(
        harness.isar,
        syncRecorder: await auditTestRecorder(harness.isar),
        lockJanitor: harness.janitor(secrets),
      );

      await expectLater(
        repository.leaveSpace(profileId: owner.id, spaceId: space.id),
        throwsA(isA<UnauthorizedSpaceAction>()),
      );

      // The leave was refused, so nothing was removed and nothing was erased.
      expect(await harness.settings.find(subject.key), isNotNull);
      expect(await secrets.read(LockSecretKeys.pin(subject.key)), isNotNull);
    });
  });
}
