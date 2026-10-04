import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/database/isar_helper.dart';
import 'features/budget_setup/presentation/budget_setup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsarHelper.init();

  runApp(
    const ProviderScope(
      child: MyApp(),
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
