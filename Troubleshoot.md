# Beginner-Friendly Coding Error Investigator and Fix Planner

## 1. Your Role

You are my friendly, patient, and highly skilled coding coach, software engineer, and debugging specialist.

Your job is to help me understand and fix coding errors in a professional way while explaining everything in simple, beginner-friendly English.

Assume that I may not understand advanced programming concepts. Explain technical problems as if you were teaching someone who is learning to code for the first time. Use everyday examples and analogies when they make an explanation clearer, but maintain technical accuracy.

Your goal is not simply to make the error disappear. Your goal is to identify the real cause, explain why it happened, and propose a reliable solution that fixes the underlying problem without introducing new bugs or security weaknesses.

## 2. Critical Approval Gate — No Exceptions

**You MUST stop and wait for my explicit approval before taking any action that executes code, runs commands, or modifies files.**

Before approval, you may inspect the error message, logs, code, and other information already provided in the conversation.

If additional information is necessary, you may request permission to perform read-only inspection or ask me to provide the relevant files, logs, and command output.

Until I explicitly reply with **"Approved"** or **"Proceed"**, you must NOT:

- Modify, create, delete, overwrite, or reformat files.
- Run application code, scripts, tests, builds, or terminal commands.
- Install, uninstall, or update dependencies.
- Change environment variables, system settings, configuration, or database contents.
- Execute commands that may have side effects.
- Apply patches or automatically fix the problem.
- Start implementing any part of your proposed solution.

Do not interpret my questions, acknowledgements, or requests for clarification as approval to implement the fix.

Your first response must contain your diagnosis, proposed solution, and implementation plan, based on the evidence available. Then stop and wait.

If the root cause cannot yet be established, explain what is known, what remains uncertain, and what additional evidence is needed. Never invent a diagnosis simply to provide a confident answer.

## 3. Investigation Principles

Follow these principles whenever you analyze a coding error.

### A. Understand the actual error

- Read the complete error message, including the relevant stack trace and surrounding context.
- Identify what operation failed and where the failure occurred.
- Distinguish the location where an error appeared from the underlying cause.
- Determine whether the problem is caused by the code, configuration, dependencies, environment, incorrect input, or an interaction between components.
- Consider whether the error is a symptom of an earlier failure.

### B. Use evidence, not assumptions

- Base conclusions on the actual error, code, logs, and configuration provided or legitimately inspected.
- Identify the specific function, file, component, or dependency involved whenever possible.
- Clearly distinguish confirmed causes from likely explanations and unverified possibilities.
- If multiple causes are plausible, rank them by likelihood and explain what evidence would distinguish them.
- Never claim to have inspected a file, run a command, or verified a fix unless you actually did so.

### C. Choose the correct fix

Recommend the smallest complete change that resolves the underlying problem safely.

Prefer solutions that:

- Follow official documentation for the relevant language, framework, and dependency versions.
- Follow the project's existing architecture and coding conventions.
- Preserve existing functionality and compatibility.
- Handle relevant edge cases and failure conditions.
- Include suitable error handling and input validation where needed.
- Avoid introducing security vulnerabilities.
- Include regression tests where appropriate.
- Do not introduce unnecessary abstractions, dependencies, or architectural changes.

Do not choose a quick workaround simply because it makes the error disappear. Explain when a temporary workaround is acceptable and what limitations it has.

### D. Protect existing work

Treat all existing code and user changes as valuable.

Before proposing changes, identify which files are likely to be affected and whether the proposed fix could influence other features.

Do not recommend deleting or replacing an entire file when a small, targeted change is sufficient.

If a fix requires a database migration, dependency change, data modification, or other potentially disruptive operation, explain the risk and include it in the approval plan.

### E. Verify after approval

Once I approve implementation, work only within the approved scope.

- Re-examine the relevant code before modifying it.
- Implement the approved fix without unrelated refactoring.
- Add or update tests when appropriate.
- Run only the commands and checks authorized by my approval.
- Report the actual results.
- If a test fails, investigate the new failure rather than hiding it.
- Do not claim that the problem is fixed until the relevant verification has succeeded.
- If the proposed fix proves incorrect or requires a materially different approach, stop and explain the revised plan before making additional changes outside the approved scope.

Approval for one fix does not authorize unrelated modifications.

## 4. Required Response Format

Your first response must follow the structure below. Use simple language, but provide enough technical detail to make the proposed solution trustworthy.

### 🔍 1. What Happened? (The Error)

**The Oopsie:**

Explain what went wrong in plain English. Imagine that I am new to programming and have never encountered this error before.

Use a short, everyday analogy when useful. For example, explain a missing dependency as a missing ingredient in a recipe or a failed connection as a phone trying to call a number that cannot be reached.

Do not use an analogy if it would make the technical explanation less accurate.

**Why It Happened:**

Explain the technical root cause in simple language.

Include:

- The specific operation that failed.
- The relevant file, function, component, or configuration, if known.
- The chain of events that led to the error.
- The evidence supporting the diagnosis.
- Any uncertainty that remains.

If the root cause is not yet confirmed, say so explicitly. Do not present a guess as a fact.

### 🛠️ 2. The Fix-It Plan

**The Smartest Fix:**

Describe the recommended solution and explain why it addresses the root cause.

Explain:

- What must change.
- Why the change is necessary.
- Why this solution is preferable to alternatives.
- How it preserves existing behavior.
- Whether it introduces compatibility, security, or data-related risks.
- How we will verify that it works.

Keep the explanation understandable to a beginner while retaining technical precision.

**Other Ideas I Tossed Out:**

Briefly describe at least one plausible alternative or quick workaround that you considered but do not recommend.

Explain in one or two simple sentences why it is less suitable, incomplete, riskier, or likely to hide the underlying problem.

Do not invent a bad alternative just to fill this section. If no meaningful alternative exists, explain that briefly.

### 📋 3. Step-by-Step To-Do List

Provide a numbered implementation plan in the exact order the work should be performed.

For each step, specify:

1. **File or component:** The actual path, or the path that needs to be identified.
2. **Required change:** What must be modified and why.
3. **Expected result:** What should happen after the change.
4. **Verification:** How we will confirm the step worked.

Include, where relevant:

- Files that need to be inspected or modified.
- Code changes and any important implementation details.
- Configuration or dependency changes.
- Tests to add or update.
- Commands or checks proposed for after approval.
- Potential side effects and rollback considerations.

Do not fabricate file paths or pretend to know the contents of files you have not inspected. Clearly label any path or implementation detail that still needs confirmation.

Separate mandatory changes from optional improvements. Do not expand the scope with unrelated refactoring.

### 🛑 4. STOP — WAITING FOR YOUR APPROVAL

End your first response with this exact message:

**I have not changed any files or run any commands.**

Please review the explanation and proposed plan above. If you approve the proposed work, reply with **Approved** or **Proceed**. I will then carry out only the approved changes, verify the result, and report what happened.

If anything is unclear, ask me questions before approving.

Do not continue with implementation until I explicitly approve.

---

## 5. After Approval: Implementation and Verification

Once I reply with "Approved" or "Proceed":

1. Confirm the approved scope.
2. Inspect the relevant files and current implementation.
3. Make the smallest complete change that addresses the confirmed cause.
4. Preserve unrelated functionality and existing user changes.
5. Add or update relevant tests.
6. Run appropriate authorized checks.
7. Review the resulting changes for regressions and security issues.
8. Report the files changed, the reason for each change, and the tests performed.
9. Explain the outcome in beginner-friendly language.
10. If the fix fails or reveals a different underlying problem, stop and present a revised diagnosis and plan before proceeding beyond the original approval.

Never claim success without evidence. If verification is incomplete, clearly explain what remains untested.

## 6. Error Information

Analyze the error information provided below. Use all relevant context, but do not assume that the supplied information is complete.

If the error cannot be diagnosed reliably from the information available, ask for the smallest amount of additional information necessary.

Do not begin implementation merely because additional information is needed.

### Context and Code Error

[



]

### End of Error Information
---

## Phase 6.1f Verification Report — 2026-10-23

### Confirmed issues

1. Formula explanation: the detail screen subtracted Borrowed so far separately, while MonthSummary.kept already includes the associated expense in Paid out. The displayed breakdown could disagree with the total.
2. Display currency: the detail screen formatted summary amounts with mainCurrencyProvider even when the selected month used a different display currency. Already-converted USD figures could be labelled as HUF.
3. Carry-over sign: the detail row displayed a minus sign for both positive and negative carry-over values.

### Reproduction and expected behavior

1. Set the main currency to HUF and the month's display currency to USD. Open Dashboard, then tap Kept this month. Expected: the same USD amounts as the dashboard, without a second conversion. Actual before correction: the detail used the main-currency label.
2. Use a summary with income 4,000, paid out 1,200, returned 300, set aside 800, carry-over 100, and borrowing greater than zero. Expected: Kept = 2,200; borrowing is informational and already included in paid out. Actual before correction: the explanatory formula showed an additional borrowing deduction.
3. Supply carry-over -50 in a widget-test fixture. Expected: the contribution is shown as +50 because the formula subtracts carry-over. Actual before correction: the row showed -50. Carry-over policy processing remains Phase 8 work and was not implemented here.

### Errors and verification evidence

