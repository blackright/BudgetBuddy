import 'package:flutter/material.dart';

import '../../finance/presentation/net_salary_section.dart';
import 'font_setting_section.dart';
import 'theme_setting_section.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          NetSalarySection(),
          SizedBox(height: 16),
          FontSettingSection(),
          SizedBox(height: 16),
          ThemeSettingSection(),
        ],
      ),
    );
  }
}
