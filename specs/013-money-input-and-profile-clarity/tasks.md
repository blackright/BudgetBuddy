---

description: "Task list for Money Input & Profile Income Clarity implementation"
---

# Tasks: Money Input & Profile Income Clarity

**Input**: Design documents from `/specs/013-money-input-and-profile-clarity/`

**Prerequisites**: spec.md (required). Feature is UI-only — no data-model, schema, or migration work.

**Tests**: Included. The spec carries a mandatory "User Scenarios & Testing" section per story; tests are generated per story and MUST fail before implementation.

**Organization**: Tasks are grouped by user story (US1–US3 from spec.md). Git is 🛑 hands-off — the user pushes.

## Format: `[P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1–US3)
- Include exact file paths in descriptions

## Path Conventions

- Flutter single project: `lib/`, `test/` at repository root.

## Amount fields covered (from the code audit)

| Field | File |
| --- | --- |
| Salary default + month override | `lib/features/finance/presentation/net_salary_section.dart` |
| Opening balance | `lib/features/finance/presentation/opening_balance_sheet.dart` |
| Add expense | `lib/features/expenses/presentation/add_expense_screen.dart` |
| Edit expense | `lib/features/expenses/presentation/edit_expense_screen.dart` |
| Reimbursement entry | `lib/features/expenses/presentation/widgets/reimbursement_entry_sheet.dart` |
| Medical bill amount + reimbursement | `lib/features/medical/presentation/medical_bill_form.dart` |
| Insurance patient share % (no grouping) | `lib/features/medical/presentation/medical_dashboard.dart` |
| Space income (create) | `lib/features/spaces/presentation/create_space_sheet.dart` |
| Space income (settings) | `lib/features/spaces/presentation/space_settings_section.dart` |
| Monthly available amount | `lib/features/budget_setup/presentation/budget_setup_screen.dart` |

## Parsers that must become separator-tolerant

Already strip `,`/spaces (verify only): `add_expense_screen.dart:58`, `edit_expense_screen.dart:79`, `net_salary_section.dart:115`, `reimbursement_entry_sheet.dart:56`, `create_space_sheet.dart:70`, `space_settings_section.dart:119`, `money_format.dart` (`tryParseMoneyInput`).

Must be fixed (currently raw `double.tryParse`): `opening_balance_sheet.dart:73/93`, `medical_bill_form.dart:238/250/350/504/583/683`, `budget_setup_screen.dart:101` (runs on every keystroke), `medical_dashboard.dart:408/417`.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Verify the baseline is green and confirm no new dependency is needed.