- Before the correction, regression tests failed to find the expected USD detail amounts and the positive contribution for negative carry-over.
- Corrected the display-currency resolution to match monthSummaryProvider; retained already-converted amounts.
- Corrected the formula text and removed the borrowing deduction marker; added an explanation that borrowing is already included in paid out.
- Corrected the carry-over contribution's sign and semantic color.
- Verified the info dialog does not navigate, tapping the card body opens the detail, Back returns to Dashboard, and all specified drilldowns reach their destinations.
- Passed: flutter test --no-pub test/core/routing/expenses_navigation_test.dart test/features/engine/month_summary_test.dart — 45 tests (17 navigation/screen tests and 28 calculation tests).
- Passed: targeted flutter analyze --no-pub on the detail screen and navigation test — no issues found.
- Passed: Dart formatting check on those two files — zero further changes required.
- A sandbox-only Dart telemetry-file permission error occurred after the initial formatter had formatted both files; the approved elevated formatting check subsequently exited successfully.
- No device run, APK build, or full-project analysis was performed in this verification.

### Current status

Corrections implemented and targeted checks passed. The project owner explicitly accepted Phase 6.1f on 2026-10-23; T171, T172, and T173 are now marked complete. Manual device testing has not been reported. Phase 7 has not been implemented. No dependency, schema, persistent financial-data, authentication, or Git changes were made for these corrections.

---

## Phase 7 Refund and Profile Identity Verification — 2026-10-23

### Confirmed issues and reproduction

1. Partial returns were excluded as whole expenses in per-profile spending. Reproduce with a paid expense of 130,000 HUF and a 25,000 HUF return. Expected net spending: 105,000 HUF. Actual previous profile calculation: the partial-return status did not count as spending. Corrected the shared calculation and its dashboard, reserve, allocation, profile-cache and month-summary set-aside callers. Gross-payment/return summary accounting remains separate.
2. Budget and Direct profiles have independent numeric IDs, while Expense previously stored only budgetProfileId. Reproduce with Budget ID 1 and Direct ID 1 in the same month/context. Expected: the selected collection receives the expense and refund. Actual previous picker/routes/calculations could choose or count the wrong collection. The owner explicitly approved the schema expansion. Added financialProfileType and financialProfileSyncGuid, regenerated Expense schema, and updated picker, dashboard pill identity, navigation, calculations and expense sync. Version 23 fills only unique references; ambiguous references remain for explicit user confirmation on Expense Details. Refund writes reject unresolved financial references instead of guessing.
3. Replaying historic migration steps during a version 22→23 upgrade could clear the existing signed change journal. Expected: an additive profile identity upgrade preserves journal and financial data. The version 22→23 path now executes only step 23. An isolated database regression test verifies preservation and migration idempotency.
4. Direct-profile deficit capacity previously used a reserve already reduced by that profile's own spending, charging the same spending twice. Expected: compare direct spending with reserve capacity before that profile's own spending. Corrected that capacity and tested before/after refund behavior. Negative reserve no longer produces negative borrowing.
5. A legacy fully-returned expense without detailed ledger rows could display a positive refundable balance. Expected: preserve the fully-returned status meaning and clearly explain the missing legacy detail. The service now reports zero remaining; the summary card explains the legacy status; another refund is rejected.

### Verification errors corrected

- Initial service/calculation tests failed while the new implementation did not yet exist.
- Initial isolated database teardown found a nonempty fixture directory; cleanup is now restricted to the verified test-specific temporary directory.
- Month-summary provider regression fixtures lacked the context/profile overrides required by the new live spending reads; corrected fixtures, not production authorization.
- The first identity-extension test compile found an incorrect SyncRecorder database field reference; corrected to the existing private field.
- The existing vault migration test lacked the Isar import required for query extension methods; added the import.
- Initial analysis reported style issues; all were corrected. No tests were disabled.
- Isar's existing generator warned about the older analyzer package versus the current Dart SDK. Generation succeeded; no dependency upgrades were performed.

### Final verification evidence

- Passed: final authorized regression suite — 166 tests, exit code 0. Covers core service math and Isar transactions, version 23 preservation/ambiguity handling, existing schema/vault migrations, expense navigation, month summaries/providers, reimbursement attribution, refund UI, reimbursement sheet, expenses screen, medical navigation, finance refund providers and sync codecs.
- Passed: targeted flutter analyze --no-pub — 35 source/test files, no issues, exit code 0.
- Passed: Dart formatting on those 35 source/test files.
- Passed: Expense database code generation with the installed build_runner/isar_generator and a filter restricted to expense.g.dart.
- Tested rejection: overage including existing returns, concurrent submissions, another owner/month, viewer, sealed shared month, unsupported currency, unresolved profile identity and invalid repair target.
- Tested atomic rollback on audit failure and sync-journal failure; verified actual Ed25519 signatures on shared refund/expense changes.
- Tested Budget/Direct ID collisions in transaction recording, picker selection and dashboard pill expansion; tested portable GUID resolution to a different numeric local ID.
- Not run: APK/platform build, full-project analysis, actual-device/emulator UI, live paired-device exchange or migration of the user's actual application database.

### Current status

Phase 7 implementation and approved profile identity expansion are implemented and targeted automated verification passes. T057–T061 remain unchecked pending explicit acceptance of this verified work. No later phase was started. Phase 6.1f remains accepted and T171–T173 remain checked. No dependencies were added/upgraded and no Git operations were performed. Full feature-wide audit signing/verification remains Phase 9 work. Missing remote profile targets retain their GUID pending resolution; this phase does not add a separate profile-entity sync system. Manual testing and acceptance remain pending.

Full file manifest, explanations, security review, official references and manual testing guide: specs/018-financial-core-audit/phase-7-report.md.
## Phase 7 Acceptance — 2026-10-23

The project owner explicitly approved the verified Phase 7 implementation and its approved profile identity expansion. T057–T061 are now marked complete in specs/018-financial-core-audit/tasks.md. Verification remains 166 passing tests, clean targeted analysis on 35 files, and a clean formatting check. No manual device-test results were supplied by this approval; previously listed unrun checks remain unrun. No later phase has started. Work is stopped pending separate instructions.
## Phase 8 Month-End Policies — 2026-10-23

### Confirmed issues and resolutions

1. Unused allocation could otherwise be counted as both outgoing carry and spendable source reserve. Reproduce by closing a 100,000 HUF allocation with 80,000 HUF net spending. Expected: 20,000 HUF goes to the chosen Reset release or next-month carry exactly once. Added common settlement balances to reserve, summary and refund calculations. Late source spending clamps remaining Reset credit and reserves committed carry shortfalls. Saved reports remain immutable.
2. Profile sync could arrive before its funding plan or overwrite a conflicting plan. Reproduce signed profile-before-run replay or two different offline confirmations. Expected: atomic funding with no second carry. Profile projection now waits for its matching signed run; conflicting plans are flagged and block future closes. Automatic conflict correction remains outside this phase.
3. Personal and shared contexts could share the same textual identity. Expected: isolated settlement and destination keys. Added context-kind namespacing and a collision regression test.
4. Legacy month move/delete and profile deletion did not account for settlement records. Expected: no detached funding or orphaned personal history. Both legs of saved settlements are protected from month move/delete, personal deletion cascades its records, and shared financial-history guards include settlement records.
5. Narrow dashboard title and Month-End dropdown layouts overflowed in widget tests. Expected: readable phone layouts. Added Flexible title layout and expanded dropdown content; phone-width assertions pass.

### Verification errors corrected

Initial implementation tests failed before their services existed. Subsequent fixture failures involved missing schemas, provider overrides, a required Vault timestamp and the new codec count. Corrected fixtures and imports without weakening authorization or assertions. Corrected style warnings and widget scroll targeting. No tests were disabled. Existing Isar generation warned about older analyzer language support versus the installed SDK; generation succeeded without upgrading dependencies.

### Final verification evidence

- Passed: 313 tests, exit code 0; build/phase8-final-tests.log.
- Passed: targeted flutter analyze --no-pub on 44 source/test files, no issues.
- Passed: Dart formatting on those files and filtered generation of budget_profile.g.dart and month_end_run.g.dart.
- Coverage includes financial arithmetic, preview/confirm, stale and concurrent submissions, audit/journal rollback, Owner permissions, signed replay, context isolation, conflict handling, vault exclusion, source/destination lifecycle guards and UI regressions.
- Migration coverage simulates a version-23 stamp on a current-schema isolated database; an actual older-schema native database file upgrade was not run.
- Not run: APK/platform build, full-project analysis, actual-device/emulator UI or live paired-device exchange. Both sync peers require updated codecs.

### Current status

Phase 8 is implemented and automated checks pass. T062–T068 remain unchecked pending owner acceptance. Manual testing is pending. No later phase, Git operation, dependency change, deployment or actual application-database modification was performed. No known failing automated checks remain. Saved conflicts, a previously advanced vault cursor, and sealed destinations require review; no automatic correction/reopen workflow was added.

Full file manifest, official references, limitations and manual guide: specs/018-financial-core-audit/phase-8-report.md.
## Phase 8 allocation text and amount display correction — 2026-10-23

Reported: Edit Allocation displayed corrupted dash characters and loaded amounts without thousands separators. Reproduction: open Allocations, choose Edit for an allocation of 1000000. Expected: clean title and 1,000,000. Actual: a corrupted title literal and an ungrouped controller value. Flutter input formatters only run for user edits, so the existing formatter did not format the initial value. Month-End defaults also lacked live input formatting; Edit Profile had the same initial allocation display issue.

The owner approved the correction plan. Replaced both corrupted allocation-screen text literals with plain punctuation. Added exact integer-based formatMinorUnitsInput to the existing shared money formatter; Allocations, Edit Profile and Month-End use it for initial values. Month-End uses the existing ThousandsSeparatorInputFormatter for typing. Currency precision and existing save/calculation behavior remain unchanged. No migration, dependency or actual application-data changes were made.

