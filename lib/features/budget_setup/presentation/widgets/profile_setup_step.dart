import 'package:flutter/material.dart';
import '../../../../core/models/currency_code.dart';
import '../../../../shared/presentation/widgets/profile_avatar.dart';
import '../../providers/budget_setup_provider.dart';
import 'setup_form_components.dart';

class ProfileSetupStep extends StatelessWidget {
  const ProfileSetupStep(
      {super.key, required this.view, required this.controller});
  final FinancialSetupView view;
  final FinancialSetupController controller;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Your profile',
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      const Text('A little introduction. A plan that belongs to you.'),
      const SizedBox(height: 24),
      SetupSurface(
          highlight: true,
          child: Column(children: [
            ProfileAvatar(name: view.draft.profile.name, radius: 42),
            const SizedBox(height: 16),
            Text(
                view.draft.profile.name.trim().isEmpty
                    ? 'Your personal space'
                    : view.draft.profile.name.trim(),
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('Your name is separate from your sharing identity.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.onSurfaceVariant))
          ])),
      SetupSurface(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SetupInput(
            key: const Key('financialProfileName'),
            label: 'Preferred name',
            text: view.draft.profile.name,
            onChanged: controller.setProfileName,
            error: view.errors['name'],
            helper: 'Use the name you would like us to call you.'),
        const SizedBox(height: 20),
        InputDecorator(
            decoration: InputDecoration(
                labelText: 'Accounting currency',
                errorText: view.errors['currency'],
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16))),
            child: DropdownButtonHideUnderline(
                child: DropdownButton<CurrencyCode>(
                    key: const Key('financialCurrency'),
                    value: view.draft.profile.currency,
                    isExpanded: true,
                    hint: const Text('Choose currency'),
                    items: CurrencyCode.values
                        .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(
                                '${c.name.toUpperCase()} · ${c.displayName}',
                                overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: controller.currencyFixed
                        ? null
                        : (value) async {
                            if (value == null ||
                                controller.changeCurrency(value)) {
                              return;
                            }
                            final yes = await confirmDraftRemoval(context,
                                title: 'Change accounting currency?',
                                message:
                                    'Opening and income amounts must be entered again in the new currency. Names, dates and source details will stay. No conversion will be guessed.');
                            if (yes) {
                              controller.changeCurrency(value,
                                  discardAmountsConfirmed: true);
                            }
                          }))),
        const SizedBox(height: 12),
        if (controller.currencyFixed)
          const Text(
              'Accounting currency is fixed because your financial details have already been confirmed.'),
        const Text(
            'Opening money and setup income use this currency. Other expense currencies remain available later.'),
      ])),
    ]);
  }
}
