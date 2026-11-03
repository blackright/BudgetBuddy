import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/models/currency_code.dart';
import '../../../core/models/medical_bill.dart';
import '../../../core/models/money.dart';
import '../../../core/network/rate_types.dart';
import '../../../core/services/medical_management_reducer.dart';
import '../../../shared/presentation/money_conversion.dart';
import 'medical_bill_view_state.dart';
import 'medical_copy.dart';
import 'medical_status_pill.dart';
import 'medical_theme.dart';

/// One inbox row. It shows facts and exactly one resolver action label; tapping
/// the card opens detail, where guarded commands remain the only way to write.
class MedicalBillListCard extends StatelessWidget {
  const MedicalBillListCard({
    super.key,
    required this.bill,
    required this.state,
    required this.displayCurrency,
    required this.rateTable,
    this.providerName,
    this.memberName,
    this.serviceTypeName,
    this.now,
    this.onOpen,
    this.onReviewSetup,
  });

  final MedicalBill bill;
  final MedicalBillViewState state;
  final CurrencyCode displayCurrency;
  final RateTable? rateTable;
  final String? providerName;
  final String? memberName;
  final String? serviceTypeName;
  final DateTime? now;
  final VoidCallback? onOpen;
  final VoidCallback? onReviewSetup;

  @override
  Widget build(BuildContext context) {
    final management = const MedicalManagementReducer().resolve(bill);
    final statusColor =
        MedicalTheme.managementStageColor(context, management.stage);
    final statusIcon = MedicalTheme.managementStageIcon(management.stage);
    final from = bill.currencyCode ?? displayCurrency;
    final billed =
        convertAndFormat(bill.billedAmount, from, displayCurrency, rateTable);
    final meta = <Widget>[
      if (memberName != null)
        _MetaChip(icon: Icons.person_outline, label: memberName!),
      if (serviceTypeName != null)
        _MetaChip(
            icon: Icons.medical_services_outlined, label: serviceTypeName!),
    ];
    final followUp = _followUpLabel();
    final readinessBlocker = state.blocker == MedicalCopy.monthBlocked ||
        state.blocker == MedicalCopy.readinessUnknown;
    final remaining = _remaining();
    final subtle =
        TextStyle(fontSize: 12, color: MedicalTheme.subtleText(context));

    return Semantics(
      button: onOpen != null,
      label: [
        providerName ?? 'Medical bill',
        state.headline,
        state.actionLabel,
        if (followUp != null) followUp,
      ].join('. '),
      child: Card(
        margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        color: MedicalTheme.surface(context),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: statusColor.withValues(alpha: 0.25)),
        ),
        child: InkWell(
          key: Key('medicalBillCard-${bill.id}'),
          onTap: onOpen,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: statusColor, width: 4),
              ),
            ),
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(minHeight: MedicalTheme.minTouchTarget),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(statusIcon, color: statusColor, size: 21),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 2,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                providerName ?? 'Medical Bill',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 15),
                              ),
                              ConvertedAmountText(
                                text: billed.text,
                                originalText: billed.originalText,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          if (meta.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: meta,
                            ),
                          ],
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: MedicalStatusPill(
                              label: state.headline,
                              group: state.group,
                              icon: statusIcon,
                              color: statusColor,
                            ),
                          ),
                          if (followUp != null) ...[
                            const SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.schedule,
                                    size: 15, color: _followUpColor(context)),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    followUp,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _followUpColor(context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (remaining != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 2,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(remaining.label, style: subtle),
                                  ConvertedAmountText(
                                    text: remaining.amount.text,
                                    originalText: remaining.amount.originalText,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: statusColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 9),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    state.actionLabel,
                                    key: Key('medicalInboxAction-${bill.id}'),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: statusColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.arrow_forward_rounded,
                                    size: 18, color: statusColor),
                              ],
                            ),
                          ),
                          if (state.blocker != null && !readinessBlocker) ...[
                            const SizedBox(height: 6),
                            Text(state.blocker!, style: subtle),
                          ],
                          if (readinessBlocker && onReviewSetup != null) ...[
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                key: Key('medicalInboxReviewSetup-${bill.id}'),
                                style: TextButton.styleFrom(
                                  minimumSize: const Size(48, 48),
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                ),
                                onPressed: onReviewSetup,
                                icon:
                                    const Icon(Icons.build_outlined, size: 16),
                                label: const Text('Review setup'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _Remaining? _remaining() {
    if (state.isClosed) {
      final finalCost = state.estimatedFinalCost;
      return finalCost == null
          ? null
          : _Remaining('Final cost', _amount(finalCost));
    }
    final refund = state.remainingRefund;
    if (refund != null && refund.minorUnits > 0) {
      return _Remaining('Still to receive', _amount(refund));
    }
    final share = state.userObligation;
    final direct = bill.paymentMethod == MedicalPaymentMethod.insurerPaid;
    if (direct &&
        share != null &&
        state.sharePaymentLabel != 'Recorded' &&
        state.sharePaymentLabel != 'No payment needed') {
      return _Remaining(MedicalCopy.shareLeft, _amount(share));
    }
    if (share != null) {
      return _Remaining(MedicalCopy.yourShare, _amount(share));
    }
    return null;
  }

  ConvertedMoney _amount(Money money) => convertAndFormat(
        money.minorUnits,
        money.currency,
        displayCurrency,
        rateTable,
      );

  String? _followUpLabel() {
    final followUp = bill.followUpDate;
    if (followUp == null || state.group == MedicalInboxGroup.closed) {
      return null;
    }
    final at = now ?? DateTime.now();
    final difference = followUp.difference(at);
    if (difference.isNegative) {
      return 'Overdue since ${DateFormat.MMMd().format(followUp)}';
    }
    if (difference.inHours < 1) return 'Due now';
    if (difference.inHours < 24) {
      return 'Due in ${difference.inHours}h ${difference.inMinutes % 60}m';
    }
    return 'Follow up ${DateFormat.MMMd().format(followUp)}';
  }

  Color _followUpColor(BuildContext context) {
    final followUp = bill.followUpDate;
    if (followUp == null) return MedicalTheme.subtleText(context);
    final at = now ?? DateTime.now();
    return followUp.isBefore(at)
        ? MedicalTheme.semantic(context, MedicalTheme.moneyOut)
        : MedicalTheme.semantic(context, MedicalTheme.planned);
  }
}

class _Remaining {
  const _Remaining(this.label, this.amount);
  final String label;
  final ConvertedMoney amount;
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = MedicalTheme.subtleText(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
