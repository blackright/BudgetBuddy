import 'package:flutter/material.dart';
import 'brand_artwork.dart';

/// One in-memory claim per process; no new persisted stage or startup resolver.
class StartupBrandSession {
  bool _claimed = false;
  bool claim() {
    if (_claimed) return false;
    _claimed = true;
    return true;
  }
}

/// Presentation only. Readiness/errors take priority in this frame; no timer
/// controls routing, authentication, integrity checks or financial writes.
class BrandedStartup extends StatefulWidget {
  const BrandedStartup(
      {super.key,
      required this.session,
      required this.ready,
      required this.child,
      this.onRetry});
  final StartupBrandSession session;
  final bool ready;
  final Widget child;
  final VoidCallback? onRetry;
  @override
  State<BrandedStartup> createState() => _BrandedStartupState();
}

class _BrandedStartupState extends State<BrandedStartup>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final controller = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200), value: 1);
  bool initialized = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.disableAnimationsOf(context);
    if (!initialized) {
      initialized = true;
      final first = widget.session.claim();
      if (!widget.ready && first && !reduced && widget.onRetry == null) {
        controller.forward(from: 0);
      }
    }
    if (reduced) controller.value = 1;
  }

  @override
  void didUpdateWidget(BrandedStartup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ready || widget.onRetry != null) controller.value = 1;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) controller.value = 1;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.ready) return widget.child;
    return Scaffold(
        backgroundColor: brandBackground(Theme.of(context).brightness),
        body: SafeArea(
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Center(
                    child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AnimatedBuilder(
                                  animation: controller,
                                  builder: (_, __) => Opacity(
                                      opacity: (controller.value / .17)
                                          .clamp(0.0, 1.0),
                                      child: BrandWelcome(
                                          progress: controller.value,
                                          compact: true,
                                          onAssetFailure: () {
                                            if (mounted &&
                                                controller.value != 1) {
                                              controller.value = 1;
                                            }
                                          }))),
                              const SizedBox(height: 20),
                              Semantics(
                                  liveRegion: true,
                                  child: Text(
                                      widget.onRetry == null
                                          ? 'Checking saved data...'
                                          : 'Unable to check saved data',
                                      style:
                                          const TextStyle(color: Colors.white),
                                      textAlign: TextAlign.center)),
                              if (widget.onRetry != null) ...[
                                const SizedBox(height: 12),
                                const Text(
                                    'Your data has not been changed. Retry the safety check to continue.',
                                    style: TextStyle(color: Colors.white),
                                    textAlign: TextAlign.center),
                                const SizedBox(height: 16),
                                FilledButton(
                                    onPressed: widget.onRetry,
                                    child: const Text('Retry')),
                              ],
                            ]))))));
  }
}
