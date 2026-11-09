/// One place for the Settings hub's user-facing copy.
///
/// The approved vocabulary lives here so the hub and its surfaces cannot drift
/// into the banned labels listed in `contracts/settings-copy.md`. Banned terms
/// are deliberately absent from production code; the copy audit owns that list.
class SettingsCopy {
  const SettingsCopy._();

  static const String settingsTitle = 'Settings';
  static const String profileFallback = 'Profile';
  static const String sharedSpaceFallback = 'Shared space';
  static const String personal = 'Personal';
  static const String switchAction = 'Switch';
  static const String profileSpace = 'Profile & space';

  static const String budgeting = 'Budgeting';
  static const String sharing = 'Sharing';
  static const String security = 'Security';
  static const String appearance = 'Appearance';
  static const String help = 'Help & learning';
  static const String advanced = 'Advanced';

  static const String budgetingSummary = 'Income, budgets and transfers';
  static const String helpSummary = 'Basics and introduction';
  static const String advancedSummary = 'History and technical details';
  static const String noSharedSpaces = 'No shared spaces';

  static const String incomeSetup = 'Set up income';
  static const String monthEndSummary = 'Close and carry rules';
  static const String transfersSummary = 'Move money between budgets';
  static const String savingsSummary = 'Personal vault';
  static const String reportsSummary = 'Statements and exports';
  static const String bulkAddExpensesSummary = 'Add several at once';

  static const String income = 'Income';
  static const String profiles = 'Profiles';
  static const String monthEnd = 'Month end';
  static const String transfers = 'Transfers';
  static const String savings = 'Savings';
  static const String reports = 'Reports';
  static const String bulkAddExpenses = 'Bulk add expenses';
  static const String allowTransfers = 'Allow transfers';
  static const String transfersOff = 'Transfers are off.';

  static const String people = 'People';
  static const String devices = 'Devices';
  static const String history = 'History';
  static const String technicalDetails = 'Technical details';
  static const String legacySalary = 'Legacy salary';
  static const String replayIntroduction = 'Replay the introduction';

  static const String theme = 'Theme';
  static const String font = 'Font';
  static const String system = 'System';
  static const String light = 'Light';
  static const String dark = 'Dark';
  static const String systemDefault = 'System default';
  static const String roboto = 'Roboto';
  static const String inter = 'Inter';
  static const String openSans = 'Open Sans';
  static const String appearanceSeparator = ' · ';

  static const String appLockOn = 'App lock on';
  static const String appLockOff = 'App lock off';
  static const String required = 'Required';

  /// The compact Appearance value, for example `System · Roboto`.
  static String appearanceSummary({
    required String themeLabel,
    required String fontLabel,
  }) {
    return '$themeLabel$appearanceSeparator$fontLabel';
  }

  /// The Income row summary: a setup prompt or the source count.
  static String incomeSummary(int count) {
    if (count == 0) return incomeSetup;
    final sourceWord = count == 1 ? 'source' : 'sources';
    return '$count $sourceWord';
  }

  /// The Profiles row summary, for example `2 budget · 1 direct`.
  static String profilesSummary({
    required int budgets,
    required int direct,
  }) {
    return '$budgets budget$appearanceSeparator$direct direct';
  }

  /// The Sharing row summary, or [noSharedSpaces] when the profile has none.
  static String sharingSummary({
    required int spaces,
    required int people,
  }) {
    if (spaces == 0) return noSharedSpaces;
    final spaceWord = spaces == 1 ? 'space' : 'spaces';
    final peopleWord = people == 1 ? 'person' : 'people';
    return '$spaces $spaceWord$appearanceSeparator$people $peopleWord';
  }

  /// The Security row summary. An Owner-required lock wins over the local state.
  static String securitySummary({
    required bool locked,
    required bool requiredByOwner,
  }) {
    if (requiredByOwner) return required;
    return locked ? appLockOn : appLockOff;
  }
}
