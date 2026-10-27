import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../shared/presentation/money_format.dart';
import '../../domain/onboarding_finance.dart';
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
        Text(d.profile.name,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w800)),
        Text(
            '${DateFormat.yMMMM().format(DateTime.parse('${d.yearMonth}-01'))} · ${review.currency.name.toUpperCase()}'),
        TextButton(
            key: const Key('editFinancialProfile'),
            onPressed: editProfile,
            child: const Text('Edit profile'))
      ])),
      SetupSurface(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
        TextButton(
            key: const Key('editMonthIncome'),
            onPressed: editMonthIncome,
            child: const Text('Edit month & income'))
      ])),
      SetupSurface(
          highlight: true,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
