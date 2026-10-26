import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:budget_buddy/core/models/month_end_run.dart';
import 'package:budget_buddy/core/models/budget_profile.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/core/services/month_end_service.dart';
import 'package:budget_buddy/core/services/month_end_report.dart';
import 'package:budget_buddy/features/sync/domain/codecs/month_end_run_codec.dart';
import 'package:budget_buddy/features/sync/domain/codecs/budget_profile_codec.dart';
import 'package:budget_buddy/features/sync/domain/sync_codec.dart';
import 'package:budget_buddy/features/sync/repositories/sync_engine.dart';
import 'support/sync_harness.dart';
import 'support/change_factory.dart';

void main() {
  late SyncTestHarness h;
  late DeviceKeys keys;
  setUp(() async {
    h = await SyncTestHarness.create();
    keys = await DeviceKeys.generate('owner');
    await h.createSpaceAt(localId: 42, syncGuid: 'space');
    await h.addSignedMember(
        spaceId: 42, keys: keys, role: SharedMemberRole.owner);
  });
  tearDown(() async {
    await h.close();
  });
  MonthEndRun run() => MonthEndRun()
    ..syncGuid = 'month-end:${monthEndDigest(['shared', 'space', '2026-09'])}'
    ..contextGuid = 'space'
    ..yearMonth = '2026-09'
    ..destinationMonth = '2026-10'
    ..currency = 'usd'
    ..fingerprint = 'stable-preview'
    ..actor = 'owner'
    ..createdAt = DateTime(2026, 10, 1)
    ..carriedMinor = 20000
    ..releasedMinor = 0
    ..reportJson = canonicalJsonEncode({
      'lines': [
        MonthEndLine(
                sourceGuid: 'source',
                familyGuid: 'family',
                destinationGuid: 'destination',
                name: 'Food',
                existingDestination: false,
                amounts: MonthEndAmounts(
                    allocation: 100000,
                    spent: 80000,
                    defaultAllocation: 100000,
                    rule: MonthEndRule.carryForward))
            .toJson()
      ]
    });
  SyncEngine engine() =>
      SyncEngine(h.isar, trustedKeys: {'owner': keys.publicKey});

  test(
      'signed Owner settlement reads a sealed source, maps local context and applies once',
      () async {
    await h.sealMonth('2026-09');
    final change = await signedChange(
        keys: keys,
        deviceId: 'phone',
        hlcMillis: 100,
        entityType: 'MonthEndRun',
        contextSyncGuid: 'space',
        payload: const MonthEndRunCodec().toPayload(run()));
    final sync = engine();
    expect(await sync.applyIncoming(change), ApplyOutcome.applied);
    expect(await sync.applyIncoming(change), ApplyOutcome.duplicate);
    expect(
        (await h.isar.monthEndRuns.where().findAll()).single.sharedSpaceId, 42);
    final p = (await h.isar.budgetProfiles.where().findAll()).single;
    expect(p.allocation, 120000);
    expect(p.sharedSpaceId, 42);
  });
  test('Editor and sealed destination cannot author settlement', () async {
    await h.setMemberHead(
        spaceId: 42, keys: keys, role: SharedMemberRole.editor, version: 1);
    final change = await signedChange(
        keys: keys,
        deviceId: 'phone',
        hlcMillis: 100,
        entityType: 'MonthEndRun',
        contextSyncGuid: 'space',
        payload: const MonthEndRunCodec().toPayload(run()));
    expect(
        await engine().applyIncoming(change), ApplyOutcome.droppedUnauthorized);
    await h.setMemberHead(
        spaceId: 42, keys: keys, role: SharedMemberRole.owner, version: 1);
    await h.sealMonth('2026-10');
    expect(
        await engine().applyIncoming(change), ApplyOutcome.droppedUnauthorized);
    expect(await h.isar.monthEndRuns.count(), 0);
  });
  test(
      'different offline confirmations do not double carry and expose a conflict',
      () async {
    final sync = engine();
    final first = await signedChange(
        keys: keys,
        deviceId: 'one',
        hlcMillis: 100,
        entityType: 'MonthEndRun',
        contextSyncGuid: 'space',
        payload: const MonthEndRunCodec().toPayload(run()));
    await sync.applyIncoming(first);
    final second = await signedChange(
        keys: keys,
        deviceId: 'two',
        hlcMillis: 101,
        entityType: 'MonthEndRun',
        contextSyncGuid: 'space',
        payload: const MonthEndRunCodec()
            .toPayload(run()..fingerprint = 'another-preview'));
    await sync.applyIncoming(second);
    expect((await h.isar.monthEndRuns.where().findAll()).single.hasConflict,
        isTrue);
    expect((await h.isar.budgetProfiles.where().findAll()).single.allocation,
        120000);
  });
  test(
      'profile bootstrap waits for matching settlement and projects funding atomically',
      () async {
    final p = BudgetProfile()
      ..syncGuid = 'destination'
      ..yearMonth = '2026-10'
      ..name = 'Food'
      ..familyGuid = 'family'
      ..monthEndOriginGuid = run().syncGuid
      ..monthEndFingerprint = 'stable-preview'
      ..defaultAllocationMinor = 100000
      ..allocation = 125000
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);
    final profile = const BudgetProfileCodec().toJson(p)
      ..['sharedSpaceSyncGuid'] = 'space';
    final sync = engine();
    final profileChange = await signedChange(
        keys: keys,
        deviceId: 'phone',
        hlcMillis: 101,
        entityType: 'BudgetProfile',
        contextSyncGuid: 'space',
        payload: canonicalJsonEncode(profile));
    expect(await sync.applyIncoming(profileChange), ApplyOutcome.applied);
    expect(await h.isar.budgetProfiles.count(), 0);
    final settlement = await signedChange(
        keys: keys,
        deviceId: 'phone',
        hlcMillis: 100,
        entityType: 'MonthEndRun',
        contextSyncGuid: 'space',
        payload: const MonthEndRunCodec().toPayload(run()));
    expect(await sync.applyIncoming(settlement), ApplyOutcome.applied);
    expect((await h.isar.budgetProfiles.where().findAll()).single.allocation,
        125000);
    expect((await h.isar.monthEndRuns.where().findAll()).single.carriedMinor,
        20000);
    final conflict = Map<String, Object?>.of(profile)
      ..['monthEndFingerprint'] = 'different'
      ..['allocation'] = 140000;
    final badProfile = await signedChange(
        keys: keys,
        deviceId: 'phone',
        hlcMillis: 102,
        entityType: 'BudgetProfile',
        contextSyncGuid: 'space',
        payload: canonicalJsonEncode(conflict));
    await sync.applyIncoming(badProfile);
    expect((await h.isar.budgetProfiles.where().findAll()).single.allocation,
        125000);
    expect((await h.isar.monthEndRuns.where().findAll()).single.hasConflict,
        isTrue);
  });
}
