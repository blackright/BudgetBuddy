import 'package:isar/isar.dart';

part 'consent_record.g.dart';

/// The local, revocable consent trace for optional device auth (data-model
/// §2.2, FR-002, research R8).
///
/// Local only — never exchanged. The user may grant or decline device auth
/// freely; declining keeps the app fully usable and merely shows a warning. A
/// revocation re-writes this single row's [updatedAt].
@collection
class ConsentRecord {
  Id id = Isar.autoIncrement;

  /// Version of the consent text that was shown, so a later notice can be
  /// re-asked without losing what the user actually agreed to (FR-002).
  String noticeVersion = '';

  /// Whether the user enabled using the phone's PIN/biometrics to unlock the
  /// identity key. `false` is a legitimate, warning-only choice.
  bool deviceAuthGranted = false;

  /// When the decision was first recorded.
  late DateTime decidedAt;

  /// When the record was last changed (a revocation simply re-writes this row).
  late DateTime updatedAt;
}
