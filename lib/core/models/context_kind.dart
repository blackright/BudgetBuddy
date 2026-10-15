/// The kind of context a sync row or pairing belongs to (data-model §1.1).
///
/// Only [shared] contexts are paired and exchanged in v1 (FR-016 keeps personal
/// profiles local-only); [personal] exists so the model is future-proof and the
/// [ChangeRecord] / [PairedContext] shapes do not change when personal sync is
/// ever turned on (US6, deferred).
enum ContextKind {
  personal,
  shared,
}

/// Which side of a pairing a row describes (data-model §1.2).
///
/// [presented] is the inviting device that shows the QR; [claimed] is the
/// joining device that scans it (`contracts/pairing.md` §2–§3).
enum PairingDirection {
  presented,
  claimed,
}
