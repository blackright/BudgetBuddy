# Quickstart: Validation Guide

**Feature**: `008-monthly-financial-overview` | **Date**: 2026-10-04 | **Plan**: [plan.md](./plan.md)

How to prove this feature works end to end. Commands are run from the repository root on Windows PowerShell.

Detailed arithmetic lives in [contracts/month-summary.md](./contracts/month-summary.md); bill behaviour in [contracts/medical-bill-lifecycle.md](./contracts/medical-bill-lifecycle.md); layout in [contracts/dashboard-ui.md](./contracts/dashboard-ui.md). This guide only describes how to run and observe the validation.

---

## 1. Prerequisites

| Requirement | Check |
|---|---|
| Flutter SDK with Dart 3.x | `flutter --version` |
| Dependencies resolved | `flutter pub get` |
| A debug APK target | `android/` with `compileSdk = 36` in `android/build.gradle.kts` |

**Governance precondition — satisfied**: Principle IV's medical clause was amended and approved by the project owner on 2026-10-04, ratified as constitution **v1.2.0** with the superseded text, reason, approval and migration plan recorded in `.specify/memory/constitution.md`. The binding migration plan is the six-step procedure in [data-model.md](./data-model.md) §10, verified in §7 below. No approval gate remains on the medical sections (§5, §6).

---

## 2. Code generation

Isar schemas are generated from the model annotations. After any change to a `@collection` class:

```powershell
dart run build_runner build --delete-conflicting-outputs
```

Expected: `lib/core/models/*.g.dart` and `lib/features/expenses/models/reimbursement.g.dart` regenerate without error. A stale `.g.dart` is the most common cause of a confusing "field does not exist" failure.

---

## 3. Automated test suite

```powershell
flutter analyze
flutter test
```

Expected: `flutter analyze` reports **No issues found!** and `flutter test` reports **all tests passing**.

Baseline before this feature is 72 tests. After implementation the suite must additionally cover:

| Area | Test file | Requirements |
|---|---|---|
| Month arithmetic | `test/features/engine/month_summary_test.dart` | FR-012 – FR-017, I1 – I10 in the month-summary contract |
| Reimbursement attribution | `test/features/engine/reimbursement_attribution_test.dart` | FR-032 – FR-035, SC-005 |
| Month finance records | `test/features/finance/month_finance_repository_test.dart` | FR-001 – FR-011, FR-028 – FR-030 |
| Medical payment methods | `test/features/medical/repositories/medical_repository_test.dart` (extended) | FR-041 – FR-051, SC-006 |
| Data migration | `test/features/medical/repositories/medical_repository_migration_test.dart` | steps 1 – 6 of data-model §10 |
| Dashboard layout | widget tests | FR-018 – FR-025, SC-002, SC-003 |

Repository and provider tests reuse the real-Isar harness at `test/features/medical/repositories/medical_test_harness.dart`, which opens a temporary Isar instance. The harness must be extended to register the new `MedicalServiceType` collection and to run the schema migration, otherwise migration tests cannot observe pre-migration state.

### 3.1 Verifying the two headline success criteria

| Criterion | How to observe it passing |
|---|---|
| **SC-004** — kept figure exact across 10 months of data | `month_summary_test.dart` asserts `kept == income − paymentsMade + moneyReturned` for a generated 10-month fixture with zero discrepancies |
| **SC-005** — a reimbursement entered up to 12 months late credits the original month in 100% of cases | `reimbursement_attribution_test.dart` loops entry offsets of 1, 3, 6 and 12 months against a fixed expense and asserts the origin month's `moneyReturned` in every case |
| **SC-006** — an insurer-paid bill never reduces funds by the full charge | `medical_repository_test.dart` asserts the linked expense amount equals `billedAmount × patientSharePercent ÷ 100` for every insurer-paid bill in the fixture |

---

## 4. Manual validation on device

```powershell
flutter run
```

Walk the five user stories in the specification. The steps below are the shortest path that exercises every requirement group.

### 4.1 Income and the opening balance

1. Settings → set **Net salary** to 4000.
2. Navigate the dashboard to the current month; open the expand control → set **Money in the bank** / opening balance to 1200.
3. Expected: the month shows as complete; the bank figure reads 1200 + income, and the hero is not marked incomplete.
4. Change the net salary to 5000. Expected: the **current** month's income follows the setting.
5. Navigate to a previous month. Expected: that month's income is unchanged unless it has its own override — FR-004.
6. Open a future month and set an income there. Expected: the override is marked as an override — FR-005 — and the current month is unaffected — FR-030.

### 4.2 The monthly report

1. Add a paid expense of 1200. Expected: hero shows 2800, `Out` 1200.
2. Add a planned expense of 800. Expected: hero **still 2800**, `Planned` 800 — FR-014.
3. Add a reimbursement of 300 against the paid expense. Expected: hero 3100, `Back` 300.
4. Re-record the reimbursement as 250. Expected: `Back` 250 — replaced, never 550 — FR-034.
5. Delete a paid expense that carries a reimbursement. Expected: a warning, not a silent deletion — FR-035.

### 4.3 Month navigation

