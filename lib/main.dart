import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/models/user_profile.dart';
import 'core/providers/active_profile_provider.dart';

import 'core/database/isar_helper.dart';
import 'core/presentation/database_corruption_screen.dart';
import 'core/providers/database_integrity_provider.dart';
import 'core/routing/router_providers.dart';
import 'features/engine/providers/sweep_provider.dart';
import 'features/engine/seal_coordinator.dart';

import 'core/services/reminder_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsarHelper.init();

  await ReminderNotificationService().init();

  final container = ProviderContainer();
  // Execute end of month sweep check on startup
  await container.read(sweepServiceProvider).executeSweepCheck();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );

  // The seal pass runs after the first frame so it never blocks startup
  // (invariant I3), and again whenever the app resumes (FR-004).
  final sealObserver = _SealLifecycleObserver(container);
  WidgetsBinding.instance.addObserver(sealObserver);
  WidgetsBinding.instance.addPostFrameCallback((_) => sealObserver.run());
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
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) run();
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
      loading: () => const _StartupSplash(),
      error: (error, stackTrace) => const _StartupSplash(),
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

    return MaterialApp.router(
      title: 'BudgetBuddy',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        fontFamily: fontFamily,
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}

class _StartupSplash extends StatelessWidget {
  const _StartupSplash();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BudgetBuddy',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
