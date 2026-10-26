import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/presentation/financial_feedback.dart';
import '../providers/audit_diagnostics_provider.dart';

class AuditDiagnosticsSection extends ConsumerWidget {
  const AuditDiagnosticsSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preference = ref.watch(auditDiagnosticsControllerProvider);
    return Card(
        child: Column(children: [
      SwitchListTile(
        key: const Key('audit-diagnostics-toggle'),
        secondary: const Icon(Icons.troubleshoot_outlined),
        title: const Text('Audit technical details'),
        subtitle: Text(preference.isLoading
            ? 'Loading preference...'
            : 'For troubleshooting only. Show record references and verification data in Audit History on this device.'),
        value: preference.asData?.value ?? false,
        onChanged: preference.asData == null
            ? null
            : (value) async {
                try {
                  await ref
                      .read(auditDiagnosticsControllerProvider.notifier)
                      .setEnabled(value);
                  if (context.mounted) {
                    showFinancialFeedback(
                        context,
                        value
                            ? 'Audit technical details enabled.'
                            : 'Audit technical details hidden.');
                  }
                } catch (_) {
                  if (context.mounted) {
                    showFinancialFeedback(context,
                        'The diagnostics preference could not be saved. Please retry.',
                        kind: FinancialFeedbackKind.error);
                  }
                }
              },
      ),
      if (preference.hasError)
        Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text(
                  'Technical details are hidden until this preference can be loaded.'),
              TextButton.icon(
                  onPressed: () => ref
                      .read(auditDiagnosticsControllerProvider.notifier)
                      .reload(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry preference')),
            ])),
    ]));
  }
}
