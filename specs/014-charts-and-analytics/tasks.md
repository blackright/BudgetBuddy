# Tasks: Charts & Analytics (Unified)

**Input**: Design documents from `/specs/014-charts-and-analytics/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: Included — the spec's success criteria (SC-001, SC-004, SC-006, SC-007) are test-verified and `quickstart.md` names the exact test files, so test tasks are required.

**Organization**: Tasks are grouped by user story so each story can be implemented and tested independently.

**Storage note**: This feature is **read-only** over Isar (no schema change, no migration). Do **not** add a collection or a migration step.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1–US4)
- Include exact file paths in descriptions

## Path Conventions

Single Flutter project. Feature code under `lib/features/analytics/`, tests under `test/features/analytics/`, shared widgets under `lib/shared/presentation/widgets/`.

---

## Phase 1: Setup

**Purpose**: Add the chart library and create the feature skeleton.

- [x] T001 Add `fl_chart: ^1.2.0` to `pubspec.yaml` dependencies and run `flutter pub get` (research R1)
- [x] T002 Create the feature skeleton `lib/features/analytics/{domain,repositories,providers,presentation/charts,presentation/widgets}` and `test/features/analytics/{domain,presentation}` per plan.md

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: The shared data-layer types, the repository, and the chart card shell that EVERY user story depends on.

**?? CRITICAL**: No user story work can begin until this phase is complete. This phase establishes the "One Chart Brain" boundary (`contracts/chart-data.md` §1).

- [x] T003 [P] Create the derived view models `ChartSeries`, `CategorySlice`, `DayBucket`, `BarPair`, `MemberContribution`, `ChartDegradedState` in `lib/features/analytics/domain/chart_series.dart` (data-model §3)
- [x] T004 [P] Create the `ChartFilters` value object (date range, categories, currency, statuses) in `lib/features/analytics/domain/chart_filters.dart` (data-model §4.2)
- [x] T005 Implement `AnalyticsRepository` in `lib/features/analytics/repositories/analytics_repository.dart`: load context-scoped rows for a `ContextRef`; resolve display currency via `resolveContextDisplayCurrency`; get the rate table via `rateRegistryProvider.tableFor`; convert via `expenseToDisplay`/`reimbursementToDisplay`; produce `degraded` + `excludedCount` (research R3, data-model §6)
- [x] T006 [P] Create the `ChartCard` shell in `lib/features/analytics/presentation/widgets/chart_card.dart` owning the mini/full slot, the empty state, and the degraded-rate badge (contracts/chart-ui.md §4)
- [x] T007 Create `chart_data_provider.dart` in `lib/features/analytics/providers/`: watch `budgetContextProvider` + `ChartFilters` and expose repository rows as a live stream (mirrors `month_summary_provider.dart`)

**Checkpoint**: Foundation ready — every chart can now consume one shared, currency-safe data source.

---

## Phase 3: User Story 1 - The placeholders become real charts (Priority: P1) ?? MVP

**Goal**: Dashboard mini-charts and a full Analytics screen replace the two placeholders, all fed by the one shared data layer, so their numbers agree.

**Independent Test**: Open the Dashboard, confirm mini monthly-spending / category / planned-vs-paid charts render; open the Analytics tab, confirm full versions show the same totals; confirm the category total equals the monthly-spending total (SC-001, SC-002).

### Tests for User Story 1

> **NOTE: Write these FIRST, ensure they FAIL before implementation.**

- [x] T008 [US1] Write pure aggregation tests — category total == spending total (SC-001), planned/paid/cancelled separation — in `test/features/analytics/domain/chart_query_test.dart`

### Implementation for User Story 1

- [x] T009 [US1] Implement `spendingSeries` with auto-bucketing (per-day ≤1mo, per-week ≤6mo, per-month beyond) in `lib/features/analytics/domain/chart_query.dart` (research R7)
- [x] T010 [US1] Implement `categorySeries` in `lib/features/analytics/domain/chart_query.dart`
- [x] T011 [US1] Implement `plannedPaidSeries` in `lib/features/analytics/domain/chart_query.dart`
- [x] T012 [P] [US1] Create the chart widgets `spending_chart.dart`, `category_chart.dart`, `planned_paid_chart.dart` in `lib/features/analytics/presentation/charts/`, each taking `series` + `ChartSize` (contracts/chart-ui.md §1)
- [x] T013 [US1] Expose the three series via providers in `lib/features/analytics/providers/chart_data_provider.dart`
- [x] T014 [US1] Replace `AnalyticsPlaceholderCard` with the mini charts in `lib/features/dashboard/presentation/dashboard_screen.dart`; retire `lib/shared/presentation/widgets/analytics_placeholder_card.dart`
- [x] T015 [US1] Replace the "Analytics Placeholder" body with the full charts in `lib/features/analytics/presentation/analytics_screen.dart` (route `/analytics` already exists)

**Checkpoint**: User Story 1 fully functional — the placeholders are gone and the totals agree.

---

## Phase 3a: Polish Chart UX (US1 improvements)

- [x] T036 [P] [US1-UX] Improve CategoryChart UX: compact bottom legend in mini mode and a full legend (name + amount) in full mode; hide labels inside slices so slices stay readable.
- [x] T037 [P] [US1-UX] Improve PlannedPaidChart UX: add a color legend (Planned = tertiary vs Paid = primary) in both modes; keep tooltips in full mode.
- [x] T038 [US1-UX] Improve SpendingChart UX: add total subtitle in the card header, refine `_maxY`/`_yInterval` for clean ticks, and make mini readable.
- [x] T039 [US1-UX] Verify chart readability on Dashboard (mini) and Analytics (full); adjust spacing/heights; ensure no layout overflow in compact widths.

## Phase 3b: Clean Chart Axes & Mini Spending Fix (US1 improvements)

**Goal**: The y-axis of Monthly Spending and Planned vs Paid stops printing hundreds of symbol-prefixed ticks; the Dashboard's Monthly Spending mini card always shows a visible mark, even for a single data point.

- [x] T040 [P] [US1-UX] Add shared axis helpers: `formatMinorUnitsCompact(int, CurrencyCode)` in `lib/shared/presentation/money_format.dart` (compact `850` / `12k` / `3.8M`, no repeated currency symbol) and a new `lib/features/analytics/presentation/charts/chart_scale.dart` with `niceInterval`/`prettyMaxY` yielding ~4–5 round ticks.
- [x] T041 [US1-UX] SpendingChart: use `niceInterval`/`prettyMaxY` + compact axis labels (no repeated "Ft"); guarantee a visible mark in mini (show dots when few points, clamp `maxX` so a single point still renders). Depends on T040.
- [x] T042 [US1-UX] PlannedPaidChart: use `niceInterval`/`prettyMaxY` + compact axis labels (no repeated "Ft"). Depends on T040.
- [x] T043 [US1-UX] Verify readability on Dashboard (mini) and Analytics (full); ensure no layout overflow in compact widths; run `flutter analyze` + full `flutter test`.

## Phase 4: User Story 2 - Every chart follows my wallet, my month, and my currency (Priority: P1)

**Goal**: Charts always describe the active context (personal profile or shared space), rebuild instantly on change, and stay honest when rates are missing or stale.

**Independent Test**: Add an expense and confirm charts rebuild without leaving the screen; switch personal → shared and confirm every chart switches; open a month with no rate table and confirm the "rates unavailable" warning (SC-003, SC-004, SC-005).

### Tests for User Story 2

- [x] T016 [P] [US2] Widget tests for the mini/full sizing, empty state, and degraded-rate badge in `test/features/analytics/presentation/chart_widgets_test.dart`
- [x] T017 [P] [US2] Lens-switch tests — personal ↔ shared re-derives every series, no lingering figure — in `test/features/analytics/analytics_lens_test.dart`

### Implementation for User Story 2

- [x] T018 [P] [US2] Create `chart_lens_provider.dart` in `lib/features/analytics/providers/` holding the `ChartLens {personal, shared}` state and resolving to the matching active context (data-model §4.1)
- [x] T019 [P] [US2] Create the `lens_switch.dart` Personal/Shared toggle in `lib/features/analytics/presentation/widgets/`
- [x] T020 [US2] Implement `availableTrendSeries` (monthlyAvailableAmount changes, reimbursements, paid expenses, paid medical bills) in `lib/features/analytics/domain/chart_query.dart`
- [x] T021 [US2] Create `available_trend_chart.dart` in `lib/features/analytics/presentation/charts/`
- [x] T022 [US2] Wire the lens switch into `analytics_screen.dart`; confirm live rebuild on profile/space/month/data change (FR-006) and that the degraded badge renders (FR-005)

**Checkpoint**: User Story 2 functional — charts are live, context-correct, and currency-honest.

---

## Phase 5: User Story 3 - I can look inside a chart (Priority: P2)

**Goal**: Tapping a chart segment opens the real list of records behind it, reusing the existing expense list.

**Independent Test**: Tap a category slice on the full Analytics chart and confirm the expense list opens filtered to that category; tap an empty segment and confirm an empty list, not a crash (SC-007).

### Implementation for User Story 3

- [x] T023 [US3] Create the typed `ChartDrillDown` request (`category` / `status` / `member`) in `lib/features/analytics/domain/chart_series.dart` (data-model §4.3)
- [x] T024 [US3] Wire `onDrillDown` on the full-size charts and push the existing `/expenses` route with a filter payload from `lib/features/analytics/presentation/analytics_screen.dart`; add the optional filter argument to `lib/core/routing/app_router.dart` and apply it in `lib/features/expenses/presentation/expenses_screen.dart`
- [x] T025 [P] [US3] Widget test for segment-tap drill-down (and empty-segment behaviour) in `test/features/analytics/presentation/chart_widgets_test.dart`

**Checkpoint**: User Story 3 functional — charts are actionable, not decorative.

---

## Phase 6: User Story 4 - Shared and medical views appear where they make sense (Priority: P2)

**Goal**: A shared space gains the member-contribution and shared-vs-personal charts, and every context gains the medical insurance breakdown chart.

**Independent Test**: Select a shared space and confirm the contribution chart lists each member (including zero contributors); confirm the medical chart splits each bill into insurer-paid and user-payable (SC-006).

### Tests for User Story 4

- [x] T026 [US4] Tests for the medical insurer/user split and the contribution grouping (including a zero-contribution member) in `test/features/analytics/domain/chart_query_test.dart`

### Implementation for User Story 4

- [x] T027 [US4] Implement `insuranceSeries` reusing `MedicalBill.patientShareAmount` / `insurerPaidAmount` in `lib/features/analytics/domain/chart_query.dart` (Constitution IV)
- [x] T028 [US4] Implement `contributionSeries` — group shared rows by `profileId`, join `SharedMember`, include zeros, order descending — in `lib/features/analytics/domain/chart_query.dart` (research R4, FR-011)
- [x] T029 [US4] Implement `sharedVsPersonalSeries` in `lib/features/analytics/domain/chart_query.dart`
- [x] T030 [P] [US4] Create `insurance_chart.dart`, `contribution_chart.dart`, `shared_vs_personal_chart.dart` in `lib/features/analytics/presentation/charts/`
- [x] T031 [US4] Render the shared-only charts (contribution, shared-vs-personal) only in the shared lens from `lib/features/analytics/presentation/analytics_screen.dart` (depends on T018/T019 from US2)

**Checkpoint**: All user stories independently functional.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that span stories.

- [x] T032 [P] Accessibility and dark-mode pass: theme-aware colors, legend/axis contrast, all money labels via `formatMoney` in `lib/features/analytics/presentation/` (contracts/chart-ui.md §6, Constitution VI)
- [x] T033 Verify the performance budget: seed ~1000+ records and confirm charts stay smooth (SC-008, FR-015)
- [x] T034 [P] Confirm no dead references to the retired placeholder remain in `lib/` and `test/`
- [x] T035 Run the full gate — `dart format .`, `flutter analyze`, `flutter test` — and walk quickstart scenarios V1–V8 (SC-009)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately.
- **Foundational (Phase 2)**: Depends on Setup — **BLOCKS all user stories**.
- **User Stories (Phase 3–6)**: All depend on Foundational. US1 and US2 are both P1; US3/US4 are P2.
- **Polish (Phase 7)**: Depends on the stories you are delivering.

### User Story Dependencies

- **US1 (P1)**: After Foundational only. Independent — **this is the MVP**.
- **US2 (P1)**: After Foundational. Independent of US1's widgets (shares the shell and repository).
- **US3 (P2)**: After Foundational; uses US1's full-size charts to attach drill-down.
- **US4 (P2)**: After Foundational; the shared-only charts require US2's lens (T018/T019), the medical chart does not.

### Within Each User Story

- Tests first (must fail before implementation).
- Pure `domain` queries before `providers` before `presentation`.
- Widgets before screen wiring.

### Parallel Opportunities

- Phase 2: T003 + T004 + T006 (different files).
- Phase 3: T012 (three separate widget files).
- Phase 4: T016 + T017 (different test files); T018 + T019 (different files).
- Phase 6: T027/T028/T029 are sequential (same file `chart_query.dart`) — do **not** parallelize them.

---

## Parallel Example: User Story 1

```bash
# Pure domain queries and the widget tests are independent files:
Task: "Write pure aggregation tests in test/features/analytics/domain/chart_query_test.dart"
Task: "Create spending_chart.dart in lib/features/analytics/presentation/charts/"
Task: "Create category_chart.dart in lib/features/analytics/presentation/charts/"
Task: "Create planned_paid_chart.dart in lib/features/analytics/presentation/charts/"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup.
2. Complete Phase 2: Foundational (**critical — blocks all stories**).
3. Complete Phase 3: User Story 1.
4. **STOP and VALIDATE**: run quickstart V1/V2 and confirm the totals agree.
5. Ship — the two placeholders are gone and analytics is live.

