import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/features/spaces/providers/spaces_providers.dart';
import 'package:budget_buddy/shared/presentation/widgets/context_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// US6 (T051): the dashboard banner names the active context — the personal
/// profile or the shared space — and only shows the "adding to «space»" hint
/// when a shared space is active.
void main() {
  UserProfile profile() => UserProfile()
    ..id = 1
    ..name = 'Ava'
    ..primaryCurrency = PrimaryCurrency.huf
    ..monthlyAvailableAmount = 0
    ..createdAt = DateTime(2026)
    ..updatedAt = DateTime(2026);

  SharedSpace space() => SharedSpace()
    ..id = 7
    ..name = 'Home'
    ..avatar = '🏠'
    ..currency = PrimaryCurrency.huf
    ..createdByProfileId = 1
    ..createdAt = DateTime(2026);

  Widget wrap({required SharedSpace? activeSpace}) {
    return ProviderScope(
      overrides: [
        activeProfileProvider.overrideWith((ref) => Stream.value(profile())),
        activeSpaceProvider.overrideWith((ref) => Stream.value(activeSpace)),
        mySpacesProvider.overrideWith((ref) => Stream.value(const [])),
      ],
      child: const MaterialApp(home: Scaffold(body: ContextBanner())),
    );
  }

  testWidgets('personal context names the profile and hides the hint',
      (tester) async {
    await tester.pumpWidget(wrap(activeSpace: null));
    await tester.pumpAndSettle();

    expect(find.byType(ContextBanner), findsOneWidget);
    expect(find.text('Personal · Ava'), findsOneWidget);
    expect(find.byKey(const Key('contextBannerHint')), findsNothing);
  });

  testWidgets('shared context names the space and shows the switch hint',
      (tester) async {
    await tester.pumpWidget(wrap(activeSpace: space()));
    await tester.pumpAndSettle();

    expect(find.text('Shared · Home'), findsOneWidget);
    final hint = find.byKey(const Key('contextBannerHint'));
    expect(hint, findsOneWidget);
    expect(
      tester.widget<Text>(hint).data,
      'You\'re adding to "Home" — tap to switch.',
    );
  });
}
