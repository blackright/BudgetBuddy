# Implementation Plan: Cross-Device Shared Spaces (Peer-to-Peer)

**Branch**: `012-cross-device-shared-spaces` | **Date**: 2026-10-10 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/012-cross-device-shared-spaces/spec.md`

## Summary

Extend feature 011's single-device shared spaces to **co-located peer devices** with **no server, no cloud and no accounts**. Identity is a local **username + device-generated keypair** (ed25519), unlocked by the phone's own authentication (`local_auth`) with a **voluntary, revocable consent record**. Devices join by **in-person QR pairing** (public keys + fingerprint) and exchange changes over the **local network** (mDNS discovery + a pinned-TLS socket). Sync is a **signed, versioned change-log** (HLC ordering, tombstones, per-entity codecs) applied deterministically on each device; membership rows are **signed and versioned** so role changes win without a server (011's `SpaceAccessGuard` matrix extends to apply-time enforcement). Sealed months are **content-exchanged once then immutable**, converting with each device's own device-global seals so totals match. Recovery is a **user-held encrypted backup** unlocked by a chosen passphrase **or** a generated recovery code. Everything 011 guarantees offline keeps working; co-presence only adds convergence. Git 🛑 hands-off — user pushes.

## Technical Context

**Language/Version**: Dart 3.13.5 / Flutter 3.47.6 stable (matches 009/010/011 baseline).

**Primary Dependencies**: existing Riverpod + Isar 3.1.0 (local DB, `build_runner` codegen), `uuid`, `path_provider`, `file_picker`, `intl`. **New packages required** (all standard, pub.dev): `local_auth` (device PIN/biometrics), `flutter_secure_storage` (keystore for the private key), `cryptography` (ed25519 signing, x25519+AES-GCM transport/backup, Argon2id KDF), `mobile_scanner` + `qr_flutter` (QR pairing), `multicast_dns` *(or `nsd`)* (LAN discovery), `share_plus` (backup export). Transport stack is the one place with alternatives (see research R2).

**Storage**: Isar 3.1.0, local-only. **New collections**: `Identity`, `ConsentRecord`, `PairedPeer`, `PairedContext`, `PairingToken`, `ChangeRecord` (+ `SyncCursor`). **Modified**: `SharedMember` gains `version/updatedAt/authorIdentityId/signature/revokedAt` (signed, versioned membership). App-level migration steps **14** (additive: new collections + membership sync columns) and **15** (no-op/backfill guard) in `lib/core/database/schema_migrations.dart` (`schemaVersion` 13 → 15). The private key is **not** stored in Isar (secure storage only). Seals/rates stay device-global (unchanged).

**Testing**: `flutter_test` (391 passing / 1 skipped as of 2026-10-10). New tests: identity/consent, pairing handshake + fingerprint, change-log codec round-trip, HLC deterministic merge, tombstones, membership authorization at apply-time, sealed-month invariance, backup/recovery round-trip (passphrase **and** recovery code), offline matrix. Networks are **not** exercised in unit tests: a **fake transport** + in-memory peer stand in (same pattern as 011's `_FakeSpacesRepository`), so nothing binds a socket under the test harness.

**Target Platform**: Android first; iOS later (Constitution I). LAN discovery/QR/`local_auth`/secure storage all have Android+iOS implementations; desktop/web are out of scope for this feature.

**Project Type**: Mobile app — single Flutter project with `lib/`, `test/`, platform directories.

**Performance Goals**: pairing + first convergence in under 2 minutes in person (SC-006); a change converges within 30 s of co-presence (SC-001); no regression to 011 offline operations or the 1-frame context switch (011 SC-002); change-log apply is incremental (no full-context rewrite).

**Constraints**: peer-to-peer, no server/relay (spec); fully offline for every 011 operation (FR-003); exactly-one-context invariant preserved (011 FR-003); sealed past months content-immutable on every device (FR-011); vault personal-only (FR-015); one identity ↔ one profile (FR-016); no data leaves a device except a user-initiated backup (FR-017); deterministic merge with no silently-lost whole records (FR-007).

**Scale/Scope**: small peer sets (2–5 devices per space), hundreds of rows per device-month; spans ~8 source areas: new identity/consent domain, new pairing domain, new sync engine (change-log + codec + merge), new transport abstraction, spaces repository/guard extension to signed membership, backup/recovery service, settings/onboarding UI, migration + tests.

**Unknowns**: resolved in research.md (R1–R9). Notable: transport stack choice (R2), change-log vs column-diffing (R3), authorization without a server (R5), backup archive crypto (R7).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| # | Gate (Constitution) | Verdict | Evidence |
|---|---|---|---|
| I | Cross-platform & mobile-first (Flutter, Android first) | ✅ PASS | Pure Dart/Isar/Riverpod + platform plugins with Android+iOS support; no server component |
| II | Clean Architecture & testability (Riverpod; evolve without breaking financial logic) | ✅ PASS | New seams are isolated (`IdentityService`, `SyncEngine`, `Transport`, `BackupService`); money math untouched; merge/pairing/role logic are pure Dart, unit-testable with a fake transport |
| III | Offline-first & sync-ready | ✅ PASS (directly implements the "fully support multi-device sync" clause) | All 011 ops stay local; sync is opportunistic peer exchange; user-controlled; no background cloud |
| IV | Modular financial logic (planned/paid/reimbursed; medical; single source of truth) | ✅ PASS | Changes exchange and re-apply existing rows; no amount is recomputed; one conversion path inherited |
| V | Security & privacy first | ✅ PASS (strengthened) | Device-native auth via `local_auth`; private key in platform keystore; signed changes; data stays on the two devices; explicit, revocable consent record |
| VI | Playful & modern design | ✅ PASS | Onboarding/pairing/sync-status follow existing Material patterns; emoji avatars inherited |
| A1 | Multi-Currency (≥ HUF/USD/CAD/EUR) | ✅ PASS | Space currency + device-global seals untouched; conversion stays local |
| A2 | Multi-User Profiles | ✅ PASS | One identity ↔ one profile; extra profiles remain local-only (FR-016) |
| A3 | Performance (lightweight, fast) | ✅ PASS | Incremental change-log apply; no per-frame I/O; discovery/pairing are on-demand |
| D1 | Iterative delivery & feature encapsulation | ✅ PASS | Phased: identity/consent → pairing → sync engine → signed membership/authorization → backup/recovery → UX/status → polish |

**Gate result: PASS, no violations → Complexity Tracking left empty.**

*Post-design re-check (after Phase 1):* data-model, contracts and quickstart add no new projects or byzantine layers. The change-log + codec and the transport abstraction are the only new architectural surfaces; both are single seams behind interfaces with fake implementations for tests. Membership signatures are the one judgment call, justified in R5. MonthRateSeal/LiveRateSet stay device-global (correct — market data, not user money). **Still PASS**, no violations to justify.

## Project Structure

### Documentation (this feature)

```text
specs/012-cross-device-shared-spaces/
├── plan.md              # This file (/speckit-plan output)
├── research.md          # Phase 0 output (R1–R9)
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/
│   ├── pairing.md            # QR + LAN handshake, fingerprint, single-use token (FR-004/005)
│   ├── sync-protocol.md      # Signed change-log, HLC, tombstones, deterministic merge (FR-006/007)
│   ├── role-authorization.md # Signed/versioned membership + apply-time enforcement (FR-008/009)
│   └── backup-recovery.md    # Encrypted archive, passphrase OR recovery code, restore (FR-012)
└── tasks.md             # Phase 2 output (/speckit-tasks — NOT created here)
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── models/                  # NEW: identity.dart, consent_record.dart, paired_peer.dart,
│   │                            #      paired_context.dart, pairing_token.dart, change_record.dart, sync_cursor.dart
│   │                            # SharedMember +version/updatedAt/authorIdentityId/signature/revokedAt
│   ├── database/                # schema_migrations.dart — NEW steps 14 (additive) + 15; isar_helper registers new collections
│   └── providers/               # NEW: identity_provider.dart (active identity + consent state); context router unchanged
├── features/
│   ├── identity/                # NEW FEATURE: IdentityService (create/load identity, keystore key),
│   │                            #   ConsentService (record/show/revoke), local_auth gate, onboarding UI
│   ├── pairing/                 # NEW FEATURE: pairing service + QR presentation/scan UI + LAN discovery + handshake
│   ├── sync/                    # NEW FEATURE: ChangeLog recorder + per-entity SyncCodec, HLC, SyncEngine (merge),
│   │                            #   Transport abstraction (LAN impl + fake), SyncStatus provider + UI
│   ├── spaces/                  # repositories/space_role_guard gains apply-time enforcement of signed membership;
│   │                            #   spaces_repository writes append ChangeRecords (SyncRecorder seam)
│   ├── backup/                  # NEW FEATURE: BackupService (export/import archive), RecoveryCodeService, UI
│   └── settings/                # space settings: "Paired devices" section (pair/unpair, role, status)
└── shared/presentation/widgets/ # sync status chip (waiting for peer / converged)

test/
├── features/identity/           # identity + consent + local_auth abstraction (fake)
├── features/pairing/            # handshake, token single-use/expiry, fingerprint match
├── features/sync/               # codec round-trip, HLC merge determinism, tombstones, conflict surfacing
├── features/spaces/             # signed-membership authorization at apply-time (extends T031)
├── features/backup/             # export/import round-trip via passphrase AND recovery code
└── harnesses                    # in-memory peer + fake transport; real-Isar harness gains new collections
```

**Structure Decision**: Single-project Flutter layout (unchanged). The feature is encapsulated behind five seams: **IdentityService** (identity + keystore), **ConsentService** (local, revocable), **Transport** (LAN impl vs fake; nothing else knows about sockets), **SyncEngine** (change-log + merge; pure logic over codecs), and **SpacesRepository/Guard** (writes record changes; apply-time enforcement of signed membership). Existing features stay unaware of the network — they keep writing through repositories, which now also append change records.

## Complexity Tracking

No constitution violations to justify — table intentionally empty.