### Incremental Delivery

1. Setup + Foundational — one shared, currency-safe data layer.
2. Add **US1** — real charts on Dashboard + Analytics (MVP).
3. Add **US2** — live rebuild, lens switch, currency honesty.
4. Add **US3** — tap-through to real records.
5. Add **US4** — shared contribution + medical split.

Each story adds value without breaking earlier ones.

---

## Notes

- **[P]** = different files, no dependencies. Never mark two tasks touching `chart_query.dart` as parallel.
- This feature **must not** add an Isar collection or a migration (FR-014).
- No chart may call `convert` or query Isar directly (contracts/chart-data.md §1).
- Degraded rows are excluded-and-disclosed, never zeroed (FR-005).

---

# Extension: Context & People (US5–US7)

**Why these live here**: the owner asked to track this follow-on work in this feature's `tasks.md`. They are **independent** of the chart work (US1–US4) and can be built and shipped on their own; they reuse the same phase-per-approval workflow in `Phase-Builder-Agent.md`. Task IDs continue from the chart tasks (start at T044).

**Cross-cutting UX goal**: everything below must feel effortless and obvious — no dead ends, friendly copy, clear feedback, and never a surprise about which space money lands in.

**Storage note**: US5 changes reimbursement *behaviour*, not schema. US6 is presentation + one settings flag. US7 may reuse `PairedPeer` as the contact store (no new collection) — confirm during Phase 10 that no Isar migration is required.

