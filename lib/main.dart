import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/models/user_profile.dart';
import 'core/providers/active_profile_provider.dart';

import 'core/database/isar_helper.dart';
import 'core/routing/router_providers.dart';
import 'features/engine/providers/sweep_provider.dart';

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
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final activeProfileAsync = ref.watch(activeProfileProvider);
    final AppFontFamily familySelection = activeProfileAsync.valueOrNull?.fontFamily ?? AppFontFamily.system;

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
