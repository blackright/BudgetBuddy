# Contract: Month Move Lifecycle

**Feature**: 011-shared-financial-spaces | **Owner**: `spaces` repositories (month-move + delete-space + transfer operations) | **Storage**: `MonthlyBudget`, `Expense`, `Reimbursement`, `MedicalBill`, medical directory rows

---

## 1. Participants

| Participant | Role |
|---|---|
| **`moveMonth(from, to, yearMonth, {targetProfileId?})`** | re-point one whole month between a personal profile and a shared space — **move, never copy** |
| **`deleteSpace(spaceId, decisions)`** | per-month move-back-or-delete, then atomic removal |
| **`transferOwnership` / `leaveSpace`** | role lifecycle (see space-roles contract) |
| **`SpaceAccessGuard`** | every operation re-verifies the acting member's role at the data layer |
| **`ensureMonth(contextRef, ym)`** | provisions the target context's budget row (FR-011) |

## 2. Operations

### `moveMonth(from: ContextRef, to: ContextRef, yearMonth: String, {targetProfileId})`

1. **Guard**: `to.canView(actor)`; **blocked with a clear message** if the target context already owns a `MonthlyBudget(yearMonth)` (FR-010 — "a month lives in exactly one space"; spec US3 AC4).
2. **One `writeTxn`**:
   - `MonthlyBudget`: switch context columns (profileId ⇄ sharedSpaceId).
   - `Expense([profileId|sharedSpaceId] + yearMonth)`: switch context columns.
   - `Reimbursement(originYearMonth)`: switch context columns.
   - `MedicalBill([profileId|sharedSpaceId] + yearMonth)`: switch context columns; referenced `FamilyMember/MedicalProvider/MedicalServiceType/InsuranceProfile` rows **move with them** (R3/R5), dedupe-by-name on re-entry.
   - Linked `Expense.budgetId` → target budget id.
   - Income carry per shared-income contract (R4).
3. Returns the moved `MonthlyBudget` (its id may change if it was a fresh provision).

### `deleteSpace(spaceId, {required Map<yearMonth, moveToProfileId | delete>})`

1. Owner-only, outside a txn: for each month, prompt the Owner — "move back to a personal profile (choose which)" or "delete" (FR-014; anti-accident).
2. Apply each decision via `moveMonth` (or row deletion).
3. Final atomic txn: remove the space's remaining budgets/expenses/reimbursements/bills/directory rows, then `SharedMember` rows, then the `SharedSpace`. Member profiles untouched.

## 3. State machine (normative)

A month's **home** is a small two-room machine:

```
personal(profile P) ──move(→ space S)──▶ shared(space S)
        ▲                                  │
        └────────move(← profile Q)──────────┘
```

| Transition | Trigger | Guard |
|---|---|---|
| `personal → shared` | Owner/Editor moves month into a space | target space has no `MonthlyBudget(yearMonth)` |
| `shared → personal` | delete-space per-month "move back"; or future planned "unshare" | target profile has no `MonthlyBudget(yearMonth)` |
| *(no move)* | attempt when target already owns the month | blocked, clear message, SC-006 |
| *(sealed past)* | move allowed | **never modifies** stored amounts or sealed rates — only the room the month belongs to (spec edge) |

**Lifecycle of a space**: `created (with bring-in-past choice)` → `active (months accrue automatically)` → `deleted (per-month move-back or delete, atomic)`.

## 4. Invariants

- **I1** — A month exists in exactly one context at all times; a move is atomic (single txn), so a torn/half-moved month is unobservable.
- **I2** — The move is a **move not a copy**: after it, the origin context has no rows for `yearMonth`.
- **I3** — Pre-move month totals are identical post-move (SC-006): same amounts, same seals, same derivation — the only intentional numeric write is the income override carry (R4) when currencies differ.
- **I4** — The savings vault is never part of a move (FR-017).
- **I5** — `Reimbursement` credit follows `originYearMonth`'s context — the returned money lands in the room that owns the month (R5).

## 5. Failure matrix

| Failure | Resulting state | User-visible effect |
|---|---|---|
| Target already owns the month | move refused before any write | clear blocking message (US3 AC4) |
| Actor is Viewer / non-member on a move or delete | `UnauthorizedSpaceAction` thrown | refused at data layer, UI also hides it (US4) |
| Space deletion with months still undecided | deletion paused | per-month prompt list until every month is decided (FR-014) |
| Moving a sealed past month | allowed | numbers identical before/after; still sealed, still frozen for every role |
| Same-currency move | allowed | income carries verbatim (byte-identical figure) |
| Cross-currency move | allowed | income override converted once at the month's seal/ live table (R4); all other amounts untouched |