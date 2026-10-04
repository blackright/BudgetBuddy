import 'package:isar/isar.dart';

part 'insurance_profile.g.dart';

/// Health insurance settings for a single [UserProfile].
///
/// One record per profile per [year] — the deductible limits reset annually,
/// so the [year] is part of the lookup key rather than a display-only field.
@collection
class InsuranceProfile {
  Id id = Isar.autoIncrement;

  /// Links to `UserProfile.id`.
  @Index()
  int? profileId;

  /// Annual deductible applied to a single covered person (e.g. $2000).
  double individualDeductible = 0.0;

  /// Annual deductible applied to the whole family (e.g. $4000).
  double familyDeductible = 0.0;

  /// Coverage percentage applied to a bill when the user does not override it.
  double defaultCoveragePercent = 80.0;

  /// Deductible year this profile applies to.
  @Index()
  int year = DateTime.now().year;
}

/// Someone the user can attribute medical bills to.
@collection
class FamilyMember {
  Id id = Isar.autoIncrement;

  @Index()
  int? profileId;

  String name = '';
  String relation = ''; // e.g., "Self", "Spouse", "Child"
}

/// Directory entry for a doctor, clinic or hospital (FR-008).
@collection
class MedicalProvider {
  Id id = Isar.autoIncrement;

  @Index()
  int? profileId;

  String name = ''; // e.g., "City Hospital", "Dr. Smith"
  String? specialty;

  /// Providers auto-created while saving a bill are offered for cleanup later.
  bool autoCreated = false;
}
