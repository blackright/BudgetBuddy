import 'package:flutter_test/flutter_test.dart';
import 'package:budget_buddy/features/budget_setup/domain/onboarding_startup.dart';
import 'support/financial_drafts.dart';

void main() {
  test('shared budgets never establish a missing personal owner', () {
    expect(
        resolveOnboardingStartup(profileIds: {}).kind, StartupKind.firstSetup);
    expect(resolveOnboardingStartup(profileIds: {7}).kind,
        StartupKind.establishedUser);
  });
  test('explicit corrupt state takes precedence and preserves existing access',
      () {
    final result = resolveOnboardingStartup(profileIds: {7}, invalid: true);
    expect(result.kind, StartupKind.needsReview);
    expect(result.existingProfileIds, {7});
  });
  test('a draft resumes its chosen month without inventing an owner', () {
    final result = resolveOnboardingStartup(
        profileIds: {}, state: financialDraft(month: '2025-01'));
    expect(result.kind, StartupKind.resumeSetup);
    expect(result.state!.yearMonth, '2025-01');
    expect(result.state!.committed, isNull);
  });
}
