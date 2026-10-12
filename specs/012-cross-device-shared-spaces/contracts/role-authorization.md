# Contract: Role Authorization (signed membership, enforced at apply-time)

**Feature**: 012-cross-device-shared-spaces
**Covers**: FR-008, FR-009, FR-011, SC-005 · **Design**: research R5, R6

No server, so authorization is derived from **signed, HLC-versioned** membership on every device. 011's role matrix is unchanged; only its enforcement point widens to the apply path.

---

## 1. Role Matrix (inherited verbatim from 011 `contracts/space-roles.md`)

| Action | Owner | Editor | Viewer |
|---|---|---|---|
| View space + months | ✅ | ✅ | ✅ |
| Add/edit expenses, reimburse (unsealed month) | ✅ | ✅ | ❌ |
| Manage directories / medical in space | ✅ | ✅ | ❌ |
| Rename space / change currency / add or change roles / remove members | ✅ | ❌ | ❌ |
| Transfer ownership | ✅ | ❌ | ❌ |
| Seal a month | ✅ | ✅ | ❌ |
| Leave space | ✅ (if not last Owner) | ✅ | ✅ |

Enforced locally by `SpaceAccessGuard.canView/canEdit/canManage` (`space_role_guard.dart:27-104`).

## 2. Signed, Versioned Membership

- `SharedMember` carries `version` (HLC), `updatedAt`, `authorIdentityId`, `signature`, `revokedAt` (R5).
- Every membership change is signed by the acting **Owner** and rides the change-log.
- Removals set `revokedAt` + a new HLC `version` (authoritative removal, no cooperation needed by the removed device). Demotion is just a role change at a higher HLC.

## 3. Apply-Time Enforcement (new)

For every incoming change:

```
verify signature (author public key, known from pairing)
assertAuthorizedAt(change, membershipHead):
    author = membership(change.authorIdentityId)
    require author != null AND author.revokedAt == null (as of change.hlc)
    require author.role permitted the change.entityType/op at change.hlc
        (e.g. expenses/directories ⇒ owner|editor; membership/space ⇒ owner only)
    require month not sealed (if the change targets a month)
else: drop the change (log + conflictCount++)
```

- A change authored **after** an effective `revokedAt` is refused **everywhere** (FR-008, SC-005).
- A Viewer's money-directory change is refused even if it reaches a device (FR-009).
- 011's `assertMonthEditable` refuses all sealed-month content edits on both local and apply paths (FR-011, R6).

## 4. Ownership Transfer & Last-Owner Invariant

- Transfer = a signed change promoting the new Owner and demoting the former Owner to Editor (011 FR-014); ordered by HLC so both devices converge to one Owner.
- A space always keeps **≥ 1 non-revoked Owner**; removal/leave of the last Owner is refused (011 FR-006).

## 5. Failure & Edge Cases

| Case | Behavior |
|---|---|
| Tampered membership record | Signature fails ⇒ dropped; local membership head unchanged |
| Removed member edits locally | Their device may show it locally, but **no peer ever applies** it (FR-008); re-sync never imports it |
| Concurrent role changes | Higher HLC wins on all devices |
| Unauthorized action authored offline | Applied nowhere (refused at apply-time) |
| Sealed-month edit (any role) | Refused locally and at apply-time (FR-011) |

## 6. Non-Goals

No central ACL store · no server-side revocation list · no cooperation requirement from the removed device (removal is authoritative via signed history).
