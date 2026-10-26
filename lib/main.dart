import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/models/user_profile.dart';
import 'core/presentation/app_themes.dart';
import 'core/providers/active_profile_provider.dart';
import 'core/providers/selected_month_provider.dart';

import 'core/database/isar_helper.dart';
import 'core/presentation/database_corruption_screen.dart';
import 'core/providers/database_integrity_provider.dart';
import 'core/routing/router_providers.dart';
import 'features/engine/providers/sweep_provider.dart';
import 'features/engine/seal_coordinator.dart';
import 'features/identity/presentation/app_lock_gate.dart';
import 'features/security/providers/lock_lifecycle_observer.dart';
import 'features/security/repositories/monotonic_clock_impl.dart';
import 'features/settings/providers/settings_provider.dart';
import 'features/sync/providers/sync_coordinator_provider.dart';
import 'features/sync/repositories/sync_coordinator.dart';

import 'core/services/reminder_notification_service.dart';
import 'features/vault/providers/vault_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsarHelper.init();
  // Read the boot-relative monotonic base before the first frame, so the lock's
  // away-time and lockout wait use `SystemClock.elapsedRealtime()` rather than
  // the clamped wall-clock fallback (FR-015, research R3).
  await appMonotonicClock.warmUp();

  final container = ProviderContainer();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );

  // The vault sweep runs after the first frame — never before it — because it
  // needs the rate registry and the active profile hydrated. It runs again on
  // resume so a month that rolled over while the app was backgrounded is swept
  // without waiting for a cold start.
  final sweepObserver = _SweepLifecycleObserver(container);
  WidgetsBinding.instance.addObserver(sweepObserver);

  // The seal pass runs after the first frame so it never blocks startup
  // (invariant I3), and again whenever the app resumes (FR-004).
  final sealObserver = _SealLifecycleObserver(container);
  WidgetsBinding.instance.addObserver(sealObserver);
  // The exchange loop follows the app lifecycle: it runs while foregrounded and
  // an unlocked session exists, and stops the moment either goes away (FR-009).
  final syncObserver = _SyncLifecycleObserver(container);
  WidgetsBinding.instance.addObserver(syncObserver);
  // The lock follows the app lifecycle too: it starts the away window when the
  // app backgrounds and re-locks on resume when the away-time has passed, or
  // immediately when the phone's own lock engaged (FR-022).
  final lockObserver = LockLifecycleObserver(container);
  WidgetsBinding.instance.addObserver(lockObserver);
  WidgetsBinding.instance.addPostFrameCallback((_) {
    sweepObserver.run();
    sealObserver.run();
    syncObserver.run();
    // Warm up notifications only once the first frame is up, so the Android
    // plugin's context is guaranteed to exist (never block startup on it).
    unawaited(ReminderNotificationService().ensureInitialized());
  });
}

/// Runs the end-of-month Savings Vault sweep on cold start and resume.
///
/// Fire-and-forget: the sweep is personal and best-effort, and a paused sweep
/// surfaces its reason in the vault screen rather than blocking the UI.
class _SweepLifecycleObserver extends WidgetsBindingObserver {
  _SweepLifecycleObserver(this._container);

  final ProviderContainer _container;

  void run() {
    _container.invalidate(vaultNowProvider);
    unawaited(_container.read(sweepServiceProvider).executeSweepCheck());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) run();
  }
}

/// Drives the device-global month-seal coordinator on cold start and resume.
class _SealLifecycleObserver extends WidgetsBindingObserver {
  _SealLifecycleObserver(this._container);

  final ProviderContainer _container;

  void run() {
    // Fire-and-forget: a failed fetch downgrades labels, never blocks the UI.
    unawaited(
      _container.read(sealCoordinatorProvider).runSealPass(DateTime.now()),
    );
    _snapToCurrentMonth();
  }

  /// US8: if the app comes back after the month rolled over, show the current
  /// month rather than the one it was left on. A current or deliberately chosen
  /// future month is left alone.
  void _snapToCurrentMonth() {
    final selected = _container.read(selectedYearMonthProvider);
    final snapped = snapToCurrentMonthIfBehind(selected);
    if (snapped != selected) {
      _container.read(selectedYearMonthProvider.notifier).state = snapped;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) run();
  }
}

