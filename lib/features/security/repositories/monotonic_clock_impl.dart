import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/monotonic_clock.dart';

/// The one method name the native side answers (R3).
const String kElapsedRealtimeChannel = 'budget_buddy/monotonic_clock';

/// The app's monotonic clock instance.
///
/// `main.dart` warms it before `runApp` so the first frame already has the
/// boot-relative base; tests override [monotonicClockProvider] instead and never
/// touch this.
final WarmUpMonotonicClock appMonotonicClock = MethodChannelMonotonicClock();

/// The clock the lock reads. Overridden in tests with a stepping fake.
final monotonicClockProvider = Provider<MonotonicClock>(
  (ref) => appMonotonicClock,
);

/// `SystemClock.elapsedRealtime()` over a one-method platform channel
/// (research R3).
///
/// `elapsedRealtime()` counts real time since boot, including sleep, and ignores
/// every clock change — which is exactly what FR-015 needs. Because a channel
/// call is asynchronous while the lock's seam is synchronous, the boot-relative
/// base is read **once** in [warmUp] and every later [nowMs] adds the elapsed
/// time of a running [Stopwatch] (itself monotonic). The result therefore keeps
/// advancing across a process restart as well, so the lockout count can survive
/// a force-quit (FR-014).
class MethodChannelMonotonicClock implements WarmUpMonotonicClock {
  MethodChannelMonotonicClock({
    MethodChannel channel = const MethodChannel(kElapsedRealtimeChannel),
    MonotonicClock? fallback,
  })  : _channel = channel,
        _fallback = fallback ?? ClampedWallClock();

  final MethodChannel _channel;
  final MonotonicClock _fallback;

  final Stopwatch _since = Stopwatch();
  int? _baseMs;

  @override
  Future<void> warmUp() async {
    try {
      final base = await _channel.invokeMethod<int>('elapsedRealtimeMs');
      if (base == null) return;
      _baseMs = base;
      _since
        ..reset()
        ..start();
    } on MissingPluginException {
      // No native side (a test, the web, a desktop build): keep the fallback.
    } on Object {
      // A platform hiccup must not block startup. The fallback is still a
      // monotonic source within this session; research R3 records its limit.
    }
  }

  @override
  int nowMs() {
    final base = _baseMs;
    if (base == null) return _fallback.nowMs();
    return base + _since.elapsedMilliseconds;
  }
}

/// The fallback for a platform without the monotonic channel (research R3).
///
/// It uses the wall clock, clamped so it can never run **backwards** within a
/// session: moving the clock back cannot shorten an active wait. The honest
/// limit is recorded in research R3 rather than hidden — a forward clock move
/// can end that wait early here, and the clamp itself does not survive a
/// restart. The failure **count** is never affected on any platform, so the
/// escalating schedule still applies.
class ClampedWallClock implements MonotonicClock {
  ClampedWallClock({DateTime Function()? now}) : _now = now ?? DateTime.now;

  final DateTime Function() _now;

  int _last = 0;

  @override
  int nowMs() {
    final value = _now().millisecondsSinceEpoch;
    if (value < _last) return _last;
    _last = value;
    return value;
  }
}
