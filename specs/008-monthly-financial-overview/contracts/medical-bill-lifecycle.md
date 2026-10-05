# Contract: Medical Bill Lifecycle & Money Impact

**Feature**: `008-monthly-financial-overview` | **Requirements**: FR-036 – FR-056 | **Data model**: [../data-model.md](../data-model.md) | **Research**: [research.md](../research.md)

Defines the five bill states, the amount each state removes from available funds, and the reimbursement rules. This contract is the oracle for `medical_repository_test.dart` and `medical_repository_migration_test.dart`.

**Constitution note**: clauses 1–4 of this contract implement Principle IV's medical clause as ratified in constitution **v1.2.0** (approved 2026-10-04). The migration plan that accompanies the amendment is the six-step procedure in [../data-model.md](../data-model.md) §10.

---

## 1. Payment methods

Exactly two (FR-041). No third method may be introduced.

| Method | Meaning | Reimbursement | Documents |
|---|---|---|---|
| **Insurer-paid** | The insurer bills the hospital directly. The user pays only their share, at the hospital. | Never (FR-044) | None required |
| **Self-paid** | The user pays the hospital in full, then claims the insurer's share back. | Required once resolved | Bill photo + insurer reply photo (FR-047) |

---

## 2. The percentage the user is responsible for

`patientSharePercent` is the share **the user** pays (FR-048). For the user's plan this is 20 for most services and 0 for fully covered services.

```
patientShareAmount = billedAmount × patientSharePercent ÷ 100
```

Validation: `0 ≤ patientSharePercent ≤ 100`.

Correcting the percentage after entry MUST update every affected figure immediately (FR-048, FR-054). For a self-paid bill the percentage does not change what left funds — the user already paid the full charge — but it does change the expected reimbursement.

---

## 3. States

Exactly five (FR-052). There is no separate claim workflow; a bill's state drives both its insurance meaning and its effect on totals (FR-053).

| State | Meaning | Counts as | Reimbursement |
|---|---|---|---|
| `planned` | The user intends to pay; nothing has moved | planned | none |
| `waiting` | Submitted; the insurer has not answered | paid | none |
| `paid` | Settled from the user's side | paid | none yet |
| `finished` | Fully resolved, money accounted for | paid | self-paid: exactly one, all-or-nothing |
| `rejected` | The insurer declined | paid | **none** — funds never return |

**Invalid combination**: `finished` on an insurer-paid bill. There is no reimbursement to record, so the state cannot be reached (FR-044).

---

## 4. Money impact table

The single authority for how much a bill removes from available funds. `Expense.amount` MUST equal the "reduces funds by" column (R07).

| Method | State | Reduces funds by | Requirement |
|---|---|---|---|
| Insurer-paid | `planned` | `0` | FR-042, FR-053 |
| Insurer-paid | `waiting` | `patientShareAmount` | FR-042, FR-043 |
| Insurer-paid | `paid` | `patientShareAmount` | FR-042 |
| Insurer-paid | `finished` | `patientShareAmount` | FR-042 |
| Insurer-paid | `rejected` | **`billedAmount`** | FR-051 |
| Self-paid | `planned` | `0` | FR-045, FR-053 |
| Self-paid | `waiting` | `billedAmount` | FR-045 |
| Self-paid | `paid` | `billedAmount` | FR-045 |
| Self-paid | `finished` | `billedAmount` | FR-045 |
| Self-paid | `rejected` | `billedAmount` | FR-050 |

**Invariants**:
- **M1** — an insurer-paid bill MUST never reduce available funds by the full charge while it is unresolved (FR-042).
- **M2** — the reduction MUST be applied at the moment the bill is entered, not deferred to a month-end event (FR-043).
- **M3** — a rejected insurer-paid bill raises the obligation to the full charge; a rejected self-paid bill leaves the amount unchanged and returns nothing (FR-050, FR-051).
- **M4** — a bill in `planned` contributes to planned totals only and never to payments (FR-053).
- **M5** — moving between states MUST update totals immediately (FR-054).

---

## 5. Transitions

| From | To | Allowed | Effect on funds |
|---|---|---|---|
| — | `planned` | yes | none |
| — | `waiting` | yes | per §4 for the method |
| — | `paid` | yes | per §4 for the method |
| `planned` | `waiting` \| `paid` | yes | `0` → share or full |
| `waiting` | `paid` \| `finished` \| `rejected` | yes | see §4 |
| `paid` | `finished` \| `rejected` | yes | see §4 |
| `finished` | `rejected` | yes | reimbursement deleted |
| `rejected` | `waiting` \| `paid` | yes | recomputed from method + share; no return |
| `waiting` | `planned` | yes | funds return to the planned pool |
| `paid` | `planned` | yes | funds return to the planned pool |
| self-paid `finished` | any | yes | changing away from `finished` removes the reimbursement |

