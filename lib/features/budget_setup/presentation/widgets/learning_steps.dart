import 'package:flutter/material.dart';
import 'setup_form_components.dart';
import '../../../../shared/presentation/branding/brand_artwork.dart';

const setupStageLabels = [
  'Welcome',
  'Budgeting explained',
  'Your profile',
  'Your first month',
  'Security',
  'App overview',
  'Finish'
];

class SetupProgress extends StatelessWidget {
  const SetupProgress({super.key, required this.stage});
  final int stage;
  @override
  Widget build(BuildContext context) => Semantics(
      label: '${setupStageLabels[stage]}, step ${stage + 1} of 7',
      header: true,
      excludeSemantics: true,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text('Step ${stage + 1} of 7',
                  style: Theme.of(context).textTheme.labelLarge)),
          Text('${((stage + 1) / 7 * 100).round()}%')
        ]),
        const SizedBox(height: 10),
        ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child:
                LinearProgressIndicator(value: (stage + 1) / 7, minHeight: 6)),
        const SizedBox(height: 20),
      ]));
}

class SetupWelcomeContent extends StatelessWidget {
  const SetupWelcomeContent({super.key, this.replay = false});
  final bool replay;
  @override
  Widget build(BuildContext context) => SetupSurface(
      highlight: true,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const BrandWelcome(),
        const SizedBox(height: 24),
        Text('A little clarity. A brighter month.',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        const Text(
            'Welcome to BudgetBuddy. Build a plan around your real income, keep purchases organised and grow your savings, one step at a time.'),
        const SizedBox(height: 20),
        const Wrap(spacing: 8, runSpacing: 8, children: [
          Chip(
              avatar: Icon(Icons.edit_calendar_outlined),
              label: Text('Plan your month')),
          Chip(
              avatar: Icon(Icons.receipt_long_outlined),
              label: Text('Track purchases')),
          Chip(
              avatar: Icon(Icons.savings_outlined),
              label: Text('Build savings'))
        ]),
        const SizedBox(height: 12),
        Text(replay
            ? 'This is a read-only introduction. Your current profile, month and protection stay unchanged.'
            : 'Your information stays on this device. Phone verification comes before personal entry. No sharing account is required.'),
      ]));
}

class LearningSteps extends StatelessWidget {
  const LearningSteps({super.key, this.overview = false});
  final bool overview;
  @override
  Widget build(BuildContext context) {
    final lessons = overview
        ? const [
            (
              Icons.receipt_long_outlined,
              'Planned, Paid and Cancelled',
              'Planned records a future purchase; Paid records money spent; Cancelled has no spending effect. Recorded refunds return money according to the original expense.',
              'Example: planning a purchase does not spend its amount. Marking it Paid does.'
            ),
            (
              Icons.health_and_safety_outlined,
              'Medical bills and returns',
              'Insurer-paid bills count your patient share. Self-paid bills count the full charge; an approved insurer return is recorded separately. Returns follow the bill\'s financial month, not simply the day money arrives.',
              'Example: a self-paid bill and its insurer return remain separate records. Not every bill produces a payout.'
            ),
            (
              Icons.savings_outlined,
              'Your Savings Vault',
              'The vault holds savings across months. Deposits and withdrawals move money; they are not new income or purchases. A savings goal tracks progress.',
              'Example: saving toward a goal does not automatically make another expense or reserve money twice.'
            ),
            (
              Icons.groups_outlined,
              'Share when you are ready',
              'Start with your personal budget. You can visit Spaces later to create or join a permitted shared context.',
              'Example: viewing this explanation creates no space, identity or invitation.'
            ),
          ]
        : const [
            (
              Icons.account_balance_outlined,
              'Opening money and income',
              'Opening money is what was in your bank at the start of the selected month. Income Sources record money earned for that month. Keep them separate so the same money is not counted twice.',
              'Example only: an opening balance of 100,000 and applicable income of 500,000 represent two different facts, not two salary entries.'
            ),
            (
              Icons.pie_chart_outline,
              'Allocations and Free to spend',
              'An allocation sets money aside for a budget profile. Free to spend follows the app\'s existing income, spending, allocation and movement rules. A planned expense does not count as a paid purchase.',
              'Example only: putting money into a budget envelope is a plan for that money, not another purchase.'
            ),
          ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
          overview
              ? 'Your everyday companion'
              : 'Make your money easier to understand',
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 10),
      const Text(
          'Explore what is useful now. You can skip these explanations without skipping your setup choices.'),
      const SizedBox(height: 20),
      for (final lesson in lessons)
        Card(
            clipBehavior: Clip.antiAlias,
            child: ExpansionTile(
                expansionAnimationStyle: MediaQuery.disableAnimationsOf(context)
                    ? AnimationStyle.noAnimation
                    : null,
                leading: Icon(lesson.$1,
                    color: Theme.of(context).colorScheme.primary),
                title: Text(lesson.$2),
                childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                children: [
                  Text(lesson.$3),
                  const SizedBox(height: 14),
                  SetupSurface(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text('Example',
                            style: Theme.of(context).textTheme.labelLarge),
                        const SizedBox(height: 6),
                        Text(lesson.$4),
                        const SizedBox(height: 6),
                        const Text('Learning only. No records are created.')
                      ]))
                ])),
    ]);
  }
}

/// Public content only: it cannot read drafts or call financial repositories.
class PublicSetupIntroduction extends StatefulWidget {
  const PublicSetupIntroduction({super.key, required this.onContinue});
  final VoidCallback onContinue;
  @override
  State<PublicSetupIntroduction> createState() =>
      _PublicSetupIntroductionState();
}

class _PublicSetupIntroductionState extends State<PublicSetupIntroduction> {
  final _scroll = ScrollController();
  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  int stage = 0;
  void _show(int value) {
    setState(() => stage = value);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) => SetupPresentation(
      child: Scaffold(
          appBar: AppBar(title: const Text('Welcome to BudgetBuddy')),
          body: SafeArea(
              child: SingleChildScrollView(
                  controller: _scroll,
                  padding: const EdgeInsets.all(20),
                  child: Center(
                      child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 640),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SetupProgress(stage: stage),
                                if (stage == 0)
                                  const SetupWelcomeContent()
                                else
                                  const LearningSteps(),
                                const SizedBox(height: 20),
                                FilledButton(
                                    onPressed: stage == 0
                                        ? () => _show(1)
                                        : widget.onContinue,
                                    child: Text(stage == 0
                                        ? 'Get started'
                                        : 'Continue to phone verification')),
                                if (stage == 1) ...[
                                  TextButton(
                                      onPressed: widget.onContinue,
                                      child: const Text('Skip explanations')),
                                  TextButton(
                                      onPressed: () => _show(0),
                                      child: const Text('Back'))
                                ]
                              ])))))));
}
