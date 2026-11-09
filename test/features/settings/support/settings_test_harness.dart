import 'package:budget_buddy/core/models/budget_profile.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/direct_expense_profile.dart';
import 'package:budget_buddy/core/models/identity.dart';
import 'package:budget_buddy/core/models/income_source.dart';
import 'package:budget_buddy/core/models/lock_setting.dart';
import 'package:budget_buddy/core/models/paired_peer.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/presentation/app_themes.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/core/providers/identity_provider.dart';
import 'package:budget_buddy/core/providers/selected_month_provider.dart';
import 'package:budget_buddy/features/finance/providers/income_source_providers.dart';
import 'package:budget_buddy/features/finance/providers/profile_providers.dart';
import 'package:budget_buddy/features/identity/repositories/secret_store.dart';
import 'package:budget_buddy/features/pairing/providers/pairing_providers.dart';
import 'package:budget_buddy/features/security/domain/lock_subject.dart';
import 'package:budget_buddy/features/security/providers/lock_providers.dart';
import 'package:budget_buddy/features/settings/providers/audit_diagnostics_provider.dart';
import 'package:budget_buddy/features/settings/providers/settings_provider.dart';
import 'package:budget_buddy/features/spaces/providers/spaces_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// The month every Settings test fixture uses.
const String settingsTestMonth = '2026-01';

/// Base provider overrides and fixtures for the Settings surfaces.
///
/// The harness mirrors the real marker-derived providers so changing
/// `activeProfileIdProvider` or `activeSpaceIdProvider` updates the context in
/// the same frame. It covers personal/shared, read-only, lock and appearance
/// states; tests that need a write path or a surface-specific repository append
/// their own overrides through [extraOverrides].
class SettingsTestHarness {
  SettingsTestHarness({
    List<UserProfile>? profiles,
    List<SharedSpace>? spaces,
    this.isShared = false,
    this.canEdit = true,
    this.hasLockSubject = true,
    this.lockEnabled = false,
    this.hasIdentity = true,
    this.themeMode = ThemeMode.light,
    this.extraOverrides = const [],
  })  : profiles = profiles ??
            [
              settingsTestProfile(),
              settingsTestProfile(id: 2, name: 'Bea', avatar: '🧑‍🦰'),
            ],
        spaces = spaces ?? [settingsTestSpace()] {
    assert(this.profiles.isNotEmpty, 'SettingsTestHarness needs a profile');
    assert(this.spaces.isNotEmpty, 'SettingsTestHarness needs a space');
  }

  final List<UserProfile> profiles;
  final List<SharedSpace> spaces;
  final bool isShared;
  final bool canEdit;
  final bool hasLockSubject;
  final bool lockEnabled;
  final bool hasIdentity;
  final ThemeMode themeMode;
  final List<Override> extraOverrides;

  UserProfile get activeProfile => profiles.first;
  SharedSpace get activeSpace => spaces.first;

  UserProfile _profileFor(int? id) => id == null
      ? activeProfile
      : profiles.firstWhere((profile) => profile.id == id,
          orElse: () => activeProfile);

  SharedSpace _spaceFor(int? id) => id == null
      ? activeSpace
      : spaces.firstWhere((space) => space.id == id, orElse: () => activeSpace);

  LockSubject _subjectFor(SharedSpace? space, UserProfile profile) {
    if (space != null) {
      return LockSubject.space(
        localId: space.id,
        syncGuid: space.syncGuid,
        name: space.displayName,
        avatar: space.avatar,
      );
    }
    return LockSubject.profile(
      id: profile.id,
      name: profile.name,
      avatar: profile.avatar,
    );
  }

  List<SharedMember> _membersFor(SharedSpace? space) {
    if (space == null) return const [];
    return [
      for (var index = 0; index < profiles.length; index++)
        SharedMember()
          ..id = index + 1
          ..sharedSpaceId = space.id
          ..profileId = profiles[index].id
          ..role = index == 0 ? SharedMemberRole.owner : SharedMemberRole.editor
          ..joinedAt = DateTime(2026),
    ];
  }

  Identity _identityFor(UserProfile profile) => Identity()
    ..id = 1
    ..localProfileId = profile.id
    ..username = profile.name
    ..fingerprint = 'fp-${profile.id}'
    ..publicKey = 'test-public-key'
    ..createdAt = DateTime(2026)
    ..updatedAt = DateTime(2026);

