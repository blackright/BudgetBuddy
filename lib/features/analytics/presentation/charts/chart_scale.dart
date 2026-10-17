import 'dart:math' as math;

/// Axis-scaling helpers shared by every chart, so no chart invents its own
/// tick maths (and no axis ends up with hundreds of labels).

/// Picks a "nice" axis step — `1`, `2`, `2.5`, `5` or `10` times a power of ten —
/// that splits [maxValue] into roughly [tickCount] intervals.
///
/// Using a round step means the axis shows a handful of readable numbers
/// (`0, 1k, 2k, 3k, 4k`) instead of hundreds of arbitrary ones.
double niceInterval(double maxValue, {int tickCount = 4}) {
  if (maxValue <= 0 || tickCount <= 0) return 1;
  final rough = maxValue / tickCount;
  final magnitude =
      math.pow(10, (math.log(rough) / math.ln10).floor()).toDouble();
  final normalized = rough / magnitude;
  final double niceNormalized;
  if (normalized <= 1) {
    niceNormalized = 1;
  } else if (normalized <= 2) {
    niceNormalized = 2;
  } else if (normalized <= 2.5) {
    niceNormalized = 2.5;
  } else if (normalized <= 5) {
    niceNormalized = 5;
  } else {
    niceNormalized = 10;
  }
  return niceNormalized * magnitude;
}

/// Rounds [maxValue] up to a whole multiple of [interval], so the top gridline
/// lands on a round number and the tallest bar/point never touches the ceiling.
double prettyMaxY(double maxValue, double interval) {
  if (interval <= 0) return maxValue <= 0 ? 1 : maxValue;
  if (maxValue <= 0) return interval;
  return (maxValue / interval).ceil() * interval;
}
