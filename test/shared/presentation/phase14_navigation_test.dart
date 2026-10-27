import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/core/providers/selected_month_provider.dart';
import 'package:budget_buddy/core/services/context_navigation.dart';
import 'package:budget_buddy/shared/presentation/widgets/spaces_dropdown.dart';
import 'package:budget_buddy/shared/presentation/providers/context_navigation_provider.dart';
import 'package:budget_buddy/features/budget_setup/presentation/welcome_step.dart';

void main() {
  UserProfile profile(String name) => UserProfile()
    ..id = 1
    ..name = name
    ..primaryCurrency = PrimaryCurrency.huf
    ..monthlyAvailableAmount = 0
    ..createdAt = DateTime(2026)
    ..updatedAt = DateTime(2026);
  Future<(ProviderContainer, GoRouter)> pump(WidgetTester tester,
      {String name = 'Jason',
      bool fail = false,
      ThemeMode mode = ThemeMode.light,
      double scale = 1}) async {
    final router = GoRouter(initialLocation: '/expenses', routes: [
      for (final path in [
        '/expenses',
        '/dashboard',
        '/profile',
        '/reports',
        '/settings',
        '/spaces'
      ])
        GoRoute(
            path: path,
            builder: (context, state) => Scaffold(
                    body: Column(children: [
                  const SpacesDropdown(),
                  Text('Destination $path')
                ])))
    ]);
    addTearDown(router.dispose);
    final container = ProviderContainer(overrides: [
      activeProfileIdProvider.overrideWith((ref) => 1),
      activeProfileProvider.overrideWith((ref) => Stream.value(profile(name))),
      activeSpaceProvider.overrideWith((ref) {
        final id = ref.watch(activeSpaceIdProvider);
        return Stream.value(id == null
            ? null
            : (SharedSpace()
              ..id = id
              ..name = 'Family'
              ..currency = PrimaryCurrency.huf
              ..createdByProfileId = 1
              ..createdAt = DateTime(2026)));
      }),
      contextDestinationsProvider.overrideWith((ref) async => const [
            ContextDestination(name: 'Jason', locked: false),
            ContextDestination(name: 'Family', spaceId: 7, locked: true),
            ContextDestination(name: 'Work', spaceId: 8, locked: false)
          ]),
      selectNavigationContextProvider.overrideWith((ref) => (id) async {
            if (fail) throw StateError('Revoked');
            ref.read(activeSpaceIdProvider.notifier).state = id;
            return ContextDestination(
                name: 'Family', spaceId: id, locked: true);
          })
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: mode,
            routerConfig: router,
            builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(scale)),
                child: child!))));
    await tester.pumpAndSettle();
    return (container, router);
  }

  Future<void> open(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('spacesNavigationMenu')));
    await tester.pumpAndSettle();
  }

  testWidgets('all four destinations are present and Profile routes correctly',
      (tester) async {
    final (_, router) = await pump(tester);
    expect(find.text('J'), findsOneWidget);
    await open(tester);
    for (final label in ['Profile', 'Spaces', 'Reports', 'Settings']) {
      expect(find.text(label), findsWidgets);
    }
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Destination /profile'), findsOneWidget);
    expect(router.canPop(), isTrue);
  });
  testWidgets(
      'search filters contexts, shows lock, preserves month and opens dashboard',
      (tester) async {
    final (container, router) = await pump(tester);
    final month = container.read(selectedYearMonthProvider);
    await open(tester);
    await tester.tap(find.text('Spaces').last);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    await tester.enterText(find.byKey(const Key('contextSearchField')), 'fami');
    await tester.pumpAndSettle();
    expect(find.text('Work'), findsNothing);
    await tester.tap(find.byKey(const Key('contextChoice_7')));
    await tester.pumpAndSettle();
    expect(container.read(activeSpaceIdProvider), 7);
    expect(container.read(selectedYearMonthProvider), month);
    expect(router.routeInformationProvider.value.uri.path, '/dashboard');
    expect(find.text('J'), findsOneWidget);
    expect(find.text('Shared · Family'), findsOneWidget);
    expect(find.text('Switched to Family.'), findsOneWidget);
  });
  testWidgets('same context closes without navigation or feedback',
      (tester) async {
    final (_, router) = await pump(tester);
    await open(tester);
    await tester.tap(find.text('Spaces').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('contextChoice_personal')));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/expenses');
    expect(find.textContaining('Switched to'), findsNothing);
  });
  testWidgets('revoked selection keeps original context and explains failure',
      (tester) async {
    final (container, router) = await pump(tester, fail: true);
    await open(tester);
    await tester.tap(find.text('Spaces').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('contextChoice_7')));
    await tester.pumpAndSettle();
    expect(container.read(activeSpaceIdProvider), isNull);
    expect(router.routeInformationProvider.value.uri.path, '/expenses');
    expect(find.textContaining('Could not switch.'), findsOneWidget);
  });
  testWidgets('legacy name prompt dismisses without renaming', (tester) async {
    final (container, _) = await pump(tester, name: 'User');
    expect(find.text('Personalise your profile'), findsOneWidget);
    await tester
        .tap(find.byTooltip('Dismiss name suggestion for this session'));
    await tester.pumpAndSettle();
    expect(find.text('Personalise your profile'), findsNothing);
    expect(container.read(activeProfileProvider).value!.name, 'User');
  });
  for (final mode in [ThemeMode.dark, ThemeMode.light]) {
    testWidgets('compact navigation fits narrow large text $mode',
        (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await pump(tester, mode: mode, scale: 1.8);
      expect(tester.takeException(), isNull);
      await open(tester);
      await tester.tap(find.text('Spaces').last);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('Welcome validates, previews and emits the chosen name',
      (tester) async {
    String? chosen;
    await tester.pumpWidget(MaterialApp(
        home: WelcomeStep(name: '', onContinue: (name) => chosen = name)));
    await tester.scrollUntilVisible(
        find.byKey(const Key('welcomeContinueButton')), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('welcomeContinueButton')));
    await tester.pump();
    expect(chosen, isNull);
    expect(find.text('Enter the name you would like to use.'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('welcomeNameField')), ' José ');
    await tester.pumpAndSettle();
    expect(find.text('J'), findsOneWidget);
    await tester.scrollUntilVisible(
        find.byKey(const Key('welcomeContinueButton')), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('welcomeContinueButton')));
    expect(chosen, 'José');
  });
}