---

## Phase 8: User Story 5 - Insurance money returns next month, and a finished bill is final (Priority: P1)

**Goal**: When a self-paid bill is finished and the insurer's payout is recorded, the returned money is credited to the **following month** (it arrives with next month's salary), and a finished bill becomes a **locked, final** state.

**Independent Test**: Finish a self-paid bill owned by `2026-01` and confirm the payout appears in **February's** returned money (not January's); confirm the bill shows `finished`, and that no other status, payment-method change, or rejection is possible.

### Tests for User Story 5

- [x] T044 [P] [US5] Unit tests: `nextMonth('2026-12') == '2027-01'`; `medical_repository.logReimbursement` sets `originYearMonth` to the next month; cross-month `excessReturned` resolves the target expense; `setBillState` refuses any state change away from `finished` — in `test/features/medical/` and `test/features/engine/`

### Implementation for User Story 5

- [x] T045 [US5] Medical payout attribution: `originYearMonth = nextMonth(bill.yearMonth)` in `lib/features/medical/repositories/medical_repository.dart` (`logReimbursement`), and next month in `lib/features/expenses/presentation/widgets/reimbursement_entry_sheet.dart` when `medicalBill != null` (**generic expense reimbursements are unchanged**). Reuses `nextMonth`/`monthLabel` from `lib/core/providers/selected_month_provider.dart` (FR-032 revision).
- [x] T046 [US5] Fix cross-month excess: `lib/features/engine/providers/month_summary_provider.dart` must resolve `targetPaidAmounts` by `expenseId` across months (not only the selected month) so a next-month payout is not counted as excess (`lib/features/engine/month_summary.dart`, invariant I7).
- [x] T047 [US5] Make `finished` terminal in the data layer: `_validateTransition` throws for any next state when `bill.state == finished`; block `setPaymentMethod` and rejection while finished — `lib/features/medical/repositories/medical_repository.dart`.
- [x] T048 [US5] Lock the UI when finished: in `lib/features/medical/presentation/medical_detail_screen.dart` show only the selected `finished` chip and **disable every other status, the payment-method switch, and the Reimbursement button**; mirror the rule in `lib/features/medical/presentation/medical_bill_form.dart`. Add a lock icon + hint on the "Bill Status" card.
- [x] T049 [US5] UX: on the finish/reimbursement flow show **"Returned money will be credited to <Month Year>"** using `monthLabel(nextMonth(...))` — friendly, no jargon.
- [x] T050 [US5] Verify: `dart format .`, `flutter analyze`, `flutter test`; hand-check finishing a January bill credits February.

