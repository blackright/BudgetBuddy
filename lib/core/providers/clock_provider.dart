import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides a reactive, real-time clock that ticks once a minute.
/// Useful for updating UI that depends on "now" (e.g., upcoming reminders, times).
class ClockNotifier extends StateNotifier<DateTime> {
  ClockNotifier() : super(DateTime.now()) {
    _initTimer();
  }

  Timer? _timer;

  void _initTimer() {
    _timer?.cancel();
    final now = DateTime.now();
    // Align to the next minute boundary.
    final msUntilNextMinute = 60000 - (now.millisecondsSinceEpoch % 60000);
    _timer = Timer(Duration(milliseconds: msUntilNextMinute), _onTick);
  }

  void _onTick() {
    state = DateTime.now();
    _initTimer();
  }

  /// Refreshes the clock immediately, for example when the app resumes.
  void refresh() {
    state = DateTime.now();
    _initTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final clockProvider = StateNotifierProvider<ClockNotifier, DateTime>((ref) {
  return ClockNotifier();
});