  /// The base overrides plus any test-specific [extraOverrides].
  List<Override> get overrides => [
        profilesProvider.overrideWith(
          (ref) => Stream<List<UserProfile>>.value(profiles),
        ),
        activeProfileIdProvider.overrideWith((ref) => activeProfile.id),
        activeSpaceIdProvider.overrideWith(
          (ref) => isShared ? activeSpace.id : null,
        ),
        activeProfileProvider.overrideWith((ref) {
          final id = ref.watch(activeProfileIdProvider);
          return Stream<UserProfile?>.value(_profileFor(id));
        }),
        activeSpaceProvider.overrideWith((ref) {
          final id = ref.watch(activeSpaceIdProvider);
          return Stream<SharedSpace?>.value(id == null ? null : _spaceFor(id));
        }),
        budgetContextProvider.overrideWith((ref) {
          final spaceId = ref.watch(activeSpaceIdProvider);
          if (spaceId != null) {
            return ContextRef.shared(
              spaceId: spaceId,
              yearMonth: settingsTestMonth,
            );
          }
          final profile =
              ref.watch(activeProfileProvider).valueOrNull ?? activeProfile;
          return ContextRef.personal(
            profileId: profile.id,
            yearMonth: settingsTestMonth,
          );
        }),
        selectedYearMonthProvider.overrideWith((ref) => settingsTestMonth),
        mainCurrencyProvider.overrideWith((ref) {
          final spaceId = ref.watch(activeSpaceIdProvider);
          if (spaceId != null) return _spaceFor(spaceId).currency.code;
          final profile =
              ref.watch(activeProfileProvider).valueOrNull ?? activeProfile;
          return profile.primaryCurrency.code;
        }),
        activeContextCanEditProvider.overrideWithValue(canEdit),
        lockSubjectProvider.overrideWith((ref) {
          if (!hasLockSubject) return null;
          final spaceId = ref.watch(activeSpaceIdProvider);
          final profile =
              ref.watch(activeProfileProvider).valueOrNull ?? activeProfile;
          return _subjectFor(
            spaceId == null ? null : _spaceFor(spaceId),
            profile,
          );
        }),
        activeLockSettingProvider.overrideWith((ref) {
          final subject = ref.watch(lockSubjectProvider);
          if (subject == null) return Stream<LockSetting?>.value(null);
          return Stream<LockSetting?>.value(
            LockSetting.forSubject(subject)..lockEnabled = lockEnabled,
          );
        }),
        identityProvider.overrideWith((ref) {
          if (!hasIdentity) return Stream<Identity?>.value(null);
          final profile =
              ref.watch(activeProfileProvider).valueOrNull ?? activeProfile;
          return Stream<Identity?>.value(_identityFor(profile));
        }),
        mySpacesProvider.overrideWith(
          (ref) => Stream<List<SharedSpace>>.value(spaces),
        ),
        activeSpaceMembersProvider.overrideWith((ref) {
          final spaceId = ref.watch(activeSpaceIdProvider);
          return Stream<List<SharedMember>>.value(
            _membersFor(spaceId == null ? null : _spaceFor(spaceId)),
          );
        }),
        activeSpaceMyRoleProvider.overrideWith((ref) {
          final spaceId = ref.watch(activeSpaceIdProvider);
          if (spaceId == null) return null;
          final profile =
              ref.watch(activeProfileProvider).valueOrNull ?? activeProfile;
          for (final member in _membersFor(_spaceFor(spaceId))) {
            if (member.profileId == profile.id) return member;
          }
          return null;
        }),
        memberDisplayNamesProvider.overrideWithValue({
          for (final profile in profiles) profile.id: profile.name,
        }),
        pairedPeersProvider.overrideWith(
          (ref) => Stream<List<PairedPeer>>.value(const <PairedPeer>[]),
        ),
        pairingServiceProvider.overrideWithValue(null),
        incomeSourcesProvider.overrideWith(
          (ref) => Stream<List<IncomeSource>>.value(const <IncomeSource>[]),
        ),
        budgetProfilesProvider.overrideWith(
          (ref) => Stream<List<BudgetProfile>>.value(const <BudgetProfile>[]),
        ),
        directExpenseProfilesProvider.overrideWith(
          (ref) => Stream<List<DirectExpenseProfile>>.value(
            const <DirectExpenseProfile>[],
          ),
        ),
        deviceAuthEnabledProvider.overrideWithValue(false),
        auditDiagnosticsStoreProvider.overrideWithValue(InMemorySecretStore()),
        ...extraOverrides,
      ];

  /// A Material app with the harness overrides and the app's real themes.
  Widget app(Widget home, {ThemeMode? themeMode}) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: buildAppTheme(brightness: Brightness.light),
        darkTheme: buildAppTheme(brightness: Brightness.dark),
        themeMode: themeMode ?? this.themeMode,
        home: home,
      ),
    );
  }

  /// Pumps [home] at a controlled viewport and text scale.
  Future<void> pump(
    WidgetTester tester,
    Widget home, {
    Size size = const Size(360, 800),
    double textScale = 1,
    ThemeMode? themeMode,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(app(home, themeMode: themeMode));
    await tester.pumpAndSettle();
  }

  /// A container for pure provider tests. The caller must be inside a test.
  ProviderContainer container() {
    final container = ProviderContainer(overrides: overrides);
    addTearDown(container.dispose);
    return container;
  }
}

UserProfile settingsTestProfile({
  int id = 1,
  String name = 'Alex',
  String avatar = '🧑',
  PrimaryCurrency currency = PrimaryCurrency.huf,
  AppThemeMode themeMode = AppThemeMode.system,
  AppFontFamily fontFamily = AppFontFamily.system,
  bool confirmSharedSave = true,
}) {
  return UserProfile()
    ..id = id
    ..name = name
    ..avatar = avatar
    ..primaryCurrency = currency
    ..monthlyAvailableAmount = 0
    ..themeMode = themeMode
    ..fontFamily = fontFamily
    ..confirmSharedSave = confirmSharedSave
    ..createdAt = DateTime(2026)
    ..updatedAt = DateTime(2026);
}

SharedSpace settingsTestSpace({
  int id = 10,
  String name = 'Home',
  String avatar = '🏠',
  PrimaryCurrency currency = PrimaryCurrency.huf,
}) {
  return SharedSpace()
    ..id = id
    ..name = name
    ..avatar = avatar
    ..currency = currency
    ..createdByProfileId = 1
    ..createdAt = DateTime(2026);
}