**Checkpoint**: Returned money lands next month; finished bills are final and unmistakably locked.

---

## Phase 8a: User Story 8 - Dashboard shows insurance returns apart from expense returns, and opening the app shows the current month (Priority: P1)

**Goal**: Under the Dashboard's "Returned" figure, show **Insurance return** (money an insurer paid back on a medical bill) and **Expense returns** (reimbursements on ordinary expenses) as their own lines — each tappable — and mirror them in the collapsed Details. Classification is by the *target expense's* type (`medical` vs `standard`); a return whose target was deleted counts as an expense return. Separately, when the app opens or resumes with the **selected month behind the current calendar month**, snap forward to the current month (never jump backward or override a current/future choice).

**Storage note**: Read-only over the existing schema — no Isar collection, no schema bump, no sync-codec change, no migration. The split is derived in the data layer from the reimbursement's already-stored `expenseId`.

**Independent Test**: Reimburse one medical bill (payout lands next month) and one ordinary reimbursable expense (lands its own month). In the payout month, "Insurance return" shows the insurer amount, "Expense returns" shows the ordinary amount, and the two sum to "Returned". Leave the app on an older month, reopen after the month rolls over, and confirm the Dashboard shows the current month.

### Tests for User Story 8

- [x] T068 [P] [US8] Unit tests: `insuranceReturned + expenseReturned == moneyReturned`; a medical-target return counts as insurance; a standard-target return and an orphaned return count as expense returns — in `test/features/engine/month_summary_test.dart`
- [x] T069 [P] [US8] Unit tests for the target-resolution/classifier provider: a reimbursement whose medical target lives in the **previous** month is marked insurance; a same-month standard target is not — in `test/features/engine/`
- [x] T075 [P] [US8] Unit tests for month-on-open: selected month older than today → today; equal or newer → unchanged — in `test/core/providers/`

