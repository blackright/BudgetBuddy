import 'dart:async';

import 'package:budget_buddy/core/models/month_rate_seal.dart';
import 'package:budget_buddy/core/network/exchange_rate_client.dart';
import 'package:budget_buddy/features/engine/seal_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';

import 'rate_test_support.dart';

class _BlockedClient extends FakeRateClient {
  final entered = Completer<void>();
  final release = Completer<RateSnapshot?>();

  @override
  Future<RateSnapshot?> fetchLatest() {
    latestCalls++;
    if (!entered.isCompleted) entered.complete();
    return release.future;
  }
}

void main() {
  late RateTestHarness harness;
  setUp(() async => harness = await RateTestHarness.create());
  tearDown(() async => harness.close());

  test('overlapping resumes share one pass and one month write', () async {
    await harness.seedBudget('2026-02');
    final client = _BlockedClient();
    final coordinator = SealCoordinator(isar: harness.isar, client: client);
    final first = coordinator.runSealPass(DateTime(2026, 3, 3));
    await client.entered.future;
    final others = List.generate(
      4,
      (_) => coordinator.runSealPass(DateTime(2026, 3, 3)),
    );
    for (final other in others) {
      expect(identical(first, other), isTrue);
    }
    client.release.complete(null);
    await Future.wait([first, ...others]);
    expect(client.latestCalls, 1);
    expect(client.historicalCalls, [DateTime(2026, 2, 28)]);
    final seal = (await harness.sealFor('2026-02'))!;
    expect(seal.status, SealStatus.provisional);
    expect(seal.attemptCount, 1);

    await coordinator.runSealPass(DateTime(2026, 3, 4));
    expect(client.latestCalls, 2);
    expect((await harness.sealFor('2026-02'))!.attemptCount, 2);
  });

  test('a failed pass releases the guard so the next call retries', () async {
    final client = _BlockedClient();
    final coordinator = SealCoordinator(isar: harness.isar, client: client);
    final first = coordinator.runSealPass(DateTime(2026, 3, 3));
    await client.entered.future;
    final joined = coordinator.runSealPass(DateTime(2026, 3, 3));
    final assertions = [
      expectLater(first, throwsStateError),
      expectLater(joined, throwsStateError),
    ];
    client.release.completeError(StateError('injected fetch failure'));
    await Future.wait(assertions);
    expect(client.latestCalls, 1);

    await expectLater(
      coordinator.runSealPass(DateTime(2026, 3, 3)),
      throwsStateError,
    );
    expect(client.latestCalls, 2);
  });
}
