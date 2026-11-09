import 'package:flutter/material.dart';

import '../../finance/presentation/net_salary_section.dart';
import 'settings_copy.dart';
import 'settings_theme.dart';

/// The focused surface for the reviewed-transition salary fields.
///
/// It hosts the existing [NetSalarySection] unchanged, so its wording, keys and
/// write paths stay exactly as they were before the hub was reorganised.
class SettingsLegacySalaryScreen extends StatelessWidget {
  const SettingsLegacySalaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('settingsLegacySalaryScreen'),
      appBar: AppBar(title: const Text(SettingsCopy.legacySalary)),
      body: const SettingsCardTheme(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: NetSalarySection(),
        ),
      ),
    );
  }
}