### Implementation for User Story 8

- [x] T070 [US8] Extend `MonthSummary` with `insuranceReturned` / `expenseReturned` and give `MonthSummary.from` a pure classifier input (the set of medical target expense ids), keeping `moneyReturned` as their sum — `lib/features/engine/month_summary.dart`
- [x] T071 [US8] Resolve each reimbursement's target expense **by id, across months** and pass the medical set into `MonthSummary.from`; add a `watchExpensesByIds(...)` stream to `ExpenseRepository` (mirrors the existing `anyOf` pattern) — `lib/features/engine/providers/month_summary_provider.dart`, `lib/features/expenses/repositories/expense_repository.dart`
- [x] T072 [US8] Dashboard card: add "Insurance return" and "Expense returns" sub-lines under "Returned" (only when > 0); tap "Insurance return" → `/medical`, tap "Expense returns" → the existing `/expenses` route filtered to reimbursed — `lib/features/dashboard/presentation/widgets/month_summary_card.dart`
- [x] T073 [US8] Mirror both figures in the collapsed Details section — `lib/features/dashboard/presentation/widgets/month_summary_details.dart`
- [x] T074 [US8] Widget tests: the split lines render, sum to the total, and the tap-through routes fire — `test/features/dashboard/`
- [x] T076 [US8] Month-on-open: snap the selected month forward to the current month only when it is behind, reusing the existing lifecycle hook (`_SealLifecycleObserver`) and `currentYearMonth()` — `lib/main.dart`, `lib/core/providers/selected_month_provider.dart`
- [x] T077 [US8] Rewrite `README.md` for the current app — what BudgetBuddy is; the feature set (budgets/expenses, medical/insurance with next-month returns, multi-currency, shared spaces + cross-device sync, charts & analytics, insurance-vs-expense returns); architecture (Flutter + Isar + Riverpod, feature-based modules under `lib/features/`); setup (`flutter pub get`, `flutter run`); test device (SM G965F); commands (`dart format .`, `flutter analyze`, `flutter test`) — `README.md`

