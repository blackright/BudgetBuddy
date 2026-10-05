import 'package:isar/isar.dart';

part 'insurance_profile.g.dart';

/// Health insurance settings for a single [UserProfile].
///
/// One row per profile. There used to be one per year, because deductible limits
/// reset annually; with deductibles gone (FR-037, FR-038) the year is no longer
/// part of the identity of this record.
@collection
class InsuranceProfile {
  Id id = Isar.autoIncrement;

  /// Links to `UserProfile.id`.
  @Index()
  int? profileId;

  /// Percentage **the user** is responsible for, used for a bill when the bill
  /// itself does not say. Inverted from the retired `defaultCoveragePercent`.
  double defaultPatientPercent = 20.0;

  /// Who the plan is with, e.g. "Blue Cross". Optional: purely descriptive, so
  /// every other feature works without it.
  String? insurerName;

  /// Which plan, e.g. "PPO 500". Optional, and often the same for a whole family,
  /// which is why this is one field on the profile rather than per member.
  String? planName;

  /// Records the plan details, treating a blank entry as "not recorded".
  ///
  /// Both fields are optional, and "not recorded" has to be distinguishable from
  /// "recorded as empty" — the summary joins whatever is set with a separator, so
  /// an empty string would leave a stray dot on screen. Trimming and nulling
  /// happens here so every caller gets the same result, and a value can be
  /// cleared by passing null or blank.
  void setPlanDetails({String? insurerName, String? planName}) {
    this.insurerName = _trimmedOrNull(insurerName);
    this.planName = _trimmedOrNull(planName);
  }

  /// "Blue Cross · PPO 500", or an empty string when neither part is recorded.
  ///
  /// Returns null rather than a partial string so a caller can skip the line
  /// entirely instead of rendering an empty one.
  String? get planSummary {
    final parts = [
      if (insurerName != null) insurerName!,
      if (planName != null) planName!,
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }

  static String? _trimmedOrNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
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