Changed code: lib/shared/presentation/money_format.dart; lib/features/finance/presentation/allocations_screen.dart; lib/features/finance/presentation/profiles_screen.dart; lib/features/finance/presentation/month_end_screen.dart. Tests: test/shared/presentation/money_format_test.dart; test/features/finance/month_end_screen_test.dart; new test/features/finance/allocation_amount_format_test.dart.

Verification: 37 focused tests passed, exit 0, covering existing formatter behavior, exact HUF/USD/EUR/CAD values, loaded/typed allocation grouping, clean dialog title, cancellation preserving allocation, and Month-End reading a grouped default as the correct integer amount. Initial new widget fixture used an unsupported StateProvider overrideWithValue; corrected to overrideWith and reran successfully. Seven changed Dart files formatted successfully. Static analysis result is recorded below. No device/emulator test was performed. Correction awaits owner review.

Manual check: open Allocations → Edit. Expect Edit allocation: [profile name], no corrupted characters, and 1,000,000 for a million-HUF allocation. Type 2345678; expect 2,345,678. Cancel first and verify no amount changes. Check Edit Profile and Month-End defaults for the same grouping; USD/EUR/CAD retain two decimal places.
Final correction analysis: flutter analyze --no-pub on all seven changed source/test files passed with no issues, exit code 0.

## Phase 8 Acceptance and Phase 8.1a Planning — 2026-10-23

The owner explicitly accepted Phase 8 and its verified allocation display correction. T062–T068 are now checked in specs/018-financial-core-audit/tasks.md. Evidence remains 313 Phase 8 regression tests and 37 focused correction tests, clean targeted analysis and formatting; no additional tests or manual-device outcomes are claimed by this documentation update.

The owner requested Phase 8.1a for Savings Vault and a check for prior planning. Savings Vault was already planned and marked completed as T160 in Phase 6.1e. Inspection confirms existing model/repository/provider, personal-only screen, Settings navigation, route, sweep and Phase 8 settlement coordination. Created a Phase 8.1a discovery/planning section with unchecked T174–T175. Enhancement scope awaits owner choices and plan approval. No application code or future-phase implementation changed.
## Phase 8.1a Savings Vault Reliability, History & Goal — 2026-10-23

### Confirmed problem and reproduction

With the saved cursor at August, process a valid August month, then encounter an unconfirmed September opening balance. The previous sweep saved August's increased vault total when pausing but kept the old cursor. A retry could add August again. Expected: August is committed once and the cursor remains at September. Confirmed by source inspection; the new isolated regression exercises a successful month, a paused month, retries and four overlapping checks.

### Approved resolution

Each processed month now atomically reads its financial inputs and writes contribution history, vault balance and next-month cursor. Missing months advance without invented contributions; zero-saving processed months retain a reason. Duplicate keys and transactional rereads prevent overlapping checks from repeating a contribution. Migration 25 preserves existing totals/currency/cursor and adds one labeled opening-history entry. Existing inaccurate balances are not silently repaired.

The approved phase also adds expandable saved calculations/conversion evidence, structured check outcomes, an informational goal, a personal dashboard card and scoped history deletion. Deposits and withdrawals remain Phase 8.1b. No dependencies were changed and no Git operations were performed.

### Implementation verification issues corrected

- Corrected a new deletion test's local helper declaration order.
- Initialized native Isar widget streams outside the simulated frame clock; retained UI assertions and real database writes.
- Corrected the conversion fixture to update the existing Riverpod override set.
- Updated three stale schema-version expectations to 25 without removing financial-preservation or sync-conflict assertions.
- Fixed style warnings and an unused test import.
- Actual native tests rejected the generated ID-sort query with Unknown property id. History uses saved time/source month instead; final native query tests pass.
- Filtered code generation succeeded with the existing analyzer/SDK compatibility warning. No dependency upgrade was performed.

### Final verification

- Passed: 216 tests, exit 0; build/phase8-1a-tests.log. Includes vault service/UI, deletion, all core database tests, Month-End service/report/UI/summary and all sync tests.
- Passed: analysis of all 22 changed source/test files; separate lifecycle caller analysis of lib/main.dart; no issues.
- Passed: final Dart formatting check, 22 files, 0 changed; filtered vault model code generation.
- Tested: partial-progress retry, overlapping checks, injected transaction rollback, migration/opening-history idempotency, currencies, partial refunds, saved conversion evidence, unsupported currency refusal, goal validation/ownership, carry exclusion, profile deletion isolation, phone layout and card navigation.
- Not run: platform/APK build, full-project analysis, actual device/emulator, live paired-device exchange or an actual older-schema native database file upgrade. Migration tests simulate an older stamp on an isolated current-schema database. No actual app data was changed by the tests.

### Current status and manual guide

Implemented and verified; T174–T183 remain unchecked awaiting owner acceptance. Phase 8.1b and later phases have not started. No tests were disabled or assertions weakened. No known failing automated checks remain.

In the updated app, open the personal dashboard card below Allocation or Settings → Savings Vault. Check opening history and grouped amounts. Add/edit/remove a goal and verify savings do not change. Check finished months and inspect the actual ADDED/PAUSED/UNCHANGED result, calculation detail and duplicate-safe retry. Verify another profile has separate data and shared spaces hide/block the vault. October is unfinished on 2026-10-23; do not change the clock or database to force a sweep.

Full exact file manifest, architecture/security review, official sources, limitations and numbered manual steps: specs/018-financial-core-audit/phase-8.1a-report.md.
## Phase 8.1a reported invalid Saved / Opening balance — 2026-10-23

Reported: Saved and Opening balance displayed -Ft --9,223,372,036,854,775,808. Reproduction now uses a REAL older-schema native vault database: write the legacy-only shape, close it, reopen with the current schema. Absent totalMinor is Isar's minimum integer, not the Dart initializer zero. The old step 22 skipped conversion because it tested only zero and could then clear the legacy amount. Step 25 copied the invalid value into opening history. Native abs() explains the double minus.

Approved correction: recognize missing integers during legacy conversion, consume only successfully converted finite/bounded evidence, reject invalid balances/history, check bounds before arithmetic/conversion, reconcile saved calculations and running history, and never display the marker as money. Invalid existing values are preserved; no automatic guessed-zero repair occurs.

Actual phone investigation: debug phone accessible read-only through ADB. Before/after phone checksums matched the binary-safe local snapshot. Original snapshot is preserved in ignored build/vault-diagnostics. Inspection and recovery rehearsal used a separate disposable analysis copy. The phone records show one personal HUF vault/opening with the marker and zero recorded saving for completed personal August/September 2026 (confirmed zero openings, no expenses/returns/carry). October is unfinished, later months are future, and the Ft 1,000,000 opening belongs to the shared space. Therefore the recorded completed personal data supports Ft 0.

The owner explicitly approved a one-time in-app recovery preview/confirmation. Implemented a narrow matching-case service and dialog: revalidate all evidence/owner/fingerprint inside one transaction, update the two invalid records to zero, retain original values/metadata as recovery JSON, and leave source monthly/shared funds untouched. Rehearsal on the local analysis copy passed with financial rows unchanged. The phone itself has NOT been repaired; its user confirmation is pending.

Verification: 258 tests passed, exit 0, build/phase8-1a-correction-final-tests.log; clean targeted analysis on 30 source/test files; zero-change formatting; filtered schema/legacy-fixture generation passed. Native older-schema tests cover all four currencies; regressions cover sentinel display, non-finite/excessive values, overflow, invalid evidence, recovery cancellation, stale and duplicate submissions, concurrent confirmation, owner switching and rollback. No tests disabled, dependencies upgraded, Git operations or database resets performed. APK build status is recorded below after completion.

Full corrected findings, file list, formulas, limitations, approvals and manual recovery guide: specs/018-financial-core-audit/phase-8.1a-correction-report.md. T174–T183 remain unchecked; Phase 8.1b remains deferred.

## Final Android build update — 2026-10-23

Passed: flutter build apk --debug --no-pub, exit 0. Artifact: build/app/outputs/flutter-apk/app-debug.apk. SHA-256: c0a6b7b7e226b2ee2f8961321b8bfbdd36a0e01ce4ed0bd9cff375c9f7a17a40. Gradle assembleDebug completed in 80.8 seconds. Existing plugin Kotlin Gradle compatibility warnings concern future Flutter versions; this build succeeded without dependency upgrades. No APK was installed and no recovery was executed on the phone. Installation permission and explicit in-app confirmation remain pending.

## Approved startup and resume corrections — 2026-10-23

The owner's pasted flutter run log shows a successful build, installation and launch, skipped frames, future compatibility warnings and biometric success messages. It does not show a Dart exception or fatal Android crash. It does not establish the cause of the skipped frames or whether the in-app vault recovery was confirmed. The owner's later flutter run installation supersedes the earlier statement that installation was pending; no installation was performed by the agent.

Read-only investigation found two independent weaknesses, followed by explicit owner approval to fix them and run focused checks:

- lib/features/engine/seal_coordinator.dart: overlapping runSealPass callers now share one in-flight future, using the first caller's timestamp. Completion or failure releases the guard so later calls can run again. Existing month calculations, fallback rates and immutable-seal rules remain in place. This guard covers runSealPass, not the separate closeCurrentMonth API.
- lib/main.dart: a failed money-integrity scan now shows a clear error and Retry button instead of a permanent spinner. Retry invalidates the scan provider and shows loading while the new scan runs. Financial routing remains inaccessible during scan failure or loading, and raw database errors are not displayed.
- test/features/engine/seal_concurrency_test.dart: native database regressions cover overlapping calls, one monthly attempt, subsequent passes, shared failures and guard release after failure.
- test/startup_integrity_test.dart: widget regression covers failure, a fresh scan on Retry, loading, repeated failure and blocked financial routing throughout.

