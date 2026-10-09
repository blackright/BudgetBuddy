---

description: "Task list template for feature implementation"
---

# Tasks: Multi-Currency System (Unified)

**Input**: Design documents from `/specs/010-multi-currency-system/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/](./contracts/), [quickstart.md](./quickstart.md)

**Tests**: Included — explicitly justified: spec success criterion **SC-005** requires the no-fabricated-rate property to be "verifiable by test across all 12 directed currency pairs", and [quickstart.md](./quickstart.md) V1 names the automated matrix as the primary validation gate.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

Flutter single project (per plan.md): source in `lib/`, tests in `test/`, CI in `.github/workflows/`, schema migrations in `lib/core/database/`.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Establish a green, test-capable baseline before any feature code

- [X] T001 [P] Add a `flutter test` step (after `flutter analyze`) to `.github/workflows/flutter_validation.yml` — CI currently never runs tests (research R10, defect D11)
- [X] T002 Run the baseline from repo root — `flutter pub get`, `dart run build_runner build --delete-conflicting-outputs`, `dart format --output=none --set-exit-if-changed .`, `flutter analyze`, `flutter test` — and record expected starting point (221 tests green, 1 pre-existing analyzer warning in `lib/features/medical/presentation/medical_dashboard.dart`)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Value types, rate plumbing and additive schema that EVERY user story consumes

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T003 [P] Create `CurrencyCode` value type (code, symbol, exponent, displayName, exhaustive enum + parse/lookup helpers) in `lib/core/models/currency_code.dart` — the single definition per FR-001 / data-model §1.1
- [X] T004 [P] Create `Money` value type (int minorUnits + CurrencyCode, round-half-away-from-zero, exact `+`/`−`, rate scaling with single rounding) in `lib/core/models/money.dart` per data-model §1.2
- [X] T005 Create the single shared money formatter (exponent-aware: HUF 0 decimals, others 2; symbol from `CurrencyCode`) in `lib/shared/presentation/money_format.dart` per contract `currency-conversion.md` §4 — the only rounding-at-display point in the app (FR-015, FR-018, defect D10)
- [X] T006 Rewrite the rate client to Frankfurter in `lib/core/network/exchange_rate_client.dart`: live `v1/latest?base=USD`, historical `v1/{date}?base=USD`, ≤7-day walk-back on 404 (weekends/holidays, verified behavior research R1), 24h-throttle metadata (`fetchedAt`) — replaces the deprecated v4 endpoint
- [X] T007 [P] Create the bundled baseline rate table (first-launch-offline seed, `source: bundled`) in `lib/core/network/baseline_rates.dart` per research R11
- [X] T008 Create the `RateTable` + rate registry provider — in-memory `yearMonth → RateTable`, synchronous lookup, `ConversionResult` with `isStale`/`isDegraded`, hydration from Isar, unsealed months read the live table — in `lib/features/engine/providers/rate_registry_provider.dart` per research R4 and contract `currency-conversion.md` §1
- [X] T009 [P] Create the `MonthRateSeal` Isar collection (yearMonth unique, status enum, four USD-based rates, asOf/fetchedAt/source/closedAt/attemptCount) in `lib/core/models/month_rate_seal.dart` per data-model §2.1 — run build_runner
- [X] T010 [P] Create the `LiveRateSet` Isar collection (four rates vs USD, fetchedAt, source, stale flag) in `lib/core/models/live_rate_set.dart` per data-model §2.2 — run build_runner
- [X] T011 Register migration **step 8** (additive, reversible): create the two new collections, add `MedicalBill.currency` field, bump `schemaVersion` 7 → 8 in `lib/core/database/schema_migrations.dart`; add regression test for step idempotency in `test/core/database/schema_migrations_test.dart`

**Checkpoint**: Foundation ready — user story implementation can now begin

---

## Phase 3: User Story 1 - Spend in any currency, see my month in my main currency (Priority: P1) 🏆 MVP

**Goal**: Expenses recorded in their original currency; all totals displayed in the profile's main currency through one conversion path, original amount always shown, record CRUD fully offline

**Independent Test**: Set main currency HUF; create expenses in HUF, USD and EUR; verify dashboard/list/detail totals equal the originals converted at the displayed rate, originals shown adjacent, and creation/edit/delete succeed in airplane mode (quickstart V2, V8)

### Tests for User Story 1

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation** (SC-005)

- [X] T012 [P] [US1] Conversion matrix tests — all 12 directed pairs, round-trip `A→B→C = A→C` within display tolerance, missing rate yields `isDegraded` and **asserts the result is NOT 1.0** — in `test/features/engine/currency_conversion_test.dart` (FR-012, FR-013, FR-014, SC-005, SC-009)

### Implementation for User Story 1

- [X] T013 [US1] Implement pure `convert()` returning `ConversionResult` (rate from registry, rounding to target exponent) in `lib/features/engine/currency_conversion.dart` per contract `currency-conversion.md` §2 (depends T008)
- [X] T014 [US1] Money one-cut on models: convert `amount` to integer minor units and currency to `CurrencyCode`-backed values on `lib/core/models/expense.dart`, `lib/features/expenses/models/reimbursement.dart`, `lib/core/models/medical_bill.dart`; run build_runner; fix type fallout in constructors (FR-015)
- [X] T015 [US1] Migration **step 9** — dry-run capable two-phase: doubles → minor units with lossless/lossy **flagging** (never silent rounding), report generator first, commit path second — in `lib/core/database/schema_migrations.dart`, with harness test asserting report contents and exact amount preservation in `test/core/database/schema_migrations_money_test.dart` (FR-021, data-model §6)
- [X] T016 [US1] Delete write-path rate resolution: remove `getRate` calls and `exchangeRateToPrimary` writes from `lib/features/expenses/repositories/expense_repository.dart` (addExpense/updateExpense) and `lib/features/expenses/repositories/reimbursement_repository.dart`, updating callers in `lib/features/expenses/presentation/widgets/reimbursement_entry_sheet.dart` — saving offline needs no rate (FR-017, defect D1)
- [X] T017 [US1] Re-point engine aggregates to conversion: per-row convert then exact integer sum in `lib/features/engine/month_summary.dart`, `lib/features/engine/providers/true_available_provider.dart`, `lib/features/engine/providers/safe_to_spend_provider.dart`, `lib/features/engine/providers/month_summary_provider.dart`, `lib/features/engine/expense_delta.dart` (fixes unconverted `moneyReturned`/`excessReturned`, defect D2; FR-018)
- [X] T018 [P] [US1] Consolidate currency pickers onto the single `CurrencyCode` list and remove GBP: `lib/features/expenses/presentation/add_expense_screen.dart`, `lib/features/expenses/presentation/edit_expense_screen.dart`, `lib/features/expenses/presentation/widgets/reimbursement_entry_sheet.dart` (FR-001, defect D4)
- [X] T019 [US1] Route every money display through the shared formatter with original amount adjacent: `lib/features/dashboard/presentation/widgets/month_summary_card.dart`, `lib/features/dashboard/presentation/widgets/month_summary_details.dart`, `lib/features/expenses/presentation/expenses_screen.dart`, `lib/features/expenses/presentation/expense_detail_screen.dart`, `lib/features/medical/presentation/medical_theme.dart` (replace `MedicalTheme.money` hardcode), `lib/features/medical/presentation/medical_dashboard.dart` (FR-002, FR-018, defects D8-adjacent display drift, D10)
- [X] T020 [US1] Give `MedicalBill` its own currency end-to-end — entry + display: `lib/features/medical/presentation/medical_bill_form.dart`, `lib/features/medical/repositories/medical_repository.dart` (stop inheriting expense currency with forced 1.0, defect D6; insurance % stays in original currency per FR-016)
  - **Result (2026-10)**: entry + display already folded in by T-R02/T-R03/T-R04 (form records the bill's own currency from the picker; `_syncLinkedExpense` copies it to the linked expense; detail/dashboard render the bill currency with the converted budget figure beside it). Re-verified and pinned with new `medical_repository_test.dart` cases: a €1,000 EUR bill keeps `currency = 'eur'`, computes the 20% share in EUR (FR-016), and writes a EUR linked expense (no forced 1.0); a legacy `currency == ''` bill follows the budget currency on its expense.
- [X] T021 [US1] Render degraded/unavailable labels on any value whose `ConversionResult.isDegraded = true` (shared label widget used by money display paths) in `lib/shared/presentation/widgets/degraded_amount_label.dart` (FR-014)
  - **Result (2026-10)**: new shared `DegradedAmountLabel` renders converted + original for a good result, and for a `null`/degraded result shows the original amount with an explicit "Rate unavailable" text marker (never colour alone) and a tooltip — no fabricated figure. Wired into `medical_detail_screen.dart` `_PaymentMethodSection` (the money-impact line), which now uses the registry's `convert()` so `isDegraded` is visible instead of silently zeroed. Covered by `test/shared/presentation/degraded_amount_label_test.dart` (5 cases: converted+original, same-currency collapse, degraded original+label, no converted figure when degraded, null treated as degraded).
- [X] T022 [US1] Validate story end-to-end against scenarios V2, V8 in `specs/010-multi-currency-system/quickstart.md` and confirm all pre-existing tests still green; record results in this task's completion note
  - **Result (2026-10)**: full gate from repo root — `dart format .` (3 changed, then clean), `flutter analyze lib test` → **No issues found**, `flutter test` → **282 passed / 1 skipped** (pre-existing skip), no regressions. Automated coverage for V2/V8: conversion matrix (T012), dashboard/engine scale (T-R07), foreign-bill display (T-R06), and the new T020/T021 tests. **Open**: the manual on-device airplane-mode walkthrough of V2/V8 (create HUF/USD/EUR expenses offline; verify totals + originals) still needs a device session — no device was attached during this run.

**Checkpoint**: User Story 1 fully functional and testable independently — **MVP milestone**

---

## Phase 4: User Story 2 - Closed months never move (Priority: P1)

**Goal**: Every completed calendar month freezes with its own four-currency rate table; sealed totals are immutable, offline and unaffected by rate changes or main-currency switches

**Independent Test**: Seal a month, then change rates / go offline for weeks / switch main currency — the month's totals are identical every time (quickstart V3, V4, V6; SC-003)

### Tests for User Story 2

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [X] T023 [P] [US2] Seal lifecycle tests — offline close → `provisional`; retry success within 7 days → `sealed`; grace expiry → `approximate`; sealed rows never modified by auto passes; weekend 404 walk-back — in `test/features/engine/month_seal_lifecycle_test.dart` per contract `month-seal-lifecycle.md` (FR-006, FR-007, FR-008, SC-003)
  - **Result (2026-10)**: new `test/features/engine/month_seal_lifecycle_test.dart` (9 cases) + `test/features/engine/rate_test_support.dart` (fake client, scripted Dio adapter, real-Isar harness). Covers: offline close → `provisional` (last-known/bundled, `closedAt = now`, `attemptCount = 1`); retry inside grace → `sealed` with `closedAt` preserved; grace expiry → `approximate`; long-past month offline → `approximate` with `closedAt == null`; reachable history → `sealed` `asOf` = its own close date; the open month is never sealed; live refresh throttled to 24h; failed refresh flags `stale` but keeps the rates. Weekend walk-back is exercised against the **real** `ExchangeRateClient` via a scripted `HttpClientAdapter` (Saturday 2026-09-26 → Friday 2026-09-25) plus a give-up-after-7-days case.

### Implementation for User Story 2

- [X] T024 [US2] Implement the idempotent seal coordinator — `runSealPass(now)`: seal eligible months via historical fetch, upgrade `provisional` ≤ 7 days, refresh live table ≤ 24h, increment `attemptCount`, emit registry updates — in `lib/features/engine/seal_coordinator.dart` per contract `month-seal-lifecycle.md` §2
  - **Result (2026-10)**: new `lib/features/engine/seal_coordinator.dart` — `SealCoordinator(isar, client, clock)` with `runSealPass([now])`, `closeCurrentMonth([now])`, and `sealCoordinatorProvider`. State machine: final rows (`sealed`/`approximate`) skipped (I2); fetch success → `sealed`/`historical`; failure with no row → `provisional` inside the 7-day grace else `approximate` (`closedAt = null`); existing `provisional` retried, upgraded on success or frozen to `approximate` after grace; `attemptCount` incremented per failed attempt (I6). Live singleton refreshed only when absent or `now − fetchedAt ≥ 24h`; on failure the row is flagged `stale` and rates kept (I4). Registry updates flow automatically through the existing Isar `.watch()` seats (`sealedRateTablesProvider`/`liveRateTableProvider`).
- [X] T025 [US2] Register the coordinator on cold start and `AppLifecycleState.resumed` (post-frame, never blocks first frame) in `lib/main.dart` — no lifecycle observer exists today (research R3; FR-004, invariant I3)
  - **Result (2026-10)**: `main.dart` gains `_SealLifecycleObserver` (a `WidgetsBindingObserver`) registered after `runApp`; the first pass runs in an `addPostFrameCallback` and every `AppLifecycleState.resumed` re-runs it via `unawaited(...)` — so no network is ever awaited before the first frame (I3).
- [X] T026 [US2] Registry sealed-read semantics: `sealed`/`approximate` months read only their seal; live table restricted to the open month; historical 404 walk-back ≤ 7 days with `lastKnown` → `approximate` fallback — update `lib/features/engine/providers/rate_registry_provider.dart` and `lib/core/network/exchange_rate_client.dart` (FR-006, FR-008)
  - **Result (2026-10)**: already satisfied by the Foundational registry + writer: `tableFor(month)` returns the month's seal first and reaches the live/bundled table only when no seal exists, so once a month is sealed its values are read from the seal alone; the 404 walk-back (≤ 7 days) lives in `ExchangeRateClient.fetchHistorical` and is now covered by the T023 test. The coordinator seals every closed month from the earliest budget forward, so the live table is only ever consulted for the open month in practice.
- [X] T027 [US2] Initial backfill for pre-existing history: seal past months from the legacy rate cache where present (`source: lastKnown`, status per state machine), otherwise historical fetch — in `lib/features/engine/seal_coordinator.dart` (delivers data-model step 9c via backfill rather than a migration write, see Notes)
  - **Result (2026-10)**: `_eligibleMonths` walks every month from the earliest persisted budget up to the current month and `_sealMonth` backfills each: historical fetch first, else `_lastKnownTable()` (the live singleton's rates re-labelled `lastKnown`, else the bundled baseline) → `approximate` when the grace window is gone. The legacy `exchange_rate_cache.dart` JSON holds only one latest table per base (no per-month history), so it is intentionally not consulted — its successor `LiveRateSet` is, and T047 deletes it.
- [X] T028 [P] [US2] Immutability guard tests proving sealed months ignore subsequent fetches and main-currency switches (zero writes to seal rows) — in `test/features/engine/seal_immutability_test.dart` (SC-002, SC-003)
  - **Result (2026-10)**: new `test/features/engine/seal_immutability_test.dart` (3 cases): a `sealed` row is never re-fetched (the provider is not even asked for its close date) and its rates/`updatedAt` stay frozen; an `approximate` row is likewise permanent; moving the live table never changes a sealed month.
- [X] T029 [US2] Extend the conversion matrix to month states — {sealed, provisional, approximate, open} × offline/online expectations — in `test/features/engine/currency_conversion_test.dart` (quickstart V1)
  - **Result (2026-10)**: added a `month states (T029, quickstart V1)` group to `test/features/engine/rate_registry_test.dart` (the registry-level test) — sealed→`historical`, provisional→`lastKnown`, approximate→`bundled`, open-online→`live`, open-offline→bundled baseline; each asserts `isDegraded == false` (the table exists) while the source labels the state. Placed in the registry test rather than `currency_conversion_test.dart` because the state is a property of which table governs a month, not of the pure conversion arithmetic.
- [X] T030 [US2] Validate story end-to-end against scenarios V4, V5, V6 in `specs/010-multi-currency-system/quickstart.md` (rollover, offline seal → retry → correct, missed-month historical backfill)
  - **Result (2026-10)**: full gate from repo root — `dart format --output=none --set-exit-if-changed .` → 0 changed; `flutter analyze lib test` → **No issues found**; `flutter test` → **282 passed / 1 skipped** … then **+18 US2 tests** (lifecycle 9, immutability 3, month-state matrix 5, plus coverage folding) for a final **300 passed / 1 skipped**. Automated coverage for V4 (rollover seals the ended month), V5 (offline → `provisional` → retry → `sealed`), V6 (missed months seal per their own close date; weekend walk-back; total failure → `approximate`). **Open**: the manual on-device date-control/airplane-mode walkthrough of V4–V6 still needs a device session — none was attached.

**Checkpoint**: User Stories 1 AND 2 both work independently

---

## Phase 5: User Story 3 - Choose my own main currency, change it any time (Priority: P2)

**Goal**: Profile main currency (default HUF) is the single source of truth; changing it re-renders every screen within 1 second with zero stored-data modifications

**Independent Test**: Change main currency HUF → EUR; every screen updates in < 1 s; a before/after inventory of records shows zero modifications (quickstart V3; SC-002)

### Implementation for User Story 3

- [X] T031 [US3] Make `UserProfile.primaryCurrency` the live, watched main-currency write path — activate `lib/features/settings/providers/settings_provider.dart` (remove dead-code status), UI writes profile only (FR-009, defect D5)
- [X] T032 [US3] Re-point global display reads from `budget.currency` to profile main currency across `lib/features/dashboard/presentation/dashboard_screen.dart`, `lib/features/expenses/presentation/expenses_screen.dart`, `lib/features/medical/providers/medical_providers.dart`, `lib/features/engine/providers/month_summary_provider.dart` — switch is then instant + zero-write (FR-010, SC-002)
- [X] T033 [US3] Seed new months from the profile and kill divergent defaults: `lib/features/finance/repositories/month_finance_repository.dart` (remove `?? PrimaryCurrency.usd`), `lib/features/budget_setup/presentation/budget_setup_screen.dart`, `lib/features/finance/presentation/net_salary_section.dart` (HUF everywhere, defect D7)
- [X] T034 [US3] Migration **step 10** — reconcile defaults to HUF, retire the dead settings seed path, relabel `MonthlyBudget.currency` as display-only; bump `schemaVersion` 9 → 10 in `lib/core/database/schema_migrations.dart` + idempotency test in `test/core/database/schema_migrations_test.dart`

  **Result (2026-10)**: `_step10ReconcileCurrencyDefaults` clears unrecognised/legacy `MonthlyBudget.currency` values to null (they join the profile fallback) and normalises a supported code to its canonical lowercase form; display-only, no amount/rate/seal touched (FR-010, FR-021). `schemaVersion` now 10. Idempotency + keep/clear tests added (`step 10 clears unrecognised convert-to values and keeps canonical ones`, `step 10 is idempotent`). `schema_migrations_money_test.dart` step-9 commit test updated to assert "current version ≥ 10" instead of the literal 9.

- [X] T035 [US3] Multi-profile independence test — two profiles with different main currencies do not affect each other or the device-global seals — in `test/features/settings/main_currency_test.dart` (FR-009, Constitution A2)

  **Result (2026-10)**: 5 tests — provider defaults to HUF with no profile; provider reflects the watched profile; a convert-to-less month resolves per-profile; the same row displays differently per profile with nothing written; `MainCurrencyController.setMainCurrency` changes only the active profile, and a sealed `MonthRateSeal` is untouched.

**Checkpoint**: Main currency switching is live, instant and side-effect-free

---

## Phase 6: User Story 4 - View any month in any currency, independently (Priority: P2)

**Goal**: Per-month display-only "convert this month to…" choice, independent across months and separate from the profile main currency

**Independent Test**: March → USD, April default; both render simultaneously and correctly; clearing March restores the main currency; sealed-month views stay offline (quickstart V7; SC-006)

### Implementation for User Story 4

- [X] T036 [P] [US4] Repurpose `MonthlyBudget.currency` as the display-only convert-to choice (documented as cleared/null = main-currency default; seed-from-profile at creation) in `lib/core/models/monthly_budget.dart` per data-model §4.2 (FR-011)

  **Result (2026-10)**: field is now `String? currency` (nullable, stored `CurrencyCode.name`; cleared once it was the app-wide currency, and `@enumerated PrimaryCurrency` was forbidden by Isar "Bytes must not be nullable"). New months seed `null` → follow the profile; FR-011 won over the ambiguous seed-from-profile phrasing in the original brief. Isar rebuilt via build_runner.
- [X] T037 [US4] Implement the display-currency resolver (`convertTo ?? profile.mainCurrency`) as the single authority for engine and UI — in `lib/core/providers/active_budget_provider.dart` + `lib/features/engine/providers/month_summary_provider.dart` (FR-011)

  **Result (2026-10)**: `resolveDisplayCurrency` lives in `lib/features/engine/currency_resolution.dart` (month?.currency?.code ?? profile?.primaryCurrency.code ?? huf) and is the read path for dashboard/medical/expenses display.
- [X] T038 [US4] Dashboard month-header popup gains a "Show in {main} (default)" option, persists the choice per month, and clearing restores fallback — in `lib/features/dashboard/presentation/dashboard_screen.dart` (repurpose existing control at lines 114–133; FR-011)

  **Result (2026-10)**: `_ConvertToMenu` (`PopupMenuButton<CurrencyCode?>`) with default-null option; writes via `monthFinanceRepositoryProvider.saveConvertTo(yearMonth, currency)`.
- [X] T039 [US4] Independence tests — two months in different view currencies simultaneously, sealed-month view offline, clear-to-default behavior — in `test/features/dashboard/convert_to_test.dart` (SC-006, quickstart V7)

  **Result (2026-10)**: 6 tests — Jan Eur / Feb CAD coexist + a null month follows profile; `saveConvertTo` persists and clears to null; changing one month leaves the other + profile untouched; a sealed month converts through its own frozen table (never the bundled baseline) with `RateSource.historical`; a no-seal/no-live month is still backed by the bundled baseline labelled `bundled`; resolver needs no rate at all.

**Checkpoint**: All user stories 1–4 independently functional

---

## Phase 7: User Story 5 - I can see and trust the rates (Priority: P3)

**Goal**: Currency Settings screen (main currency, live rates + timestamps, seal status list, manual refresh), persistent banners and a settings badge so every number's provenance is visible

**Independent Test**: Airplane-mode month close produces the banner + settings badge; Currency Settings lists every month with status and rate date; refresh shows updated timestamp (quickstart V5; SC-007, SC-008)

### Tests for User Story 5

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [ ] T040 [P] [US5] Widget tests for banner triggers, badge presence/auto-clear, and settings screen states — in `test/features/settings/currency_settings_ui_test.dart` (FR-019, FR-020, SC-007, SC-008)

### Implementation for User Story 5

- [ ] T041 [P] [US5] Create `RateStatusBanner` widget (persistent, non-dismissable-while-condition, follows `MonthIncompleteBanner` pattern, dark-mode aware) in `lib/shared/presentation/widgets/rate_status_banner.dart` per contract `currency-settings-ui.md` §2
- [ ] T042 [US5] Create the banner/badge state projection provider (pure function of registry state; auto-clears when all months final + rates fresh) in `lib/features/settings/providers/rate_status_provider.dart` (FR-020)
- [ ] T043 [US5] Build Currency Settings section — main currency picker, live rate table with last-updated + stale marker + manual refresh, month seal status list with per-month status chips and Retry action — in `lib/features/settings/presentation/currency_settings_section.dart`, registered in `lib/features/settings/presentation/settings_screen.dart` (FR-019, contract §1)
- [ ] T044 [US5] Mount banner + badge: dashboard beside `MonthIncompleteBanner` in `lib/features/dashboard/presentation/dashboard_screen.dart`, Currency Settings top, and the settings-row badge in `lib/features/settings/presentation/settings_screen.dart` (FR-020, SC-007)
- [ ] T045 [US5] Unsupported-data audit list (legacy non-supported currency records, read-only) in `lib/features/settings/presentation/currency_settings_section.dart` per data-model §4.4 (FR-001 edge handling)
- [ ] T046 [US5] Validate story end-to-end against scenario V5 in `specs/010-multi-currency-system/quickstart.md` (offline seal → provisional → banner → badge → auto-clear on retry)

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Cleanup and full-feature validation across all stories

- [ ] T047 [P] Delete superseded code: `lib/core/network/exchange_rate_cache.dart` (silent-1.0 defect D3), leftover per-screen symbol switches, orphaned GBP entries, unused `getRate` plumbing (defects D3/D4)
- [ ] T048 [P] Physically remove `exchangeRateToPrimary` from models + schema now that all readers/writers are gone (fold into still-unshipped migration steps; shipped steps stay immutable per `schema_migrations.dart:84-90`)
- [ ] T049 [P] Audit every money render site for shared-formatter usage (no stray `NumberFormat('#,##0.00')`, no hardcoded symbols) across `lib/features/**/presentation/**` (defect D10, FR-018)
- [ ] T050 Run full validation gate from repo root: `dart format --output=none --set-exit-if-changed .`, `flutter analyze` (0 new issues), `flutter test` (all green incl. new matrix + migration tests); confirm CI runs tests (quickstart V10)
- [ ] T051 Execute quickstart manual scenarios **V2–V9** end-to-end on a device with airplane-mode control and record pass/fail against each success criterion SC-001…SC-009 in `specs/010-multi-currency-system/quickstart.md`
- [ ] T052 FR traceability review — walk the validation table in `specs/010-multi-currency-system/data-model.md` §7, mapping every FR-001…FR-022 to shipped code/tests; file gaps as follow-ups (Constitution governance)

---

## Phase 9: Conversion Correctness & Rate Visibility (Defect Batch)

**Purpose**: Fix the wrong dashboard conversion (income + opening balance were never converted), show the rate each conversion used, and surface the month-global currency picker + a live conversion hint in the expense form. Follows Phase-Builder-Agent.md strictly: each phase-letter below is a stop-and-verify unit.

**Reported defect**: with a HUF month, choosing USD in the dashboard currency picker rendered "Kept this month" as ~"$999,838.48" — a HUF-major double re-formatted through the USD cent scale. Root cause: `monthSummaryProvider` converts expenses/reimbursements to the display currency but passes `income` and `openingBalance` through unconverted (main-currency majors), so `kept = income − payments + returned` mixes units (income not converted; no rate visible anywhere).

**Audit finding (2026-10)**: every conversion site already uses the same per-month table `rateRegistryProvider.tableFor(selectedYearMonth)` — dashboard summary, true available, safe-to-spend, medical totals, expense detail, edit-screen impact. The only broken inputs are income + opening balance; the only missing UX is a visible rate. Add-Expense additionally defaults its currency dropdown to `'USD'`, silently recording main-currency expenses as USD.

### Phase 9-A — Correct the amounts (stop-and-test after)

- [x] T053 [Defect] Convert income and the confirmed opening balance from the profile **main** currency → the chosen display currency through the existing `toDisplay`/month-table path, so `kept`, `moneyInBank` and Safe-to-Spend are single-currency. Add `mainSourceCurrency(profile)` in `lib/features/engine/currency_resolution.dart`; wire it in `lib/features/engine/providers/month_summary_provider.dart` and `lib/features/engine/providers/true_available_provider.dart`. Provider-level regression tests: HUF income/opening → correct USD hero, income line and money-in-bank (no more $999,838-type hybrids) in `test/features/engine/month_summary_provider_test.dart` (5) + `test/features/engine/true_available_provider_test.dart` (5, incl. Safe-to-Spend). **Result (2026-10)**: DONE — `kept = 2000.0` (was mixed 690000-HUF/100-USD → rendered as a $-scaled hybrid); same-currency months and USD profiles verified unchanged; gate green `dart format` 0 changed / `flutter analyze lib test` clean / `flutter test` 324 passed, 1 skipped.

### Phase 9-B — Show the rate every conversion used (stop-and-test after)

- [x] T054 [Defect] New shared `ConversionFootnote` widget in `lib/shared/presentation/widgets/conversion_footnote.dart`: renders `1 {display} = {rate} {main}` via `table.crossRate(main, display)` with provenance label (live / sealed-historical / last-known / bundled baseline), the table's as-of date, and a stale/offline flag; reuses `DegradedAmountLabel` when the rate is missing. Mount under the dashboard hero (`month_summary_card.dart`), Medical dashboard totals (`medical_dashboard.dart`), Expenses screen, and expense detail — shown only when the display currency differs from the main currency. Widget tests in `test/shared/presentation/conversion_footnote_test.dart` + presence in each screen's widget test. **Result (2026-10)**: DONE — widget renders `1 {display.symbol} = {rate} {main.symbol}` via `table.crossRate(display, main)` (direction corrected from the task text: `1 $ = 345 Ft` needs usdRate[main]/usdRate[display], i.e. crossRate(display, main)) with provenance label (live rate / sealed at month close / last known rate / offline estimate), table as-of date `yyyy-MM-dd`, and `· stale` appended only when `table.isStale` and source ≠ bundled; degraded branch shows an error icon + `'Rate unavailable — the figures above are shown as recorded.'` — **deviation**: does NOT reuse `DegradedAmountLabel` (its constructor requires a `Money` original, unsuitable for a rate caption; the marker reuses the same wording/visual language instead). Mounted under the hero after the 'Returned' line, on the Medical `_BudgetImpactCard` after 'Net cost to you', at the end of the expense-detail `_ImpactCard`, and as list index 0 (incl. empty state) on the Expenses screen via a local `_MonthRateFootnote`. Hidden when main == display (SizedBox.shrink). Gate green: `dart format` 0 changed / `flutter analyze lib test` clean / `flutter test` 337 passed, 1 skipped. T054 medical layout note: the new presence test runs on a 600×800 surface — the earlier 360/500 overflows were a Flutter Ahem test-font artifact (every glyph renders at fontSize width, e.g. 'Estimated out-of-pocket' = 327px vs ~155px in production), not a real layout bug.

### Phase 9-C — Picker everywhere + live conversion in the expense form (stop-and-test after)

- [x] T055 [Defect] Extract the dashboard's `_ConvertToMenu` into a shared `MonthConvertToMenu` widget (`lib/features/dashboard/presentation/widgets/month_convert_to_menu.dart`) and add it to the Medical dashboard and Expenses screen app bars — same month-global convert-to selection (SC-006).
  - `flutter analyze` clean; `flutter test` 350 passed / 1 skipped (the harness-driven medical widget test stays skipped — Isar I/O hangs under the widget-test fake clock; every real read must run inside `tester.runAsync`).
  - Tests: `test/features/dashboard/month_convert_to_menu_test.dart` (hides without budget; all 4 currency options; real-DB persistence of a pin; clear-on-reopen wiring via a recording repo), `expenses_screen_test.dart` (menu on the app bar), `medical_layout_overflow_test.dart` T055 presence test.
  - Gotchas pinned in tests: a `PopupMenuItem` with `null` value never fires `onSelected` (Flutter treats it as cancel), so the clear item carries a sentinel `Object` and `onSelected` maps it back to `null`; an un-overridden Isar-backed repo view keeps a loader spinning and makes `pumpAndSettle` time out, so the Expenses test overrides the repo watches with immediate `Stream.value` results.
- [x] T056 [Defect] Add-Expense: default the currency dropdown to the profile main currency instead of `'USD'` (`lib/features/expenses/presentation/add_expense_screen.dart` line ~25) so stored expenses match the recording currency; under the Amount field, show a live conversion of the typed amount into the display currency at the month's table (e.g. `≈ $2,741.75 · at 1 $ = 345 Ft`), updating on input and clearing when invalid/same-currency. Mirror the hint on `lib/features/expenses/presentation/edit_expense_screen.dart`. Tests in `test/features/expenses/presentation/add_expense_screen_test.dart` + edit screen test.
  - `AmountConversionHint` (`lib/features/expenses/presentation/widgets/amount_conversion_hint.dart`) renders `≈ $x.xx · at 1 $ = N Ft`, hides on invalid/≤0/same-currency/unconvertible (`isDegraded`). Tests: 5 add-screen tests (default is Profile main, hint value + rate line, hidden same-currency, cleared on invalid input) + 3 edit-screen tests.
  - Edit-screen test data must use uppercase currency codes — `_currencies = ['USD','EUR','HUF','CAD']` falls back to `'USD'` for a lowercase `'huf'`, which silently hides the hint (screen behavior is correct for real stored data).

**Post-approval walkthrough fix batch** (defects found by the reviewer on device, fixed + gated together):
- Log Reimbursement crash: `reimbursement_entry_sheet.dart` seeded its dropdown from the raw expense currency (lowercase `'huf'`) with no matching item — now normalized `(CurrencyCode.tryParse(...) ?? CurrencyCode.huf).code.toUpperCase()`, items built from `CurrencyCode.values`, and the "fully reimbursed" comparison uses enum-normalized codes. `medical_detail_screen.dart` gates the button on `linkedExpenseId != null` and null-checks it in the handler.
- Edit crash: `medical_bill_form.dart` seeded the service-type `DropdownButtonFormField` with an id missing from the (archived-excluding) selectable list — when the selected id isn't present, a disabled placeholder item is inserted; the reimbursement validator now accepts 0 so an unpaid self-paid bill can be saved.
- Per-expense conversion: `expenses_screen.dart` `_ExpenseTile` shows `≈ <display amount>` under the amount when the row's currency differs from the month display currency (and the rate isn't degraded).
- Regression tests: `reimbursement_entry_sheet_test.dart` (lowercase `'huf'` expense renders, no exception), `medical_bill_form_edit_test.dart` (archived + not-yet-loaded service types render without asserting), `expenses_screen_test.dart` per-row caption (`≈ \$ 2.90` for 1000 HUF, none for a USD row).
- Gate after fixes: `dart format` clean, `flutter analyze lib test` clean, `flutter test` 354 passed / 1 skipped.

### Phase 9-D — Prove one rate governs the app (stop-and-test after)

- [x] T057 [Test] Regression test asserting the same per-month `RateTable` (same cross-rates for the same pair) is resolved by the dashboard summary, true-available/safe-to-spend, medical totals and expense-detail conversions for one month — no divergent rate between screens.
  - `test/features/engine/one_rate_governs_test.dart`: one `ProviderContainer`, one month (`2026-02`), one sealed table (1 US$ = **300** Ft — deliberately not the bundled 345), and the assertions span `monthSummaryProvider` (income 2,000 / paymentsMade 230 / moneyReturned 10 / moneyInBank 11,780), `trueAvailableProvider` + `safeToSpendProvider` (9,780), `patientShareTotalsProvider` + `medicalBudgetImpactProvider` (in USD minor: billed 20,000, share 10,000, insurer 10,000, reimbursed 3,000, net 17,000), the budget-scoped `medicalBillContextProvider` (its `rateTable` is `identical` to the sealed object), and the `convert(...)` call the expense tiles/hints make. Negative guards assert the 345-derived equivalents do not appear — any consumer keying a different month falls back to the bundled table and fails.
  - Note: `medical_providers.dart:102` and `medical_repository.dart:957` derive `budget.yearMonth` / `expense.yearMonth` instead of `selectedYearMonthProvider`; they agree in production because `activeBudgetProvider` filters by the selected month. T057 pins both to the same `YYYY-MM` so the divergence hazard stays covered while `selectedYearMonthProvider` remains the single application month key.
  - Gate: `dart format` clean, `flutter analyze lib test` clean, `flutter test` 355 passed / 1 skipped.

**Gateway**: after T053-T057, run `dart format --output=none --set-exit-if-changed .`, `flutter analyze lib test`, `flutter test`; then manual device walkthrough — set HUF month, pick USD in the dashboard picker, confirm hero/summary/safe-to-spend/medical all match the shown footnote rate; add an expense in HUF and confirm the live `≈ $` hint and Profile-main default.

---

## Phase 9-E — Dark / light theme (stop-and-test after)

**Purpose**: Add a persistent theme choice (Light / Dark / Follow system) to Settings with eye-friendly palettes in both modes — warm off-white surfaces + soft dark text (not pure black) in light, warm near-black surfaces + soft off-white text in dark — fonts applying in both, via a safe additive migration for existing installs.

**Decisions recorded (2026-10, user-approved)**: three options incl. "Follow system"; setting lives on `UserProfile` as `AppThemeMode` (consistent with the `fontFamily`/`primaryCurrency` precedent, and live via `activeProfileProvider`). The earlier "default-currency picker" idea was **dropped by the user** before planning — only the theme ships. Owned by this feature's tasks.md per user instruction (theme is cross-cutting but tracked here).

- [ ] T058 [Test] Theme persistence tests in `test/features/settings/app_theme_setting_test.dart` — real-Isar write (inside `tester.runAsync`, never outside) persists `profile.themeMode` across rebuilds; the section renders all three options; default is `system`.
- [ ] T059 [Model] Add `AppThemeMode { light, dark, system }` (default `system`) to `lib/core/models/user_profile.dart`; migration **step 11** (additive, no-op at runtime, doc-comment like step 8) in `lib/core/database/schema_migrations.dart` bumping `schemaVersion` 10 → 11; run build_runner; confirm `test/core/database/schema_migrations_test.dart` still passes (idempotency + version-agnostic asserts).
- [ ] T060 [Theme] Create the two eye-friendly Material 3 themes in `lib/core/presentation/app_themes.dart` — `buildAppTheme(Brightness, {String? fontFamily})` seeded from `Colors.deepPurple`, `useMaterial3: true`: light = warm off-white surfaces, soft dark on-surface text (never pure black), low-glare borders; dark = warm near-black surfaces, soft off-white text (never pure white); both apply `fontFamily`.
- [ ] T061 [UI] New `ThemeSettingSection` mirroring `lib/features/settings/presentation/font_setting_section.dart` (Card + Light / Dark / Follow system selector) writing `profile.themeMode` in an Isar `writeTxn`; register it in `lib/features/settings/presentation/settings_screen.dart`.
- [ ] T062 [App] Wire the themes into `lib/main.dart` — `MaterialApp.router` gains `darkTheme:`, `theme:`, and `themeMode:` derived from `activeProfileAsync.valueOrNull?.themeMode ?? AppThemeMode.system`; both themes use the resolved `fontFamily`. Main app only; the `_StartupSplash` / `DatabaseCorruptionScreen` themes are untouched.
- [ ] T063 [Validate] Full gate from repo root — `dart format --output=none --set-exit-if-changed .`, `flutter analyze lib test`, `flutter test` (all green incl. new theme tests); widget test asserting the selected theme is reflected at the section level; record results here.

**Gateway**: after T058-T063, run the full gate above; then manual device check — switch Light/Dark/Follow system in Settings on a device and confirm every screen re-themes within a frame and the choice survives a restart.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Setup — **BLOCKS all user stories**
  - Within phase: T003/T004 → T005 (formatter needs both); T009/T010 → T011 (step 8 needs collections); T006 → T008 (registry hydrates from client+store)
- **User Stories (Phase 3–7)**: All depend on Foundational completion
  - **US1 (P1, MVP)**: no dependencies on other stories
  - **US2 (P1)**: no dependencies on other stories (reads registry from Foundational; extends it)
  - **US3 (P2)**: needs US2 for SC-002's "sealed months re-render" verification (functional code itself only needs Foundational)
  - **US4 (P2)**: needs US3 — resolver sits on profile main currency as fallback
  - **US5 (P3)**: needs US2 (seal status exists to display) and US3 (main currency control)
- **Polish (Phase 8)**: T047/T048 need US1 (all rate-column consumers gone); T050/T051/T052 need all stories being validated
- **Defect batch (Phase 9)**: T053-T057 need US3 + US4 (profile main currency + per-month convert-to resolver already shipped); independent of US5
- **Phase 9-E (theme)**: no story dependencies — reads the shipped `activeProfileProvider`, adds a profile field via an additive migration, and touches no currency logic

### User Story Dependencies

| Story | Priority | Starts after | Depends on stories |
|---|---|---|---|
| US1 | P1 (MVP) | Foundational | — |
| US2 | P1 | Foundational | — (parallel with US1) |
| US3 | P2 | Foundational | US2 (for full SC-002 verification) |
| US4 | P2 | Foundational | US3 |
| US5 | P3 | Foundational | US2, US3 |

### Within Each User Story

Tests first (must fail) → models → services → integration → story validation checkpoint

### Parallel Opportunities

- **Phase 1**: T001 ∥ T002 (different files)
- **Phase 2**: {T003, T004} ∥ each other; {T009, T010} ∥ each other; T007 ∥ T005/T006 group
- **US1**: T012 (tests) runs while T008-era groundwork settles; T018 ∥ T013 (disjoint files); T021 ∥ T020
- **US2**: T023 (tests) ∥ T024 (impl) start-parallel; T028 ∥ T027
- **US3**: T031 ∥ T033 (disjoint files)
- **US5**: T040 (tests) ∥ T041 (widget file)
- **Polish**: T047 ∥ T048 ∥ T049 (disjoint files)
- **Across stories**: US1 ∥ US2 are fully parallel after Foundational (different files, no shared writes)

---

## Parallel Example: User Story 1

```text
# Launch together (disjoint files):
Task T012: "Conversion matrix tests in test/features/engine/currency_conversion_test.dart"
Task T018: "Consolidate currency pickers in add_expense_screen.dart, edit_expense_screen.dart, reimbursement_entry_sheet.dart"

# Then together:
Task T020: "MedicalBill currency wiring in medical_bill_form.dart + medical_repository.dart"
Task T021: "Degraded label widget in lib/shared/presentation/widgets/degraded_amount_label.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (green baseline + CI test step)
2. Complete Phase 2: Foundational (**CRITICAL** — blocks all stories)
3. Complete Phase 3: User Story 1 — money cut, conversion path, engine re-point, offline CRUD
4. **STOP and VALIDATE**: quickstart V2 + V8 + full `flutter test`
5. Ship/demo — the app already handles multi-currency correctly for the current month with originals shown

### Incremental Delivery

1. Setup + Foundational → foundation ready
2. + US1 → MVP: correct conversion today (test → deploy/demo)
3. + US2 → history frozen and offline-safe (the correctness core)
4. + US3 → profile main currency, instant zero-write switching
5. + US4 → per-month independent viewing
6. + US5 → full transparency UI
7. Polish → cleanup, full quickstart V1–V10, traceability sign-off

### Parallel Team Strategy

1. Team completes Setup + Foundational together
2. Then: Developer A → US1, Developer B → US2 (fully disjoint)
3. After US2+US3: Developer A → US4, Developer B → US5
4. Everyone → Polish

---

## Notes

- **[P]** tasks = different files, no dependencies; **[Story]** labels map tasks to spec user stories for traceability
- **Test tasks are intentional** (not sample leftovers): SC-005 mandates test-verifiable no-fabricated-rate behavior; quickstart V1 makes the matrix the merge gate
- **Migration step mapping vs data-model §6**: step 9(b) "drop rate column semantics" is delivered as code removal in US1 (T016/T017) + physical removal in Polish (T048) because the column's consumers die there; step 9(c) "seed initial seals" is delivered by the coordinator's backfill (T027) so seeds use real fetched data rather than stale cache values. Steps remain immutable once this feature ships.
- **Money one-cut lands inside US1**, not Foundational: converting `amount` to `int` forces engine adaptation in the same change set — splitting them would leave the app non-compiling between phases
- Each story phase ends with an explicit validation checkpoint — stop there to test the story independently
- Commit after each task or logical group

---

## Phase 0 (Interrupt): Money-Unit Correctness Remediation — BLOCKS T020+

**Status**: Proposed — awaiting approval. **Do not implement until approved.**

**Why**: T014 ("money one-cut") converted persisted `amount` fields from `double` major units to `int` minor units on `Expense`, `Reimbursement` and `MedicalBill`, but the display + derived-aggregate layers were only partially updated. Two formatters now coexist and call sites mix them, so the app renders and computes money at the wrong scale. This must be fixed and proven before T020–T052 build on top of it.

### Audit findings (read-only, 2026-01 current tree)

- **A1 — Two competing semantics.** `Money` stores whole minor units (`Money.minorUnits`), and `formatMinorUnits`/`formatMoney` render them exactly. But `MedicalTheme.money(currency, num)` → `formatMajorUnits` treats its argument as *major* (multiplies by `minorUnitsPerMajor`). Any minor-unit value passed to `MedicalTheme.money` is inflated ×100 for USD/EUR/CAD (HUF is masked because exponent 0).
- **A2 — Medical aggregates are wrong scale + ignore currency.** `PatientShareTotals` and `MedicalBudgetImpact` (`lib/features/medical/providers/medical_providers.dart`) accumulate `MedicalBill` minor `int`s into `double` fields, then `medical_dashboard.dart` renders them with `MedicalTheme.money` (major) at lines 515, 554–571, 586. Result: `$1,000.00` renders as `$100,000.00`. They also sum bills across currencies without conversion and never use the bill's own `currencyCode`.
- **A3 — Medical bill form compounds the error on edit.** `medical_bill_form.dart:156` seeds the amount field with `bill.billedAmount.toStringAsFixed(2)` (minor shown as major). Saving re-parses through `Money.fromMajor` (line 51 semantics), so every edit multiplies the stored amount again. The same card mixes units: `_estimate` returns major (`_amount`-derived) but `_projectedImpact` (line 854) returns `probe.fundsImpact.toDouble()` which is minor, both passed to `MedicalTheme.money` at lines 878/883/891.
- **A4 — Medical display sites mix `money` and `moneyMinor`.** `medical_detail_screen.dart` uses `moneyMinor` for bill fields but at line 222/273/280/286/292/307/388 formats them in the *display* currency while the bills carry their own currency; `medical_dashboard.dart:831` prints `bill.fundsImpact` in display currency with no conversion. `moneyMinor` values in a non-display currency are silently mislabelled.
- **A5 — Repo/notification deltas mix units.** `medical_repository.dart:258` (`setBillPaidToProvider`) and `expenses_provider.dart:53` build engine deltas with `s.amount.toDouble()` (minor treated as major). Edit/toggle flows that display these deltas show the wrong magnitude for non-HUF.
- **A6 — Tests enshrine the bug.** `medical_test_harness.dart:152-177` subtracts minor `expense.amount` from major `baseAvailable`; `medical_repository_test.dart` uses "major-like" ints (`billedAmount = 1000`, expecting patient share `200`, balance `4800`). Green tests therefore do **not** prove correct scale and will mask regressions. These tests must be rewritten to real minor-unit semantics.
- **A7 — Dashboard/engine math is actually unit-correct in the clean path** (`income`/`openingBalance` stay major; expenses convert via `Money` then `.majorValue`). So the *reported* dashboard corruption comes from the medical write/read path (A3 poisoning stored `MedicalBill.billedAmount`) and the linked `Expense.amount`, plus A2/A4 on the medical surfaces. Confirm with the regression tests in T-R07 before assuming otherwise.

### Remediation tasks

- [X] T-R01 Define the money-unit contract in one place and enforce it: document that persisted fields are `int` minor units, engine aggregates may stay `double` major, and **display must go through the shared formatter**; rename `MedicalTheme.money` → `moneyMajor` (major, engine-only) and keep `moneyMinor` (stored). Add the rule to `data-model.md` §1.2 or a `money-format` contract note, plus a unit test pinning both formatter helpers. Files: `lib/features/medical/presentation/medical_theme.dart`, `lib/shared/presentation/money_format.dart`, docs.
- [X] T-R02 Fix medical aggregate providers to be minor-unit and currency-aware: change `PatientShareTotals` and `MedicalBudgetImpact` (`lib/features/medical/providers/medical_providers.dart`) to sum `Money` in the display currency via the rate registry (skip/flag unsupported legacy codes), exposing minor-unit ints; keep `bill.patientShareAmount`/`insurerPaidAmount`/`fundsImpact` in the **bill's** currency per FR-016 and convert at the boundary. Depends on T-R01.
- [X] T-R03 Re-point every medical render site to the correct formatter/currency (enumerate and verify each): `lib/features/medical/presentation/medical_dashboard.dart` (`_SplitRow`, `_BudgetImpactCard`, `_BillTile` bill/page/budget lines), `lib/features/medical/presentation/medical_detail_screen.dart` (billed/insurer/share/reimbursed/net/funds-impact rows), and the delete-dialog row. Depends on T-R02.
- [X] T-R04 Fix `lib/features/medical/presentation/medical_bill_form.dart`: seed the amount controller from minor units (`Money(bill.billedAmount, code).majorValue`), make `_projectedImpact` and the whole `_EstimateCard` use one unit consistent with the entered currency, and confirm `currency` is the **entered** bill currency, not the display currency. Add a test that open→save→reopen does not change the stored amount. Depends on T-R01.
- [X] T-R05 Fix engine deltas to convert rather than cast: `lib/features/medical/repositories/medical_repository.dart:258` and `lib/features/expenses/providers/expenses_provider.dart:53` (and any other `.amount.toDouble()` money path) must convert minor→display through the registry/`toDisplay`. Depends on T-R01.
- [X] T-R06 Correct the medical test suite to real minor-unit semantics and add scale regressions: rewrite `test/features/medical/repositories/medical_test_harness.dart` `trueAvailable` to convert via `Money`/engine, update `medical_repository_test.dart`, `medical_providers_test.dart`, `medical_layout_overflow_test.dart`, `schema_migrations_test.dart` amounts to `Money.fromMajor(...).minorUnits`, and add a regression proving a `$1,000.00` bill stores `100000`, renders `"$ 1,000.00"`, and a non-HUF bill shows its original amount beside the converted one. Depends on T-R02, T-R03, T-R04.
- [X] T-R07 Add engine/dashboard scale + multi-currency regressions: assert `MonthSummaryCard`/`MonthSummaryDetails` render the correct magnitude for a minor-unit expense (e.g. USD `10.00` → `"$ 10.00"`, not `"$ 1,000.00"`), and that a mixed-currency month sums through the conversion path. Files: `test/features/dashboard/dashboard_summary_test.dart`, `test/features/engine/month_summary_test.dart`. Depends on T-R01.
- [X] T-R08 Run the money-render audit across `lib/features/**/presentation/**` (this closes T049 early): no `MedicalTheme.money` on stored fields, no `NumberFormat('#,##0.00')` on minor ints, no hardcoded symbols, no `toStringAsFixed` on minor ints in display paths; add a small guard test if practical.
- [X] T-R09 Full validation gate from repo root (`dart format`, `flutter analyze` = 0 issues, `flutter test` all green) and record results in this section. Depends on T-R01…T-R08.
  - **Result (2026-01)**: `dart format .` → 0 changed; `flutter analyze lib test` → **No issues found**; `flutter test` → **265 passed, 1 skipped**. New coverage: `test/shared/presentation/money_format_test.dart` (13), T-R04 repository round-trip (1), T-R06 cross-currency aggregates (2) + foreign-bill dashboard widget (1), T-R07 dashboard/engine scale regressions. Audit (T-R08) removed the duplicate `PrimaryCurrencyExt.symbol` source and routed `dashboard_screen`/`net_salary_section` through `CurrencyCode.symbol`.
- [X] T-R10 **Approval gate**: re-verify A7 (dashboard) with T-R07 results, then resume T020 onward only after sign-off.
  - **Result (2026-01)**: signed off. A7 re-verified via T-R07; T-R09 gate green. Also cleared two field issues found during re-verification: (1) a pre-`int` device DB was silently reinterpreted by the step-9 type cut (all stored money read back as `int64` min `-9223372036854775808`, producing `9223372036854775807` on the dashboard and an `ArgumentError` from `MedicalBill.netOutOfPocket`'s `clamp(0, billedAmount)` on the Medical screen); the local device DB was reset (`pm clear`) and the fresh DB verified clean (`schema_version=9`). This confirms the migration gap flagged at `schema_migrations.dart:140` — tracked as T-R11. (2) `medical_bill_form.dart` had three double-encoded literals (two `·` separators and two `✅`) rendering as `Â·`/garbage; restored. Gate re-run after the fix: `dart format .` 0 changed, `flutter analyze lib test` No issues, `flutter test` 265 passed / 1 skipped. Resume T020.
- [X] T-R11 Close the in-place money type-change migration gap so a pre-`int` database can never render corrupted `int64`-min money again. The step-9 cut changes `Expense.amount`, `Reimbursement.amount` and `MedicalBill.billedAmount`/`reimbursedAmount` from `double` major to `int` minor in place; Isar 3 silently reinterprets the old bytes as `int64` min instead of failing, so the corruption is invisible until render time. **Decision: startup integrity guard** (no transitional legacy column — the old bytes are unrecoverable through the ORM, so a migration could not help already-cut DBs and would add permanent schema debt). Depends on T-R10.
  - **Result (2026-01)**: new `lib/core/database/money_integrity.dart` — `isCorruptedMoney` (anything beyond ±1e17 minor units is a reinterpreted `int64` extreme, never real money), `corruptedMinorSentinel`, `findCorruptedMoney(Isar)` scanning `expenses.amount`, `reimbursements.amount`, `medicalBills.billedAmount`/`reimbursedAmount`, and `resetLocalDatabase(Isar)` (`isar.clear()` + re-stamp). `moneyIntegrityIssuesProvider` (`lib/core/providers/database_integrity_provider.dart`) is watched by `MyApp` (`lib/main.dart`): empty → app renders as before; non-empty → `DatabaseCorruptionScreen` (`lib/core/presentation/database_corruption_screen.dart`) explains the unrecoverable data and offers "Reset and continue" (clears, routes to `/setup`, re-scans). So a corrupted DB can never again show garbage or hit the `clamp` crash. Gate: `dart format .` 0 changed, `flutter analyze lib test` No issues, `flutter test` **271 passed / 1 skipped** (new: `test/core/database/money_integrity_test.dart`, 6 cases).

**Sequencing**: T-R01 → {T-R02, T-R04, T-R05, T-R07} → T-R03 (needs T-R02) → T-R06 → T-R08 → T-R09 → T-R10 → resume T020.
**Not in scope here**: T020–T052 remain as written; T-R02/T-R03 fold the parts of T020/T021 they overlap, so re-check T020 after T-R03.