**Rules**:
- **T1** — reaching `finished` on a self-paid bill requires a recorded reimbursement (FR-046).
- **T2** — reaching `finished` on an insurer-paid bill is impossible (FR-044).
- **T3** — entering or leaving `rejected` MUST recompute the expense amount from the method and percentage, never leave a stale value (FR-051, M5).
- **T4** — moving away from `rejected` MUST delete any reimbursement row (Constitution IV: money that did not return must not appear as returned).
- **T5** — deleting a bill that carries a reimbursement MUST warn the user before it removes money from a closed month's history, and MUST NOT delete the reimbursement silently (FR-035).

---

## 6. Reimbursement rules

| Rule | Behaviour | Requirement |
|---|---|---|
| **R-1** | Reimbursement applies to self-paid bills only | FR-044 |
| **R-2** | All-or-nothing. No partial state, no accumulation | FR-049 |
| **R-3** | At most one reimbursement row per bill | FR-034 |
| **R-4** | Re-recording replaces the previous amount | FR-034 |
| **R-5** | The returned amount is attributed to the bill's owning month, not the date it was recorded | FR-032 |
| **R-6** | Amount MUST be greater than zero | validation |
| **R-7** | An amount exceeding the original payment MUST still be credited in full, with the excess surfaced separately | R14 |

`MedicalRepository.logReimbursement` already collapses duplicate rows; this contract states the guarantee rather than changing the mechanism.

---

## 7. Month ownership

- A bill belongs to the month of its **service date** (FR-055).
- The user MAY override that month; the override wins and is persisted (FR-055).
- The owning month is stored on `MedicalBill.yearMonth` **and** mirrored onto the linked `Expense.yearMonth`, so the bill appears in exactly one month's general totals (FR-055, FR-056).
- **O1** — a service on 31 January paid in February belongs to January unless overridden.
- **O2** — moving a bill's month MUST move its expense in the same transaction, so the two can never disagree.

---

## 8. Documents

| Field | Required when | Requirement |
|---|---|---|
| `billPhotoPath` | optional, any method | FR-047 |
| `insurerReplyPath` | optional, **self-paid only** | FR-047 |

- **D1** — an insurer-paid bill MUST be savable with neither document (FR-044).
- **D2** — attaching an insurer reply to an insurer-paid bill MUST be rejected as invalid.

---

## 9. Service types

- Every bill records a service type from the user's list (FR-039).
- The list is seeded with: Radiology, Lab Work, Specialist Consultation, Generalist Consultation, Surgery, Medicine / Pharmacy.
- The user may add, rename and archive types (FR-040).
- Archiving preserves historical bills; an archived type remains readable on bills that reference it.
- Service types group medical spending within a month; they never change a bill's money impact.

---

## 10. Out of contract

Deductibles, partial reimbursements, dependent tracking, EOB parsing, insurer synchronisation, and coverage verification against a policy (spec Assumptions).

---

## 11. Test matrix

Minimum cases required before this contract is satisfied. Each maps to an acceptance scenario.

| # | Case | Expectation | Scenario |
|---|---|---|---|
| 1 | Insurer-paid $1000 @ 20%, entered `waiting` | funds −200 | US2.1 |
| 2 | Insurer-paid @ 0% | funds −0 | FR-042 |
| 3 | Self-paid $1000, entered `waiting` | funds −1000 | US2.2 |
| 4 | Self-paid, reimbursement 800 → `finished` | funds +800 | US2.3 |
| 5 | Insurer-paid → `rejected` | funds −1000 | US2.4 |
| 6 | Self-paid → `rejected` | funds −1000, no return | US2.5 |
| 7 | Any bill, deductible inspected | no deductible field or progress anywhere | US2.6 |
| 8 | Percentage corrected 20 → 0 after entry | funds recomputed immediately | FR-048 |
| 9 | Self-paid reimbursement re-recorded at a different amount | replaced, not stacked | FR-034 |
| 10 | Reimbursement entered 3 months later | credited to the bill's month | FR-032 |
| 11 | Reimbursement with a deleted expense | retained, flagged, user chooses | FR-035 |
| 12 | Bill in `planned` | excluded from payments, included in planned | FR-053 |
| 13 | `finished` on an insurer-paid bill | rejected as invalid | FR-044 |
| 14 | Service 31 Jan, paid Feb | January unless overridden | FR-055 |
| 15 | Service type added / renamed / archived | list updates; bills unaffected | FR-040 |
| 16 | Medical total on dashboard vs Medical tab | identical | SC-009 |