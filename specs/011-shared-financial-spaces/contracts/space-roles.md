# Contract: Shared-Space Roles & Enforcement

**Feature**: 011-shared-financial-spaces | **Owner**: `SpaceAccessGuard` (spaces feature) | **Storage**: `SharedMember`

---

## 1. Participants

| Participant | Role |
|---|---|
| **`SpaceAccessGuard`** | pure Dart gate — the **only** authority for shared-space writes; unit-tested matrix |
| **Repositories** (spaces, finance, expenses, medical) | call the guard inside every shared-space write txn |
| **`SharedMember`** rows | role + join date per (space, profile) |
| **UI** | hides disallowed controls for UX; **never** the security boundary |

## 2. Roles (normative)

| Role | View | Edit (money + month income) | Manage (space + people) |
|---|---|---|---|
| **Owner** | ✅ | ✅ | ✅ |
| **Editor** | ✅ | ✅ | ❌ |
| **Viewer** | ✅ | ❌ | ❌ |

- **View**: open the space, its months, expenses, medical bills, reimbursements, currency views — read-only (US4 AC1).
- **Edit**: add/update/delete a shared expense, medical bill, reimbursement, the month's income, convert-to (US4 AC2).
- **Manage**: rename space, change avatar/currency/income, invite (FR-002), change roles, remove a member, transfer ownership, delete the space (US4 AC3).

## 3. Operations (all enforce the guard)

```
canView(ctx, member)   → member != null && role ∈ {owner, editor, viewer}
canEdit(ctx, member)   → role ∈ {owner, editor}
canManage(ctx, member) → role == owner
```

Every write path: `if (!guard.canEdit/Manage) throw UnauthorizedSpaceAction`.

### Membership ops

- `invite(spaceId, profileId, role)` — Owner-only; creates `SharedMember` (FR-002: only the Owner invites; invite-only, no self-join).
- `setRole(spaceId, profileId, role)` — Owner-only; demoting the last Owner refused (FR-006).
- `removeMember(spaceId, profileId)` — Owner-only; rows are space-owned so nothing is orphaned (spec edge).
- `transferOwnership(spaceId, newOwner)` — same txn: newOwner→owner, formerOwner→editor (FR-014); former Owner may then stay or leave.
- `leaveSpace(profileId, spaceId)` — refused while the leaver is the **only** Owner (FR-006/US2 AC3).

## 4. Invariants

- **I1** — Enforcement lives at the data layer; no repository write reaches Isar without passing the guard (SC-005).
- **I2** — No two rows for the same (space, profile) (`@Index(unique: true)` composite).
- **I3** — A space always has ≥ 1 Owner (proved by tests: leave/demote/transfer paths).
- **I4** — Sealed past months are immutable for **every role** — the guard refuses even Owners (FR-012).
- **I5** — Exactly-one-context is a data-layer invariant too: a record with both contexts set, or neither, is refused (FR-003, SC-005).

## 5. Failure matrix

| Attempt | Result |
|---|---|
| Viewer adds/edits/deletes anything | refused by guard; nothing persisted |
| Editor renames space / changes roles / removes member / deletes space | refused |
| Non-member reads or writes a space | refused (canView fails) |
| Only Owner tries to leave or be demoted | refused; must transfer or delete first |
| Any role writes a sealed shared month | refused — past stays frozen |
| A write sets both profileId and sharedSpaceId (or neither) | refused by the invariant check |