Verification: flutter test --no-pub test/features/engine/seal_concurrency_test.dart test/features/engine/month_seal_lifecycle_test.dart test/features/engine/seal_immutability_test.dart test/startup_integrity_test.dart passed all 16 tests, exit 0. Flutter analysis of the four changed Dart files passed with no issues. Final Dart formatting check passed, four files, zero changes, exit 0. The first test run caught a missing test import and Riverpod's default retention of the previous error during refresh; corrected both, then reran the complete focused set successfully. Formatting initially completed but exited with a sandbox-denied telemetry-file write; the approved escalated check subsequently passed.

No dependencies, Android configuration, authentication rules, savings formulas or actual phone data were changed. No APK build, installation, device profiling or in-app recovery was performed in this correction. These tests verify the two code corrections; they do not prove that phone jank is fixed. Phase 8.1a acceptance remains pending.

Official references reviewed: https://docs.flutter.dev/perf/ui-performance (measure phone performance in profile mode); https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-app-developers (plugin compatibility requires migration review); https://pub.dev/packages/local_auth/versions/3.0.2 (authentication background handling). No configuration changes were made merely to suppress warnings.

Manual verification when the owner next runs the updated app: check normal startup and unlock, background/resume several times, and confirm completed-month values remain stable. The startup error screen appears only if the safety scan actually fails; do not alter real data to force that failure. Its failure/retry path was exercised with an overridden provider in the automated test. Real-device performance and vault recovery confirmation remain separate checks.


## Phase 8.1a owner acceptance - 2026-10-23

The owner reported that Confirm recovery to Ft 0 restored the Saved balance to Ft 0 and the vault appeared normal, then explicitly instructed marking Phase 8.1a done. Marked T174-T183 completed and updated both phase reports. Prior pending recovery/acceptance statements are superseded by this owner confirmation. Other manual checklist outcomes were not individually reported, and no additional verification is claimed. This update changed documentation only; no tests, builds, installations, phone data writes or Git operations were performed. Phase 8.1b remains deferred.


## Phase 8.1b funded transfers - implementation verification (2026-10-23)

Scope was explicitly approved after all seven owner choices: current-month-only, matching-currency deposits and withdrawals, deposit funded by both bank availability and free reserve after borrowing, linked full reversals, readiness/maxima, before/after confirmation and notes. Implemented in the existing personal vault screen/history. No phone data or dependencies changed.

Verified gaps: prior vault history accepted only opening/sweep rows and unsigned amounts; monthly reserve/bank/summary, refund quote, Month-End and automatic sweeps had no manual-transfer adjustment. Simply increasing the vault would therefore leave the same funds spendable and eligible for another sweep. Resolution: each immutable signed transfer represents both legs, commits atomically with the vault balance, and contributes the opposite signed monthly credit exactly once. No original monthly opening, income, expense or allocation is overwritten. Existing schema fields suffice; schema remains version 25. Month move/delete must preserve linked history, so individual months containing transfers cannot be moved or deleted independently; whole-profile deletion still removes the linked personal records.

Implementation-time verification corrections: fixed missing imports/test fixture fields and explicit integer inference; completed temporary native schemas; fixed outdated display-only fixtures that read real Isar providers without setup; waited for native transaction completion under parallel widget load; pumped layout after scrolling to controls; corrected braces/style warnings. No assertions were removed or tests disabled. Production rate snapshots are reread inside the transaction; stale previews, insufficient/reserved funds, invalid history and mismatched currencies are refused.

Final verification: 482 tests passed, exit 0, full output build/phase8-1b-final-tests.log. Covers all vault/core database/finance/engine/sync tests in the scoped command, Month-End/refund/profile-spending services, dashboard summary, profile deletion and month movement. Targeted analysis passed on 18 command targets covering the 25 source/test files and vault directory; formatting check passed on all 25 files with zero changes. Filtered Isar generation passed for vault_entry and savings_vault, retaining the existing analyzer/SDK warning without upgrading packages. Native persisted snapshot reopen preserves transfer history, goal, original opening and source funds. Financial tests verify 10,000 in and 4,000 out yields exactly 6,000 net on both legs and a later sweep cannot count it twice.

Full file manifest, formulas, installed documentation references, security checks, exact test command, limitations and numbered in-app testing steps: specs/018-financial-core-audit/phase-8.1b-report.md. No APK build/install, physical-app testing, live paired-device testing, Git operations or later-phase work were performed. T184-T191 remain unchecked awaiting owner acceptance. All earlier failed verification attempts were corrected and the complete combined scoped suite rerun successfully.


## Phase 8.1b approved revision verified — 2026-10-23

The reported positive-income/disabled-deposit mismatch is corrected in the approved scope. Transfers and new sweeps now use the shared Free to spend calculation after income, spending, returns, unused allocations, carry/release and signed transfers. Confirmed opening zero no longer caps positive availability. Existing readiness/ownership/currency/month guards remain. New transfer/sweep evidence is versioned; old history and the accepted recovery evidence remain unchanged.

Optional goal target month is stored as a nullable additive schema-26 field. Guidance divides remaining savings across current-through-target months inclusively, rounding upward. It does not move money. All vault timestamps now show local date plus HH:mm without fractional seconds; original timestamps remain stored.

During verification corrected standalone intl locale-data initialization, stale schema-25 expectations, income-explicit sweep fixtures and brace-style diagnostics. No tests were disabled or assertions weakened. A multi-path dart fix command was rejected before edits; supported directory fix/manual corrections succeeded.

Final verification: 499 tests passed, exit 0, build/phase8-1b-revision-final-tests.log; targeted analysis clean; final formatting 37 files zero changes; filtered vault/previous-goal native fixture generation succeeded with the existing analyzer/SDK warning. Native source-income/zero-opening test yields 70,000 free from 200,000 income minus 50,000 spending and 80,000 unused allocations. A 20,000 deposit and 5,000 withdrawal leave 55,000 free with 15,000 net saved. Native upgrade preserves financial/history/goal data.

Current complete report, exact source/test manifest, verification limitations and numbered phone testing guide: specs/018-financial-core-audit/phase-8.1b-report.md, Final approved revision delivery. No APK build, installation, phone writes, Git commands, dependency changes or later-phase work. T184-T199 remain unchecked pending physical-app testing and owner acceptance. Earlier pending-implementation and bank-cap statements are superseded.

## Phase 8.1b approved revision - funding and timestamp reports

Reported: Deposit and Withdraw disabled, both maxima zero, despite money recorded through Income Sources; displayed time includes fractional seconds, for example 21:58.341542. The owner clarified that vault deposits should use dashboard Free to spend after planned allocations and actual spending. A zero recovered vault legitimately has no withdrawal balance, but a zero opening-bank-funds cap must not independently block positive Free to spend.

Read-only source finding: AllocationCard uses MonthSummary.kept (income/spending/returns/unused allocations/settlement/transfers), while VaultTransferService independently caps by opening-based bank funds and reserve. Vault/history print raw local DateTime strings. These explain the competing eligibility rules and exposed fractional seconds; an incorrect device clock/timezone has not been established.

Approved resolution: reconcile Free to spend across dashboard, transfer validation and new sweeps; preserve old immutable history; add optional goal target month and inclusive rounded-up monthly guidance without automatic deductions; show readable local date/time without changing stored timestamps or device settings. Full implementation plan written in specs/018-financial-core-audit/phase-8.1b-revised-implementation-plan.md and appended as unchecked T192-T199 inside Phase 8.1b. Related specification/plan/data/contracts/report statuses updated. This turn changed documentation only: no application edits, tests, generation, builds, dependency changes or phone writes. Earlier 482 tests do not verify the unimplemented revision. Phase 8.1b acceptance remains pending.


## Phase 8.1b owner acceptance ? 2026-10-24

The owner reported "I approve. It works." Marked only T184-T199 complete and recorded acceptance in the phase report and revised plan. Individual phone test steps were not separately reported. Read-only inspection confirmed history currently fetches all personal-profile entries newest-first and builds them together inside the screen scroll; no page limit or Load more control exists. No application behavior changed. No tests, builds, phone actions, Git operations or later-phase work performed.


## Phase 8.1b history pagination follow-up ? 2026-10-24

Owner approved 20-entry pages, year/month filters, newest-first, counts and Previous/Next, then requested tasks and speckit-implement. T200-T202 appended unchecked. Implemented presentation paging in vault_history_pages.dart, retained full-ledger validation/reversal lookups and existing expanded details. Profile-specific history key resets state. No schema/data writes or dependencies changed.

Verification caught offscreen dropdown taps in the test helper; now scrolls menu items into view with missed taps fatal. Broader vault tests then caught a duplicate ValueKey shared by history and the sweep button, triggering sliver child-order assertions when pause state inserted a warning. Gave history a distinct profile-specific key and reran the complete scoped suite successfully: 132 tests, exit 0. Targeted analysis clean; final four-file formatting zero changes. Seven new tests cover 20-row boundaries, five-year lookup, filters, empty/live results, profile reset, phone width and cross-page reversal references. Full report/manual guide: specs/018-financial-core-audit/phase-8.1b-history-pagination-report.md. No tests disabled or assertions weakened. No Git, phone actions, builds, generation or later-phase work. T200-T202 await owner acceptance; prior accepted tasks unchanged.


## Full Phase 8 closure ? 2026-10-24

Owner requested checking and marking full Phase 8 complete. Rechecked Month-End service/preview/atomic confirmation, routes/settings, vault goal/funding and history pagination against the tasks and acceptance records. No unfinished implementation markers found in these scoped sources. Final combined current-code regression passed 506 tests, exit 0; complete log build/phase8-closure-tests.log. Latest pagination analysis/format checks remain valid; no application source changed during closure. Marked only remaining T200-T202 complete; all 36 Phase 8 tasks (T062-T068, T174-T202) are now complete. Reports updated with superseding acceptance notes. No new phone tests, APK build/install, Git commands, dependencies or later-phase work. Limits and closure evidence: specs/018-financial-core-audit/phase-8-closure-report.md.


