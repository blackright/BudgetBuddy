# Phase 4–5 validation results (US2 + US3)

Scope: `T033`–`T055` (US2, medical bill lifecycle) and `T056`–`T063` (US3,
reimbursement attribution). Phases 6–8 are out of scope and not started.

## Commands

```powershell
dart analyze lib      # clean
dart analyze test     # clean
flutter test --concurrency=1   # 206 tests, all passing
```

Suites:

| Suite | Tests |
|---|---|
| `medical_repository_test.dart` | 61 |
| `medical_providers_test.dart` | 30 |
| `medical_repository_migration_test.dart` | 12 |
| `reimbursement_attribution_test.dart` | 13 (incl. the generated 1/3/6/12-month loop) |
| `medical_layout_overflow_test.dart` | 8 (added after the UI pass below) |

## US2 acceptance scenarios (`quickstart.md` §6.1–§6.3)

| # | Scenario | Result | Evidence |
|---|---|---|---|
| 6.1.1 | Insurer-paid $1000, 20% share, waiting → funds drop by 200 | pass | `FR-043: an insurer-paid waiting bill costs only the share (M2)`; `M1: an insurer-paid bill is never charged the full amount while open` |
| 6.1.1 | The deductible appears nowhere | pass | `the profile carries a default patient share, not deductibles`; `no deductible wording survives on the screen` (widget test, `medical_layout_overflow_test.dart`). Corrected on the UI pass: the Medical dashboard's empty state had been left saying "a bill against your deductible" after R12 removed the concept. That string is gone, and it is now asserted in a test rather than by inspection. |
| 6.1.2 | Self-paid $1000, waiting → funds drop by 1000 | pass | `FR-045: a self-paid waiting bill costs the full charge` |
| 6.1.3 | Reimbursement of 800 + finished → funds return by 800 | pass | `logging a payout lifts available and finishes the bill` |
| 6.1.4 | Insurer-paid → rejected → obligation rises to 1000 | pass | `FR-051: a rejected insurer-paid bill raises the cost to full`; `FR-051: rejecting a live insurer-paid bill raises it to full` |
| 6.1.5 | Self-paid → rejected → amount unchanged | pass | `FR-050: rejecting a self-paid bill leaves the amount unchanged` |
| 6.1.6 | Share 20% → 0% updates the expense immediately | pass | `FR-054: correcting the percentage updates the expense immediately` |
| 6.1.7 | Finished is not offered on an insurer-paid bill | pass | `R-1: an insurer-paid bill cannot be finished` (repository rejects it; the detail screen's state section hides the option) |
| 6.2.1 | Six seeded types present | pass | `step 0: every profile is given the default service types` (migration) |
| 6.2.2 | Add / rename / archive; existing bills keep their type | pass | `service types are created, renamed and archived`; archiving hides the type from `getServiceTypes` while `getAllServiceTypes` still returns it |
| 6.3.1 | Service on the 31st, paid next month → service month owns the bill | pass | `a bill lands in its service month by default`; migration: `step 5: the service month owns the bill (FR-055)` |
| 6.3.2 | Month override moves the bill and the totals follow | pass | `an explicit month overrides the service month`; `bills are queried by their owning month` |

## US2 migration validation (`quickstart.md` §7)

| Step | Result | Evidence |
|---|---|---|
| 1 – deductibles cleared | pass (with limitation) | `steps 1-3: retired insurance concepts leave the declared defaults` |
| 2 – percentage inverted | pass (with limitation) | same test; documented in `schema_migrations.dart` |
| 3 – states mapped | pass (with limitation) | same test; documented in `schema_migrations.dart` |
| 4 – origin months backfilled | pass | `step 4: a reimbursement is credited to its expense month`; `step 4: an existing origin month is never overwritten`; `step 4: an orphaned reimbursement falls back to its own month` |
| 5 – bill months backfilled | pass | `step 5: the service month owns the bill (FR-055)`; `step 5: a bill without a service date borrows its expense month` |
| 6 – existing budgets confirmed | pass | `step 6: an existing opening balance counts as confirmed (FR-010)` |
| Idempotent | pass | `running the migrations twice changes nothing`; `a stamped database skips every step` |
| Single transaction | pass by construction | `runSchemaMigrations` opens one `writeTxn` around every step and the version stamp, so a partial run is unobservable |

**Documented limitation (steps 1–3).** Isar 3 unmaps retired columns when it
reconciles the schema on open, so `individualDeductible`,
`familyDeductible`, `insuranceCoveragePercent`, `defaultCoveragePercent` and the
legacy claim enum cannot be read back through the ORM. Rows therefore land on the
declared defaults. For the inverted percentage this is exactly right for the
shipped default (`100 − 80 = 20`); a bill the user had set to another coverage
percentage, and any legacy `reimbursed`/`denied` bill, need manual correction.
Recovering the values would require reading dropped columns through raw SQL,
which Isar 3 does not expose. Recorded in the step doc comments rather than
papered over.

## US3 acceptance scenarios (`quickstart.md` §4.2)

| # | Scenario | Result | Evidence |
|---|---|---|---|
| E4 | Re-record a 300 reimbursement as 250 → `Back` is 250, never 550 | pass | `re-recording replaces the amount instead of adding to it`; `replacement keeps the original row identity and date` |
| E5 | Delete a paid expense carrying a reimbursement → warning, not silent loss | pass | `deleting the target keeps the row and flags it`; UI: the `_OrphanBannerButton` in `expenses_screen.dart` badges the orphan count and offers Move / Remove |

E1–E3 remain covered by `month_summary_test.dart` (`E1: income 4000, one paid
expense of 1200 keeps 2800`, `E2: adding a planned 800 leaves kept unchanged`,
`E3: a reimbursement of 300 raises kept to 3100`).

## SC-005 — late entry credits the origin month

`reimbursement_attribution_test.dart` generates one test per entry offset from
`[0, 1, 3, 6, 12]`, and for each asserts the origin month's `moneyReturned` while
asserting the entry month does **not** double-count it. All pass.

- `entered 1 month(s) late still credits 2026-01`
- `entered 3 month(s) late still credits 2026-01`
- `entered 6 month(s) late still credits 2026-01`
- `entered 12 month(s) late still credits 2026-01`

Covered alongside: year-boundary entry (`2026-11` → `2027-02`), all four offsets
landing in one ledger (`moneyReturned` 400 against 2000 paid), and attribution
surviving a year of unopened months.

## SC-006 — insurer-paid bills never reduce funds by the full charge

Asserted structurally across the fixture by
`M1: an insurer-paid bill is never charged the full amount while open`, plus the
per-state amount tests (`FR-043`, `FR-045`, `FR-051`, `FR-050`) and the
transition tests (`M5: moving from planned to waiting applies the share at once`,
`M5: moving back to planned restores the balance`).

## Defects found and fixed while validating

1. **`_syncLinkedExpense` inherited the stored expense status.** Moving a bill
   back to `planned` left the linked expense `paid`, so the balance was not
   restored (M4). Now the status is derived from `bill.state`.
2. **`_applyOwningMonth` overrode an explicit month with the service date**, so a
   user's month override was silently discarded (FR-055). Precedence is now
   override → service date → expense month.
3. **`logReimbursement` accepted an insurer-paid bill**, injecting a payout that
   can never exist (FR-044 / R-1). Now rejected before the budget is touched.
4. **`getServiceTypes` returned archived types**, so an archived type kept
   cluttering the picker (FR-040 / R10). Now filtered on `archived`; historical
   lookups still use `getAllServiceTypes`.
5. **Migration step 4 did not flag a dangling reimbursement.** Older rows have no
   `orphaned` flag, so a reimbursement whose target was already gone was not
   surfaced. Step 4 now sets it.
6. **`MedicalTestHarness` could not open two Isar instances.** Isar 3 keys open
   instances by name and refuses duplicates; each harness now gets a unique name.

## Post-validation UI pass (items 1–4)

A crash report from the device supplied three errors: `RenderFlex overflowed ...
on the bottom`, then `_dependents.isEmpty`, then `Tried to build dirty widget in
the wrong build scope`. Changes made:

1. **Stale deductible copy.** The Medical dashboard empty state said "a bill
   against your deductible" (line 611 of `medical_dashboard.dart`). Replaced with
   "Log a bill to see what it costs you and what comes back."
2. **Keyboard-inset surfaces.** The log-reimbursement `AlertDialog` and the
   insurance, provider, family and directory sheets now subtract
   `MediaQuery.viewInsetsOf(context).bottom` and wrap their content in a
   `SingleChildScrollView` (the directory sheet additionally caps itself at 80%
   height). The reimbursement dialog's `autofocus: true` is removed, so the
   keyboard is not raised the instant the dialog opens.
3. **Orphan dialog.** `SizedBox(width: double.maxFinite)` + `Flexible` +
   `ListView(shrinkWrap: true)` inside a min-size column replaced with a bounded
   `SizedBox(width: 360, height: 96 + n.clamp(1, 4) * 56)` and a single
   `Expanded` + `ListView`.
4. **Add Bill moved out of a FAB.** `FloatingActionButton.extended` sat on top of
   whichever row was at the bottom of the viewport. It is now a
   `TextButton.icon` in the `Medical Bills` section header, keyed
   `addBillButton`; a test asserts it does not overlap the row's trailing amount.
5. **Settings made visible.** The sheet is titled `Bill Defaults`, the field is
   `Usual patient share (%)`, and a configured profile renders a
   `Usually pay N%` summary card (key `billDefaultsSummary`) instead of nothing.

### What these changes do *not* establish

The 8 tests in `medical_layout_overflow_test.dart` do **not** reproduce the crash.
I checked the previous layouts directly at 360x800 with a 300px keyboard inset,
with and without `autofocus`: the old dialog and the old orphan dialog both lay
out clean, `tester.takeException()` returns null. So the ~99770px overflow in the
pasted log came from a widget the log does not identify, and the two follow-on
framework errors are secondary. The changes above are defensive and each carries
a test of its own layout invariant, but the root cause remains unconfirmed and a
full device log (route + complete stack, including the first
`RenderFlex` overflow frame) is needed to pin it down.

## Known gaps

- Steps 1–3 of the legacy migration cannot preserve custom values (see the
  limitation above).
- The device crash is not yet reproducible in a test; see the UI pass above.
- The orphaned-reimbursement widget path now has structural coverage only in the
  sense that the dialog layout is asserted in isolation; the repository rules are
  covered, the end-to-end tap path is not.
