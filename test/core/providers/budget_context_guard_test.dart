import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('no profile and no space is not a resolvable context', () {
    final container = ProviderContainer(overrides: [
      activeProfileProvider
          .overrideWith((ref) => Stream<UserProfile?>.value(null)),
    ]);
    addTearDown(container.dispose);

    expect(hasResolvableBudgetContext(container), isFalse);
  });

  test('a selected profile is resolvable before its stream emits', () {
    final container = ProviderContainer(overrides: [
      activeProfileProvider
          .overrideWith((ref) => Stream<UserProfile?>.value(null)),
    ]);
    addTearDown(container.dispose);
    container.read(activeProfileIdProvider.notifier).state = 1;

    expect(hasResolvableBudgetContext(container), isTrue);
  });

  test('a selected shared space is resolvable', () {
    final container = ProviderContainer(overrides: [
      activeProfileProvider
          .overrideWith((ref) => Stream<UserProfile?>.value(null)),
    ]);
    addTearDown(container.dispose);
    container.read(activeSpaceIdProvider.notifier).state = 7;

    expect(hasResolvableBudgetContext(container), isTrue);
  });
}
