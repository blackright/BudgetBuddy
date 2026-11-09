import 'package:flutter/material.dart';

import '../../../../shared/presentation/modals/app_sheet.dart';
import '../dashboard_copy.dart';
import 'onboarding_guidance_card.dart';

/// The full setup-suggestion list behind the `+N more` affordance.
class NextStepsSheet extends StatelessWidget {
  const NextStepsSheet({
    super.key,
    required this.suggestions,
    required this.onSelected,
  });

  final List<SetupSuggestion> suggestions;
  final ValueChanged<SetupSuggestion> onSelected;

  static Future<void> show(
    BuildContext context, {
    required List<SetupSuggestion> suggestions,
    required ValueChanged<SetupSuggestion> onSelected,
  }) {
    return showAppSheet<void>(
      context,
      builder: (_) => NextStepsSheet(
        suggestions: suggestions,
        onSelected: onSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppSheet(
      key: const Key('nextStepsSheet'),
      title: DashboardCopy.nextStep,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final suggestion in suggestions)
            ListTile(
              key: ValueKey('nextStep-${suggestion.route}-${suggestion.title}'),
              leading: Icon(suggestion.icon),
              title: Text(suggestion.title),
              subtitle: Text(suggestion.detail),
              onTap: () {
                Navigator.of(context).pop();
                onSelected(suggestion);
              },
            ),
        ],
      ),
    );
  }
}
