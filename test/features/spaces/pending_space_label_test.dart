import 'dart:async';

import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/features/spaces/presentation/space_switcher.dart';
import 'package:budget_buddy/features/spaces/providers/spaces_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// T072: a freshly-added phone shows a "waiting for first sync" hint while its
/// space is still the bare `resolveLocalContext` anchor, and the hint gives way
/// to the real name as soon as the peer's space record lands.
///
/// Driven purely by overridden streams — no Isar, so nothing fights the
/// widget-test fake clock.
void main() {
  testWidgets(
      'a placeholder space shows a waiting hint until the real space arrives '
      '(T071/T072)', (WidgetTester tester) async {
    final profile = UserProfile()
      ..id = 1
      ..name = 'Ava'
      ..primaryCurrency = PrimaryCurrency.usd
      ..createdAt = DateTime(2026, 1, 1)
      ..updatedAt = DateTime(2026, 1, 1);

    // The bare anchor stored on first sight of the peer's GUID: name is the
    // fallback and `createdAt` is the epoch sentinel.
    SharedSpace placeholder() => SharedSpace()
      ..id = 7
      ..syncGuid = 'space-guid'
      ..name = 'Shared space'
      ..currency = PrimaryCurrency.usd
      ..createdByProfileId = 0
      ..createdAt = DateTime.fromMillisecondsSinceEpoch(0);

    // The same local row once the peer's real space record is applied.
    SharedSpace hydrated() => SharedSpace()
      ..id = 7
      ..syncGuid = 'space-guid'
      ..name = 'Family budget'
      ..currency = PrimaryCurrency.usd
      ..createdByProfileId = 1
      ..createdAt = DateTime(2026, 1, 1);

    final active = StreamController<SharedSpace?>.broadcast();
    final mine = StreamController<List<SharedSpace>>.broadcast();
    addTearDown(active.close);
    addTearDown(mine.close);

    final container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith((ref) => Stream.value([profile])),
        activeProfileProvider.overrideWith((ref) => Stream.value(profile)),
        activeSpaceProvider.overrideWith((ref) => active.stream),
        mySpacesProvider.overrideWith((ref) => mine.stream),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: SpaceSwitcher())),
      ),
    );

    // Before the first sync: a waiting hint, never a bare "Shared space".
    active.add(placeholder());
    mine.add([placeholder()]);
    await tester.pump();
    await tester.pump();
    expect(find.textContaining('Waiting for first sync'), findsOneWidget);
    expect(find.textContaining('Shared space'), findsNothing);

    // Once the real space row arrives the hint gives way to the real name.
    active.add(hydrated());
    mine.add([hydrated()]);
    await tester.pump();
    await tester.pump();
    expect(find.textContaining('Family budget'), findsOneWidget);
    expect(find.textContaining('Waiting for first sync'), findsNothing);
  });
}
