import 'dart:async';

import 'package:budget_buddy/core/database/isar_helper.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/core/providers/identity_provider.dart';
import 'package:budget_buddy/features/identity/presentation/app_lock_gate.dart';
import 'package:budget_buddy/features/security/domain/lock_subject.dart';
import 'package:budget_buddy/features/security/providers/lock_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/security_test_harness.dart';

/// T015/T017: the gate must hide content on the **very first frame** after a cold
/// start when a lock is configured (FR-023), without ever leaking a frame of the
/// app behind it — and must still show the app when nothing is locked.
///
/// The subject is derived from the active-space and active-profile *streams*, so
/// on that first frame the app genuinely cannot say whose lock applies. The one
/// thing it can answer is "is a lock configured at all?", because `main.dart`
/// awaits `IsarHelper.init()` before `runApp` and `anyLockConfiguredProvider`
/// reads the two tables synchronously. That synchronous answer is what
/// `lockResolutionPendingProvider` turns into "paint the lock screen, not the
/// app" for exactly the resolving window, and nothing longer.
///
/// The window is deliberately bounded: once both streams have answered, the
/// subject is definitive and `lockResolutionPendingProvider` is `false` for good,
/// so an orphaned setting can never hold the app shut with no way in (FR-034).
void main() {
  late SecurityTestHarness harness;

  setUp(() async {
    harness = await SecurityTestHarness.create();
    IsarHelper.instance = harness.isar;
  });

  tearDown(() async {
    await harness.dispose();
  });

  /// Settles the two streams the lock subject is derived from.
  Future<void> settleStreams(ProviderContainer container) async {
    await container.read(activeSpaceProvider.future);
    await container.read(activeProfileProvider.future);
  }

  ProviderContainer containerWith({
    Stream<SharedSpace?>? space,
    Stream<UserProfile?>? profile,
  }) {
    final container = ProviderContainer(
      overrides: [
        if (space != null) activeSpaceProvider.overrideWith((ref) => space),
        if (profile != null)
          activeProfileProvider.overrideWith((ref) => profile),
        // The 015 gate reads these once nothing is locked; keep them off Isar so
        // the test never leaves an async Isar stream open in the widget tree.
        identityProvider.overrideWith((ref) => Stream.value(null)),
        consentProvider.overrideWith((ref) => Stream.value(null)),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Widget app(ProviderContainer container) => UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: AppLockGate(child: Text('secret app')),
        ),
      );

  group('T015: anyLockConfiguredProvider reads the tables synchronously', () {
    test('is false when nothing is locked', () async {
      await harness.seedProfile(name: 'Ann');
      final container = containerWith();

      expect(container.read(anyLockConfiguredProvider), isFalse);
    });

    test('is true on a member lock alone, before any stream has emitted',
        () async {
      final profile = await harness.seedProfile(name: 'Ann');
      await harness.enableLock(
        LockSubject.profile(id: profile.id, name: 'Ann'),
      );
      final container = containerWith();

      expect(container.read(anyLockConfiguredProvider), isTrue,
          reason: 'the sync check must not wait for the subject streams');
    });

    test('is true on the Owner\'s requirement alone, with no member row',
        () async {
      final profile = await harness.seedProfile(name: 'Ann');
      final space = await harness.createSpace(
        syncGuid: 'guid-required',
        ownerId: profile.id,
      );
      await harness.isar.writeTxn(() async {
        space.requirePin = true;
        await harness.isar.sharedSpaces.put(space);
      });
      final container = containerWith();

      expect(container.read(anyLockConfiguredProvider), isTrue,
          reason: 'the Owner demanding a PIN arms the gate for every member');
      expect(await harness.settings.all(), isEmpty,
          reason: 'no member has configured anything yet');
    });
  });

  group('T017: lockResolutionPendingProvider fails closed, then opens', () {
    test('is true for the resolving window when a lock is configured',
        () async {
      final profile = await harness.seedProfile(name: 'Ann');
      await harness.enableLock(
        LockSubject.profile(id: profile.id, name: 'Ann'),
      );
      final container = containerWith();

      expect(container.read(lockResolutionPendingProvider), isTrue,
          reason: 'the app cannot yet say whose lock applies');
    });

    test('is false for good once both subject streams have answered', () async {
      final profile = await harness.seedProfile(name: 'Ann');
      await harness.enableLock(
        LockSubject.profile(id: profile.id, name: 'Ann'),
      );
      final container = containerWith();

      await settleStreams(container);

      expect(container.read(lockResolutionPendingProvider), isFalse,
          reason:
              'the window is bounded; an orphan must not hold the app shut');

      // The setting row is itself streamed, so the composed lock is definitive
      // only after its stream answers — the subject resolving is not the same
      // event as its setting arriving.
      await container.read(activeLockSettingProvider.future);

      final effective = container.read(effectiveLockProvider);
      expect(effective, isNotNull);
      expect(effective!.lockRequired, isTrue,
          reason: 'the resolved subject is still genuinely locked');
      expect(container.read(lockControllerProvider).isLocked, isTrue);
    });

    test('is false when nothing is locked, even before the streams answer',
        () async {
      await harness.seedProfile(name: 'Ann');
      final container = containerWith();

      expect(container.read(lockResolutionPendingProvider), isFalse);
    });
  });

  group('T017: the gate hides content on the first frame', () {
    testWidgets('a configured lock paints the lock screen, not the app',
        (tester) async {
      // Real Isar I/O must run outside the fake-async zone `testWidgets` uses,
      // or the write future never completes. Nothing else in the test needs it:
      // the sync check is a plain `countSync`, and every stream the widget reads
      // is overridden below, so no async Isar work is left in the tree.
      await tester.runAsync(() async {
        final profile = await harness.seedProfile(name: 'Ann');
        await harness.enableLock(
          LockSubject.profile(id: profile.id, name: 'Ann'),
        );
      });

      // The subject streams never emit, so the app is stuck in the resolving
      // window for the whole test — the fail-closed case, made deterministic.
      final space = StreamController<SharedSpace?>();
      final profileStream = StreamController<UserProfile?>();
      addTearDown(space.close);
      addTearDown(profileStream.close);

      final container = containerWith(
        space: space.stream,
        profile: profileStream.stream,
      );

      await tester.pumpWidget(app(container));

      expect(find.text('secret app'), findsNothing,
          reason: 'not one frame of the app may leak behind the lock');
      expect(find.text('BudgetBuddy is locked'), findsOneWidget);
      expect(find.byKey(const Key('unlockButton')), findsNothing,
          reason: 'the window names no subject, so it offers no way in');
    });
  });

  group('T015: with no lock the gate shows the app', () {
    testWidgets('the first frame paints the app', (tester) async {
      final container = containerWith(
        space: Stream.value(null),
        profile: Stream.value(null),
      );

      await tester.pumpWidget(app(container));

      expect(find.text('secret app'), findsOneWidget);
      expect(find.text('BudgetBuddy is locked'), findsNothing);
    });
  });
}
