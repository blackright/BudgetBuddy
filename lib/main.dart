import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/database/isar_helper.dart';
import 'features/budget_setup/presentation/budget_setup_screen.dart';

import 'features/engine/providers/sweep_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsarHelper.init();

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BudgetBuddy',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const BudgetSetupScreen(),
    );
  }
}
