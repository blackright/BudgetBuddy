import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'audit_diagnostics_section.dart';
import 'settings_copy.dart';
import 'settings_legacy_salary_screen.dart';
import 'settings_theme.dart';

/// The focused surface for History, Technical details and Legacy salary.
///
/// History keeps its existing global route. Legacy salary is pushed here with a
/// `MaterialPageRoute` so the routing table only owns the screens that already
/// had one.
class SettingsAdvancedScreen extends StatelessWidget {
  const SettingsAdvancedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('settingsAdvancedScreen'),
      appBar: AppBar(title: const Text(SettingsCopy.advanced)),
      body: SettingsCardTheme(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: ListTile(
                  key: const Key('settingsHistoryRow'),
                  leading: const Icon(Icons.history),
                  title: const Text(SettingsCopy.history),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/audit_history'),
                ),
              ),
              const SizedBox(height: 12),
              const AuditDiagnosticsSection(
                title: SettingsCopy.technicalDetails,
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  key: const Key('settingsLegacySalaryRow'),
                  leading: const Icon(Icons.payments_outlined),
                  title: const Text(SettingsCopy.legacySalary),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => const SettingsLegacySalaryScreen(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
