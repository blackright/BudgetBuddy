import 'package:flutter/material.dart';

import '../../identity/presentation/app_lock_gate.dart';
import 'guided_setup_screen.dart';

/// The only setup entry. The draft is sensitive before a profile exists, so it
/// must not be constructed until native authentication succeeds. This gate
/// shares the root gate's session, so it never starts a second OS prompt.
class BudgetSetupScreen extends StatelessWidget {
  const BudgetSetupScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const AppLockGate(child: GuidedSetupScreen());
}
