import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/medical_bill.dart';
import '../providers/medical_providers.dart';
import 'medical_management_detail.dart';
import 'medical_theme.dart';

/// Detail + management view for a single medical bill.
///
/// All bills use the Bill Management workflow. Legacy rows are read through the
/// same tracker fields and keep their earlier records visible in the management
/// detail. The legacy five-state surface is no longer reachable.
class MedicalDetailScreen extends ConsumerWidget {
  const MedicalDetailScreen({super.key, required this.billId});

  final int billId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billAsync = ref.watch(medicalBillProvider(billId));

    return billAsync.when(
      data: (MedicalBill? bill) {
        if (bill == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Medical Bill')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.search_off, size: 48),
                    const SizedBox(height: 12),
                    Text('This medical bill no longer exists.',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      'It may have been deleted on this or another device. '
                      'Your recorded history is unchanged.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: MedicalTheme.subtleText(context)),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.tonalIcon(
                      onPressed: () => context.canPop()
                          ? context.pop()
                          : context.go('/medical'),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back to Medical'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return MedicalManagementDetail(billId: bill.id);
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Medical Bill')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Medical Bill')),
        body: Center(child: Text('Could not load this bill: $error')),
      ),
    );
  }
}
