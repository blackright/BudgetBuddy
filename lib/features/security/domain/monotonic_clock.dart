/// The monotonic clock seam (research R3, FR-014/FR-015).
///
/// The wall clock cannot satisfy FR-015: it cannot tell "the app was closed for
/// ten minutes" from "the user moved the clock forward ten minutes", so a
/// wall-clock lockout is escaped by moving the clock forward. This seam counts
/// **real elapsed time** instead, and it must keep counting across a force-quit
/// (FR-014), which is why its Android implementation reads
/// `SystemClock.elapsedRealtime()` — time since boot — and then tracks elapsed
/// time from there.
///
/// The read is synchronous by design: the lockout check happens inside `build`
/// and inside transaction-free reads, so the underlying platform value is cached
/// once via [warmUp] rather than awaited per call.
abstract class MonotonicClock {
  /// Milliseconds from a fixed, monotonically increasing origin. Only
  /// *differences* between two readings are meaningful. Never decreases while a
  /// process is running.
  int nowMs();
}

/// A [MonotonicClock] that must be prepared once before its readings are
/// trusted (the Android channel reads its boot-relative base asynchronously).
abstract class WarmUpMonotonicClock implements MonotonicClock {
  /// Reads the platform base. Safe to call more than once; a platform without
  /// the channel keeps its documented fallback (research R3).
  Future<void> warmUp();
}
