import 'package:flutter/material.dart';

import '../../pairing/presentation/paired_devices_section.dart';
import '../../pairing/presentation/people_section.dart';
import '../../spaces/presentation/space_settings_section.dart';
import 'settings_copy.dart';
import 'settings_theme.dart';
import 'shared_save_setting_section.dart';

/// The focused surface for active-space management, people, devices and the
/// shared-save preference.
class SettingsSharingScreen extends StatelessWidget {
  const SettingsSharingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('settingsSharingScreen'),
      appBar: AppBar(title: const Text(SettingsCopy.sharing)),
      body: const SettingsCardTheme(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SpaceSettingsSection(),
              SizedBox(height: 12),
              PeopleSection(),
              SizedBox(height: 12),
              PairedDevicesSection(),
              SizedBox(height: 12),
              SharedSaveSettingSection(),
            ],
          ),
        ),
      ),
    );
  }
}
