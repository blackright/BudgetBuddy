# Quickstart: Live Device Sync (Deliver Cross-Device Changes)

**Feature**: 015-wire-device-sync

This is a verification guide, not a hello-world. It maps each user story to an observable outcome and
to commands you can run. The real transport (mDNS + TLS) cannot run in CI, so automated checks drive
two in-memory peers through `FakeTransportHub`; manual checks use two physical Android phones on one
Wi-Fi/hotspot.

---

## Prerequisites

- Flutter 3.47.6 / Dart 3.13.5; Android device SM G965F (or two emulators/phones).
- App installed on **two** devices, each with its own identity created.
- The two devices paired (014 "People": scan the contact QR on one, confirm on the other).
- Both devices on the **same** Wi-Fi network or one acting as a hotspot (co-location only).

Quality gate (run before and after changes):

```powershell
$env:FLUTTER_ALREADY_LOCKED='true'
dart format lib test
flutter analyze --no-pub
flutter test
```

---

## Automated checks (fast, hermetic)

Run the sync suite:

```powershell
flutter test test/features/sync
```

Expected, and what each proves:

| Test | Proves | User story |
|---|---|---|
| `entity_identity_test.dart` | two peers with **different** local ids converge; a member's edit to an Owner-created row merges into the *same* row (not a duplicate) | US1 |
| `bootstrap_delivery_test.dart` | a context the receiver has never seen materializes whole (space + members + months + expenses), usable offline | US2 |
| `convergence_delivery_test.dart` | GUID-keyed convergence of a create and an edit in both directions | US1 |
| `sealed_delivery_test.dart` | a sealed month stays byte-identical through delivery; a post-seal edit is refused; totals match | US1 |
| `sync_coordinator_test.dart` | discover → connect → per-context round over `FakeTransportHub`; only own-authored records are sent; non-paired peers are refused | US1/US4 |
| `sync_privacy_test.dart` | offline no-send; unpaired proof refused before apply; deactivated context not exchanged | US4 |
| `sync_confidentiality_test.dart` | session only after the paired key proves possession; no payload bytes before proof | US4 |
| `sync_status_test.dart` | `pending>0 ⇒ waiting for peer`, else up to date; per-space independence | US3 |
| `schema_migrations_test.dart` | step 17 assigns a unique `syncGuid` to every existing row; idempotent; no amount/seal changed | data integrity |

Full suite: `flutter test` (expect all prior tests green plus the new ones).

---

## Manual validation (two real phones)

### Scenario A — a change reaches the other phone (US1)

1. On phone **A**, open the shared space and add a shared expense (e.g. 5 000).
2. Keep both phones with the app **open, unlocked, on the same Wi-Fi**, near each other.
3. Within ~30 s (SC-001), phone **B** shows the expense. A's status chip reads "up to date".

### Scenario B — a member's edit merges (US1, the GUID case)

1. On phone **B**, edit that **same** expense (change the amount or title).
2. Both phones near each other; within ~30 s phone **A** shows B's edit **on the same row** (one
   expense, not two).
3. Confirm no pre-existing phone-B expense got overwritten (local data is never clobbered).

### Scenario C — a brand-new shared space materializes on the member's phone (US2)

1. On phone **A**, create a new space and add phone **B**'s person as Editor.
2. Keep both phones open and near each other. Within ~60 s (SC-002), the space — its months, expenses
   and members — appears on phone **B**, usable with no network.
3. Reopen B's app: the space is still there (no half-apply).

### Scenario D — honest status (US3)

1. On phone **A**, make a change, then immediately send phone **B** to the background or off Wi-Fi.
2. Phone **A**'s chip reads "waiting for peer" for that space only.
3. Bring B back: A converges to "up to date".

### Scenario E — offline & privacy (US4)

1. Turn off Wi-Fi on both phones: every feature keeps working; nothing is transmitted (FR-007).
2. With a laptop running a packet capture on the LAN, perform a sync: you see only TLS, no readable
   financial data (SC-008).
3. Lock phone **A** (or kill the app): A neither writes nor sends changes; the change-log stays inert.

---

## What "done" looks like

- `flutter test` is green (currently 759 passed, 1 skipped — including the full `test/features/sync/`
  suite), `flutter analyze` clean, `dart format` no diffs.
- Scenarios A–E pass on two real phones.
- The status chip appears beside the month on the shared-space money screen and in space settings, per
  space.
- No new dependency, no server, no background service.
