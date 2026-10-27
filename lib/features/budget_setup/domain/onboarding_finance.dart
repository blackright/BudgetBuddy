import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../../core/models/currency_code.dart';
import '../../../core/models/income_source.dart';
import '../../../core/models/money.dart';
import '../../../core/services/filter_service.dart' show parseSearchAmount;
import '../../../core/services/free_funds.dart';
import '../../../core/services/income_aggregation_service.dart';
import '../../../core/services/profile_name.dart';
import '../../sync/domain/sync_codec.dart' show canonicalJsonEncode;
import 'onboarding_state.dart';

class OnboardingFinanceException implements Exception {
  OnboardingFinanceException(Map<String, String> fields)
      : fields = Map.unmodifiable(fields);
  final Map<String, String> fields;
  @override
  String toString() => 'Review the highlighted setup fields.';
}

class OnboardingContribution {
  const OnboardingContribution(
      this.sourceGuid, this.name, this.minor, this.explanation);
  final String sourceGuid, name, explanation;
  final int minor;
}

class OnboardingReview {
  OnboardingReview(
      {required this.normalized,
      required this.currency,
      required this.openingMajor,
      required this.incomeMinor,
      required this.freeMinor,
      required this.bankMinor,
      required this.digest,
      required List<OnboardingContribution> contributions})
      : contributions = List.unmodifiable(contributions);
  final OnboardingState normalized;
  final CurrencyCode currency;
  final double openingMajor;
  final int incomeMinor, freeMinor;
  final int? bankMinor;
  final String digest;
  final List<OnboardingContribution> contributions;
}

/// Fresh-month projection. All entry is parsed from raw text into exact minors;
/// the existing aggregation/free-funds rules remain the accounting authority.
class OnboardingFinance {
  static OnboardingReview review(OnboardingState state) {
    final errors = <String, String>{};
    final nameProblem = profileNameProblem(state.profile.name);
    if (nameProblem != null) errors['name'] = nameProblem;
    final currency = state.profile.currency;
    if (currency == null) {
      errors['currency'] = 'Choose your accounting currency.';
    }
    final month = state.yearMonth;
    if (month == null ||
        !RegExp(r'^(20\d{2}|2100)-(0[1-9]|1[0-2])$').hasMatch(month) ||
        month.compareTo('2100-01') > 0) {
      errors['month'] = 'Choose a month from January 2000 to January 2100.';
    }
    if (state.stage != OnboardingStage.draft) {
      errors['setup'] = 'This setup needs its existing recovery flow.';
    }
    int? parse(String text, CurrencyCode? code, String field) {
      try {
        final result = parseSearchAmount(text, code);
        if (result == null) {
          errors[field] = 'Enter an amount, including 0 if none.';
        }
        return result;
      } on FormatException {
        errors[field] =
            'Enter a nonnegative grouped amount within the currency precision and supported range.';
        return null;
      }
    }

    int? opening;
    if (state.opening.choice == OnboardingOpeningChoice.unset) {
      errors['opening'] =
          'Choose a known opening balance or I do not know yet.';
    } else if (state.opening.choice == OnboardingOpeningChoice.known) {
      opening = parse(state.opening.amountText, currency, 'opening');
      if (state.opening.currency != currency) {
        errors['opening'] =
            'Re-enter the opening amount in the selected currency.';
      }
    }
    if (state.incomeChoice == OnboardingIncomeChoice.unset ||
        (state.incomeChoice == OnboardingIncomeChoice.sources &&
            state.sources.isEmpty)) {
      errors['income'] =
          'Add an income source or explicitly choose No income yet.';
    }
    if (state.incomeChoice != OnboardingIncomeChoice.sources &&
        state.sources.isNotEmpty) {
      errors['income'] =
          'Confirm removal of entered sources before choosing No income yet.';
    }
    final normalizedSources = <OnboardingSourceDraft>[];
    for (final source in state.sources) {
      final key = 'source:${source.sourceGuid}';
      if (source.name.trim().isEmpty) {
        errors['$key:name'] = 'Name this income source.';
      }
      if (source.currency != currency) {
        errors['$key:amount'] =
            'Re-enter this amount in the selected currency.';
      }
      final amount = parse(source.amountText, currency, '$key:amount');
      if (source.startDate != null &&
          source.endDate != null &&
          _day(source.endDate!).compareTo(_day(source.startDate!)) < 0) {
        errors['$key:dates'] = 'End date must not precede start date.';
      }
      if (source.frequency == IncomeFrequency.oneTime &&
          source.startDate == null) {
        errors['$key:dates'] = 'Choose the date of this one-time income.';
      }
      normalizedSources.add(OnboardingSourceDraft(
          sourceGuid: source.sourceGuid,
          name: source.name.trim(),
          type: source.type,
          frequency: source.frequency,
          amountText: source.amountText,
          minorUnits: amount,
          currency: currency,
          startDate: source.startDate,
          endDate: source.endDate,
          notes: source.notes?.trim().isEmpty == true
              ? null
              : source.notes?.trim()));
    }
    if (errors.isNotEmpty) throw OnboardingFinanceException(errors);
    // Validate structural evidence separately; errors never echo user content.
    try {
      state.encode();
    } on OnboardingStateException {
      throw OnboardingFinanceException(
          {'setup': 'Saved setup metadata needs review.'});
    }
    final normalized = replaceOnboardingDraft(state,
        profile: OnboardingProfileDraft(
            name: checkedProfileName(state.profile.name), currency: currency),
        opening: OnboardingOpeningDraft(
            choice: state.opening.choice,
            amountText: state.opening.amountText,
            minorUnits: opening,
            currency: state.opening.choice == OnboardingOpeningChoice.known
                ? currency
                : null),
        sources: normalizedSources);
    normalized.encode();
    final code = currency!;
    final contributions = <OnboardingContribution>[];
    var total = BigInt.zero, engineBound = BigInt.zero;
    final bound = BigInt.from(OnboardingState.maxInteger);
    for (final source in normalizedSources) {
      // Match the current audited engine's checked four-occurrence envelope,
      // without overflowing an int while validating a multi-source submission.
      engineBound += BigInt.from(source.minorUnits!) * BigInt.from(4);
      if (engineBound > bound) {
        throw OnboardingFinanceException({
          'income':
              'These source amounts exceed the current accounting engine safe range.'
        });
      }
      final row = sourceRecord(source, profileId: 1, at: state.createdAt);
      final minor = const IncomeAggregationService()
          .monthlyTotal([row], month!, currency: code);
      total += BigInt.from(minor);
      if (total > bound) {
        throw OnboardingFinanceException(
            {'income': 'Monthly income exceeds the supported range.'});
      }
      contributions.add(OnboardingContribution(
          source.sourceGuid,
          source.name,
          minor,
          minor == 0
              ? 'Contributes 0 in $month based on its amount, frequency and active dates.'
              : 'Contribution to $month using the existing ${source.frequency.name} schedule.'));
    }
    final income = total.toInt();
    final bank = opening == null ? null : BigInt.from(opening) + total;
    if (bank != null && bank > bound) {
      throw OnboardingFinanceException(
          {'totals': 'Opening plus income exceeds the supported range.'});
    }
    final openingMajor = checkedMajor(opening ?? 0, code, 'opening');
    checkedMajor(income, code, 'income');
    if (bank != null) checkedMajor(bank.toInt(), code, 'totals');
    final free =
        freeToSpend(income: income, paid: 0, returned: 0, unused: 0).toInt();
    final evidence = <String, Object?>{
      'flow': state.flowId,
      'revision': state.revision,
      'profile': normalized.profile.toJson(),
      'month': month,
      'openingChoice': normalized.opening.choice.name,
      'openingMinor': opening,
      'incomeChoice': normalized.incomeChoice.name,
      'sources': normalizedSources
          .map((s) => {...s.toJson()}..remove('amountText'))
          .toList()
    };
    return OnboardingReview(
        normalized: normalized,
        currency: code,
        openingMajor: openingMajor,
        incomeMinor: income,
        freeMinor: free,
        bankMinor: bank?.toInt(),
        digest: sha256
            .convert(utf8.encode(canonicalJsonEncode(evidence)))
            .toString(),
        contributions: contributions);
  }