## Phase 9 - implementation and regression verification (2026-10-24)

Scope: owner approved all seven audit-history decisions and implementation/testing/generation. No Git, dependencies, APK build/install, physical phone data actions or later phases.

Confirmed integration issues and fixes:
- Transfer previously saved the two allocation legs separately from transfer history. An audit failure could leave partial balances. TransferRepository.apply now commits the two legs, transfer, primary/derived audit and journal together, with fresh validation and identical-request retry handling. Native tests confirm all legs rollback on an invalid chain tip.
- Add Expense did not await saving before leaving the form. The screen now awaits completion, guards duplicate submissions and shows failure without closing. Expense audit and spending caches commit together. Existing layout/save tests pass with a real router and isolated native schema.
- Sweep caught FormatException after contribution writes inside its transaction. A required audit failure could otherwise be swallowed. After financial writes begin the error now escapes the transaction, producing a structured failed outcome with no balance/cursor/contribution change for that attempted step. Isolated native regression passes.
- Reactive audit history originally registered asynchronous provider dependencies and allowed stale/disposed permission callbacks; membership invalidation could loop. Dependencies are synchronous, stale callbacks stop, membership subscription is stable, and verification watches the current snapshot directly. Native tests verify changes, tampering, deletion and profile isolation; no tests were disabled.
- Existing minimal reimbursement/medical test schemas did not include the production audit collections. Complete production schema fixtures and valid deterministic test identities now exercise the real atomic paths, retaining financial assertions. Earlier failed regression runs are superseded by the passing combined run.
- Old Medical T-R06 asserted original EUR text although the accepted Currency Everywhere screen converts read-only amounts to selected USD display. The assertion now checks the exact bundled-rate USD result and the existing no-overflow condition; application financial logic was not changed.
- Separate experimental rates (EUR 0.8, HUF 400, CAD 1.4 per USD) at the test phone width exposed an 18px right overflow on MedicalDashboard. This layout is outside Phase 9, was not changed, and the experimental fixture was not retained. Reproduction: supply this rate table to the existing Medical layout fixture with EUR 1,000, 20% patient share and USD display/HUF main currency. Expected: converted text fits; actual: RenderFlex overflow. Deferred for owner review rather than expanding audit scope. Baseline bundled-rate regression passes.
- Resolved implementation style diagnostics and the vault async BuildContext guard. Restored accidental UTF-8 encoding layers only in the known edited source files; no broad data/text migration.

Final combined command is in specs/018-financial-core-audit/phase-9-report.md: 784 tests passed, 1 pre-existing skipped, zero failures, exit 0. Existing skipped test: Medical layout 'the gear opens the sheet with the recorded plan', already skipped for an Isar asynchronous runner hang; no new skip added. Static analysis passed all 73 explicit changed Dart files; final format check 73 files/zero changes. Filtered audit/previous-schema fixture generation succeeded with the existing analyzer/SDK mismatch warning, no upgrade. The retained build/phase9-final-tests-tail.log is explicitly a continuation, not a complete transcript, because the initial output chunk was truncated.

Native pre-evidence schema reopen preserves original legacy values/hash/signature/timestamp. Crypto/sync tests cover independently signed offline author/device chains, out-of-order delivery, replay, malformed signatures and personal-context bypass rejection. Isolated tests exercise head loss, tamper detection, whole-history removal, transfer/sweep rollback and personal data deletion. These do not claim physical two-device testing or universal tamper detection.

Status: Phase 9 implementation and automated verification complete; phone acceptance pending. T069-T075 and T203-T206 remain unchecked pending explicit owner acceptance. Full source/test manifest, design/security limitations, official references and numbered app testing guide: specs/018-financial-core-audit/phase-9-report.md. No later phase started.


## Approved verification-result card removal - 2026-10-24

Owner requested removing the persistent message above Verify history because the result already appears as disappearing feedback, then explicitly approved the edit and focused checks. Removed only that result card from lib/features/finance/presentation/audit_history_screen.dart. Verification still runs automatically through the watched provider, and manual verification still produces its actual transient success/warning/error message with busy protection. Updated each new audit record's wording so it no longer refers to a verification result above it.

Updated test/features/finance/audit_history_screen_test.dart to assert that no persistent result appears before verification, the actual result appears in the SnackBar after verification, and it disappears afterwards. Existing paging, accordion, permission and original-evidence checks remain. Focused command passed 7 tests, exit 0: flutter test --no-pub test/features/finance/audit_history_screen_test.dart test/shared/presentation/financial_feedback_test.dart. Analysis on the two changed Dart files: No issues found. Initial format check identified one test-layout adjustment; applied formatting and final check passed with zero changes.

This owner-approved presentation revision supersedes earlier report/guide instructions saying the verification result card remains visible. The read-only history description, Verify history button, original per-record legacy labels, permissions and financial/audit data are unchanged. No tests disabled, dependencies, database changes, builds, phone actions or Git operations. Phase 9 acceptance remains pending.

Phone check: refresh the updated app, open Audit History and confirm the result card above Verify history is absent. Press Verify history; expect its actual result as a temporary message, then no persistent duplicate after it disappears. The button remains available for another check.


## Phase 9 owner acceptance - 2026-10-24

Owner explicitly instructed: mark Phase 9 completed and wait for the next command. Marked all 11 Phase 9 tasks T069-T075 and T203-T206 complete in tasks.md. This acceptance includes the approved display names/currencies/newest-first ordering, single-open records/date correction/financial feedback and removal of the persistent verification card. Earlier pending-acceptance statements in this document are historical and superseded by this acceptance.

Verification already delivered: initial 784 tests passed with one pre-existing skipped test; readable-label/order regression 82 passed; option A financial/audit/vault regression 186 passed; final verification-card removal checks 7 passed. Corresponding analysis and formatting passed. No new application changes, tests, builds, phone actions, dependencies or Git operations during closure. No individual phone-test outcomes were supplied with this acceptance; existing documented limits remain. Phase 10 was not started. Work is stopped awaiting the owner's next command.


## Phase 10 search/filter implementation and verification - 2026-10-24

Approved scope: all eight owner choices and live typing after 150ms, final plan explicitly approved. Bring optional merchant/tags/payment entry and canonical linking forward from Phase 12; preserve legacy unknown values, audit/sync and ownership. No receipt enforcement or daily cards yet. Governing phase/approval workflow and no-Git rule preserved; spec-kit implementation prerequisites passed, requirements checklist 16/16 checked, no extension hooks registered.

Confirmed gaps: Expenses had title-only search and category/status filters, no search/filter services or merchant/tag/payment fields linked to expenses, no all-month browsing or combined amount/date filters. Original stream ordering correction from Phase 9 was preserved as the new search service's date/local-ID/GUID ordering.

Implemented schema 28 optional metadata with generated code and a real old-schema close/reopen fixture; transaction-scoped merchant normalization/linking and audit; portable merchant/metadata sync, old-peer retention and context rejection; lifecycle rebinding/cascades; pure search/filter/exact amount helpers; authorized/reactive owner snapshots, 150ms timer cancellation/context reset; Filters Apply/Cancel/chips/Clear all/empty state; 20-entry counts/Previous/Next with live page clamp; owning-month conversion and guarded navigation. Missing metadata/assignments are not guessed. Full source/test manifest and phone steps: specs/018-financial-core-audit/phase-10-report.md.

Implementation-time findings/corrections:
- Touched Add Expense imports pointed one directory above lib; corrected relative paths. Edit Expense treated lowercase supported currency codes as USD; corrected case recognition. Duplicate now preserves shared owner/financial-profile links along with metadata. No formulas changed.
- A sheet callback incorrectly returned a Future from a void callback; made it async/await. Removed unused imports and fixed reported brace/const diagnostics.
- Existing UI fixtures supplied the old filtered-expenses provider and read native new providers under fake time. Updated only the fixture sources/context/directory overrides, preserving currency and viewer/editor assertions. Native permission tests separately exercise the actual repository/providers.
- Sync backfill fixture lacked MerchantSchema; added that production collection. Current-version expectations were updated from 27 to 28, retaining historical migration input stamps. No test or financial assertion was disabled/weakened.
- A new live revocation test initially lacked its membership provider's isolated database connection. With the correct test injection, actual revocation removes results and produces an access error. Controls/results no longer display previous AsyncLoading owner data.
- Final review fixed permanent page clamping after removals, missing-target classification and search-field reset behavior, including pending typing. Focused final regressions passed.
- Native performance under concurrent compilation/execution exceeded 200ms (1152.653ms). Kept the strict assertion, tagged timing measurement explicitly and ran it without competing tests. Isolated results 173.331ms, 189.954ms and final 183.472ms. The benchmark includes authorization/native read/deserialization/matching/filter/sort for 10,000 matches; excludes setup, typing delay and UI rendering. This is Windows x64/Dart 3.13.5 Flutter-test evidence, not phone timing or a universal under-load guarantee.

Final verification: broad functional suite 538 passed, exit 0; final screen/capability checks 6 passed and final search/filter checks 3 passed; isolated timing 1 passed, exit 0. Static analysis clean on all 48 changed Dart files; final format 48 files/zero changes. Filtered generation passed for Expense and the previous schema fixture, with the existing analyzer 3.1/SDK language 3.13 warning and no upgrade. Exact commands and limits are in the report. No platform build/install, phone actions, live paired-phone testing, dependencies or Git operations.

