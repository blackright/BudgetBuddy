# Contract: Shared Income ("My income" / "Our income")

**Feature**: 011-shared-financial-spaces | **Owner**: finance (income resolution) | **Storage**: `UserProfile.defaultNetSalary`, `MonthlyBudget.netSalaryOverride`, `SharedSpace.defaultIncome`, `MonthlyBudget.sharedIncomeOverride`

---

## 1. The two pots

| Pot | Default (storage) | Per-month override (storage) | Units |
|---|---|---|---|
| **"My income"** (personal) | `UserProfile.defaultNetSalary` (`double`, legacy) | `MonthlyBudget.netSalaryOverride` (`double?`, legacy) | major units, unchanged (spec assumption) |
| **"Our income"** (shared) | `SharedSpace.defaultIncome` (`int`) | `MonthlyBudget.sharedIncomeOverride` (`int?`) | **whole minor units** (new fields rule) |

JSON-style resolution rule (identical shape to today's `ResolvedIncome.resolve`, `month_finance_repository.dart:25-33`): **override beats default** — per pot, independently. The two pots never read each other (FR-009/SC-007).

## 2. Resolution

```
myIncome(context)   = override ?? profileDefault        (double, ignores shared pot entirely)
ourIncome(context)  = sharedOverride ?? spaceDefault    (minor units, ignores personal pot entirely)
```

Context picks the pot automatically via `budgetContextProvider`:
- personal context → "My income" drives dashboard/engine income.
- shared context → "Our income" drives dashboard/engine income.

## 3. Carry-on-move (FR-008, one-cut conversion at the boundary)

When `moveMonth` re-homes a month, the **resolved** income figure follows into the target pot's **per-month override**:

| Move | What lands |
|---|---|
| personal → shared | `sharedIncomeOverride = toMinorUnits(resolvedMyIncome, spaceCurrency, monthSeal/liveTable)` |
| shared → personal | `netSalaryOverride = toMajorUnits(resolvedOurIncome, profileMainCurrency, monthSeal/liveTable)` |

- Round half-away-from-zero, exactly once (010 house rule, research R5 there).
- Same currency both sides → carried verbatim (byte-identical; SC-006 "pre-move totals identical").
- Sealed month → convert against **that month's own seal**; open month → live table (FR-012: moving never changes sealed rates; the convert is a display-grade read through the same source).

## 4. Invariants

- **I1** — The personal pot is never read by the shared pot and vice versa; the resolution shape stays one rule.
- **I2** — Moved month reports its income under the space's pot (SC-007).
- **I3** — Labels only change on the personal side ("Net salary" → "My income"); no personal column changes meaning or type.
- **I4** — Shared override is stored as minor units only; personal override stays double (legacy).

## 5. Failure matrix

| Situation | Result |
|---|---|
| Space created; no months yet | "Our income" default = `SharedSpace.defaultIncome`; editable Owner-only |
| Month override absent in shared pot | falls back to the space default |
| Move with same currency | override carries verbatim |
| Move across currencies | one-cut conversion at the month's seal/live table; totals equal pre/post move via shared display pipeline |
| Settings opened in shared context | shows "Our income"; personal "My income" still editable via personal profile switch |