  /// Only the legacy storage/provider boundary uses doubles, with a mandatory
  /// minor-unit round trip; no financial arithmetic is performed on doubles.
  static double checkedMajor(int minor, CurrencyCode currency, String field) {
    final major = minor / currency.minorUnitsPerMajor;
    if (!major.isFinite ||
        Money.fromMajor(major, currency).minorUnits != minor) {
      throw OnboardingFinanceException({
        field: 'This amount cannot be stored exactly. Enter a smaller amount.'
      });
    }
    return major;
  }

  static IncomeSource sourceRecord(OnboardingSourceDraft draft,
          {required int profileId, required DateTime at}) =>
      IncomeSource()
        ..syncGuid = draft.sourceGuid
        ..profileId = profileId
        ..sharedSpaceId = null
        ..name = draft.name
        ..type = draft.type
        ..frequency = draft.frequency
        ..amount = draft.minorUnits!
        ..currency = draft.currency!.code
        ..startDate = draft.startDate
        ..endDate = draft.endDate
        ..notes = draft.notes
        ..createdAt = at
        ..updatedAt = at;
  static String _day(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

/// Copy only a draft, retaining stable IDs. Completion/recovery changes use
/// their own reviewed commands in later phases, not this form-editing helper.
OnboardingState replaceOnboardingDraft(OnboardingState old,
        {int? revision,
        DateTime? updatedAt,
        String? yearMonth,
        OnboardingProfileDraft? profile,
        OnboardingOpeningDraft? opening,
        OnboardingIncomeChoice? incomeChoice,
        List<OnboardingSourceDraft>? sources}) =>
    OnboardingState(
        flowId: old.flowId,
        revision: revision ?? old.revision,
        createdAt: old.createdAt,
        updatedAt: updatedAt ?? old.updatedAt,
        stage: old.stage,
        step: old.step,
        yearMonth: yearMonth ?? old.yearMonth,
        profile: profile ?? old.profile,
        opening: opening ?? old.opening,
        incomeChoice: incomeChoice ?? old.incomeChoice,
        sources: sources ?? old.sources,
        committed: old.committed,
        categoriesReady: old.categoriesReady,
        directoryReady: old.directoryReady,
        securityChoice: old.securityChoice,
        completedAt: old.completedAt);
