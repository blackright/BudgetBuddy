import 'dart:io';

import 'package:budget_buddy/core/models/app_settings.dart';
import 'package:budget_buddy/features/budget_setup/domain/onboarding_state.dart';
import 'package:budget_buddy/features/settings/providers/app_settings_providers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

void main() {
  late Directory directory;
  late Isar db;
  late AppSettingsRepository repository;
  final now = DateTime.utc(2026, 10, 27);
  OnboardingState draft(int revision, {String flow = 'flow-1'}) =>
      OnboardingState(
          flowId: flow, revision: revision, createdAt: now, updatedAt: now);
  setUp(() async {
    await Isar.initializeIsarCore(download: false);
    directory = await Directory.systemTemp.createTemp('onboarding_settings_');
    db = await Isar.open([AppSettingsSchema],
        directory: directory.path,
        name: directory.uri.pathSegments.where((s) => s.isNotEmpty).last);
    repository = AppSettingsRepository(db);
  });
  tearDown(() async {
    await db.close(deleteFromDisk: true);
    expect(
        directory.absolute.path.startsWith(
            '${Directory.systemTemp.absolute.path}${Platform.pathSeparator}onboarding_settings_'),
        isTrue);
    await directory.delete(recursive: true);
  });

  test('concurrent get/create always returns the same singleton', () async {
    final rows =
        await Future.wait(List.generate(10, (_) => repository.getOrCreate()));
    expect(rows.every((row) => row.id == 1), isTrue);
    expect(await db.appSettings.count(), 1);
    expect(rows.map((row) => row.createdAt).toSet(), hasLength(1));
  });

  test('concurrent field writes preserve progress, decimal and policy values',
      () async {
    await db.writeTxn(() async {
      await db.appSettings.put(AppSettings()
        ..id = 1
        ..createdAt = now
        ..updatedAt = now
        ..starterCategoryPolicy = 'preserveExisting');
    });
    await Future.wait([
      repository.setTransferToggle(true),
      repository.setDecimalPreferences('{"HUF":0}'),
      repository.saveOnboardingState(draft(0),
          expectedFlowId: null, expectedRevision: null),
    ]);
    final row = (await db.appSettings.get(1))!;
    expect(row.transferToggle, isTrue);
    expect(row.decimalPreferences, '{"HUF":0}');
    expect(row.starterCategoryPolicy, 'preserveExisting');
    expect(OnboardingState.decode(row.onboardingStateJson!).revision, 0);
    expect(row.createdAt.toUtc(), now);
  });

  test('overlapping revisions have one winner; stale retry cannot overwrite',
      () async {
    await repository.saveOnboardingState(draft(0),
        expectedFlowId: null, expectedRevision: null);
    var successes = 0, stale = 0;
    await Future.wait(List.generate(2, (_) async {
      try {
        await repository.saveOnboardingState(draft(1),
            expectedFlowId: 'flow-1', expectedRevision: 0);
        successes++;
      } on StaleOnboardingRevisionException {
        stale++;
      }
    }));
    expect(successes, 1);
    expect(stale, 1);
    final before = (await db.appSettings.get(1))!.onboardingStateJson;
    await expectLater(
        repository.saveOnboardingState(draft(2, flow: 'other'),
            expectedFlowId: 'flow-1', expectedRevision: 1),
        throwsA(isA<StaleOnboardingRevisionException>()));
    expect((await db.appSettings.get(1))!.onboardingStateJson, before);
  });

  test('transaction-aware progress patch rolls back with its caller', () async {
    await repository.saveOnboardingState(draft(0),
        expectedFlowId: null, expectedRevision: null);
    await expectLater(db.writeTxn(() async {
      await repository.saveOnboardingStateInTxn(draft(1),
          expectedFlowId: 'flow-1', expectedRevision: 0);
      throw StateError('simulated downstream failure');
    }), throwsStateError);
    expect(
        OnboardingState.decode(
                (await db.appSettings.get(1))!.onboardingStateJson!)
            .revision,
        0);
  });

  test('malformed existing progress is preserved rather than reset by a save',
      () async {
    final row = await repository.getOrCreate();
    row.onboardingStateJson = '{bad';
    await db.writeTxn(() => db.appSettings.put(row));
    await expectLater(
        repository.saveOnboardingState(draft(0),
            expectedFlowId: null, expectedRevision: null),
        throwsA(isA<OnboardingStateException>()));
    await repository.setTransferToggle(true);
    expect((await db.appSettings.get(1))!.onboardingStateJson, '{bad');
  });

  test('revision gaps and new-flow retries cannot replace a saved draft',
      () async {
    await repository.saveOnboardingState(draft(0),
        expectedFlowId: null, expectedRevision: null);
    for (final next in [draft(0), draft(2), draft(1, flow: 'other')]) {
      await expectLater(
          repository.saveOnboardingState(next,
              expectedFlowId: 'flow-1', expectedRevision: 0),
          throwsA(isA<StaleOnboardingRevisionException>()));
    }
    expect(
        OnboardingState.decode(
                (await db.appSettings.get(1))!.onboardingStateJson!)
            .revision,
        0);
  });

  test('recorded owner cannot be reassigned or dropped by a progress update',
      () async {
    OnboardingState complete(int revision, int profileId) => OnboardingState(
          flowId: 'flow-1',
          revision: revision,
          createdAt: now.toLocal(),
          updatedAt: now,
          stage: OnboardingStage.completed,
          step: OnboardingStep.finish,
          yearMonth: '2026-09',
          committed: OnboardingCommitReference(
              profileId: profileId,
              budgetId: 9,
              budgetSyncGuid: 'budget-1',
              yearMonth: '2026-09',
              revision: 0,
              digest: 'a' * 64,
              sourceIds: const {}),
          categoriesReady: true,
          directoryReady: true,
          securityChoice: OnboardingSecurityChoice.notNow,
          completedAt: now,
        );
    final row = await repository.getOrCreate();
    row.onboardingStateJson = complete(0, 7).encode();
    await db.writeTxn(() => db.appSettings.put(row));
    await expectLater(
        repository.saveOnboardingState(complete(1, 8),
            expectedFlowId: 'flow-1', expectedRevision: 0),
        throwsA(isA<StaleOnboardingRevisionException>()));
    await expectLater(
        repository.saveOnboardingState(draft(1),
            expectedFlowId: 'flow-1', expectedRevision: 0),
        throwsA(isA<StaleOnboardingRevisionException>()));
    await repository.saveOnboardingState(complete(1, 7),
        expectedFlowId: 'flow-1', expectedRevision: 0);
    expect(
        OnboardingState.decode(
                (await db.appSettings.get(1))!.onboardingStateJson!)
            .committed!
            .profileId,
        7);
  });
}