1. Move to the previous month. Expected: every figure belongs to that month.
2. Edit an expense in it. Expected: the change is accepted and that month's totals update — FR-028.
3. Navigate forward to a future month with no records. Expected: a prompt to start, not a zero; planned expenses can still be added — FR-029.
4. Press **Today**. Expected: back to the current month.
5. Switch to Expenses, then Medical. Expected: the same month is still selected — FR-027.

### 4.4 No carryover

1. Note the bank figure in the current month.
2. Move to the next month. Expected: no figure is carried forward; the new month asks for its own opening balance — FR-007, SC-012.

---

## 5. Dashboard presentation checks

| Check | Expected | Requirement |
|---|---|---|
| Open the app | The hero figure is visible without scrolling or tapping | SC-001 |
| Visual hierarchy | The hero is the largest element; no other figure matches it | SC-002 |
| Colour removal | With colour ignored, in / out / planned remain distinguishable by label and position | SC-003 |
| Expand control | The bank figure, medical portion, cancelled total and override marker are hidden until expanded | FR-021 |
| Prohibited content | No safe-to-spend figure, cross-month bank balance, opening-balance breakdown, medical breakdown or chart on the default view | FR-023 |
| Navigation cost | Any previous or next month reachable in two interactions or fewer | SC-008 |

---

## 6. Medical bill validation

### 6.1 The two payment methods

1. Create a bill: $1000, service type Radiology, payment method **Insurer paid**, patient share 20%, state *Waiting for insurance*. Expected: available funds drop by **200**; the deductible is nowhere on screen — US2.1, US2.6.
2. Create a bill: $1000, payment method **Self paid**, state *Waiting for insurance*. Expected: available funds drop by **1000** — US2.2.
3. On the self-paid bill, record a reimbursement of 800 and set the state to *Finished*. Expected: funds return by 800 — US2.3.
4. Change the insurer-paid bill's state to *Rejected*. Expected: the obligation rises to the full 1000 — US2.4.
5. Change the self-paid bill's state to *Rejected*. Expected: no funds return; the full amount stays spent — US2.5.
6. Change the patient share on the insurer-paid bill from 20% to 0%. Expected: the expense amount updates immediately — FR-048.
7. Attempt to set an insurer-paid bill to *Finished*. Expected: not offered — FR-044.

### 6.2 Service types

1. Confirm the six seeded types are present — FR-039.
2. Add one, rename one, archive one. Expected: the list updates and existing bills keep their type — FR-040.

### 6.3 Month ownership

1. Create a bill with a service date of the 31st and pay it in the following month. Expected: it belongs to the service month — FR-055.
2. Override the month. Expected: it moves, and the general totals follow.

### 6.4 Cross-tab agreement

1. Note the medical portion shown in the dashboard's hidden detail.
2. Open the Medical tab for the same month. Expected: an identical figure — FR-024, SC-009.

---

## 7. Migration validation

The migration must be exercised against a database written by the **previous** schema, not a fresh one.

```powershell
flutter test test/features/medical/repositories/medical_repository_migration_test.dart
```

| Step | Expected outcome |
|---|---|
| 1 — deductibles cleared | No deductible value remains in stored settings; no deductible UI anywhere in the running app (SC-007) |
| 2 — percentage inverted | An existing 80% coverage bill shows a 20% patient share, not 0% |
| 3 — states mapped | Old unclaimed/processing/reimbursed/denied bills appear as waiting/waiting/finished/rejected |
| 4 — origin months backfilled | A pre-existing reimbursement credited in April still lands in its January expense's month |
| 5 — bill months backfilled | Existing bills are attributed to their service month |
| 6 — existing budgets confirmed | Months created before this feature are not treated as missing an opening balance |

Re-running the migration MUST be a no-op (idempotent), and a failure partway MUST leave the database untouched (single transaction).

---

## 8. Regression checks for untouched behaviour

These consumers must keep working unchanged, because the plan deliberately preserves them:

| Behaviour | Requirement |
|---|---|
| Safe to Spend still correct on the expense add, edit and detail screens | plan Technical Context |
| Analytics screen still renders | unchanged |
| Onboarding budget setup still creates the first month | `budget_setup_provider` |
| Multi-currency expense conversion unchanged | Constitution additional constraints |
| Medical provider and family member directories still function | FR scope boundary |

---

## 9. Build validation

```powershell
flutter build apk --debug
```

Expected: a successful build producing `build\app\outputs\flutter-apk\app-debug.apk`. A failure mentioning `core:android` and `compileSdk` indicates the Android plugin requires 36, which `android/build.gradle.kts` already sets.

---

## 10. Definition of done

- [ ] `flutter analyze` clean
- [ ] `flutter test` fully passing, including the new test files in §3
- [x] Principle IV amendment approved and recorded (constitution v1.2.0, 2026-10-04)
- [ ] Migration steps 1 – 6 verified against a pre-existing database
- [ ] All five user stories' acceptance scenarios walked on device
- [ ] SC-007 confirmed by inspection: no deductible anywhere in the running app
- [ ] SC-009 confirmed: dashboard and Medical tab agree for the same month
- [ ] Regression checks in §8 pass
- [ ] Debug APK builds