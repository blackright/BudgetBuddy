# Quickstart Validation Guide: Multi-User Profiles & Shared Financial Spaces (Unified)

**Feature**: 011-shared-financial-spaces | **Purpose**: prove the feature works end-to-end before merge. Validation only — implementation details live in `tasks.md`.

---

## Prerequisites

- Flutter 3.47.6 stable on PATH; `flutter pub get` succeeds.
- Codegen up to date: `dart run build_runner build --delete-conflicting-outputs` (required after any model change).
- A device/emulator (offline scenarios: airplane-mode toggle; month rollover: system date control or seeded date).

## Commands (from repo root)

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart format --output=none --set-exit-if-changed .
flutter analyze          # expected: 0 new issues
flutter test             # expected: all green (includes the CI step already added in 010)
```

---

## Scenario matrix

### V1 — Multi-profile isolation (automated)

Run `flutter test`. Expected:
- New context-isolation tests green: profile A's rows are unreadable from profile B and from any space **in 100% of cross-context tests** (SC-001); the exactly-one-context write invariant refuses both/null-context records (SC-005).
- Migration tests (real-Isar harness): upgrading an existing database assigns every existing month to the (single) active personal profile; **no amount, seal or month total changes** (SC-003); step 13 idempotent on re-run.
- Existing suite remains green (357 test cases as of planning).

### V2 — Context switching (manual)

1. With a profile and a space both present, switch profile → space → profile.
2. Expected: every screen (dashboard, expenses, medical, dashboard currency, settings income pot, analytics placeholder) shows the newly active context **within 1 s** and within one frame of the switch (SC-002); the only stored change is the active-context marker (profile `lastActiveAt`).

### V3 — Create a space, invite, role behaviour (manual, mirrors US2/US4)

1. Create a space (name + emoji avatar), pick currency + "Our income", choose bring-in-past.
2. Invite a second profile as **Viewer**; verify the Viewer opens the space and sees everything but no add/edit/delete control **and** no repository write path grants it (SC-005 — try a forced write via the guard test, not just the UI).
3. Invite a third as **Editor**; editor adds a shared expense and confirms the shared totals update **immediately, no approval step** (FR-018) and both people see the same updated single copy (US3).
4. Editor attempts rename/role-change/remove/delete → refused (US4 AC2).

### V4 — Move a whole month (manual, mirrors US3)

1. Build a complete personal month (income, expenses, medical bill, reimbursement). Move it into the space.
2. Expected: the month appears in **exactly one** room with the same income figure reported under "Our income" (FR-008/SC-007); pre-move totals identical post-move (SC-006); moving that same year-month into the target again is blocked with a clear message (FR-010).
3. Move a **sealed past** month: allowed, numbers identical, still frozen for every role (US4 AC4/US5 AC4).

### V5 — Space deletion, per-month prompt (manual, mirrors FR-014)

1. Space holds two months. Delete the space: the "Delete <space>" sheet lists each month; choose **Move to profile A** for month 1 and **Delete this month** for month 2.
2. Expected: month 1 reappears under the chosen personal profile; month 2 is gone; member profiles untouched.
3. Once no month remains, **Continue** opens the GitHub-style typed-name dialog. Delete stays disabled until the typed name matches the space name exactly; confirming removes the space and its members atomically (no half-state).
4. Interrupt the flow (leave after resolving only month 1): reopen settings → the space is still deletable and the remaining months reappear — the flow is resumable.
5. Deleting an **empty** space (owns no months) skips the month sheet and goes straight to the typed-name dialog. An Editor/Viewer is refused at the data layer.

### V6 — Income pots independence (manual)

1. In the profile set "My income" with a per-month override; in the space set a different "Our income" + override.
2. Expected: personal dashboard uses My income, space dashboard uses Our income; **never** the other (SC-007). Labels read "My income"/"Our income" (FR-009); personal columns unchanged.

### V7 — Future months appear automatically (manual; mirrors US5)

1. Create a space with "this month only"; advance device month; reopen.
2. Expected: the new month appears in the space with no action (FR-011) and behaves like a personal month (seal applies; SC-004).
3. Repeat for "this year so far" (this-year months present, older absent) and "everything".
4. **How to bring a month in by hand**: a brand-new space whose creator has no current personal month owns **nothing** — opening it shows no month until one is brought in. From a personal profile's dashboard use "Move this month" and pick the space; the space then owns ≥1 month and later months accrue automatically (FR-011). Bringing in a month the space already owns is refused with a clear message (FR-010).

### V8 — Offline-everything (manual; mirrors FR-016)

Airplane mode ON: create a second profile, switch contexts, invite a profile, move a month, delete a space. Expected: every operation succeeds with zero network.

### V9 — Analytics placeholder (manual; mirrors FR-015/SC-008)

1. Open the dashboard in a personal profile → visible Analytics placeholder section, compute-nothing.
2. Open a space's dashboard → placeholder present and distinct; switch context → re-renders with the active context, no numbers from the previous context linger.

### V10 — Vault stays personal (manual; mirrors FR-017)

Confirm no shared-space screen offers or accepts vault data; vault queries remain `profileIdEqualTo`-scoped. (No UI exists yet — covered by `vault_repository` scope test.)

### V11 — Delete a personal profile (manual; mirrors FR-019/SC-009)

1. Create a second profile "Bea" with some data (a month with an expense, a medical bill, a reimbursement, and a vault sweep). In Settings ▸ Profiles, open Bea's **⋮** menu → **Delete profile**.
2. Expected: the confirmation lists what will be deleted (counts) and requires typing "Bea" exactly; **Delete** stays disabled until the name matches. Confirming removes Bea — her personal rows and space memberships are gone; a shared space she was **not** the only Owner of stays intact; another profile's data is untouched.
3. If Bea is the **only** profile, her tile shows **no** ⋮ delete control (the last profile can never be deleted). If Bea is the **sole Owner** of a space, deletion is refused with a message naming that space (transfer ownership or delete the space first).
4. Delete the **active** profile: after deletion the app falls back to a surviving profile and clears any active space — no screen is left pointing at the deleted profile.
5. Automated: `flutter test` — `profile_deletion_test.dart` (cascade + refusals), `profile_deletion_widget_test.dart` (affordance + typed-name gate), and the `T075` ownership group in `role_guard_matrix_test.dart` are green.