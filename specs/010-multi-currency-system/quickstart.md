# Quickstart Validation Guide: Multi-Currency System (Unified)

**Feature**: 010-multi-currency-system | **Purpose**: prove the feature works end-to-end before merge. Validation only — implementation details live in `tasks.md`.

---

## Prerequisites

- Flutter 3.47.6 stable on PATH; `flutter pub get` succeeds.
- Codegen up to date: `dart run build_runner build --delete-conflicting-outputs` (required after any model change).
- A device/emulator; **for offline scenarios: ability to toggle airplane mode**, and the ability to change system font scale / date (or a seeded device date) for month-rollover checks.
- Network available for the online scenarios (rate fetches are anonymous GETs).

## Commands (from repo root)

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart format --output=none --set-exit-if-changed .
flutter analyze          # expected: 0 new issues
flutter test             # expected: all green; this step must also exist in CI
```

---

## Scenario matrix

### V1 — Conversion correctness (automated)

Run `flutter test`. Expected:
- Conversion matrix green: all 12 directed pairs × {sealed, provisional, approximate, missing} × {4 main currencies}; round-trip `A→B→C = A→C` within display tolerance (SC-009).
- Missing-rate cases assert `isDegraded` and **assert the value is NOT 1.0** (FR-014, SC-005).
- Seal lifecycle tests: offline close → provisional → retry → sealed; grace expiry → approximate; sealed rows never mutate (SC-003).
- Migration tests (real-Isar harness): step 9 dry-run report lists lossy rows; committing preserves every amount exactly or flags it (FR-021).
- Existing 221 tests remain green.

### V2 — Original + converted display (manual)

1. Main currency HUF; add a $10.00 USD expense.
2. Expected: dashboard/list show the HUF amount **and** `· $10.00` beside it (FR-002); no screen shows a different total (SC-001).

### V3 — Main currency switch = zero writes (manual)

1. Note a sealed month's displayed totals; change profile main currency HUF → EUR.
2. Expected: every screen updates in < 1 s (SC-002); stored records unchanged (verify the same expense still shows `$10.00` original and its stored amount untouched); sealed months re-render via their own seals.

### V4 — Month seal on rollover (manual, needs date control)

1. With the device in the previous calendar month, open the app (cold start).
2. Advance device date past the month boundary; reopen the app.
3. Expected: previous month appears in Currency Settings as `sealed` with an `asOf` date ≤ its close date; **no user action taken** (FR-004); app interactive throughout (I3).

### V5 — Offline seal → provisional → correct (manual)

1. Airplane mode ON before crossing a month boundary; reopen app after boundary.
2. Expected: month closes as `provisional`; dashboard banner explains approximate rates; settings badge lit; app fully usable (SC-004); **no crash, no blocked action**.
3. Airplane OFF; reopen within 7 days.
4. Expected: month upgrades to `sealed`; banner and badge clear automatically (FR-007).

### V6 — Missed months / historical fetch (manual)

1. Seed several unsealed past months (e.g. move date forward by 3 months while offline, then reconnect).
2. Expected: each missed month seals with rates for **its own** close date (`asOf` matches its month, not today) — FR-008; month-end on a weekend seals with the nearest prior business day; total provider failure → `approximate` with permanent badge, never a fabricated rate (SC-005).

### V7 — Per-month convert-to independence (manual)

1. Set March → USD, leave April at default; view both.
2. Expected: March renders in USD, April in main currency simultaneously (SC-006); clearing March restores main currency; switching one never rewrites stored data (FR-011).

### V8 — Offline CRUD + no fabricated rates (manual)

1. Airplane mode ON.
2. Expected: create/edit/delete expense, reimbursement, medical bill all succeed with no rate error (FR-017, SC-004); viewing sealed months is identical to online (SC-003).
3. Force a missing rate (e.g. seed a legacy GBP record): value displays with the unavailable label; **nowhere** does a converted figure equal the raw amount as if rate = 1 (SC-005).

### V9 — Single formatting path (manual spot-check)

Check dashboard, expense list, expense detail, medical dashboard, reimbursement sheet, settings for: same currency symbol source, HUF with **no decimals**, USD with 2, original amount always adjacent. No screen may show `$` when main currency is EUR (defects D4/D10 fixed; FR-018).

### V10 — CI gate

Push a branch and confirm the workflow runs `flutter test` in addition to format/analyze (research R10). Expected: test step present and green.
