import 'package:budget_buddy/features/analytics/presentation/charts/chart_scale.dart';
import 'package:flutter_test/flutter_test.dart';

/// Locks the shared axis-scaling rules (Phase 3b T040): few, round ticks and a
/// ceiling the data never touches.
void main() {
  group('niceInterval picks round steps', () {
    test('degrades safely for empty/zero ranges', () {
      expect(niceInterval(0), 1);
      expect(niceInterval(-5), 1);
    });

    test('returns 1, 2, 2.5 or 5 times a power of ten', () {
      expect(niceInterval(100), 25); // rough 25 → 2.5 × 10
      expect(niceInterval(10000), 2500); // rough 2500 → 2.5 × 1000
      expect(niceInterval(4000), 1000); // rough 1000 → 1 × 1000
      expect(niceInterval(2000), 500); // rough 500 → 5 × 100
    });

    test('never produces more than a handful of ticks', () {
      final interval = niceInterval(3820000);
      expect(3820000 / interval, lessThanOrEqualTo(5));
    });
  });

  group('prettyMaxY rounds the ceiling up', () {
    test('lands on a whole multiple of the interval', () {
      expect(prettyMaxY(10000, 2500), 10000);
      expect(prettyMaxY(3800, 1000), 4000);
      expect(prettyMaxY(1, 100), 100);
    });

    test('handles degenerate inputs', () {
      expect(prettyMaxY(0, 100), 100);
      expect(prettyMaxY(500, 0), 500);
    });
  });
}