**Checkpoint**: The Dashboard tells insurance returns apart from expense returns at a glance, and opening the app in a new month lands on that month.

---

## Phase 9: User Story 6 - I always know which space I am in, and cannot post to the wrong one (Priority: P1)

**Goal**: The Dashboard states the active context (personal profile or shared space) prominently, and saving to a shared space asks for confirmation first.

**Independent Test**: On the Dashboard the banner names the active profile/space; in a shared space, saving an expense or medical bill shows a confirm dialog naming the space; in personal mode **no** dialog appears.

### Tests for User Story 6

- [x] T051 [P] [US6] Widget tests: `ContextBanner` shows profile vs space; the shared-context save confirmation appears only when a space is active; the settings toggle suppresses it — in `test/features/dashboard/` and `test/features/context/`

### Implementation for User Story 6

- [x] T052 [US6] Create a reusable `ContextBanner` widget in `lib/shared/presentation/widgets/` (Personal `👤 <name>` / Shared `<avatar> <space>`, with a "switch" affordance) — theme-aware, no overflow at small widths.
- [x] T053 [US6] Show `ContextBanner` at the top of `lib/features/dashboard/presentation/dashboard_screen.dart` (above `MonthIncompleteBanner`), with a gentle shared-context hint: "You're adding to «space» — tap to switch."
- [x] T054 [US6] Create a shared `confirmSpaceOnSave(...)` helper (dialog: "Add «title» (amount) to «space»?" — `Change context` / `Confirm`) that only triggers when a shared space is active.
- [x] T055 [US6] Wire the confirmation into the add-expense save path (`lib/features/expenses/presentation/add_expense_screen.dart`) and the medical-bill save path (`lib/features/medical/presentation/medical_bill_form.dart`).
- [x] T056 [US6] Add a Settings toggle "Confirm before saving to a shared space" (default ON) in `lib/features/settings/presentation/`, backed by the settings provider.
- [x] T057 [US6] Verify: `dart format .`, `flutter analyze`, `flutter test`; hand-check personal vs shared.

**Checkpoint**: The context is unmistakable, and shared saves are confirmed by design.

---

## Phase 10: User Story 7 - People are global; pairing is no longer trapped inside a space (Priority: P2)

**Goal**: A global People list; identity pairing reachable anywhere; scanning adds **both** sides to each other's list; adding a person to a shared space can pick from the list **or** scan.

**Independent Test**: From Settings with **no** space active, show your code and have another identity scan it → both appear in each other's People list; then add a contact to a space from the list and confirm they become a member — this closes the chicken-and-egg that blocked new people from joining.

