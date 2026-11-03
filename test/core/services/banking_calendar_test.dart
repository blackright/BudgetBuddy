import 'package:flutter_test/flutter_test.dart';
import 'package:budget_buddy/core/services/salary_cycle_service.dart';

void main() {
  test('nominalPayday returns 25 for normal months', () {
    expect(SalaryCycleService.nominalPayday(2026, 10), DateTime(2026, 10, 25));
  });

  test('nominalPayday returns 15 for December', () {
    expect(SalaryCycleService.nominalPayday(2026, 12), DateTime(2026, 12, 15));
  });

  test('nominalPayday handles January', () {
    expect(SalaryCycleService.nominalPayday(2027, 1), DateTime(2027, 1, 25));
  });
}
