import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/shared/presentation/widgets/analytics_placeholder_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Oracle for US6 (FR-015, SC-008): the Analytics placeholder is visible in
/// both contexts, follows the active context on every switch, and computes no
/// numbers.
///
/// The context providers are overridden so these tests need no Isar instance.
void main() {
  UserProfile profile({int id = 1, String name = 'Alex'}) => UserProfile()
    ..id = id
    ..name = name
    ..primaryCurrency = PrimaryCurrency.usd
    ..monthlyAvailableAmount = 0
    ..createdAt = DateTime(2026)
    ..updatedAt = DateTime(2026);

  SharedSpace space({int id = 7, String name = 'Home'}) => SharedSpace()
    ..id = id
    ..name = name
    ..currency = PrimaryCurrency.usd
    ..createdByProfileId = 1
    ..createdAt = DateTime(2026);

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        activeProfileProvider.overrideWith((ref) => Stream.value(profile())),
        activeSpaceProvider.overrideWith((ref) {
          final id = ref.watch(activeSpaceIdProvider);
          return Stream.value(id == null ? null : space(id: id));
        }),
      ],
    );
    container.read(activeProfileIdProvider.notifier).state = 1;
    return container;
  }

  Widget wrap(ProviderContainer container) => UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: AnalyticsPlaceholderCard()),
        ),
      );

  /// The scope+name line the card renders for the active context.
  String labelOf(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const Key('analyticsContextLabel'))).data!;

  testWidgets('US6 AC1/FR-015: visible in a personal context', (tester) async {
    final container = makeContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(wrap(container));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('analyticsPlaceholder')), findsOneWidget);
    expect(find.text('Analytics'), findsOneWidget);
    expect(labelOf(tester), contains('Personal'));
    expect(labelOf(tester), contains('Alex'));
  });

  testWidgets('US6 AC2: visible and distinct in a shared context',
      (tester) async {
    final container = makeContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(wrap(container));
    await tester.pumpAndSettle();
    final personal = labelOf(tester);

    container.read(activeSpaceIdProvider.notifier).state = 7;
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('analyticsPlaceholder')), findsOneWidget);
    expect(labelOf(tester), contains('Shared'));
    expect(labelOf(tester), contains('Home'));
    expect(labelOf(tester), isNot(personal));
  });

  testWidgets('US6 AC3/SC-008: re-renders on switch, no numbers linger',
      (tester) async {
    final container = makeContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(wrap(container));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('analytics-personal-1')), findsOneWidget);

    container.read(activeSpaceIdProvider.notifier).state = 7;
    await tester.pumpAndSettle();

    // The card computes nothing, so no figure from the previous context can
    // survive the switch.
    expect(find.textContaining(RegExp(r'[0-9]')), findsNothing);
    expect(find.byKey(const ValueKey('analytics-personal-1')), findsNothing);
    expect(find.byKey(const ValueKey('analytics-shared-7')), findsOneWidget);
  });
}