- [x] T001 [P] Verify baseline is green before any change: from repo root run `flutter pub get`, `dart format --output=none --set-exit-if-changed .`, `flutter analyze`, `flutter test` and record the pass/skip/fail counts (baseline: 453 pass / 1 skip / 0 fail; analyze clean; format 0 changed)
- [x] T002 Confirm no new package is required (Flutter's built-in `TextInputFormatter`/`TextEditingController` suffice) and that no `pubspec.yaml` change is needed (confirmed: no dependency added)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: The one shared formatter, the one shared parser, and the one shared widget that every screen will use.

**CRITICAL**: No user-story wiring can begin until this phase is complete.

- [x] T003 [P] Create `ThousandsSeparatorInputFormatter` in `lib/shared/presentation/input_formatters/thousands_separator_input_formatter.dart` — group the integer part with `,`, allow at most one decimal separator, insert separators on the fly, and preserve the caret's logical position (FR-001)
- [x] T004 [P] Add a shared `parseMoneyInput(String)` helper (strip `[,\s]`, tolerate empty) in `lib/shared/presentation/money_format.dart`; refactored `tryParseMoneyInput` to delegate to it so all screens call one stripping rule (FR-002)
- [x] T005 Create the shared `MoneyField` widget in `lib/shared/presentation/widgets/money_field.dart` — wraps `TextFormField` with: numeric keyboard, the grouping formatter, **select-all-on-focus when prefilled**, optional `initialValue`, a `syncKey` that re-syncs the controller text via `didUpdateWidget` when the context identity changes, `validator`, `key` passthrough, and `onChanged` (FR-003, FR-007, FR-010); also exports `selectAllOnFocus` for percentage fields
- [x] T006 [P] Unit tests for the formatter in `test/shared/presentation/thousands_separator_input_formatter_test.dart` — 12 tests: grouping, leading zeros, decimal, stray chars, minus, caret preservation, digit-by-digit typing (SC-001)
- [x] T007 [P] Unit tests for the parser in `test/shared/presentation/money_parse_test.dart` — 8 tests: grouped/space/empty/invalid plus `tryParseMoneyInput` positive-only contract (SC-002)

**Checkpoint**: Formatter, parser, and widget exist and are unit-tested; no screen wired yet.

---

## Phase 3: User Story 1 - Big amounts are easy to read while typing (Priority: P1) 🎯 MVP

**Goal**: Every amount field groups digits while typing and saves the exact value.

**Independent Test**: Type `1000000` into any wired field → shows `1,000,000`; save → value is `1000000`.

- [x] T008 [US1] Adopt `MoneyField` (and shared parser) in `lib/features/expenses/presentation/add_expense_screen.dart` (replace the amount `TextField` at ~31/139; keep `_parseAmount` delegating to `parseMoneyInput`)
- [x] T009 [US1] Adopt `MoneyField` in `lib/features/expenses/presentation/edit_expense_screen.dart`; make the prefill helper `_formatEditable` (~75) emit grouped text and route ~78 through `parseMoneyInput`
- [x] T010 [US1] Adopt `MoneyField` in `lib/features/finance/presentation/net_salary_section.dart` for both the default salary and the month override (`_AmountField` ~106); route parsing through `parseMoneyInput`
- [x] T011 [US1] Adopt `MoneyField` in `lib/features/finance/presentation/opening_balance_sheet.dart`; fix the validator/parse at ~73/~93 to use `parseMoneyInput` (currently raw `double.tryParse`)
- [x] T012 [US1] Adopt `MoneyField` in `lib/features/medical/presentation/medical_bill_form.dart` for amount (~111/238) and reimbursement (~115/163-173/350); fix all parsers at ~238/250/350/504/583/683 to use `parseMoneyInput`
- [x] T013 [US1] Adopt `MoneyField` in `lib/features/spaces/presentation/create_space_sheet.dart` (~income) and `lib/features/spaces/presentation/space_settings_section.dart` (income dialog ~84/~119); both already strip `,` — verify via `parseMoneyInput`
- [x] T014 [US1] Adopt `MoneyField` in `lib/features/budget_setup/presentation/budget_setup_screen.dart` (~92/101) and fix the on-every-keystroke parser to use `parseMoneyInput`
- [x] T015 [US1] Adopt `MoneyField` in `lib/features/expenses/presentation/widgets/reimbursement_entry_sheet.dart` (~192; parser already strips `,` at ~56)
- [x] T016 [US1] Widget tests: one representative test per screen group asserting grouped display while typing AND the saved value after submit (SC-001, SC-002)

**Checkpoint**: Grouping works app-wide; saved values are exact.

---

## Phase 4: User Story 2 - Tapping a prefilled field and typing just works (Priority: P1)

**Goal**: Prefilled values are selected on focus so the first keystroke replaces them.

**Independent Test**: Open Settings income (`0.00`), tap, type `5` → shows `5`.

- [x] T017 [US2] Verify `MoneyField`'s select-all-on-focus fires for every prefilled field (salary `0.00`, edit expense, medical bill, opening balance) and add/keep a `Key` on each for tests
- [x] T018 [US2] Give percentage fields select-all-on-focus **without** grouping: `lib/features/medical/presentation/medical_dashboard.dart` patient share (~293/408/417) — use a plain select-all-on-focus helper, not the money formatter (FR-009)
- [x] T019 [US2] Widget tests: focusing a prefilled field selects the text; typing one digit replaces it; focusing and leaving without typing preserves the value (SC-003)

**Checkpoint**: The "0.00 does not disappear" issue is gone; edit screens don't lose data.

---

## Phase 5: User Story 3 - It is clear whose income I am editing (Priority: P2)

**Goal**: Name the profile on the income card; offer an optional starting salary on profile creation.

**Independent Test**: Switch profiles → income card header shows the active profile's name.

- [X] T020 [US3] Show the active profile's name in the Settings income card header in `lib/features/finance/presentation/net_salary_section.dart` (read the active profile from the existing providers) (FR-005)
- [X] T021 [US3] Add an optional "Starting salary" field to `ProfileSwitcherController.createProfile` (`lib/features/settings/presentation/profile_switcher_section.dart:93`) that sets `defaultNetSalary`, defaulting to `0` when left blank (FR-006)
- [X] T022 [US3] Tests: income card shows the active profile name and updates on switch; create-profile with and without a starting salary (SC-004)
- [X] T023 [US3] Wire `syncKey` into the two `NetSalarySection` income fields so a change of active profile, selected month, or personal↔shared context re-syncs the field text (replace the once-only `late final _controller` in `_AmountField`, `net_salary_section.dart:104-106`); the field shows the new context's value, or empty/`0.00` when unset (FR-010)
- [X] T024 [US3] Tests: switching profile (set and unset), switching month, and switching personal↔shared context each re-sync every income field; the previous context's value never lingers (SC-006)

**Checkpoint**: Per-profile income is unambiguous and always shows the current context.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Documentation and the final quality gate.

- [X] T025 [P] Add a short "Money input" note to `specs/013-money-input-and-profile-clarity/quickstart.md` describing the shared `MoneyField`/formatter/parser and the `syncKey` re-sync rule, and how to add a new amount field
- [X] T026 Run the final gate: `dart format .` (0 changed), `flutter analyze` (zero issues), `flutter test` (488 pass / 1 skip / 0 fail) and record counts (SC-005)

---

## Dependencies & Execution Order

- **Phase 1** → **Phase 2** (T003–T005 block everything) → **Phase 3/4/5** → **Phase 6**.
- T003, T004, T006, T007 are `[P]`; T005 depends on T003+T004.
- US1 and US2 are delivered by the same `MoneyField`, so US2 is effectively complete once US1 adoption is done + T017–T019.
- US3 (T020–T024) is independent of US1/US2 and can be done in parallel; T023 depends on T005 (`syncKey` support).

## Notes

- No schema change, no `build_runner`, no migration (FR-008).
- Prefer editing existing files; only three new files are created (`thousands_separator_input_formatter.dart`, `money_field.dart`, plus tests).
