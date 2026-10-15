# Contract: Context Router

**Feature**: 011-shared-financial-spaces | **Owner**: `budgetContextProvider` (core/providers) | **Storage**: `UserProfile` (selection), `SharedSpace` (active space), `selectedYearMonthProvider`

---

## 1. Participants

| Participant | Role |
|---|---|
| **`activeProfileIdProvider`** | `StateProvider<int?>` — the selected personal profile; persisted marker; fallback = lowest-id row (today's `profiles.first`) until user picks (R2) |
| **`activeSpaceIdProvider`** | `StateProvider<int?>` — null ⇒ personal context; non-null ⇒ the selected shared space |
| **`selectedYearMonthProvider`** | unchanged `StateProvider<String>` (app-global month, `selected_month_provider.dart:9-10`) |
| **`budgetContextProvider`** | derived `ContextRef { isShared, profileId?, spaceId?, yearMonth }` — the **single route** (FR-004) |
| **Every scoped provider/repository** | resolves through `budgetContextProvider`; no `yearMonth`-only queries in feature code |

## 2. Resolution (normative)

```
ContextRef:
  yearMonth = selectedYearMonthProvider
  isShared  = activeSpaceIdProvider != null
  spaceId   = activeSpaceIdProvider
  profileId = isShared ? null : activeProfileIdProvider
```

- **Personal context**: budget = `MonthlyBudget(profileId, yearMonth)`; streams = rows with `profileIdEqualTo(p)` + `yearMonth`.
- **Shared context**: budget = `MonthlyBudget(sharedSpaceId, yearMonth)`; streams = rows with `sharedSpaceIdEqualTo(s)` + `yearMonth`.

## 3. Operations

### `switchContext(to: ContextRef)` — must be instant and write-nothing-but-marker

1. Set `activeSpaceIdProvider` (or clear it for personal + set `activeProfileIdProvider`).
2. Update `lastActiveAt` on the profile (`UserProfile`), a marker-only write (SC-002 allows the active-context marker).
3. Every dependent stream re-derives synchronously (they all watch `budgetContextProvider`); **no month reload, no stored money write**.

### `setProfile(profileId)` / `setSpace(spaceId)` — the two public entry points

- `setSpace(null)` = back to the previous/selected personal profile.
- Switching never creates a month; `ensureMonth(contextRef, yearMonth)` provisions a budget on first navigation if absent (FR-011).

## 4. Invariants

- **I1** — One and only one route; a query not expressible as "ContextRef + filters" does not exist in feature code.
- **I2** — A context switch changes no stored record except the active-profile timestamp.
- **I3** — `expense_id`/`yearMonth`/`originYearMonth`/`budgetId` reads inside a context resolve to that context's rows only.
- **I4** — Rebuild completes within one frame (synchronous derived provider over watched streams, ≤ 1 s device, SC-002).
- **I5** — Theme/font/currency defaults resolve against the active *profile*; display currency resolves against the *space* when a space is active (`mainCurrencyProvider` reads the context, research R8). Neither leaks context data; both re-derive on switch.

## 5. Failure matrix

| Failure | Resulting state | User-visible effect |
|---|---|---|
| No profile exists (first launch) | onboarding `/setup` remains the router's initial location (`app_router.dart:34-37`) | create-first-profile flow, optional space |
| Two rows share a context+month (should be impossible) | unique composite indexes prevent it; worst-case the invariant check (SC-005) surfaces in tests | none — structural |
| Missing budget for the selected month | `ensureMonth(context, ym)` provisions a zero budget (FR-011) | normal month view |
| Selected profile deleted | `activeProfileIdProvider` falls back to lowest-id row | implicit switch, marker only |