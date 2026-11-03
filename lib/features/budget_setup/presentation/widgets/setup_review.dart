import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../shared/presentation/money_format.dart';
import '../../../../shared/presentation/widgets/app_card.dart';
import '../../domain/onboarding_finance.dart';
import '../../domain/onboarding_starting_position.dart';
import 'setup_form_components.dart';

class SetupReview extends StatelessWidget {
  const SetupReview(
      {super.key,
      required this.review,
      required this.editProfile,
      required this.editMonthIncome});
  final OnboardingReview review;
  final VoidCallback editProfile, editMonthIncome;
  @override
  Widget build(BuildContext context) {
    final d = review.normalized;
    String money(int value) => formatMinorUnits(value, review.currency);
    Widget line(String label, String amount) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: SizedBox(
            width: double.infinity,
            child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 16,
                runSpacing: 4,
                children: [
                  Text(label),
                  Text(amount,
                      style: const TextStyle(fontWeight: FontWeight.w700))
                ])));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Review your first month',
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      const Text('One last look before anything becomes recorded money.'),
      const SizedBox(height: 24),
      SetupSurface(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const AppSectionHeader(
          icon: Icons.person_outline,
          title: 'Profile',
          subtitle: 'The owner of this setup.',
        ),
        const SizedBox(height: 12),
        Text(d.profile.name,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w800)),
        Text(
            '${DateFormat.yMMMM().format(DateTime.parse('${d.yearMonth}-01'))} · ${review.currency.name.toUpperCase()}'),
        OutlinedButton.icon(
            key: const Key('editFinancialProfile'),
            onPressed: editProfile,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit profile'))
      ])),
      SetupSurface(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const AppSectionHeader(
          icon: Icons.payments_outlined,
          title: 'Month and income',
          subtitle: 'Opening money is separate from income.',
        ),
        const SizedBox(height: 12),
        line(
            'Opening balance',
            d.opening.minorUnits == null
                ? 'Not confirmed'
                : money(d.opening.minorUnits!)),
        const Divider(),
        for (final c in review.contributions) ...[
          line(c.name, money(c.minor)),
          Text(c.explanation, style: Theme.of(context).textTheme.bodySmall)
        ],
        if (review.contributions.isEmpty)
          const Text('No income yet. No source will be created.'),
        const Divider(),
        line('Monthly income', money(review.incomeMinor)),
        OutlinedButton.icon(
            key: const Key('editMonthIncome'),
            onPressed: editMonthIncome,
            icon: const Icon(Icons.edit_calendar_outlined),
            label: const Text('Edit month & income'))
      ])),
      SetupSurface(
          highlight: true,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const AppSectionHeader(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Your first month',
              subtitle: 'What is available before expenses and allocations.',
            ),
            const SizedBox(height: 12),
            const Text('FREE TO SPEND',
                style:
                    TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1.3)),
            const SizedBox(height: 8),
            Text(money(review.freeMinor),
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text(
                'Income available before expenses and allocations. Opening money is separate.'),
            const Divider(height: 28),
            line(
                'Money in bank',
                review.bankMinor == null
                    ? 'Opening not confirmed'
                    : money(review.bankMinor!))
          ])),
      const Text(
          'Saving records your financial details together. Remaining setup preparation and security are separate steps.'),
    ]);
  }
}

/// The final first-month position after activation choices are saved.
///
/// Only opening money and confirmed actual receipts are available. Pending,
/// skipped, cancelled and not-configured amounts remain visible but excluded.
class StartingPositionReview extends StatelessWidget {
  const StartingPositionReview({super.key, required this.position});
  final OnboardingStartingPosition position;

  String _money(int minor) => formatMinorUnits(minor, position.currency);

  Widget _line(BuildContext context, StartingPositionLine line) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
              width: double.infinity,
              child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: 16,
                  runSpacing: 4,
                  children: [
                    Text(line.name),
                    Text(_money(line.minor),
                        style: const TextStyle(fontWeight: FontWeight.w700))
                  ])),
          if (line.note != null)
            Text(line.note!, style: Theme.of(context).textTheme.bodySmall),
        ]),
      );

  Widget _section(
    BuildContext context, {
    required String title,
    required String subtitle,
    required List<StartingPositionLine> lines,
    required int total,
    String? emptyText,
    String? note,
  }) =>
      SetupSurface(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AppSectionHeader(
            icon: Icons.payments_outlined, title: title, subtitle: subtitle),
        const SizedBox(height: 12),
        if (lines.isEmpty)
          Text(emptyText ?? 'None')
        else ...[
          for (final line in lines) _line(context, line),
          const Divider(),
          SizedBox(
              width: double.infinity,
              child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: 16,
                  children: [
                    const Text('Total',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    Text(_money(total),
                        style: const TextStyle(fontWeight: FontWeight.w800))
                  ])),
        ],
        if (note != null) ...[
          const SizedBox(height: 8),
          Text(note, style: Theme.of(context).textTheme.bodySmall),
        ],
      ]));

  @override
  Widget build(BuildContext context) {
    final free = position.freeToUseMinor;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Your starting position',
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      const Text('What is available before you start spending.'),
      const SizedBox(height: 24),
      SetupSurface(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const AppSectionHeader(
            icon: Icons.savings_outlined,
            title: 'Opening balance',
            subtitle: 'Money you already had at the start of the month.'),
        const SizedBox(height: 12),
        Text(
            position.openingMinor == null
                ? 'Not confirmed'
                : _money(position.openingMinor!),
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800)),
      ])),
      _section(context,
          title: 'Confirmed current income',
          subtitle: 'Actual receipts already added to this month.',
          lines: position.confirmed,
          total: position.confirmedMinor,
          emptyText: 'No confirmed income yet.'),
      _section(context,
          title: 'Pending expected income',
          subtitle: 'Expected later. Not available yet.',
          lines: position.pending,
          total: position.pendingMinor,
          emptyText: 'No pending income.',
          note: 'Pending amounts are excluded from Free to Use.'),
      _section(context,
          title: 'Skipped current period',
          subtitle: 'These source periods start later.',
          lines: position.skipped,
          total: position.skippedMinor,
          emptyText: 'No skipped periods.',
          note: 'Skipped amounts are not money and are excluded.'),
      if (position.unconfigured.isNotEmpty)
        _section(context,
            title: 'Not configured yet',
            subtitle: 'You can set these up from Pending Actions.',
            lines: position.unconfigured,
            total: position.unconfiguredMinor,
            note: 'Not-configured amounts are excluded.'),
      if (position.cancelled.isNotEmpty)
        _section(context,
            title: 'Cancelled periods',
            subtitle: 'Cancelled expected income is not available.',
            lines: position.cancelled,
            total: position.cancelledMinor,
            note: 'Cancelled amounts are excluded.'),
      if (position.future.isNotEmpty)
        _section(context,
            title: 'Starting later',
            subtitle: 'These sources are not active in this month yet.',
            lines: position.future,
            total: 0,
            note: 'Future amounts are excluded.'),
      SetupSurface(
          highlight: true,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const AppSectionHeader(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Initial Free to Use',
                subtitle: 'Opening money plus confirmed income only.'),
            const SizedBox(height: 12),
            const Text('FREE TO USE',
                style:
                    TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1.3)),
            const SizedBox(height: 8),
            Text(free == null ? 'Opening not confirmed' : _money(free),
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text(
                'Pending, skipped, cancelled and not-configured income is not included.'),
          ])),
    ]);
  }
}
