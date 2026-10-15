# Contract: Month Summary Calculation

**Feature**: `008-monthly-financial-overview` | **Requirements**: FR-006 – FR-017, FR-031 – FR-035 | **Data model**: [../data-model.md](../data-model.md)

This is the arithmetic contract for one calendar month. It is the single source of truth for every figure the dashboard, Expenses tab and Medical tab display. It is technology-agnostic and is the oracle for `month_summary_test.dart` and `reimbursement_attribution_test.dart`.

---

## 1. Scope

A month summary is computed for exactly one `yearMonth`. It is derived, never stored, and never cached across writes (FR-017). No input from any other month may affect it (FR-016).

---

## 2. Inputs

| Input | Source | Notes |
|---|---|---|
| `income` | `MonthlyBudget.netSalaryOverride` if set, else `UserProfile.defaultNetSalary` | FR-002, FR-003 |
| `usesOverriddenIncome` | `netSalaryOverride != null` | FR-005 |
| `openingBalance` | `MonthlyBudget.baseAvailableAmount`, or **absent** when `openingBalanceConfirmed == false` | FR-006, FR-010 |
| Expenses of the month | rows where `yearMonth == this month` | — |
| Reimbursements of the month | rows where `originYearMonth == this month` | FR-032 |

**Currency rule**: expense-derived amounts are converted with the expense's own `exchangeRateToPrimary`. Income and opening balance are already primary-currency values. Reimbursements are assumed to be denominated in their target expense's currency and inherit that expense's rate; where the target is missing, the recorded amount is used unconverted.

---

## 3. Outputs

| Output | Definition | Requirement |
|---|---|---|
| `income` | resolved income for the month | FR-012 |
| `paymentsMade` | Σ `amount × rate` over expenses with `status = paid` | FR-012 |
| `moneyReturned` | Σ `amount` over reimbursements attributed to this month | FR-012, FR-032 |
| `planned` | Σ `amount × rate` over expenses with `status = planned` | FR-018 |
| `cancelled` | Σ `amount × rate` over expenses with `status = cancelled` | hidden detail only |
| `medicalPaid` | the subset of `paymentsMade` where `type = medical` or `categoryId = 'health'` | FR-022, FR-056 |
| `kept` | `income − paymentsMade + moneyReturned` | FR-012 |
| `moneyInBank` | `openingBalance + income − paymentsMade + moneyReturned`, or **absent** if no opening balance | FR-008 |
| `excessReturned` | Σ of the portion of each reimbursement exceeding its target's paid amount | R14 |
| `isComplete` | opening balance present **and** `income > 0` | FR-025 |

---

## 4. Invariants

These MUST hold for every input. Each is a direct assertion in `month_summary_test.dart`.

| # | Invariant | Requirement |
|---|---|---|
| I1 | `kept == income − paymentsMade + moneyReturned` exactly | SC-004 |
| I2 | `moneyInBank == openingBalance + income − paymentsMade + moneyReturned` exactly | FR-008 |
| I3 | `planned` appears in none of `kept`, `paymentsMade`, `moneyInBank` | FR-014, FR-015 |
| I4 | `openingBalance` appears in no term of `kept` | FR-013 |
| I5 | `moneyInBank` is absent **iff** the month has no confirmed opening balance | FR-010 |
| I6 | `medicalPaid ≤ paymentsMade` | FR-056 |
| I7 | `kept` and `moneyInBank` are never floored at zero because of an excess reimbursement | R14 |
| I8 | `cancelled` expenses contribute to nothing except `cancelled` | Constitution IV |
| I9 | For any two months A and B, mutating B's rows does not change A's summary | FR-016 |
| I10 | `moneyInBank == trueAvailable + income` whenever the opening balance is confirmed | R01 |

---

## 5. Worked examples

Each example is taken from an acceptance scenario in the specification.