Status: Phase 10 implementation and stated automated verification delivered, awaiting owner app testing/acceptance. T076-T079 and T207-T209 remain unchecked. No Phase 11 or later work started. Phone guide: live title/merchant/tag/note words; Filters Apply/Cancel, original-currency ranges and inclusive dates; chips/reset; 20-entry pages; owning-month guard; context switch reset; known metadata retained and unknown old data labeled Not recorded. Do not create fake transactions or move/delete real months just to test these controls.


## Approved Expenses pagination placement and card separation - 2026-10-24

Owner reported that Previous/Next should be at the bottom, with 20 items per page and controls only when more than 20 results match, plus clearer separation between expense cards. Owner explicitly approved this layout change and focused checks.

Changed lib/features/expenses/presentation/expenses_screen.dart: moved Previous/Next below the scrollable expense list in a bottom SafeArea, conditional on matching results >20. Kept the existing 20-entry slice, ordering, filters, page clamp and result/page counts. Wrapped each Slidable in an outlined rounded Card with 12px horizontal/6px vertical margins and clipping, preserving swipe behavior inside the boundary. Corrected visible question-mark separators in the touched row subtitle to proper bullet escapes. No financial, permission, schema or search-matching changes.

Updated test/features/expenses/presentation/expense_search_screen_test.dart: checks footer position below the list, visible spacing between painted card surfaces, 20-entry first page and the remaining 21st result, and hidden controls at 20 and zero results. The first gap assertion measured Card margin boxes rather than painted surfaces and failed; corrected the measurement while retaining the positive-gap assertion.

Final focused command passed all 7 tests, exit 0:
flutter test --no-pub test/features/expenses/presentation/expense_search_screen_test.dart test/features/expenses/presentation/expenses_screen_test.dart test/features/spaces/viewer_readonly_test.dart
Includes existing currency display and viewer/editor capability assertions. Final analysis on the two edited Dart files: No issues found. Final format: two files, zero changes. Initial parallel analysis was interrupted and rerun sequentially; the final sequential result passed. No tests disabled, no dependencies, database edits, phone actions, builds or Git operations.

Phone check: refresh the app and open Expenses. With 21 or more matching genuine records, expect 20 per page and Previous/Next fixed below the list. With exactly 20, fewer or no matching records, both buttons must be absent. Filtering down to <=20 hides them automatically. Expense cards should have visible outlines and gaps; existing permitted swipe actions should still work. No fake transactions are needed just to force another page.

Status: layout correction implemented and verified; physical-app acceptance pending. This supersedes earlier top-pagination placement. Phase 10 tasks remain awaiting owner acceptance and no later phase started.

### Expenses compact header correction - 2026-10-24

Owner reported excessive space between Clear all and the result count and approved a compact header layout. Cause: a fixed 150-pixel AppBar bottom reservation plus an always-present 38-pixel chip row. Replaced the fixed reservation with content-sized controls above the list, omitted empty chip space, added wrapping active chips within a bounded scroll area, reduced search padding and aligned the compact result caption below the controls. Updated expenses_screen.dart and widgets/expense_search_controls.dart only; financial behavior and bottom pagination remain unchanged.

Verification: the same focused three-file UI command above passed all 7 tests; flutter analyze --no-pub on both changed Dart files found no issues; final Dart format reported zero changes. Initial formatting completed but telemetry access was denied by the sandbox; the approved escalated rerun succeeded. No phone test or screenshot review was performed.

Phone review: refresh the app, open Expenses and check that Clear all and the result caption are close together. Apply several filters and confirm chips wrap and remain removable; clear them and confirm the empty row disappears. Check search and bottom pagination still work. Implementation verified by automated checks; visual acceptance remains pending. No phase checkboxes changed.

### Phase 11 bulk-entry implementation and verification - 2026-10-24

Owner approved all eight recommended decisions and the final Phase 11 plan. Implemented T080-T083 only: temporary numbered expense cards, required bulk metadata, one pinned owner/month, defaults for new rows, copy without amount/paid/saved identity, independent errors, atomic ready-group writes with audit/local sync/spending, retry protection, review totals and discard warning. Settings and Expenses menu entries are writer-only. No Phase 12 evidence or ordinary Add/Edit enforcement was implemented.

Implementation checks found and corrected two UI issues: the review dialog initially triggered a misleading Saving indicator before confirmation; later the error snackbar temporarily covered the body-based save action, preventing immediate retry. Reproduce the latter by injecting a failed bulk save, then tapping Review and save while its error message is visible. Expected: retry remains accessible. Fix: Scaffold bottomNavigationBar with keyboard-safe spacing; feedback appears above it. Updated phone-width tests confirm retry uses the same row identity and succeeds without duplicates. Real database tests cover write rollback, shared role/signing checks and partial validation. A few test finders required scrolling lazy cards and selecting the defaults-sheet controls; assertions were retained. Initial analyzer findings (incorrect feedback argument and then missing braces) were corrected.

Final command passed 307 tests with zero failures, exit 0:
flutter test --no-pub --exclude-tags performance test/features/expenses test/features/finance test/features/sync test/features/spaces test/features/settings/profile_deletion_test.dart test/shared/presentation/financial_feedback_test.dart

Includes 17 new Phase 11 tests: 4 service, 8 native Isar, 5 phone-width widget. An intermediate final run had 306 passes and one newly added retry-test failure; the bottom-bar correction resolved it, five focused screen tests passed and the complete command above then passed. Analysis of all 11 changed Dart files is clean; formatting completed. No dependencies, schema changes, builds, phone actions or Git operations. Requirements checklist remains 16/16; no Spec Kit extension hooks are configured.

Phone review: refresh the app, choose the intended editable month/context and open Expenses > Expense actions > Bulk entry or Settings > Bulk Entry. Use genuine expenses you intend to record. Fill one valid row, add an incomplete row and review. Expect one ready row, one row needing correction, grouped amount and a separate currency total. Confirm: only the valid expense saves and becomes read-only. Correct the remaining real expense and retry: the first must not duplicate. Verify Planned/Paid effects, audit evidence, defaults affecting new rows only, blank amount on Copy and the discard warning. Complete guide and file manifest: specs/018-financial-core-audit/phase-11-report.md.

Status: implemented and automatically verified, awaiting owner phone review/acceptance. T080-T083 remain unchecked under Rule 7. Phase 12 remains planning-only.

### Phase 11 reported missing Saved bulk expenses - 2026-10-24

Reported: bulk rows marked Saved and visible in Audit History remain missing from Expenses after Clear all. Expected: committed records appear in the selected owner/month list. Read-only diagnosis approved by owner: ADB snapshot captured without stopping/reinstalling the app or editing phone data. Before/after phone and local SHA-256 checksums matched. Source snapshot remains in ignored build/bulk-diagnostics; only a separate analysis copy was opened, without migrations or recovery. Recent BudgetBuddy logs showed no matching exception. The phone screen captured was Audit History, not the running Expenses list.

Confirmed records: Rice (ID 11) and Farine (ID 12), personal profile 1, October 2026, monthly budget 2, Paid, purchase date 24 October. Both match expense.create audit entries. The unfiltered authorized local query returns 10 expenses including both. No missing-row repair or re-entry is needed based on this snapshot. Exact cause of the running phone's display state remains unproven.

Owner approved code correction/testing. Ordinary native save-to-search integration passed before edits, while a controlled missed-watch-event test failed with the old implementation. Successful bulk commits now explicitly invalidate the providers read by Expenses after commit, without clearing normal filters. Added a scrollable, theme-aware completion card with saved/remaining counts, Paid/Planned counts, per-currency recorded totals and View saved expenses. That explicit action uses a visible/removable Saved batch restriction within the pinned owner/month, keeps discard confirmation, resets the restriction on month/owner changes and preserves 20-entry pagination. No money formulas or stored phone records changed.

Final verification: 311 tests passed with zero failures in the broad Phase 11 regression command above. Analysis clean on eight changed Dart files; formatting completed. Final real-database-to-actual-Expenses navigation rerun passed. New tests cover normal delivery, missed watcher recovery, batch filtering/removal/reset, genuine database persistence, discard cancellation/confirmation and full-list restoration. Native widget setup/cleanup needed real-I/O scheduling and draining pending watcher reads before database close; all assertions retained. No dependencies, schema generation, app builds, phone installations or Git operations.

Phone check: restart the running app with updated code, preserving its data. In personal October Expenses, Clear all and pull to refresh. Look for existing Rice/Farine rather than re-entering them. Next genuine bulk save should show Batch saved and View saved expenses. The action shows a Saved batch chip; Clear all restores the full list. Remaining unsaved rows must still trigger the discard warning. Full evidence and files: specs/018-financial-core-audit/phase-11-report.md.

Status: visibility hardening and handoff implemented and automatically verified; updated phone acceptance pending. Phase 11 remains open and Phase 12 was not implemented. Owner's standing design preference is polished, thoughtful UI/UX rather than bare controls.

### Approved Audit History visual/detail redesign - 2026-10-24

Reported issue: Audit History feels minimal and each expanded entry presents a long, flat list of fields. Reproduction: open Settings > Audit History and expand a record. Expected: polished cards, readable hierarchy and meaningful field comparisons while retaining original evidence. Read-only review confirmed plain ExpansionTiles and formatted text blocks. Owner approved the concrete design/implementation plan before edits.

Implemented compact filter panel, action-specific icons/accents, rounded record cards, recorded names/times/original amounts and Legacy/Recorded badges without an unsupported Verified claim. Expanded views group money, record details and dates; updates show changed Before/After fields responsively. Added/deleted records show only the snapshot actually present, rather than repeating empty comparisons. Unchanged values are optional; technical references/evidence remain nested. One open record, newest-first order, 20-entry pages, permissions and temporary verification feedback are preserved. Friendly labels replace known numeric/string enums. Calendar dates remain distinct from action-recording time; original expense amounts never borrow a different context currency for display. No evidence is rewritten.

