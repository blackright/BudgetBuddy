import 'package:flutter/material.dart';

import '../../identity/presentation/identity_section.dart';
import '../../spaces/presentation/spaces_list_section.dart';
import 'profile_switcher_section.dart';
import 'settings_copy.dart';
import 'settings_theme.dart';

/// The focused surface for profile switching, identity and spaces.
///
/// The existing sections own their dialogs, keys and write paths; this screen
/// only gives them one focused, consistently styled place.
class SettingsProfileSpaceScreen extends StatelessWidget {
  const SettingsProfileSpaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('settingsProfileSpaceScreen'),
      appBar: AppBar(title: const Text(SettingsCopy.profileSpace)),
      body: const SettingsCardTheme(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileSwitcherSection(),
              SizedBox(height: 12),
              IdentitySection(),
              SizedBox(height: 12),
              SpacesListSection(),
            ],
          ),
        ),
      ),
    );
  }
}
