import 'package:flutter/material.dart';
import 'widgets/setup_form_components.dart';
import '../../../shared/presentation/branding/brand_artwork.dart';
import '../../../core/services/profile_name.dart';
import '../../../shared/presentation/widgets/profile_avatar.dart';

/// A temporary draft: no profile is written until Budget Setup is saved.
class WelcomeStep extends StatefulWidget {
  const WelcomeStep({super.key, required this.name, required this.onContinue});
  final String name;
  final ValueChanged<String> onContinue;
  @override
  State<WelcomeStep> createState() => _WelcomeStepState();
}

class _WelcomeStepState extends State<WelcomeStep> {
  late final controller = TextEditingController(text: widget.name);
  String? error;
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void next() {
    final problem = profileNameProblem(controller.text);
    setState(() => error = problem);
    if (problem == null) widget.onContinue(checkedProfileName(controller.text));
  }

  @override
  Widget build(BuildContext context) => SetupPresentation(
      child: Scaffold(
          body: SafeArea(
              child: Center(
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: ListView(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(28),
                          children: [
                            const BrandWelcome(),
                            const SizedBox(height: 24),
                            Text('Welcome to BudgetBuddy',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 12),
                            const Text('What should we call you?',
                                textAlign: TextAlign.center),
                            const SizedBox(height: 28),
                            Center(
                                child: ProfileAvatar(
                                    name: controller.text, radius: 42)),
                            const SizedBox(height: 24),
                            TextField(
                                key: const Key('welcomeNameField'),
                                controller: controller,
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                    labelText: 'Your preferred name',
                                    hintText: 'For example, Jason',
                                    helperText:
                                        'Your local profile name. You can change it later.',
                                    helperMaxLines: 3,
                                    errorText: error,
                                    border: const OutlineInputBorder()),
                                onChanged: (_) => setState(() => error = null),
                                onSubmitted: (_) => next()),
                            const SizedBox(height: 24),
                            FilledButton.icon(
                                key: const Key('welcomeContinueButton'),
                                onPressed: next,
                                icon: const Icon(Icons.arrow_forward),
                                label: const Text('Continue')),
                            const SizedBox(height: 12),
                            const Text(
                                'Next: choose your currency and set up your first month.',
                                textAlign: TextAlign.center)
                          ]))))));
}