### E1 — FR-012, scenario US1.1
```
income           = 4000
paymentsMade     = 1200     (one paid expense)
moneyReturned    = 0
planned          = 0

kept             = 4000 − 1200 + 0        = 2800   ✓
```

### E2 — FR-014, scenario US1.2
Same month plus a `planned` expense of 800.
```
planned          = 800
kept             = 4000 − 1200 + 0        = 2800   ✓ unchanged
```

### E3 — FR-012, scenario US1.3
Same month plus a reimbursement of 300 against a paid expense.
```
moneyReturned    = 300
kept             = 4000 − 1200 + 300      = 3100   ✓
```

### E4 — FR-008, scenario US5.1
```
openingBalance   = 1200
income           = 4000
paymentsMade     = 1200
moneyReturned    = 800

moneyInBank      = 1200 + 4000 − 1200 + 800 = 4800  ✓
```

### E5 — FR-032, scenario US3.1 — the defect this feature fixes
A $1000 expense paid in **January**; an $800 reimbursement recorded in **April**.
```
January:  moneyReturned = 800   ← attributed to the expense's month, not April's
          kept = income − 1000 + 800

April:    moneyReturned = 0     ← April's own figures are unaffected
```
**Before this feature** the reimbursement is invisible in both months, because the reimbursement set is derived from the *viewed* month's expense ids and the January expense is not in April's set.

### E6 — FR-034, scenario US3.3
An expense already carries a reimbursement of 800. The user records 650 instead.
```
moneyReturned    = 650   ← replaced, never 800 + 650
```
At most one reimbursement row may exist per target at any time.

### E7 — R14, over-reimbursement edge case
A reimbursement of 900 against a paid expense of 800.
```
moneyReturned    = 900     ← full amount credited; nothing hidden
excessReturned   = 100     ← surfaced as a distinct figure
paymentsMade     = 800     ← never reduced
kept             = income − 800 + 900
```

### E8 — FR-010, scenario US5.2
A month with no confirmed opening balance.
```
moneyInBank      = absent  ← the app prompts; it never assumes a value
isComplete       = false
```

### E9 — FR-007 / SC-012, scenario US5.3
February is opened after January closed with 4800 in the bank.
```
February: openingBalance = absent    ← nothing carried forward
          moneyInBank    = absent    ← February asks for its own
```

### E10 — FR-025, future month edge case
A future month with planned expenses but no income and no opening balance.
```
planned          = sum of planned expenses   ← allowed
kept             = presented as INCOMPLETE, not as a real number
isComplete       = false
```

---

## 6. Reimbursement attribution rules

| Rule | Behaviour | Requirement |
|---|---|---|
| Attribution source | The target expense's owning month, copied at record time | FR-032 |
| Entry month irrelevance | Recording in a later month never changes attribution | FR-033 |
| Replacement | One reimbursement row per target; re-recording replaces it | FR-034 |
| Orphan | A reimbursement whose expense is deleted is retained, flagged, and surfaced to the user | FR-035 |
| Orphan contribution | Still counted in `moneyReturned` for its `originYearMonth` | FR-035 |
| All-or-nothing | A single amount; no accumulation of partials | FR-049 |

---

## 7. Change propagation

| Event | Must update |
|---|---|
| Expense added / edited / deleted / status changed | `paymentsMade`, `planned`, `cancelled`, `medicalPaid`, `kept`, `moneyInBank` |
| Reimbursement recorded / replaced / removed | `moneyReturned`, `excessReturned`, `kept`, `moneyInBank` |
| Opening balance entered / edited | `moneyInBank`, `isComplete` |
| Income resolved or overridden | `income`, `kept`, `moneyInBank`, `isComplete`, `usesOverriddenIncome` |
| Month selected | The whole summary, from that month's rows only |

Every propagation MUST be observable in the UI without a manual refresh (FR-028, FR-054).

---

## 8. Out of contract

Charts, trends, comparisons across months, category breakdowns beyond `medicalPaid`, and bank or insurer synchronisation (spec Assumptions).