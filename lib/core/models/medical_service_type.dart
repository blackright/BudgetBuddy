import 'package:isar/isar.dart';

import '../../features/sync/domain/sync_guid.dart';

part 'medical_service_type.g.dart';

/// User-editable classification of a medical service (FR-039, FR-040).
///
/// Types are archived rather than deleted so historical bills keep a valid
/// [id] reference (R10).
@collection
class MedicalServiceType {
  Id id = Isar.autoIncrement;

  /// Device-independent identity of this row (research R5); indexed, not unique
  /// (uniqueness held by construction and migration step 17).
  @Index()
  String syncGuid = newSyncGuid();

  /// Links to `UserProfile.id`.
  @Index()
  int? profileId;

  /// Owning shared space, or `null` for a personal type (data-model §3.6).
  @Index()
  int? sharedSpaceId;

  /// Display name. Unique per profile, case-insensitive.
  String name = '';

  /// One of the six seeded types. Protected from casual deletion.
  bool isDefault = false;

  /// Stable ordering in pickers.
  int sortOrder = 0;

  bool archived = false;
}

/// The service types seeded for a profile on first run (FR-039).
class MedicalServiceTypeDefaults {
  const MedicalServiceTypeDefaults._();

  static const String radiology = 'Radiology';
  static const String labWork = 'Lab Work';
  static const String specialistConsultation = 'Specialist Consultation';
  static const String generalistConsultation = 'Generalist Consultation';
  static const String surgery = 'Surgery';
  static const String medicinePharmacy = 'Medicine / Pharmacy';

  static const List<String> seedNames = [
    radiology,
    labWork,
    specialistConsultation,
    generalistConsultation,
    surgery,
    medicinePharmacy,
  ];

  /// Builds the seeded rows for [profileId], in display order.
  static List<MedicalServiceType> seed(int profileId) => [
        for (var i = 0; i < seedNames.length; i++)
          MedicalServiceType()
            ..profileId = profileId
            ..name = seedNames[i]
            ..isDefault = true
            ..sortOrder = i,
      ];
}
