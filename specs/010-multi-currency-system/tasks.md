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
- [ ] T020 [US1] Give `MedicalBill` its own currency end-to-end — entry + display: `lib/features/medical/presentation/medical_bill_form.dart`, `lib/features/medical/repositories/medical_repository.dart` (stop inheriting expense currency with forced 1.0, defect D6; insurance % stays in original currency per FR-016)
- [ ] T021 [US1] Render degraded/unavailable labels on any value whose `ConversionResult.isDegraded = true` (shared label widget used by money display paths) in `lib/shared/presentation/widgets/degraded_amount_label.dart` (FR-014)
- [ ] T022 [US1] Validate story end-to-end against scenarios V2, V8 in `specs/010-multi-currency-system/quickstart.md` and confirm all pre-existing tests still green; record results in this task's completion note

**Checkpoint**: User Story 1 fully functional and testable independently — **MVP milestone**

---

## Phase 4: User Story 2 - Closed months never move (Priority: P1)

**Goal**: Every completed calendar month freezes with its own four-currency rate table; sealed totals are immutable, offline and unaffected by rate changes or main-currency switches

**Independent Test**: Seal a month, then change rates / go offline for weeks / switch main currency — the month's totals are identical every time (quickstart V3, V4, V6; SC-003)

### Tests for User Story 2

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [ ] T023 [P] [US2] Seal lifecycle tests — offline close → `provisional`; retry success within 7 days → `sealed`; grace expiry → `approximate`; sealed rows never modified by auto passes; weekend 404 walk-back — in `test/features/engine/month_seal_lifecycle_test.dart` per contract `month-seal-lifecycle.md` (FR-006, FR-007, FR-008, SC-003)

### Implementation for User Story 2

- [ ] T024 [US2] Implement the idempotent seal coordinator — `runSealPass(now)`: seal eligible months via historical fetch, upgrade `provisional` ≤ 7 days, refresh live table ≤ 24h, increment `attemptCount`, emit registry updates — in `lib/features/engine/seal_coordinator.dart` per contract `month-seal-lifecycle.md` §2
- [ ] T025 [US2] Register the coordinator on cold start and `AppLifecycleState.resumed` (post-frame, never blocks first frame) in `lib/main.dart` — no lifecycle observer exists today (research R3; FR-004, invariant I3)
- [ ] T026 [US2] Registry sealed-read semantics: `sealed`/`approximate` months read only their seal; live table restricted to the open month; historical 404 walk-back ≤ 7 days with `lastKnown` → `approximate` fallback — update `lib/features/engine/providers/rate_registry_provider.dart` and `lib/core/network/exchange_rate_client.dart` (FR-006, FR-008)
- [ ] T027 [US2] Initial backfill for pre-existing history: seal past months from the legacy rate cache where present (`source: lastKnown`, status per state machine), otherwise historical fetch — in `lib/features/engine/seal_coordinator.dart` (delivers data-model step 9c via backfill rather than a migration write, see Notes)
- [ ] T028 [P] [US2] Immutability guard tests proving sealed months ignore subsequent fetches and main-currency switches (zero writes to seal rows) — in `test/features/engine/seal_immutability_test.dart` (SC-002, SC-003)
- [ ] T029 [US2] Extend the conversion matrix to month states — {sealed, provisional, approximate, open} × offline/online expectations — in `test/features/engine/currency_conversion_test.dart` (quickstart V1)
- [ ] T030 [US2] Validate story end-to-end against scenarios V4, V5, V6 in `specs/010-multi-currency-system/quickstart.md` (rollover, offline seal → retry → correct, missed-month historical backfill)

**Checkpoint**: User Stories 1 AND 2 both work independently

---

## Phase 5: User Story 3 - Choose my own main currency, change it any time (Priority: P2)

**Goal**: Profile main currency (default HUF) is the single source of truth; changing it re-renders every screen within 1 second with zero stored-data modifications

**Independent Test**: Change main currency HUF → EUR; every screen updates in < 1 s; a before/after inventory of records shows zero modifications (quickstart V3; SC-002)

### Implementation for User Story 3

- [ ] T031 [US3] Make `UserProfile.primaryCurrency` the live, watched main-currency write path — activate `lib/features/settings/providers/settings_provider.dart` (remove dead-code status), UI writes profile only (FR-009, defect D5)
- [ ] T032 [US3] Re-point global display reads from `budget.currency` to profile main currency across `lib/features/dashboard/presentation/dashboard_screen.dart`, `lib/features/expenses/presentation/expenses_screen.dart`, `lib/features/medical/providers/medical_providers.dart`, `lib/features/engine/providers/month_summary_provider.dart` — switch is then instant + zero-write (FR-010, SC-002)
- [ ] T033 [US3] Seed new months from the profile and kill divergent defaults: `lib/features/finance/repositories/month_finance_repository.dart` (remove `?? PrimaryCurrency.usd`), `lib/features/budget_setup/presentation/budget_setup_screen.dart`, `lib/features/finance/presentation/net_salary_section.dart` (HUF everywhere, defect D7)
- [ ] T034 [US3] Migration **step 10** — reconcile defaults to HUF, retire the dead settings seed path, relabel `MonthlyBudget.currency` as display-only; bump `schemaVersion` 8 → 10 in `lib/core/database/schema_migrations.dart` + idempotency test in `test/core/database/schema_migrations_test.dart`
- [ ] T035 [US3] Multi-profile independence test — two profiles with different main currencies do not affect each other or the device-global seals — in `test/features/settings/main_currency_test.dart` (FR-009, Constitution A2)

**Checkpoint**: Main currency switching is live, instant and side-effect-free

---

## Phase 6: User Story 4 - View any month in any currency, independently (Priority: P2)

**Goal**: Per-month display-only "convert this month to…" choice, independent across months and separate from the profile main currency

**Independent Test**: March → USD, April default; both render simultaneously and correctly; clearing March restores the main currency; sealed-month views stay offline (quickstart V7; SC-006)

### Implementation for User Story 4

- [ ] T036 [P] [US4] Repurpose `MonthlyBudget.currency` as the display-only convert-to choice (documented as cleared/null = main-currency default; seed-from-profile at creation) in `lib/core/models/monthly_budget.dart` per data-model §4.2 (FR-011)
- [ ] T037 [US4] Implement the display-currency resolver (`convertTo ?? profile.mainCurrency`) as the single authority for engine and UI — in `lib/core/providers/active_budget_provider.dart` + `lib/features/engine/providers/month_summary_provider.dart` (FR-011)
- [ ] T038 [US4] Dashboard month-header popup gains a "Show in {main} (default)" option, persists the choice per month, and clearing restores fallback — in `lib/features/dashboard/presentation/dashboard_screen.dart` (repurpose existing control at lines 114–133; FR-011)
- [ ] T039 [US4] Independence tests — two months in different view currencies simultaneously, sealed-month view offline, clear-to-default behavior — in `test/features/dashboard/convert_to_test.dart` (SC-006, quickstart V7)

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
