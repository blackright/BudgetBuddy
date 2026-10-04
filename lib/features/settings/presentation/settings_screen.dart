import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/user_profile.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _showCurrencyChangeWarning(
      BuildContext context, WidgetRef ref, PrimaryCurrency newCurrency) async {
    final notifier = ref.read(settingsProvider.notifier);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Primary Currency?'),
        content: const Text(
          'Changing your primary currency midway through the month will trigger a recalculation of historical dashboards. '
          'Are you sure you want to proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Proceed'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final success = await notifier.updateCurrency(newCurrency);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Currency updated successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: state.isLoading && state.currency == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (state.errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.red.withValues(alpha: 0.1),
                      child: Text(
                        state.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 16),
                  const Text(
                    'Preferences',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<PrimaryCurrency>(
                    decoration: const InputDecoration(
                      labelText: 'Primary Currency',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: state.currency,
                    items: PrimaryCurrency.values.map((currency) {
                      return DropdownMenuItem(
                        value: currency,
                        child: Text(currency.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: state.isLoading
                        ? null
                        : (value) {
                            if (value != null && value != state.currency) {
                              _showCurrencyChangeWarning(context, ref, value);
                            }
                          },
                  ),
                ],
              ),
            ),
    );
  }
}
