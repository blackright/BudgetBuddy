import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/income_source.dart';
import 'package:budget_buddy/features/budget_setup/domain/onboarding_state.dart';

OnboardingState financialDraft(
        {CurrencyCode currency = CurrencyCode.huf,
        String opening = '100,000',
        OnboardingOpeningChoice openingChoice = OnboardingOpeningChoice.known,
        OnboardingIncomeChoice incomeChoice = OnboardingIncomeChoice.sources,
        List<OnboardingSourceDraft>? sources,
        String flow = 'flow-1',
        String month = '2026-10'}) =>
    OnboardingState(
      flowId: flow,
      revision: 0,
      createdAt: DateTime.utc(2026, 10, 27),
      updatedAt: DateTime.utc(2026, 10, 27),
      yearMonth: month,
      profile: OnboardingProfileDraft(name: 'Jason', currency: currency),
      opening: OnboardingOpeningDraft(
          choice: openingChoice,
          amountText:
              openingChoice == OnboardingOpeningChoice.known ? opening : '',
          currency:
              openingChoice == OnboardingOpeningChoice.known ? currency : null),
      incomeChoice: incomeChoice,
      sources: sources ??
          (incomeChoice == OnboardingIncomeChoice.sources
              ? [
                  OnboardingSourceDraft(
                      sourceGuid: 'salary-1',
                      name: 'Salary',
                      type: IncomeSourceType.salary,
                      amountText: '500,000',
                      currency: currency,
                      startDate: DateTime(2026, 10, 1))
                ]
              : []),
    );
