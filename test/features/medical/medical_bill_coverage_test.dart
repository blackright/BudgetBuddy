import 'package:flutter_test/flutter_test.dart';

import 'package:budget_buddy/core/models/medical_bill.dart';

/// Pure model checks for the Bill Creation rework (PRD §8, §9, §10, §17).
///
/// Amounts are whole minor units, so every case asserts the stored split rather
/// than a formatted value.
void main() {
  MedicalBill bill({
    required int billed,
    double sharePercent = 20,
    MedicalPaymentMethod method = MedicalPaymentMethod.selfPaid,
  }) =>
      MedicalBill()
        ..billedAmount = billed
        ..patientSharePercent = sharePercent
        ..paymentMethod = method;

  test('coverage is the inverse of the stored share', () {
    final subject = bill(billed: 50000, sharePercent: 20);

    expect(subject.insuranceCoveragePercent, 80);
    expect(subject.patientShareAmount, 10000);
    expect(subject.insurerPaidAmount, 40000);
  });

  test('setInsuranceCoverage stores the inverted share and clamps', () {
    final subject = bill(billed: 50000, sharePercent: 20);

    subject.setInsuranceCoverage(80);
    expect(subject.patientSharePercent, 20);

    subject.setInsuranceCoverage(-5);
    expect(subject.patientSharePercent, 100);
    expect(subject.insuranceCoveragePercent, 0);

    subject.setInsuranceCoverage(120);
    expect(subject.patientSharePercent, 0);
    expect(subject.insuranceCoveragePercent, 100);
  });

  test('self-paid shows a refund and the full bill as planned effect', () {
    final subject = bill(billed: 50000, sharePercent: 20);

    expect(subject.expectedInsuranceRefund, 40000);
    expect(subject.insurancePaysProviderAmount, 0);
    expect(subject.plannedBudgetEffect, 50000);
  });

  test('insurer-paid shows a provider payment and only the share as effect',
      () {
    final subject = bill(
      billed: 50000,
      sharePercent: 20,
      method: MedicalPaymentMethod.insurerPaid,
    );

    expect(subject.expectedInsuranceRefund, 0);
    expect(subject.insurancePaysProviderAmount, 40000);
    expect(subject.plannedBudgetEffect, 10000);
  });

  test('0% and 100% coverage are valid', () {
    final fullCoverage = bill(billed: 99999, sharePercent: 0);
    expect(fullCoverage.insuranceCoveragePercent, 100);
    expect(fullCoverage.patientShareAmount, 0);
    expect(fullCoverage.expectedInsuranceRefund, 99999);

    final noCoverage = bill(billed: 99999, sharePercent: 100);
    expect(noCoverage.insuranceCoveragePercent, 0);
    expect(noCoverage.patientShareAmount, 99999);
    expect(noCoverage.expectedInsuranceRefund, 0);
  });

  test('rounding once keeps both portions equal to the bill total', () {
    for (final billed in [1, 3, 7, 999, 10001, 123457]) {
      for (final share in [0.0, 12.5, 20.0, 33.33, 66.67, 99.9, 100.0]) {
        final subject = bill(billed: billed, sharePercent: share);
        expect(
          subject.patientShareAmount + subject.insurerPaidAmount,
          billed,
          reason: 'billed=$billed share=$share',
        );
        expect(
          subject.patientShareAmount + subject.expectedInsuranceRefund,
          billed,
          reason: 'self-paid split for billed=$billed share=$share',
        );
      }
    }
  });

  test('creating a planned bill still has no funds impact', () {
    final subject = bill(billed: 50000, sharePercent: 20)
      ..state = MedicalBillState.planned;

    expect(subject.fundsImpact, 0);
    expect(subject.plannedBudgetEffect, 50000);
  });
}