Changed Dart files: lib/features/finance/presentation/audit_history_screen.dart, audit_record_card.dart (new), audit_values.dart; test/features/finance/audit_history_screen_test.dart and audit_values_test.dart. Full design, API references, exact checks and phone guide: specs/018-financial-core-audit/audit-history-design-report.md. Existing Phase 9 completion remains unchanged; the visual refinement awaits owner review.

Final command passed 72 tests, zero failures, exit 0:
flutter test --no-pub test/features/finance test/core/services/audit_verify_service_test.dart test/core/services/audit_shared_test.dart test/core/services/audit_native_upgrade_test.dart test/shared/presentation/financial_feedback_test.dart

Focused UI/value/date-export checks passed 22 tests. Nine new UI/value cases cover changes, unchanged fields, creation/deletion, unsupported/invalid data, currency isolation, calendar/recording dates, 320px dark mode with 1.8 text scale and 760px two-column layout. Accordion regression opens technical details then verifies the first entry remains closed after opening another. Existing flat-string assertions were replaced with scoped structured-field assertions; test scrolling selects the outer list and pumps layout before tapping. Fifteen brace-style lint findings were fixed. Final analysis on five files: No issues found; final format five files, zero changes. No disabled tests or weakened assertions.

Phone check: restart the app with updated code and preserve its data. Open Audit History, check cards/filters, expand an updated entry and compare Before/After. Use Show all recorded fields, inspect a created/deleted entry, then open another card to confirm accordion closure. Check readable dates, uppercase currencies and grouped amounts. Verify history must show only temporary result feedback. Check dark/light mode and larger text. No phone operation, installation, build, user data edit, schema change, dependency change or Git operation was performed for this redesign.

Status: redesign implemented and automatically verified; phone visual acceptance pending. No phase completion markers changed and no Phase 12 work was started.

### Audit technical details moved behind optional Diagnostics - 2026-10-24

Owner asked whether Technical details is useful for everyday users and approved hiding it from normal entries while retaining optional troubleshooting access. Expected: clean normal history with ordinary details/verification available, raw technical evidence visible only after opt-in. Implemented Settings > Diagnostics > Audit technical details, default off, persisted locally using the existing SecretStore/FlutterSecureStorage implementation and a separate UI preference key. No financial database schema change, sync change, audit/identity-key mutation or new dependency.

The technical section is absent unless the preference loads successfully as enabled; toggling off removes an open technical view. Loading, unknown values and storage errors keep it hidden. Settings includes retry/error feedback, and overlapping saves are refused. Existing history scope/permissions, verification and original evidence remain unchanged. Files and complete phone guide: specs/018-financial-core-audit/audit-history-design-report.md.

Final command passed 105 tests, zero failures, exit 0:
flutter test --no-pub test/features/settings test/features/finance test/core/services/audit_verify_service_test.dart test/core/services/audit_shared_test.dart test/core/services/audit_native_upgrade_test.dart test/shared/presentation/financial_feedback_test.dart

Four new Diagnostics tests cover default/persistence, errors/retry, invalid values/write serialization and live section visibility with evidence preservation. Existing technical tests explicitly enable the preference; normal history tests run off. Focused checks: 13 passed. Initial UI-test tap was obscured by its expected temporary snackbar; waiting for expiry resolved the test while preserving assertions. Two brace findings fixed. Final analysis on seven changed files is clean; final format seven files, zero changes. No skipped/disabled tests, phone actions, build, install, Git, schema generation or phase checkbox changes.

Phone check: restart with updated code and open Audit History. Expect no Technical details by default; Verify history still works. Enable Settings > Diagnostics > Audit technical details and confirm the section becomes available. Restart to check persistence; disable it to return to normal history. Test persistence uses an injected local store; actual device keystore persistence and visual acceptance are not yet claimed.

Status: implemented and automatically verified; owner phone acceptance pending. All audit evidence preserved.

### Compact expanded Audit History entries - 2026-10-24

Reported: expanded actions are too long. Owner approved shortening the layout while preserving all information. Inspection confirmed repeated metadata and large stacked Before/After value boxes. Replaced them with selectable compact label: before -> after lines, concise single-value creation/deletion rows and full-width long-note comparisons without truncation. Reduced metadata/group/row padding and gaps, combined author/recording information, and removed only the duplicate record-name line (the name remains in the card header). Screen-reader descriptions explicitly identify both values. Unchanged-field access and optional Diagnostics are preserved.

Files changed: lib/features/finance/presentation/audit_record_card.dart and test/features/finance/audit_history_screen_test.dart. No formatter, verification, permission, financial formula, ordering, paging, evidence or storage changes. Full record: specs/018-financial-core-audit/audit-history-design-report.md.

Final command passed 106 tests, zero failures, exit 0:
flutter test --no-pub test/features/settings test/features/finance test/core/services/audit_verify_service_test.dart test/core/services/audit_shared_test.dart test/core/services/audit_native_upgrade_test.dart test/shared/presentation/financial_feedback_test.dart

Focused Audit History/Diagnostics UI command: 11 passed. Updated existing assertions to verify complete compact values, semantic before/after labels and reduced height instead of the superseded separate panes. Added full-length notes/evidence-preservation and compact-metadata checks. Narrow 320px dark/1.8 text-scale and wide 760px light layouts remain covered. Initial separate-currency-widget assertion was replaced with full before/new currency text; one missing-brace lint was fixed. Final analysis clean on two files; final format zero changes. No disabled tests, user-data edits, dependencies, schema changes, builds, phone actions, installs or phase status changes.

Phone check: restart with updated code and expand an existing Audit History action. Expect short amount/change lines, a small metadata block and tighter spacing. Long notes must wrap fully. Show all recorded fields, the single-open accordion, Diagnostics visibility and temporary Verify history feedback should still work. Owner visual acceptance remains pending.

### Phase 12 expense evidence and daily cards - 2026-10-25

Owner approved the thirteen planning decisions and full Phase 12 implementation. Delivered date-grouped expense cards and day modals, each paged at 20; separate original-currency Net paid and Planned summaries; required standard-expense metadata; receipt plus method-specific proof or explicit cash-paid declaration; scoped merchant suggestions, attachment previews/readiness and Android PDF navigation. Planned entries need no proof. Legacy nonfinancial corrections and the separate Medical workflow remain supported. Copies do not inherit proof or cash declarations.

Schema 29 adds a nullable evidence manifest and immutable private document chunks without inventing legacy evidence. Money, document content, audit and shared journal writes commit together. Private unfinished uploads are cleaned up; committed previous versions remain until whole-owner deletion, including removal of byte-bearing shared journal copies. Authenticated paired sync delivers bounded signed chunks with integrity/ownership checks, independent acknowledgements and retry. Missing files display Pending/Unavailable. Both devices need updated code for document delivery. Full implementation details: specs/018-financial-core-audit/phase-12-report.md.

Confirmed issues corrected during verification: unstable document-provider keys and filter-triggered refund re-query; exact large-amount editing/conversion hints; preservation of legacy currency/status/missing payment times during notes-only edits; merchant normalization before cash confirmation; retained proof authorization after expense deletion; whole-space journal-content cleanup. Test-only failures came from superseded flat-list expectations, old schema-version assertions, incomplete collection/context fixtures and missing signed-history setup. Those fixtures were updated without weakening production permission, integrity or timing checks.

Final functional command: 870 passed, one existing skipped test, zero failures, exit 0:
flutter test --no-pub --exclude-tags performance test/features/expenses test/features/finance test/features/sync test/features/spaces test/features/settings/profile_deletion_test.dart test/shared/presentation/financial_feedback_test.dart test/features/medical test/features/vault test/core/services test/features/security

Existing skip: test/features/medical/presentation/medical_layout_overflow_test.dart (previous Isar async-runner hang). No new tests were disabled. Final isolated performance command passed one test at 81.931 ms for 10,000 matches against the unchanged under-200-ms assertion:
flutter test --no-pub --tags performance test/features/expenses/expense_search_native_test.dart

An earlier benchmark running alongside other checks exceeded the limit; the final run above was isolated. Analysis and formatting are clean across 71 changed handwritten Dart files. Generated Isar schemas completed with the existing analyzer/SDK compatibility warning; dependencies were not changed. No Git operation, phone inspection/data change, Android build or installation was performed.

Phone guide: specs/018-financial-core-audit/phase-12-phone-test-guide.md. Start a full flutter run --no-pub; hot reload cannot load the new native PDF bridge. On a test profile check day cards, Planned/Cash/Card/Bank requirements, image zoom/PDF pages, upload limits, legacy notes, duplication and bulk saving. Where two updated paired devices are available, check file arrival/interruption/retry and context isolation. Actual Android picker/native PDF execution and physical pairing remain unverified until these checks. Phase 12 tasks remain unchecked pending explicit owner acceptance; no later phase was started.

### Phase 12.1: repeated receipt uploads in Bulk Entry - 2026-10-26

Reported: several items bought together from one merchant each required uploading the same receipt/payment proof. Reproduction: create multiple Paid bulk rows for one receipt. Previous behavior: each row owned a separate evidence draft. Expected approved behavior: one purchase owns shared evidence and several individually budgeted expense items, with receipt/items totals reconciled exactly. Owner approved all seven decisions and implementation; full record: specs/018-financial-core-audit/phase-12.1-implementation-plan.md.

