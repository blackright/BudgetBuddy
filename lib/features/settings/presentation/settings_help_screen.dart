import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'settings_copy.dart';
import 'settings_theme.dart';
import 'widgets/settings_row.dart';

/// The focused surface for replaying the introduction.
class SettingsHelpScreen extends StatelessWidget {
  const SettingsHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('settingsHelpScreen'),
      appBar: AppBar(title: const Text(SettingsCopy.help)),
      body: SettingsCardTheme(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Card(
            child: SettingsRow(
              key: const Key('replayIntroduction'),
              title: SettingsCopy.replayIntroduction,
              summary: SettingsCopy.helpSummary,
              icon: Icons.school_outlined,
              onTap: () => context.push('/introduction'),
            ),
          ),
        ),
      ),
    );
  }
}
