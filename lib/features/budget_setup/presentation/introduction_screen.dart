import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'widgets/learning_steps.dart';
import 'widgets/setup_form_components.dart';

/// Educational replay has no financial/setup providers, writes or enrollment.
/// The app's existing outer authentication gate protects this normal route.
class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({super.key});
  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  final _scroll = ScrollController();
  int _chapter = 0;
  static const _labels = ['Welcome', 'Budgeting explained', 'App overview'];
  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _move(int chapter) {
    setState(() => _chapter = chapter);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  void _close() {
    // Normal pushed replay returns to its caller. A direct link has no caller.
    final router = GoRouter.maybeOf(context);
    if (router != null) {
      if (router.canPop()) {
        router.pop();
      } else {
        router.go('/settings');
      }
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SetupPresentation(
        child: Scaffold(
      appBar: AppBar(
          title: const Text('Introduction',
              maxLines: 1, overflow: TextOverflow.ellipsis),
          leading: IconButton(
              tooltip: 'Close introduction',
              onPressed: _close,
              icon: const Icon(Icons.close))),
      body: SafeArea(
          child: SingleChildScrollView(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Center(
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 640),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Align(
                                alignment: Alignment.centerLeft,
                                child: Chip(
                                    avatar: Icon(Icons.visibility_outlined),
                                    label: Text('Read-only introduction'))),
                            const SizedBox(height: 12),
                            Semantics(
                                label:
                                    'Chapter ${_chapter + 1} of 3: ${_labels[_chapter]}',
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Chapter ${_chapter + 1} of 3',
                                          style: theme.textTheme.labelLarge),
                                      const SizedBox(height: 8),
                                      ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: LinearProgressIndicator(
                                              value: (_chapter + 1) / 3,
                                              minHeight: 6))
                                    ])),
                            const SizedBox(height: 16),
                            Wrap(spacing: 8, runSpacing: 8, children: [
                              for (var index = 0;
                                  index < _labels.length;
                                  index++)
                                ChoiceChip(
                                    label: Text(_labels[index]),
                                    selected: _chapter == index,
                                    onSelected: (_) => _move(index))
                            ]),
                            const SizedBox(height: 20),
                            KeyedSubtree(
                                key: ValueKey(_chapter),
                                child: _chapter == 0
                                    ? const SetupWelcomeContent(replay: true)
                                    : LearningSteps(overview: _chapter == 2)),
                          ]))))),
      bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: SetupActions(children: [
                if (_chapter > 0)
                  OutlinedButton(
                      onPressed: () => _move(_chapter - 1),
                      child: const Text('Back')),
                FilledButton(
                    onPressed:
                        _chapter == 2 ? _close : () => _move(_chapter + 1),
                    child: Text(_chapter == 2 ? 'Done' : 'Next')),
              ]))),
    ));
  }
}
