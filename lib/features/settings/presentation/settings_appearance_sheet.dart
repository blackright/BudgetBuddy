import 'package:flutter/material.dart';

import '../../../shared/presentation/modals/app_sheet.dart';
import 'font_setting_section.dart';
import 'settings_copy.dart';
import 'settings_theme.dart';
import 'theme_setting_section.dart';

/// The theme and font sheet reached from the Appearance row.
///
/// Both controls write immediately through their controllers; the sheet closes
/// by drag or barrier, and the hub summary follows the persisted profile.
class SettingsAppearanceSheet extends StatelessWidget {
  const SettingsAppearanceSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showAppSheet<void>(
      context,
      builder: (_) => const SettingsAppearanceSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const AppSheet(
      key: Key('settingsAppearanceSheet'),
      title: SettingsCopy.appearance,
      body: SettingsCardTheme(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ThemeSettingSection(),
            SizedBox(height: 12),
            FontSettingSection(),
          ],
        ),
      ),
    );
  }
}