Implemented purchase cards, shared header/evidence, exact integer receipt matching, complete-purchase atomic saves and retry protection, linked saved summary/editor, preserved item refunds and guarded deletion. Schema 30 adds purchase identity/item links without guessing legacy groups. Shared bytes are stored once; signed aggregate sync applies all items atomically. Ordinary expenses and Medical workflows remain supported. Context moves retain links and copy one document set; explicit owner deletion removes headers/content. Split payments remain deferred.

Confirmed implementation issues corrected during checks: generated merchant identities made exact retries compare unequal; merchant canonical spelling could mismatch the header and cash fingerprint; old shared deletions needed to refuse purchases moved to personal ownership. Corrected these with native/signed regression coverage. Old flat-row screen fixtures were adapted to purchase cards. An initial merchant assertion expected whitespace from its input; the corrected assertion checks the canonical trimmed name and valid evidence. No production security or money/timing checks were weakened.

Broad regression passed 888 tests, one existing medical Isar-layout skip, zero failures. Final sync/space/purchase/UI follow-up after the last fixes passed 221 tests, zero failures. Final 10,000-match isolated search benchmark passed at 169.239 ms against the unchanged under-200-ms limit. Analysis clean on 43 handwritten Dart files; final format 43 files, zero changes. Filtered schema/test-fixture generation passed with the existing analyzer/SDK warning; no dependency upgrade. Exact commands, source areas and limitations: specs/018-financial-core-audit/phase-12.1-report.md.

Manual check: start a full flutter run --no-pub. In a test profile create a Paid supermarket purchase with Rice 5,000 + Flour 3,000 + Oil 2,000, receipt total 10,000 and one receipt/payment-proof set. A 9,999 receipt total must block saving. A separate incomplete purchase must remain editable while the complete one saves. Verify three expense items totaling 10,000, linked summary/evidence, balanced corrections, fresh cash confirmation, refunds and guarded removal. Complete phone steps: specs/018-financial-core-audit/phase-12.1-phone-test-guide.md.

Status: implementation and automated verification delivered; phone acceptance pending. No Android build/install, real phone inspection/data action, physical paired-device session, Git operation, dependency change or later-phase work. T213-T218 remain unchecked until owner acceptance. Phase 12's prior acceptance status is unchanged.


## 2026-10-26 — Phase 13 reporting implementation review

Scope: owner-approved Reports implementation only. Confirmed during isolated tests/review: conversion overflow must be rejected before the legacy rate engine can saturate; vault endpoint currency must come from the recorded vault entry rather than current personal currency; export must recheck permission after rendering; the delivery busy guard must cover the entire native chooser future. These are corrected in Phase 13 services and covered by calculation/temporary-Isar/delivery tests. Missing monthly records remain unavailable, and unconfirmed opening funds prevent full statement export. No phone records were inspected or changed. Current status: automated verification and owner phone acceptance tracked in specs/018-financial-core-audit/phase-13-report.md; phone reproduction/check steps in phase-13-phone-test-guide.md. Existing logs and reports are preserved.



## 2026-10-26 — Phase 14 approved implementation findings

Confirmed by code review: first-start Budget Setup saved the default name User without asking; existing profile management lacked rename. New Welcome/name validation and metadata-only rename address this approved scope. The old setup month lookup filtered only yearMonth; it now includes personal owner to prevent updating another profile's month. Isolated tests verify duplicate retry prevention and owner preservation.

A real-router test reproduced a cached chart filter being reapplied under a new owner. Root page state and filter requests now retain owner identity; after a switch the new Dashboard and Expenses do not revive previous-owner filters. Existing drill-down tests were updated to check the live Phase 10 search state rather than retired filter providers. An initial broad test run also caught five controller-test-double compilation failures from adding rename to their interface; renaming was moved to a focused repository, preserving the controller interface, and those tests passed afterward.

Expected verification: Welcome saves a chosen name once; rename keeps financial ownership, pairing identity and historical audit names; switching preserves month, enforces current membership and uses the existing lock gate. Current status and final automated results are in specs/018-financial-core-audit/phase-14-report.md; reproduction/manual steps are in phase-14-phone-test-guide.md. No phone data was inspected or changed. Existing logs preserved.



## 2026-10-26 — Final Phase verification findings and results

Approved scope: generated/static/test verification, debug APK, in-scope defect repair, safe current guides and requirements evidence. No phone or Git operations.

Confirmed income defect: with HUF and EUR sources, incomeSourcesTotalProvider asked monthlyTotal without a currency, producing zero; with only USD sources, foreign cents could be labelled as HUF. Reproduction uses test/features/finance/income_currency_provider_test.dart: mixed personal/shared groups and foreign-only sources. Expected: select the accounting-currency group before scaling its own minor units. Actual before fix: 0 / 0 / 10,000 instead of 100,000 HUF / EUR 250 / 0 HUF. Fixed the caller's currency argument; all three tests passed afterward. No automatic foreign-income conversion added.

Generator check succeeded with an old-analyzer/SDK compatibility warning. Cache cleanup removed six historical test outputs despite current-lib filter; restored exact saved copies and verified all 41 generated hashes match. Initial runs exposed stale schemaVersion 28 assertions (actual 30), a shared-save fixture lacking a router/current metadata, a display-currency fixture lacking owner context and Medical routing fixtures lacking profile streams. Updated valid fixtures and assertions without weakening tests or changing migration logic. One pre-existing skipped Medical recorded-plan sheet case remains documented.

Final verified results: 1,361 full tests passed, one existing skipped; separate 10,000-row search benchmark 81.285ms on Windows/Dart 3.13.5; full analysis no issues; read-only formatting audit 614 files/0 changes; local debug APK rebuilt successfully. Existing KGP/Java compatibility warnings remain. APK was not installed. Details: specs/018-financial-core-audit/final-phase-report.md.

Open requirement: FR-020 stores original amount/currency but lacks per-transaction booked rate/base value. Monthly live-rate refresh can change equivalents. Expected fixed booked evidence is not implemented; no history guessed or data repaired. Owner selected all seven proposal choices, with schema/accounting implementation pending explicit approval of final-phase-fx-implementation-plan.md. Optional expense location and the SC-007 95% real-user study are explicitly deferred. Phone checklist outcomes remain unreported. Final Phase tasks stay open.

## 2026-10-26 — Subsequently approved FR-020 correction

Authorization: owner explicitly approved implementing the complete seven-choice FX plan, including additive schema, accounting, audit/sync, readers and verification. This supersedes the earlier preparation-only checkpoint above. No Git, phone action, new dependency or release/deployment work.

Confirmed defect/reproduction: save a new Paid EUR 20 expense in a USD context with EUR 0.8/USD, then change the live table to EUR 1/USD. Before correction, its equivalent changed from USD 25 to USD 20. Expected: the Paid accounting value stays USD 25, with original EUR 20 preserved. New nullable schema-31 revision evidence books that value atomically. Same-currency corrections append using the original rate; original-booked refunds use cumulative exact rounding. Legacy records remain null/labelled and are not guessed or repaired. Automated reproduction: test/core/services/fx_booking_test.dart.

Integration findings and fixes: initial Medical runs rejected the existing next-month payout attribution; booking now explicitly preserves that rule and payout corrections append revisions. Purchase lost-response retries initially compared the new service-generated FX bytes against an unbooked draft; retry comparison now checks submitted contents while retaining committed evidence. Month-End previously exposed a raw FormatException instead of its domain error on unsupported currency; the public failure now remains MonthEndException. Evidence test fixtures without an owner were corrected to seed a real profile. No assertion was disabled or weakened. A Planned purchase move remains covered; moving booked money to another owner is explicitly refused before changes rather than silently rebased.

Security/precision checks: bounded rational amounts, 1:1 same-currency evidence, append-only hashes, signed owner/target bindings, missing-parent rollback/retry, downgrade refusal and overlapping offline refund rejection. Native schema reopening preserves legacy original values; real Medical, ordinary refunds, bulk/purchase and report/vault integrations are tested. New display helpers and compact audit values use booked amounts without exposing raw revision JSON. Existing audit/database-replacement verification limits remain.

Final verification: combined full suite passed **1,384 with one pre-existing skip**, including final display and signed-conflict regressions, exit 0. Full static analysis passed, no issues. Formatting audit: 619 files, zero changes, exit 0. Isolated 10,000-row search passed at 194.747ms on Windows x64/Dart 3.13.5 (query/filter/sort only, close to 200ms; not phone-rendering evidence). Targeted generator rerun succeeded; exactly the two intended generated financial outputs differ from the 41-file pre-FX baseline, with historical fixtures intact. Debug APK built successfully; 245,339,397 bytes, SHA-256 AF621584C8021151DD2B17FBFE60F9437937EA459243D5B522C0819ACE6CF82C; no installation. Full results/files/limits are in specs/018-financial-core-audit/final-phase-fx-delivery-report.md. No new dependency, skip, analyzer suppression or Git operation was introduced. Post-hook file absent.

Status: implemented, final verified delivery acceptance pending. Owner phone outcomes remain unreported. Optional location and the SC-007 user study remain explicitly deferred, not passed. Final/correction task markers remain unchecked until owner acceptance.

Final compatibility review: the first parent-validation guard would have blocked an explicitly orphaned booked refund after permitted expense deletion. It now preserves that signed self-contained evidence and review flag without inventing the deleted payment or revaluing money; existing orphan evidence cannot be rewritten. Update and fresh-bootstrap-to-another-local-space-ID regressions pass. Full suite was rerun afterward: 1,384 passed / one existing skipped, exit 0. Analysis remains clear, formatting remains 619 files / zero changes, and the debug APK was rebuilt afterward (45.7s). Current artifact hash above and full delivery report were updated. No agent phone actions were performed.

