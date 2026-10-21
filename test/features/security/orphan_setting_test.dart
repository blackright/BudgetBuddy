import 'package:budget_buddy/core/database/isar_helper.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/features/security/domain/lock_subject.dart';
import 'package:budget_buddy/features/security/providers/lock_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/security_test_harness.dart';

/// T013: an orphan setting protects nothing (FR-034, data-model §1).
///
/// A `LockSetting` whose subject no longer exists must be invisible to the lock.
/// The guarantee is structural rather than defensive: the lock resolves the
/// subject from the subjects that **do** exist (the active space, else the active
/// profile) and then looks up *that* subject's row, so a row for a profile id
/// nobody has can never be found. Nothing scans the settings table and locks
/// whatever it finds.
///
/// The subject is resolved from streams, so these tests settle the streams before
/// asserting — which is also the honest observation that a cold start knows whose
/// lock applies only after that first emission (see the note in the 016 review:
/// the gate's fail-closed window).
void main() {
  group('T013: an orphan setting is never read', () {
    late SecurityTestHarness harness;
    late ProviderContainer container;

    setUp(() async {
      harness = await SecurityTestHarness.create();
      IsarHelper.instance = harness.isar;
      container = ProviderContainer();
    });

    tearDown(() async {
      container.dispose();
      await harness.dispose();
    });

    /// Waits for the two streams the subject is derived from.
    Future<void> settleSubject() async {
      await container.read(activeSpaceProvider.future);
      await container.read(activeProfileProvider.future);
    }

    test('a setting for a deleted profile id does not lock the live profile',
        () async {
      final live = await harness.seedProfile(name: 'Live');
      // Profile 4242 never existed on this device; the row is the orphan.
      await harness.enableLock(LockSubject.profile(id: 4242, name: 'Ghost'));

      await settleSubject();

      final subject = container.read(lockSubjectProvider);
      expect(subject, isNotNull);
      expect(subject!.key, LockSubject.profileKey(live.id));

      final effective = container.read(effectiveLockProvider);
      expect(effective, isNotNull);
      expect(effective!.lockRequired, isFalse,
          reason: 'an orphan setting must not lock anything');
    });

    test('the ghost row is still on disk, so nothing was silently dropped',
        () async {
      await harness.seedProfile(name: 'Live');
      await harness.enableLock(LockSubject.profile(id: 4242, name: 'Ghost'));

      await settleSubject();
      container.read(lockSubjectProvider);

      final rows = await harness.settings.all();
      expect(rows, hasLength(1));
      expect(rows.single.subjectKey, 'p4242');
    });

    test('a setting for a space this phone no longer holds protects nothing',
        () async {
      final profile = await harness.seedProfile(name: 'Live');
      final space = await harness.createSpace(
        syncGuid: 'guid-present',
        ownerId: profile.id,
      );
      // The orphan: a space guid this phone has no row for.
      await harness.enableLock(
        LockSubject.space(localId: 0, syncGuid: 'guid-gone', name: 'Gone'),
      );
      await harness.enableLock(
        LockSubject.space(
          localId: space.id,
          syncGuid: space.syncGuid,
          name: space.name,
        ),
      );

      container.read(activeSpaceIdProvider.notifier).state = space.id;
      await settleSubject();

      final subject = container.read(lockSubjectProvider);
      expect(subject, isNotNull);
      expect(subject!.guid, space.syncGuid);

      final setting = await container.read(activeLockSettingProvider.future);
      expect(setting, isNotNull);
      expect(setting!.subjectGuid, space.syncGuid,
          reason: 'only the live space\'s row is read');
    });
  });
}
