# Implementation Plan: Live Device Sync (Deliver Cross-Device Changes)

**Branch**: `015-wire-device-sync` | **Date**: 2026-10-17 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/015-wire-device-sync/spec.md`

**Note**: This file is produced by `/speckit-plan`. It is the design; `/speckit-tasks` turns it into tasks.

## Summary

Feature 012 designed and unit-tested the whole peer-to-peer sync model (identity, pairing, signed
HLC change-log, deterministic merge, apply-time role enforcement, sealed-month immutability, per-peer
cursors, an mDNS/TLS LAN transport, a status surface, and per-entity codecs/appliers). Feature 014
added "People" (pair a contact, add them to a space). **None of it ever runs in the real app**: the
production `syncRecorderProvider` is built with **no signer** (so every `record(...)` is a silent
no-op), and `SyncEngine` / `LanTransport` / `LanTransportHost` are **never constructed anywhere in
`lib/`**. On two real phones nothing is recorded, discovered or exchanged, so a space an Owner adds a
contact to never reaches the member's phone.

This feature **starts the existing machinery for real devices** and fixes the one thing 012's design
was missing to work across two real databases: **stable entity identity**. 012's wire format and
signed records carry each device's *local* integer row ids (space id, budget id, expense id, …) and
write them back verbatim; that only ever passed in tests because both in-memory peers used id `1`. On
two real phones an incoming space's rows can collide with (and overwrite) the receiver's own rows, and
two phones can never agree that "this is the same expense" — so a member's edit to a row the Owner
created is seen as a brand-new row. The fix (user-approved) is a **stable UUID (`syncGuid`)** on every
synced entity: records and payloads identify entities by GUID, cross-references travel as GUIDs, and
each phone resolves a GUID to **its own** local row (allocating a fresh one on first sight). The
unique `syncGuid` index on each collection *is* the id map, so no separate translation table is
needed and no local row is ever overwritten.

Delivered outcome: two paired phones on the same network with the app open automatically converge
their shared changes (including a space the member's phone has never seen), each phone shows an
honest per-space sync state, and every 011/012 guarantee (offline-first, pairwise-only, role safety,
sealed-month immutability, confidentiality, no server/cloud/relay) is preserved.

## Technical Context

**Language/Version**: Dart 3.13.5 on Flutter 3.47.6 (Android first; dev device SM G965F).

**Primary Dependencies**: `flutter_riverpod` (state), `isar` 3.1 + `isar_ffi` (storage),
`cryptography` (ed25519 signing/verify), `basic_utils` (self-signed TLS cert for the transport),
`nsd` (mDNS advertise/discover), `go_router`, `local_auth`, `flutter_secure_storage`. All of these
already ship with 012 — **no new package is expected**.

**Storage**: Isar 3.1, local-only. **`schemaVersion` 16 → 17** via one **additive** step (17):
add a `syncGuid` to each of the ten synced collections and backfill a fresh UUID for every
pre-existing row. The index is a plain (non-unique) `@Index()`; uniqueness is held by construction
plus the step-17 backfill (see `data-model.md` §1). No monetary amount, seal, month total or existing
id is rewritten (011 SC-003 preserved).

**Testing**: `flutter_test`. Unit + widget tests only; the real transport is replaced by the existing
in-memory `FakeTransportHub` + `SyncTestHarness` (no sockets, no mDNS, no TLS in CI). GUID identity
and local-id translation are tested with two in-memory peers that deliberately use **different** local
ids (the case 012 never exercised), including cross-device edits to the same entity.

**Target Platform**: Flutter mobile app, Android first. iOS/web/desktop out of scope for this feature.

**Project Type**: single Flutter project, feature-modular (`lib/features/<feature>/…`).

**Performance Goals**: SC-001 — a change converges within 30 s of co-presence; SC-002 — a newly
shared space appears on the member's phone within 60 s of co-presence; a large first-time space
bootstrap completes without half-apply. Discovery/connection work runs off the widget-build path.

**Constraints**: offline-first (FR-007); **no** background service — exchange only while the app is
open and a paired peer is reachable (FR-009); co-location only; strictly **pairwise** (FR-014);
link **confidential and authenticated** (FR-015); per-context honest status (FR-008); no server,
cloud, relay or telemetry.

**Scale/Scope**: 2–5 paired devices per space (typ.), 1–3 shared spaces per install, a whole-space
bootstrap may carry thousands of change records. Single shared `MonthlyBudget` per month per space.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Gate | Verdict |
|---|---|---|
| I. Cross-Platform & Mobile First | Flutter app, Android first, no platform-locked design | PASS — reuses the existing cross-platform transport abstraction. |
| II. Clean Architecture & Testability | State management + testable seams; feature modules | PASS — new orchestration sits behind providers/services; transport stays behind the `Transport` interface and is faked in tests. |
| III. Offline-First & Synchronization | Core features work with no internet; sync optional/user-controlled | PASS — this *is* the sync enablement; with no peer everything works and nothing is transmitted (FR-007). |
| IV. Modular Financial Logic | No change to availability/medical money math | PASS — sync only moves existing rows; no engine math is touched. |
| V. Security & Privacy First | Auth-gated sensitive data; nothing visible until authenticated | PASS — the private key stays keystore-backed and is released only behind the existing device-auth gate; the LAN link is TLS-encrypted and pinned to the paired key; no data leaves the two devices. |
| VI. Playful & Modern Design | Clean, fluent UI | PASS — one small status chip on an existing screen plus the existing settings entry. |

**Result: no violations. Complexity Tracking not required.**

## Project Structure

### Documentation (this feature)

```text
specs/015-wire-device-sync/
├── plan.md              # This file (/speckit-plan output)
├── research.md          # Phase 0 output (/speckit-plan)
├── data-model.md        # Phase 1 output (/speckit-plan)
├── quickstart.md        # Phase 1 output (/speckit-plan)
├── contracts/           # Phase 1 output (/speckit-plan)
│   ├── runtime-orchestration.md
│   └── entity-identity.md
├── checklists/
│   └── requirements.md
└── tasks.md             # Phase 2 output (/speckit-tasks - NOT created here)
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── database/
│   │   ├── isar_helper.dart                 # (no edit — collections unchanged; only columns added)
│   │   └── schema_migrations.dart           # EDIT: schemaVersion 16→17, step 17 (backfill GUIDs)
│   ├── models/
│   │   ├── change_record.dart               # EDIT: identity by syncGuid (contextSyncGuid/entitySyncGuid)
│   │   ├── shared_space.dart                # EDIT: add syncGuid
│   │   ├── shared_member.dart               # EDIT: add syncGuid
│   │   ├── monthly_budget.dart              # EDIT: add syncGuid
│   │   ├── expense.dart                     # EDIT: add syncGuid
│   │   ├── medical_bill.dart                # EDIT: add syncGuid
│   │   ├── insurance_profile.dart           # EDIT: add syncGuid
│   │   └── … (family_member, medical_provider, medical_service_type)  # EDIT: add syncGuid
│   └── … (reimbursement.dart)               # EDIT: add syncGuid
├── features/
│   ├── sync/
│   │   ├── domain/
│   │   ├── sync_codec.dart                  # (no change expected)
│   │   ├── sync_codec_registry.dart         # (no change expected)
│   │   ├── sync_guid.dart                   # NEW: newSyncGuid() + GUID field conventions
│   │   ├── codecs/*.dart                     # EDIT (all 10): emit syncGuid + GUID refs, no local id
│   │   ├── entity_applier.dart              # EDIT (all 10): resolve GUID → local row id
│   │   └── sync_id_translator.dart          # NEW: GUID → local id resolve/allocate + ref mapping
│   │   ├── repositories/
│   │   │   ├── change_signing.dart          # EDIT: canonical bytes by GUID, not local id
│   │   │   ├── sync_engine.dart             # EDIT: GUID identity, two-pass apply, respond()
│   │   │   ├── sync_coordinator.dart        # NEW: discovery/connect/exchange lifecycle
│   │   │   └── sync_recorder.dart           # EDIT: pass entity syncGuid
│   │   ├── providers/
│   │   │   ├── sync_session_provider.dart   # NEW: unlocked keypair → signer/session
│   │   │   ├── sync_recorder_provider.dart  # EDIT: attach the session signer when unlocked
│   │   │   ├── sync_engine_provider.dart    # NEW: engine with keys trusted from PairedPeer rows
│   │   │   ├── sync_coordinator_provider.dart # NEW: lifecycle start/stop
│   │   │   └── sync_status_provider.dart    # EDIT: per-context (family) notifier + pending
│   │   └── transport/lan_transport.dart     # unchanged (already TLS + pinned handshake)
│   ├── dashboard/presentation/
│   │   ├── dashboard_screen.dart            # EDIT: show the per-space chip beside the month
│   │   └── month_navigator.dart             # EDIT (or AppBar action): mount SyncStatusChip(spaceId)
│   ├── spaces/presentation/space_settings_section.dart  # EDIT: chip takes the active spaceId
│   └── spaces/repositories/spaces_repository.dart        # EDIT: pass GUIDs through (no wiring change)
├── shared/presentation/widgets/sync_status_chip.dart    # EDIT: take a spaceId; read family provider
├── main.dart                                # EDIT: start/stop the coordinator with app lifecycle
└── shared/presentation/app_shell.dart       # (no change expected)

test/
├── features/sync/
│   ├── entity_identity_test.dart            # NEW: different local ids each peer; cross-device edit merges
│   ├── bootstrap_delivery_test.dart         # NEW: a never-seen context materializes whole
│   ├── convergence_delivery_test.dart       # NEW: GUID-keyed convergence of create + edit both ways
│   ├── sealed_delivery_test.dart            # NEW: a sealed month stays byte-identical through delivery
│   ├── sync_coordinator_test.dart           # NEW: discover→connect→exchange over FakeTransportHub
│   ├── sync_privacy_test.dart               # NEW: offline no-send; unpaired refused; deactivated context skipped
│   ├── sync_confidentiality_test.dart       # NEW: key-pinned session; no payload before proof
│   └── sync_status_test.dart                # EDIT: per-context pending semantics
├── features/spaces/…                        # EDIT: chip placement widget tests
└── core/database/schema_migrations_test.dart # EDIT: step 17 additive + GUID backfill
```

**Structure Decision**: The feature lives inside the existing `lib/features/sync/` module (clean-
architecture feature pattern already used by 011/012). New behaviour is split into a pure
`SyncIdTranslator` (GUID→local resolution + reference rewriting, testable without a socket), a
`SyncCoordinator` (orchestration only), and Riverpod providers that wire the recorder/engine/
coordinator to the unlocked identity and the `PairedPeer` rows. Entity identity changes are additive
columns on the existing models (no new collection). UI changes are limited to the status chip and its
two mount points.

## Complexity Tracking

> No Constitution Check violations — section intentionally empty.
