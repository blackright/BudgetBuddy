import 'dart:convert';

import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/income_source.dart';
import 'package:budget_buddy/features/budget_setup/domain/onboarding_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 10, 27);
  OnboardingState draft() => OnboardingState(
        flowId: 'flow-1',
        revision: 0,
        createdAt: now,
        updatedAt: now,
        yearMonth: '2026-09',
        profile: const OnboardingProfileDraft(
            name: 'José', currency: CurrencyCode.eur),
        incomeChoice: OnboardingIncomeChoice.sources,
        sources: [
          const OnboardingSourceDraft(
              sourceGuid: 'source-1',
              amountText: '1,000.25',
              currency: CurrencyCode.eur,
              minorUnits: 100025)
        ],
      );
  Map<String, dynamic> payload() =>
      jsonDecode(draft().encode()) as Map<String, dynamic>;

  test(
      'draft round trip preserves exact grouped text, month and stable identities',
      () {
    final result = OnboardingState.decode(draft().encode());
    expect(result.flowId, 'flow-1');
    expect(result.revision, 0);
    expect(result.yearMonth, '2026-09');
    expect(result.profile.name, 'José');
    expect(result.sources.single.sourceGuid, 'source-1');
    expect(result.sources.single.amountText, '1,000.25');
    expect(result.sources.single.minorUnits, 100025);
    expect(result.createdAt, now);
    expect(result.encode(), draft().encode());
    expect(() => result.sources.clear(), throwsUnsupportedError);
  });

  test('incomplete draft text remains editable without invented amounts', () {
    final result = OnboardingState.decode(OnboardingState(
      flowId: 'flow-1',
      revision: 0,
      createdAt: now,
      updatedAt: now,
      opening: const OnboardingOpeningDraft(
          choice: OnboardingOpeningChoice.known, amountText: '1,'),
    ).encode());
    expect(result.opening.amountText, '1,');
    expect(result.opening.minorUnits, isNull);
  });

  test('unsupported versions, shapes, enums and secret fields are rejected',
      () {
    for (final change in <void Function(Map<String, dynamic>)>[
      (p) => p['version'] = 2,
      (p) => p['flowVersion'] = 2,
      (p) => p['revision'] = 0.5,
      (p) => p['stage'] = 'invented',
      (p) => p['pin'] = '1234',
      (p) => (p['profile'] as Map)['privateKey'] = 'secret',
      (p) => (p['sources'] as List).add((p['sources'] as List).first),
      (p) => p['yearMonth'] = '2026-13',
      (p) => p['updatedAt'] = '2026-02-31T00:00:00.000Z',
    ]) {
      final p = payload();
      change(p);
      expect(() => OnboardingState.decode(jsonEncode(p)),
          throwsA(isA<OnboardingStateException>()));
    }
    for (final raw in ['null', '[]', '{', '{"password":"do not echo"}']) {
      expect(() => OnboardingState.decode(raw),
          throwsA(isA<OnboardingStateException>()));
    }
    try {
      OnboardingState.decode('{"password":"do not echo"}');
    } catch (e) {
      expect(e.toString(), isNot(contains('do not echo')));
    }
  });

  test(
      'size and nesting are checked before decoding; brackets inside text are safe',
      () {
    expect(
        () =>
            OnboardingState.decode(' ' * (OnboardingState.maxEncodedBytes + 1)),
        throwsA(isA<OnboardingStateException>()));
    expect(() => OnboardingState.decode('${'[' * 40}0${']' * 40}'),
        throwsA(isA<OnboardingStateException>()));
    final p = payload();
    (p['sources'] as List).first['notes'] = '[[{ not structure }]]';
    expect(OnboardingState.decode(jsonEncode(p)).sources.single.notes,
        '[[{ not structure }]]');
    (p['sources'] as List).first['notes'] =
        'é' * (OnboardingState.maxEncodedBytes ~/ 2);
    expect(() => OnboardingState.decode(jsonEncode(p)),
        throwsA(isA<OnboardingStateException>()));
  });

  test(
      'raw monetary evidence must match parsed minor units and selected currency',
      () {
    for (final change in <void Function(Map)>[
      (s) => s['minorUnits'] = 1,
      (s) => s['minorUnits'] = -1,
      (s) => s['minorUnits'] = 9007199254740992,
      (s) => s['currency'] = 'GBP',
      (s) => s['currency'] = 'USD',
      (s) => s['startDate'] = '2026-02-31',
      (s) {
        s['startDate'] = '2026-10-10';
        s['endDate'] = '2026-10-01';
      },
    ]) {
      final p = payload();
      change((p['sources'] as List).first as Map);
      expect(() => OnboardingState.decode(jsonEncode(p)),
          throwsA(isA<OnboardingStateException>()));
    }
  });

  test('stage/reference combinations fail closed', () {
    for (final stage in [
      'coreCommitted',
      'preparing',
      'readyToFinish',
      'completed'
    ]) {
      final p = payload()..['stage'] = stage;
      expect(() => OnboardingState.decode(jsonEncode(p)),
          throwsA(isA<OnboardingStateException>()));
    }
    final p = payload()..['completedAt'] = now.toIso8601String();
    expect(() => OnboardingState.decode(jsonEncode(p)),
        throwsA(isA<OnboardingStateException>()));
  });

  test('committed states require complete matching owner and source receipts',
      () {
    for (final stage in [
      OnboardingStage.coreCommitted,
      OnboardingStage.preparing,
      OnboardingStage.readyToFinish
    ]) {
      final state = OnboardingState(
        flowId: 'flow-1',
        revision: 2,
        createdAt: now,
        updatedAt: now,
        stage: stage,
        step: OnboardingStep.security,
        yearMonth: '2026-09',
        profile: const OnboardingProfileDraft(
            name: 'Jason', currency: CurrencyCode.eur),
        opening: const OnboardingOpeningDraft(
            choice: OnboardingOpeningChoice.known,
            amountText: '0',
            minorUnits: 0,
            currency: CurrencyCode.eur),
        incomeChoice: OnboardingIncomeChoice.sources,
        sources: [
          OnboardingSourceDraft(
              sourceGuid: 'source-1',
              name:
                  'Salary and a descriptive existing income source name longer than fifty characters',
              amountText: '1.00',
              minorUnits: 100,
              currency: CurrencyCode.eur,
              frequency: IncomeFrequency.oneTime,
              startDate: DateTime(2026, 9, 1))
        ],
        committed: OnboardingCommitReference(
            profileId: 7,
            budgetId: 9,
            budgetSyncGuid: 'budget-1',
            yearMonth: '2026-09',
            revision: 1,
            digest: 'a' * 64,
            sourceIds: const {'source-1': 12}),
        categoriesReady: true,
        directoryReady: true,
        securityChoice: OnboardingSecurityChoice.notNow,
      );
      expect(OnboardingState.decode(state.encode()).stage, stage);
      for (final change in <void Function(Map)>[
        (p) => (p['committed'] as Map)['profileId'] = 0,
        (p) => (p['committed'] as Map)['yearMonth'] = '2026-10',
        (p) => (p['committed'] as Map)['revision'] = 3,
        (p) => (p['committed'] as Map)['digest'] = 'not-a-digest',
        (p) => (p['committed'] as Map)['sourceIds'] = {'other-source': 12},
      ]) {
        final p = jsonDecode(state.encode()) as Map;
        change(p);
        expect(() => OnboardingState.decode(jsonEncode(p)),
            throwsA(isA<OnboardingStateException>()));
      }
    }
  });

  test('unknown opening and explicit no-income survive without invented money',
      () {
    final state = OnboardingState(
        flowId: 'flow-1',
        revision: 0,
        createdAt: now,
        updatedAt: now,
        opening: const OnboardingOpeningDraft(
            choice: OnboardingOpeningChoice.unknown),
        incomeChoice: OnboardingIncomeChoice.none);
    final result = OnboardingState.decode(state.encode());
    expect(result.opening.minorUnits, isNull);
    expect(result.sources, isEmpty);
    final p = jsonDecode(state.encode()) as Map;
    (p['opening'] as Map)['minorUnits'] = 0;
    expect(() => OnboardingState.decode(jsonEncode(p)),
        throwsA(isA<OnboardingStateException>()));
  });

  test('source dates compare calendar days independently of timezone kind', () {
    final state = OnboardingState(
        flowId: 'flow-1',
        revision: 0,
        createdAt: now,
        updatedAt: now,
        incomeChoice: OnboardingIncomeChoice.sources,
        sources: [
          OnboardingSourceDraft(
              sourceGuid: 'source-1',
              startDate: DateTime.utc(2026, 9, 1),
              endDate: DateTime(2026, 9, 1))
        ]);
    final source = OnboardingState.decode(state.encode()).sources.single;
    expect(source.startDate, DateTime(2026, 9, 1));
    expect(source.endDate, DateTime(2026, 9, 1));
  });

  test('completion retains owner receipt but prunes financial drafts', () {
    final complete = OnboardingState(
      flowId: 'flow-1',
      revision: 5,
      createdAt: now,
      updatedAt: now,
      stage: OnboardingStage.completed,
      step: OnboardingStep.finish,
      yearMonth: '2026-09',
      committed: OnboardingCommitReference(
          profileId: 7,
          budgetId: 9,
          budgetSyncGuid: 'budget-1',
          yearMonth: '2026-09',
          revision: 2,
          digest: 'a' * 64,
          sourceIds: const {'source-1': 12}),
      categoriesReady: true,
      directoryReady: true,
      securityChoice: OnboardingSecurityChoice.notNow,
      completedAt: now,
    );
    final result = OnboardingState.decode(complete.encode());
    expect(result.committed!.profileId, 7);
    expect(result.committed!.sourceIds, {'source-1': 12});
    expect(result.profile.name, isEmpty);
    expect(result.sources, isEmpty);
    expect(() => result.committed!.sourceIds.clear(), throwsUnsupportedError);
    final p = jsonDecode(complete.encode()) as Map<String, dynamic>;
    (p['profile'] as Map)['name'] = 'Unnecessarily retained';
    expect(() => OnboardingState.decode(jsonEncode(p)),
        throwsA(isA<OnboardingStateException>()));
    p['profile'] = {'name': '', 'currency': null};
    p['directoryReady'] = false;
    expect(() => OnboardingState.decode(jsonEncode(p)),
        throwsA(isA<OnboardingStateException>()));
  });
}
