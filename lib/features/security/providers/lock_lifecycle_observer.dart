import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'lock_providers.dart';

/// Drives [LockController.noteLeftForeground] / [notePhoneLocked] /
/// [noteResumed] from the app lifecycle and the Android screen on/off stream
/// (FR-022, T046).
///
/// Modelled on the seal and sync observers in `main.dart`: it lives for the
/// app's lifetime, is registered after the first frame, and never blocks
/// startup. It never holds a reference to a widget — only to the
/// [ProviderContainer] — so it survives rebuilds.
class LockLifecycleObserver extends WidgetsBindingObserver {
  LockLifecycleObserver(this._container) {
    _subscription = _screenLockEvents.receiveBroadcastStream().listen((event) {
      final controller = _container.read(lockControllerProvider.notifier);
      if (event == 'locked') {
        controller.notePhoneLocked();
      }
    });
  }

  final ProviderContainer _container;

  static const _screenLockEvents =
      EventChannel('budget_buddy/screen_lock_events');

  StreamSubscription<dynamic>? _subscription;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _container.read(lockControllerProvider.notifier);
    switch (state) {
      case AppLifecycleState.resumed:
        controller.noteResumed();
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        // Start the away window for any backgrounding. A real phone lock is
        // reported separately by the screen-lock event stream, which calls
        // notePhoneLocked() and sets the "always lock on resume" flag.
        controller.noteLeftForeground();
      case AppLifecycleState.inactive:
        // Transient (app switcher, a call, a system dialog): do not start the
        // away window (R4).
        break;
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
