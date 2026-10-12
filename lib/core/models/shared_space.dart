import 'package:isar/isar.dart';

import 'user_profile.dart';

part 'shared_space.g.dart';

/// One shared financial space (FR-002): a room several profiles collaborate in.
///
/// A space owns months via `MonthlyBudget.sharedSpaceId`, its own "Our income"
/// pot (FR-009) and a members list (`SharedMember`). Money rows are exactly-one-
/// context: a row belongs either to a personal profile or to a space, never both
/// and never neither (`data-model` §3).
@collection
class SharedSpace {
  Id id = Isar.autoIncrement;

  /// Required, non-empty (FR-002).
  String name = '';

  /// Emoji avatar; defaults to a family glyph.
  String avatar = '👨‍👩‍👧';

  /// Shared display/default currency (FR-002).
  @enumerated
  late PrimaryCurrency currency;

  /// "Our income" default, in whole minor units of [currency] (FR-009).
  int defaultIncome = 0;

  /// The creating profile's id — provenance; the creator becomes the first
  /// Owner (FR-006).
  late int createdByProfileId;

  late DateTime createdAt;
}