> **Phase 10a — DELIVERED** (T059–T063): identity payload, service exchange, contacts provider, People screen, global Settings entry.
> **Phase 10b — DELIVERED** (T064–T066, T058 closed): add-to-space sheet (`_InviteMode.contact`), `ScanContactIntoSpaceScreen`, `PairingService.addContactToSpace`, UX polish, gate green (645 passed / 1 skipped). **Feature 014 complete.**
>
> **KNOWN GAP — deferred to feature `015-wire-device-sync` (`specs/015-wire-device-sync/`):** the membership granted by "Add a person" is written **only on the granting phone**; the other phone never receives the space. No network/transport wiring exists in production (012's transport and sync engine are built and tested but never started by the running app), so no change reaches a second device. Owner accepted this as the Phase 10b scope boundary and requested a dedicated feature for delivery — this is that feature, not a 014 bug.
>
> **Exchange decision (owner-approved):** the in-person exchange runs as an **offline QR round-trip** — presenter shows an identity code, scanner confirms the fingerprint and shows its reply code, presenter scans that reply — so no network/transport wiring is needed.
>
> **Storage confirmed (T060):** US7 reuses `PairedPeer` as the contact store; **no new collection, no schema bump, no Isar migration** (per the Extension storage note at the top of this file).

### Tests for User Story 7

- [x] T058 [P] [US7] Unit tests: identity payload round-trip (no space/role); mutual contact persistence on both sides; add-contact-to-space grants membership; scan-adds-contact — in `test/features/pairing/` — **10a part** (`identity_pairing_test.dart`: round-trip, refusals, mutual persistence, scan-adds-contact); **10b part** (`identity_pairing_test.dart` group *"add a paired contact to a space (T064/T058)"*: grants membership + context + cursor, refuses a non-contact, refuses a duplicate (I2)).

### Implementation for User Story 7

- [x] T059 [US7] Extend `lib/features/pairing/domain/pairing_protocol.dart` with a space-independent **identity** payload (keeps the existing space-invite payload) plus clean version/discriminator handling for both.
- [x] T060 [US7] Extend `lib/features/pairing/repositories/pairing_service.dart`: create/parse an identity invite, run the in-person exchange, and persist mutual `PairedPeer` contacts (keep the fingerprint confirmation, `contracts/pairing.md`).
- [x] T061 [US7] Contacts provider: expose people in `lib/features/pairing/providers/` (reusing `PairedPeer`) with shared spaces + last-seen; add repository queries.
- [x] T062 [US7] Create `lib/features/pairing/presentation/people_screen.dart`: list contacts; "Show my code"; "Scan a code"; friendly empty state and security copy. *(Follow-up fix: a **refused scan now latches** — new `widgets/scan_error_panel.dart` stops the camera and shows the reason once, instead of `MobileScanner` re-firing it every frame; same fix applied to `scan_identity_code_screen.dart` and `pair_device_screen.dart`. Regression: `test/features/pairing/identity_scan_latch_test.dart`.)*
- [x] T063 [US7] Reach pairing globally: expose `PeopleScreen` from `lib/features/settings/presentation/settings_screen.dart` (no active-space requirement); keep the in-space invite available.
- [x] T064 [US7] Add-to-space flow: a sheet that picks a contact from the list (assign role) **or** scans an identity QR (adds contact + grants membership) — `lib/features/spaces/presentation/` (reuse/extend `invite_sheet.dart`) — *delivered as `_InviteMode.contact` in `invite_sheet.dart` ("Add a person" segment) + new `scan_contact_into_space_screen.dart`; the repository side is `PairingService.addContactToSpace` (grants membership + active context + cursor, refuses non-contact/missing space/duplicate/no-Owner).*
- [x] T065 [US7] UX polish: contact rows (avatar, spaces, last-seen), success feedback, and no dead ends when no code/space exists yet — *success SnackBar "Added <name> to this space.", role picker, member-filtered contact list, and an empty-state copy ("No people paired yet…" → Settings → People) instead of a dead end.*
- [x] T066 [US7] Verify: `dart format .`, `flutter analyze`, `flutter test`; hand-check the chicken-and-egg flow (a fresh device joins with no space active) — *format clean, analyze "No issues found!", `flutter test` → 645 passed / 1 skipped; the fresh-device hand-check is the Phase 10b playground test.*

**Checkpoint**: Pairing works globally; the People list is the single place to manage contacts and membership.

---

## Phase 11: Documentation

- T067 (**moved**) — the README rewrite now lives in **Phase 8a, task T077**, so it ships together with the Dashboard work.

---

## Extension Dependencies & Ordering

- **Phase 8 (US5)**: independent — touches `medical` + `engine` only. Do **not** edit `chart_query.dart`.
- **Phase 8a (US8)**: build **next** (owner priority); independent — touches `engine` + `dashboard` + `main` + `README`. Do **not** edit `chart_query.dart`.
- **Phase 9 (US6)**: independent — shared widgets + dashboard + settings.
- **Phase 10 (US7)**: independent, largest; do not parallelize files in `pairing_service.dart` with its own protocol edits. **Split into 10a (T059–T063, delivered) and 10b (T064–T066, next)** per the owner.
- **Phase 11**: last, after the code it describes is in place.
- Each phase ends with a STOP for a playground test per `Phase-Builder-Agent.md`.
