import 'package:budget_buddy/core/database/isar_helper.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/features/security/domain/away_time.dart';
import 'package:budget_buddy/features/security/domain/lock_subject.dart';
import 'package:budget_buddy/features/security/providers/lock_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/security_test_harness.dart';

/// T054 (FR-028, FR-029): the effective lock for a shared space is the Owner's
/// requirement **composed** with the member's own, stricter choice.
///
/// Four rules, each pinned below:
/// * the away-time is the shorter of the two when the Owner set one;
/// * the member's own choice stands untouched when the Owner set none;
/// * a member cannot weaken the requirement — turning their own lock off does
///   not disarm a space the Owner locked;
/// * the member satisfies the requirement with **their own** PIN, never the
///   Owner's — so the requirement is a demand, not a shared secret.
void main() {
  late SecurityTestHarness harness;

  setUp(() async {
    harness = await SecurityTestHarness.create();
    IsarHelper.instance = harness.isar;
  });

  tearDown(() async {
    await harness.dispose();
  });

  /// A space whose ID is a real row, so `effectiveLockProvider` reads its policy
  /// through the live Isar rather than an override that could drift from it.
  Future<SharedSpace> spaceWith({
    bool requirePin = false,
    bool forbidBiometrics = false,
    AwayTime? awayTime,
  }) async {
    final owner = await harness.seedProfile(name: 'Owner');
    final space = await harness.createSpace(
      syncGuid: 'guid-compose',
      ownerId: owner.id,
    );
    await harness.isar.writeTxn(() async {
      space
        ..requirePin = requirePin
        ..forbidBiometrics = forbidBiometrics
        ..awayTime = awayTime;
      await harness.isar.sharedSpaces.put(space);
    });
    return space;
  }

  ProviderContainer containerFor(SharedSpace space) {
    final container = ProviderContainer(
      overrides: [
        activeSpaceProvider.overrideWith((ref) => Stream.value(space)),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Future<LockSubject> subjectOf(ProviderContainer container) async {
    // The space stream must answer FIRST: until it does, `lockSubjectProvider`
    // is null and the setting provider short-circuits to a null stream, which
    // would leave the composition reading a default rather than the real row.
    await container.read(activeSpaceProvider.future);
    await container.read(activeLockSettingProvider.future);
    final subject = container.read(lockSubjectProvider);
    expect(subject, isNotNull);
    return subject!;
  }

  group('T054: the away-time is the shorter of the two', () {
    test('the Owner\'s shorter window wins', () async {
      final space = await spaceWith(awayTime: AwayTime.thirtySeconds);

      // The member chose the loosest window.
      await harness.enableLock(
        LockSubject.space(
          localId: space.id,
          syncGuid: space.syncGuid,
          name: space.name,
          avatar: space.avatar,
        ),
        awayTime: AwayTime.fiveMinutes,
      );

      final container = containerFor(space);
      await subjectOf(container);

      final effective = container.read(effectiveLockProvider);
      expect(effective!.awayTime, AwayTime.thirtySeconds,
          reason: 'the member may lock sooner, never later');
    });
  });

  group('T054: the member\'s own choice stands when the Owner set none', () {
    test('an unset Owner away-time leaves the member\'s value intact',
        () async {
      final space = await spaceWith();

      await harness.enableLock(
        LockSubject.space(
          localId: space.id,
          syncGuid: space.syncGuid,
          name: space.name,
          avatar: space.avatar,
        ),
        awayTime: AwayTime.fiveMinutes,
      );

      final container = containerFor(space);
      await subjectOf(container);

      final effective = container.read(effectiveLockProvider);
      expect(effective!.awayTime, AwayTime.fiveMinutes,
          reason:
              'no hidden default: the Owner set none, so the member decides');
    });
  });

  group('T054: a member cannot weaken the requirement', () {
    test('an Owner-required lock stays required with no member lock on',
        () async {
      final space = await spaceWith(requirePin: true);
      final container = containerFor(space);
      await subjectOf(container);

      final effective = container.read(effectiveLockProvider);
      expect(effective!.lockRequired, isTrue,
          reason:
              'the Owner requires a PIN; the member has configured nothing');
    });
  });

  group('T054: the requirement demands the member\'s own PIN', () {
    test('the subject is the member\'s space, not the Owner identity',
        () async {
      final space = await spaceWith(requirePin: true);
      final container = containerFor(space);
      final subject = await subjectOf(container);

      expect(subject.kind, LockSubjectKind.space,
          reason: 'the member unlocks the space as themselves');
      expect(subject.localId, space.id,
          reason: 'no Owner id is carried: the PIN is the member\'s own');
    });
  });
}
