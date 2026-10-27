import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/isar_helper.dart';
import '../../../core/models/app_settings.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/models/monthly_budget.dart';
import '../../../core/models/income_source.dart';
import '../domain/onboarding_startup.dart';
import '../repositories/onboarding_repository.dart';

final onboardingRepositoryProvider =
    Provider((ref) => OnboardingRepository(IsarHelper.instance));

/// Re-evaluate target integrity after committed changes, not on every frame.
final onboardingStartupProvider =
    StreamProvider<OnboardingStartup>((ref) async* {
  final repo = ref.watch(onboardingRepositoryProvider);
  final events = StreamController<void>();
  final subscriptions = <StreamSubscription<void>>[
    repo.isar.appSettings.watchLazy().listen((_) => events.add(null)),
    repo.isar.userProfiles.watchLazy().listen((_) => events.add(null)),
    repo.isar.monthlyBudgets.watchLazy().listen((_) => events.add(null)),
    repo.isar.incomeSources.watchLazy().listen((_) => events.add(null)),
  ];
  ref.onDispose(() {
    for (final s in subscriptions) {
      unawaited(s.cancel());
    }
    unawaited(events.close());
  });
  yield await repo.readStartupState();
  await for (final _ in events.stream) {
    yield await repo.readStartupState();
  }
});
