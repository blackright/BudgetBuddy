/// Hybrid Logical Clock (HLC) — an immutable ordering value (data-model §1.3).
///
/// Ordering is the lexicographic tuple `(millis, counter, deviceId)`. It gives a
/// deterministic total order without any clock-sync server and tolerates device
/// clock skew: when two wall clocks collide the [counter] breaks the tie, and
/// [deviceId] breaks a counter tie so every device computes the same winner
/// (`contracts/sync-protocol.md` §2/§4).
class Hlc implements Comparable<Hlc> {
  const Hlc(this.millis, this.counter, this.deviceId);

  /// The all-zero value used before any change has been seen.
  static const Hlc genesis = Hlc(0, 0, '');

  /// `max(wallClock, lastSeenMillis)` at the moment of the tick.
  final int millis;

  /// Tiebreaker within the same [millis].
  final int counter;

  /// Stable per-install id; the final tiebreaker.
  final String deviceId;

  bool get isGenesis => millis == 0 && counter == 0;

  @override
  int compareTo(Hlc other) {
    if (millis != other.millis) return millis < other.millis ? -1 : 1;
    if (counter != other.counter) return counter < other.counter ? -1 : 1;
    return deviceId.compareTo(other.deviceId);
  }

  bool operator >(Hlc other) => compareTo(other) > 0;
  bool operator <(Hlc other) => compareTo(other) < 0;
  bool operator >=(Hlc other) => compareTo(other) >= 0;
  bool operator <=(Hlc other) => compareTo(other) <= 0;

  @override
  bool operator ==(Object other) =>
      other is Hlc &&
      other.millis == millis &&
      other.counter == counter &&
      other.deviceId == deviceId;

  @override
  int get hashCode => Object.hash(millis, counter, deviceId);

  @override
  String toString() => 'Hlc($millis,$counter,$deviceId)';
}

/// A stateful HLC generator that emits strictly increasing values.
///
/// Inject the wall clock (a `DateTime`) so tests are reproducible; production
/// passes `DateTime.now()`. [observe] folds in a remote HLC so the next local
/// tick never sorts before something already seen.
class HlcClock {
  HlcClock({required this.deviceId, Hlc? last})
      : _last = last ?? Hlc(0, 0, deviceId);

  final String deviceId;
  Hlc _last;

  /// The most recent value emitted or observed.
  Hlc get last => _last;

  /// Folds a remote HLC into local state (keeps our own [deviceId]).
  void observe(Hlc remote) {
    if (remote.compareTo(_last) > 0) {
      _last = Hlc(remote.millis, remote.counter, deviceId);
    }
  }

  /// The next HLC, strictly greater than anything emitted or observed.
  Hlc tick(DateTime now) {
    final wall = now.millisecondsSinceEpoch;
    final millis = wall > _last.millis ? wall : _last.millis;
    final counter = millis == _last.millis ? _last.counter + 1 : 0;
    _last = Hlc(millis, counter, deviceId);
    return _last;
  }
}
