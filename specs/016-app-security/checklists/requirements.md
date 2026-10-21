# Specification Quality Checklist: App Security Lock (PIN, Biometrics, Lock Behaviour, Protected Spaces)

**Purpose**: Validate specification completeness and quality before proceeding to planning
**Created**: 2026-10-18
**Feature**: [spec.md](../spec.md)

## Content Quality

- [x] No implementation details (languages, frameworks, APIs)
- [x] Focused on user value and business needs
- [x] Written for non-technical stakeholders
- [x] All mandatory sections completed

## Requirement Completeness

- [x] No [NEEDS CLARIFICATION] markers remain
- [x] Requirements are testable and unambiguous
- [x] Success criteria are measurable
- [x] Success criteria are technology-agnostic (no implementation details)
- [x] All acceptance scenarios are defined
- [x] Edge cases are identified
- [x] Scope is clearly bounded
- [x] Dependencies and assumptions identified

## Feature Readiness

- [x] All functional requirements have clear acceptance criteria
- [x] User scenarios cover primary flows
- [x] Feature meets measurable outcomes defined in Success Criteria
- [x] No implementation details leak into specification

## Notes

- Items marked incomplete require spec updates before `/speckit-clarify` or `/speckit-plan`
- Validation run 2026-10-18: all items pass.
- Deliberate wording: the specification states security *standards* as requirements ("256-bit" was the original wording; the lock spine keeps "under 300 ms", "4-8 digits", the device's own biometric prompt). No language, framework, library, or API is named, and no file, class, or schema is referenced.
- Split recorded 2026-10-18: the original draft asked for both the lock and an at-rest guarantee. Planning found the app's current local storage provides no way to encrypt records at rest, so the at-rest guarantee cannot be met without changing how data is stored. The lock spine stays here; the at-rest guarantee, the key, the reversible switch-over, and the one-time invitation move to `017-encrypted-storage`, which depends on this feature. Unused FR/SC numbers below are the ones that moved, kept visible so the split stays traceable.
- Validation run 2026-10-18 (after the split): all items pass. The earlier Notes line stating that a forgotten PIN means the data is "unreadable with no recovery" was wrong after the clarify answer and has been corrected: another subject on the same device can reset the PIN and keep every record; only when nothing on the phone can open the app is the PIN unrecoverable.
- Strength decision confirmed with the project owner on 2026-10-18: the strong option (the lock owns the way in), with the hardening rule that the PIN's verifier is never stored beside the data it protects, is delivered here; the second hardening rule (the data key is device-bound, non-exportable, absent from backups) is delivered by 017.
- Scope boundary: this feature adds a local lock only. It does not change the identity key, membership, the change exchange, or any existing sync guarantee from 015; the only new thing that travels between phones is the non-secret space access requirement.
- Honest limits recorded as assumptions rather than hidden: an Owner's requirement is enforced on each member's own device and cannot constrain a modified device, and this feature alone does not make the stored bytes unreadable - that is 017.
