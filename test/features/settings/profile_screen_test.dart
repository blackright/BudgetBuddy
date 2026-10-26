import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/identity_provider.dart';
import 'package:budget_buddy/features/settings/presentation/profile_screen.dart';
import 'package:budget_buddy/features/settings/repositories/profile_name_repository.dart';
import 'package:budget_buddy/core/services/profile_name.dart';

class _NameStore implements ProfileNameRepository {
  String name = 'Jason';
  int calls = 0;
  @override
  Isar get db => throw StateError('Widget test uses no database.');
  @override
  Future<void> rename(int profileId, String name,
      {void Function()? assertCanRename}) async {
    assertCanRename?.call();
    this.name = checkedProfileName(name);
    calls++;
  }
}

void main() {
  Future<_NameStore> pump(WidgetTester tester,
      {double scale = 1, ThemeMode mode = ThemeMode.light}) async {
    final profile = UserProfile()
      ..id = 1
      ..name = 'Jason'
      ..primaryCurrency = PrimaryCurrency.huf
      ..monthlyAvailableAmount = 0
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);
    final store = _NameStore();
    await tester.pumpWidget(ProviderScope(
        overrides: [
          activeProfileIdProvider.overrideWith((ref) => 1),
          activeProfileProvider.overrideWith((ref) => Stream.value(profile)),
          profilesProvider.overrideWith((ref) => Stream.value([profile])),
          identityProvider.overrideWith((ref) => Stream.value(null)),
          profileNameRepositoryProvider.overrideWithValue(store)
        ],
        child: MaterialApp(
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: mode,
            builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(scale)),
                child: child!),
            home: const ProfileScreen())));
    await tester.pumpAndSettle();
    return store;
  }

  testWidgets('name edit validates and Cancel never writes', (tester) async {
    final store = await pump(tester);
    await tester.tap(find.byKey(const Key('editProfileNameButton')));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const Key('editProfileNameField')), '   ');
    await tester.tap(find.byKey(const Key('saveProfileNameButton')));
    await tester.pumpAndSettle();
    expect(find.text('Enter the name you would like to use.'), findsOneWidget);
    expect(store.calls, 0);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(store.name, 'Jason');
  });
  testWidgets('name edit previews initial and saves confirmed trimmed name',
      (tester) async {
    final store = await pump(tester);
    await tester.tap(find.byKey(const Key('editProfileNameButton')));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const Key('editProfileNameField')), ' Émilie ');
    await tester.pumpAndSettle();
    expect(find.text('É'), findsOneWidget);
    await tester.tap(find.byKey(const Key('saveProfileNameButton')));
    await tester.pumpAndSettle();
    expect(store.name, 'Émilie');
    expect(store.calls, 1);
    expect(find.text('Profile name updated.'), findsOneWidget);
  });
  for (final mode in [ThemeMode.dark, ThemeMode.light]) {
    testWidgets('Profile page fits 320px large text $mode', (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await pump(tester, scale: 1.8, mode: mode);
      expect(tester.takeException(), isNull);
      await tester.drag(find.byType(ListView).first, const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
