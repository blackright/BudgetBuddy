import 'package:flutter/material.dart';

import '../../../core/models/expense.dart';
import '../../../shared/presentation/modals/app_dialog.dart';

/// What the user chose in the destination guard.
enum ExpenseDestinationDecision { save, changeProfile, cancel }

/// Which destination needs a warning.
enum DestinationGuardKind { unbudgeted, direct, overAllocation }

/// A warning that the destination spends money outside a budget envelope.
class DestinationGuard {
  const DestinationGuard({
    required this.kind,
    this.profileName,
    this.profileColor,
    this.remainingMinor,
    this.borrowMinor,
  });

  final DestinationGuardKind kind;
  final String? profileName;
  final Color? profileColor;
  final int? remainingMinor;
  final int? borrowMinor;
}

/// Decides whether saving [amountMinorInContext] to this destination needs a
/// guard.
///
/// Main always does (red). A Direct profile always does (profile colour; it has
/// no allocation). A budget profile does only when the expense exceeds what is
/// left, and then the warning is in that profile's colour. `remainingMinor` is
/// null when the profile is not loaded yet, which never invents a warning.
DestinationGuard? destinationGuardFor({
  required bool isMain,
  required bool isDirect,
  required int? remainingMinor,
  required int amountMinorInContext,
  String? profileName,
  Color? profileColor,
}) {
  if (isMain) {
    return const DestinationGuard(kind: DestinationGuardKind.unbudgeted);
  }
  if (isDirect) {
    return DestinationGuard(
        kind: DestinationGuardKind.direct,
        profileName: profileName,
        profileColor: profileColor);
  }
  if (remainingMinor != null && amountMinorInContext > remainingMinor) {
    return DestinationGuard(
        kind: DestinationGuardKind.overAllocation,
        profileName: profileName,
        profileColor: profileColor,
        remainingMinor: remainingMinor,
        borrowMinor: amountMinorInContext - remainingMinor);
  }
  return null;
}

/// Warns that an expense is not fully covered by a budget envelope.
///
/// A personal [spaceName] of `null` means a personal save; passing one combines
/// the shared-space confirmation into this single dialog, so the user is never
/// asked twice.
Future<ExpenseDestinationDecision> confirmExpenseDestination(
  BuildContext context, {
  required String amountText,
  required ExpenseStatus status,
  String? title,
  String? spaceName,
  DestinationGuardKind kind = DestinationGuardKind.unbudgeted,
  String? profileName,
  Color? profileColor,
  String? remainingText,
  String? borrowText,
}) async {
  final scheme = Theme.of(context).colorScheme;
  final tone = kind == DestinationGuardKind.unbudgeted
      ? scheme.error
      : (profileColor ?? scheme.primary);
  final when = status == ExpenseStatus.planned ? 'When it is paid, ' : '';
  final namedTitle =
      (title == null || title.trim().isEmpty) ? 'this expense' : title.trim();
  final profile = (profileName == null || profileName.trim().isEmpty)
      ? 'This profile'
      : profileName.trim();
  final left = remainingText ?? amountText;
  final borrow = borrowText ?? amountText;
  final sharedIntro = spaceName == null
      ? ''
      : 'Add "$namedTitle" ($amountText) to "$spaceName"? ';

  final body = switch (kind) {
    DestinationGuardKind.unbudgeted => spaceName == null
        ? 'This expense is not in a budget profile. '
            '$when$amountText will come from your free-to-use money, not from '
            'a budgeted amount. If this is a mistake, choose a profile.'
        : '${sharedIntro}It is not in a budget profile, so the money will come '
            "from the space's free-to-use money, not from a budgeted amount. "
            'If this is a mistake, choose a profile.',
    DestinationGuardKind.direct => spaceName == null
        ? '$profile is a direct expense profile with no allocation. '
            '$when$amountText will come from your free-to-use money. '
            'Choose a budget profile instead if this is a mistake.'
        : '${sharedIntro}It is going to $profile, a direct expense profile '
            "with no allocation, so the money will come from the space's "
            'free-to-use money. Choose a budget profile instead if this is a '
            'mistake.',
    DestinationGuardKind.overAllocation => spaceName == null
        ? '$profile has $left left this month. This expense will borrow '
            '$borrow from your free-to-use money. Choose a profile if this is '
            'a mistake.'
        : '$sharedIntro$profile has $left left, so this expense will borrow '
            "$borrow from the space's free-to-use money. Choose a profile if "
            'this is a mistake.',
  };
  final titleText = spaceName != null
      ? 'Review this save'
      : switch (kind) {
          DestinationGuardKind.unbudgeted => 'Save without a budget?',
          DestinationGuardKind.direct => 'Save to $profile?',
          DestinationGuardKind.overAllocation => 'Save to $profile anyway?',
        };
  final confirmLabel = switch (kind) {
    DestinationGuardKind.unbudgeted => 'Save to free-to-use',
    DestinationGuardKind.direct ||
    DestinationGuardKind.overAllocation =>
      profileName == null ? 'Save anyway' : 'Save to $profile',
  };
  final onTone = ThemeData.estimateBrightnessForColor(tone) == Brightness.dark
      ? Colors.white
      : Colors.black;

  final decision = await showAppDialog<ExpenseDestinationDecision>(
    context: context,
    builder: (dialogContext) => AppDialog(
      key: const Key('destinationGuardDialog'),
      icon: Icon(Icons.warning_amber_rounded, color: tone),
      title: Text(titleText),
      content: Text(body, key: const Key('destinationGuardMessage')),
      actions: [
        OutlinedButton.icon(
          key: const Key('chooseProfileForExpenseButton'),
          onPressed: () => Navigator.of(dialogContext)
              .pop(ExpenseDestinationDecision.changeProfile),
          icon: const Icon(Icons.swap_horiz),
          label: const Text('Choose a profile'),
        ),
        FilledButton(
          key: const Key('confirmDestinationButton'),
          style: FilledButton.styleFrom(
              backgroundColor: tone, foregroundColor: onTone),
          onPressed: () =>
              Navigator.of(dialogContext).pop(ExpenseDestinationDecision.save),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return decision ?? ExpenseDestinationDecision.cancel;
}