/// Starts and stops the peer-to-peer exchange with the app lifecycle
/// (FR-009, `contracts/runtime-orchestration.md` §1).
///
/// It runs the [SyncCoordinator] while the app is foregrounded **and** an
/// unlocked session exists, and stops it when either goes away — so nothing is
/// transmitted while backgrounded or locked, and there is no background service.
class _SyncLifecycleObserver extends WidgetsBindingObserver {
  _SyncLifecycleObserver(this._container) {
    // Rebuilds whenever the session unlocks/locks or a pairing changes; only the
    // running coordinator is started, and the previous one is always stopped.
    _subscription = _container.listen<SyncCoordinator?>(
      syncCoordinatorProvider,
      _reconcile,
    );
  }

  final ProviderContainer _container;
  late final ProviderSubscription<SyncCoordinator?> _subscription;
  bool _foreground = true;

  void _reconcile(SyncCoordinator? previous, SyncCoordinator? next) {
    if (identical(previous, next)) return;
    if (previous != null) unawaited(previous.stop());
    if (next != null && _foreground) unawaited(next.start());
  }

  /// Runs once after the first frame, when the app is already foregrounded.
  void run() {
    final coordinator = _container.read(syncCoordinatorProvider);
    if (coordinator != null && _foreground) unawaited(coordinator.start());
  }

  /// Detaches the provider listener (the observer lives for the app's lifetime).
  void dispose() => _subscription.close();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _foreground = true;
        final coordinator = _container.read(syncCoordinatorProvider);
        if (coordinator != null) unawaited(coordinator.start());
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _foreground = false;
        final coordinator = _container.read(syncCoordinatorProvider);
        if (coordinator != null) unawaited(coordinator.stop());
      case AppLifecycleState.inactive:
        // Transient (app switcher, a call); keep the loop running.
        break;
    }
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Refuse to render money the current schema cannot read (T-R11): a
    // pre-`int` database reinterpreted by the type cut would otherwise show
    // nonsense numbers or crash a screen.
    final integrity = ref.watch(moneyIntegrityIssuesProvider);
    return integrity.when(
      skipLoadingOnRefresh: false,
      loading: () => const _StartupSplash(),
      error: (error, stackTrace) => _StartupSplash(
        onRetry: () => ref.invalidate(moneyIntegrityIssuesProvider),
      ),
      data: (issues) => issues.isEmpty
          ? _buildRouterApp(context, ref)
          : DatabaseCorruptionScreen(issues: issues),
    );
  }

  Widget _buildRouterApp(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final activeProfileAsync = ref.watch(activeProfileProvider);
    final AppFontFamily familySelection =
        activeProfileAsync.valueOrNull?.fontFamily ?? AppFontFamily.system;

    String? fontFamily;
    switch (familySelection) {
      case AppFontFamily.roboto:
        fontFamily = GoogleFonts.roboto().fontFamily;
        break;
      case AppFontFamily.inter:
        fontFamily = GoogleFonts.inter().fontFamily;
        break;
      case AppFontFamily.openSans:
        fontFamily = GoogleFonts.openSans().fontFamily;
        break;
      case AppFontFamily.system:
        fontFamily = null;
    }

    // Phase 9-E (T062): theme follows the profile preference and defaults to
    // the operating system. Both modes are built from the same seed, so the
    // Settings font choice applies in light and dark alike.
    final themeMode = switch (ref.watch(appThemeModeProvider)) {
      AppThemeMode.system => ThemeMode.system,
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark => ThemeMode.dark,
    };

    return MaterialApp.router(
      title: 'BudgetBuddy',
      theme: buildAppTheme(
        brightness: Brightness.light,
        fontFamily: fontFamily,
      ),
      darkTheme: buildAppTheme(
        brightness: Brightness.dark,
        fontFamily: fontFamily,
      ),
      themeMode: themeMode,
      routerConfig: router,
      // US1 (FR-002 AC2): when the user has an identity and has granted device
      // auth, the app opens behind the phone's own authentication. Inert
      // otherwise, so existing (identity-less) installs are unchanged.
      builder: (context, child) =>
          AppLockGate(child: child ?? const SizedBox.shrink()),
    );
  }
}

class _StartupSplash extends StatelessWidget {
  const _StartupSplash({this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BudgetBuddy',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: Center(
          child: onRetry == null
              ? const CircularProgressIndicator()
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Unable to check saved data'),
                      const SizedBox(height: 12),
                      const Text(
                        'Your data has not been changed. Retry the safety '
                        'check to continue.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: onRetry,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
