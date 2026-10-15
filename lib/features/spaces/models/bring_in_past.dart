/// How much of the past a new space brings in at creation (FR-010).
///
/// The choice is applied at creation time; later months appear automatically.
/// Lives in the domain layer (not the create sheet) so the repository can act
/// on it without importing presentation code.
enum BringInPast { thisMonth, thisYear, everything }
