import 'package:flutter/material.dart';

import '../../finance/presentation/net_salary_section.dart';
import '../../identity/presentation/identity_section.dart';
import '../../pairing/presentation/paired_devices_section.dart';
import '../../pairing/presentation/people_section.dart';
import '../../spaces/presentation/space_settings_section.dart';
import 'font_setting_section.dart';
import 'profile_switcher_section.dart';
import 'shared_save_setting_section.dart';
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
          // US2: renders only when a space is active; personal context shows
          // nothing here (T036).
          SpaceSettingsSection(),
          SizedBox(height: 16),
          IdentitySection(),
          SizedBox(height: 16),
          // US7: the global People list — no active space required.
          PeopleSection(),
          SizedBox(height: 16),
          // US3: shows only once an identity exists.
          PairedDevicesSection(),
          SizedBox(height: 16),
          ProfileSwitcherSection(),
          SizedBox(height: 16),
          NetSalarySection(),
          SizedBox(height: 16),
          FontSettingSection(),
          SizedBox(height: 16),
          ThemeSettingSection(),
          SizedBox(height: 16),
          // US6: confirm saves into a shared space.
          SharedSaveSettingSection(),
        ],
      ),
    );
  }
}
