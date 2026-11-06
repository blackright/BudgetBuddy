import '../../../core/providers/budget_context_provider.dart';
import '../../spaces/providers/spaces_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/active_space_provider.dart';
import '../../../core/providers/selected_month_provider.dart';
import '../../identity/providers/device_auth_session.dart';
import '../../security/providers/lock_providers.dart';
import '../providers/medical_providers.dart' show MedicalDirectory;
import 'package:flutter/material.dart';
import '../../../shared/presentation/modals/app_dialog.dart';
import '../../../core/models/medical_bill.dart';
import '../../../core/models/currency_code.dart';
import '../../../core/services/medical_bill_review_service.dart';
import '../../../shared/presentation/money_format.dart';

/// Explicit reason is collected before constructing a source-bound preview.
Future<String?> medicalReviewReason(BuildContext context, String title,
        {bool Function()? isAccessCurrent}) =>
    showAppDialog<String>(
        context: context,
        builder: (dialog) => guardMedicalReview(
            dialog, isAccessCurrent, () => _MedicalReasonDialog(title: title)));

Widget guardMedicalReview(
    BuildContext dialog, bool Function()? access, Widget Function() child) {
  if (access == null) return child();
  return Consumer(builder: (_, ref, __) {
    ref.watch(budgetContextProvider);
    ref.watch(actingProfileIdProvider);
    ref.watch(activeContextCanEditProvider);
    ref.watch(deviceAuthSessionProvider);
    ref.watch(lockControllerProvider);
    ref.watch(activeProfileIdProvider);
    ref.watch(activeSpaceIdProvider);
    ref.watch(selectedYearMonthProvider);
    if (!access()) {
      return AppDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Access changed'),
          content:
              const Text('Unlock the correct profile and reopen this review.'),
          actions: [
            TextButton(
                style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                onPressed: () => Navigator.pop(dialog),
                child: const Text('Close'))
          ]);
    }
    return child();
  });
}

class _MedicalReasonDialog extends StatefulWidget {
  const _MedicalReasonDialog({required this.title});
  final String title;
  @override
  State<_MedicalReasonDialog> createState() => _MedicalReasonDialogState();
}

class _MedicalReasonDialogState extends State<_MedicalReasonDialog> {
  final controller = TextEditingController();
  final form = GlobalKey<FormState>();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(widget.title),
          content: Form(
              key: form,
              child: TextFormField(
                  controller: controller,
                  autofocus: true,
                  maxLength: 240,
                  maxLines: 3,
                  decoration: const InputDecoration(
                      labelText: 'Reason',
                      helperText: 'Kept in the claim history.'),
                  validator: (text) =>
                      (text ?? '').trim().isEmpty ? 'Enter a reason.' : null)),
          actions: [
            TextButton(
                style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                onPressed: () => Navigator.pop(context),
                child: const Text('Keep unchanged')),
            FilledButton(
                style: FilledButton.styleFrom(minimumSize: const Size(48, 48)),
                onPressed: () {
                  if (form.currentState!.validate()) {
                    Navigator.pop(context, controller.text.trim());
                  }
                },
                child: const Text('Review'))
          ]);
}

Future<bool> confirmMedicalBillReview(
    BuildContext context, MedicalBillReview review,
    {MedicalDirectory? directory,
    Map<int, String> services = const {},
    bool Function()? isAccessCurrent}) async {
  String money(int amount, String currency) {
    final code = CurrencyCode.tryParse(currency);
    return code == null
        ? '$amount ${currency.toUpperCase()}'
        : '${currency.toUpperCase()} ${formatMinorUnitsInput(amount, code)}';
  }

  String details(MedicalBill b) =>
      '${b.state == MedicalBillState.rejected ? 'Insurance declined\n' : ''}'
      '${money(b.billedAmount, b.currency)} · Your share ${b.patientSharePercent}%\n'
      '${b.paymentMethod.label} · ${b.yearMonth}\n'
      '${b.serviceDate?.toLocal().toString().split(' ').first ?? 'Date not recorded'}\n'
      'Provider: ${directory?.providerName(b.providerId) ?? 'Not recorded'}\n'
      'Person: ${directory?.memberName(b.familyMemberId) ?? 'Not recorded'}\n'
      'Service: ${services[b.serviceTypeId] ?? 'Not recorded'}';
  return await showAppDialog<bool>(
          context: context,
          builder: (dialog) => guardMedicalReview(
              dialog,
              isAccessCurrent,
              () => AppDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      title: Text(review.remove
                          ? 'Review bill entered in error'
                          : 'Review bill correction'),
                      content: SingleChildScrollView(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                            Text(
                                'Recorded on: ${DateTime.now().toLocal().toString().substring(0, 10)}'),
                            const Text('Before',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(details(review.original)),
                            const SizedBox(height: 12),
                            const Text('After',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(review.remove
                                ? 'Bill retained as entered in error; its expense is cancelled.'
                                : details(review.proposed)),
                            const SizedBox(height: 12),
                            Text(
                                'Recorded payment: ${money(review.beforeMinor, review.original.currency)} → ${money(review.afterMinor, review.proposed.currency)}'),
                            if (review.paymentDate != null)
                              Text(
                                  'Payment date: ${review.previousPaymentDate?.toLocal().toString().substring(0, 10) ?? "Not recorded"} to ${review.paymentDate!.toLocal().toString().substring(0, 10)}'),
                            Text('Reason: ${review.reason}'),
                            const SizedBox(height: 12),
                            const Text(
                                'Earlier bill and approval details stay in history. No bank transfer is made.'),
                            if (review.approvalGuid != null && !review.remove)
                              const Text(
                                  'The previous approval will need review before received money can be confirmed.'),
                          ])),
                      actions: [
                        TextButton(
                            style: TextButton.styleFrom(
                                minimumSize: const Size(48, 48)),
                            onPressed: () => Navigator.pop(dialog, false),
                            child: const Text('Keep unchanged')),
                        FilledButton(
                            style: FilledButton.styleFrom(
                                minimumSize: const Size(48, 48)),
                            onPressed: () => Navigator.pop(dialog, true),
                            child: const Text('Confirm reviewed change'))
                      ]))) ??
      false;
}
