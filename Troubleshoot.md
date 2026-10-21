You are a friendly, expert coding coach. Your job is to look at the code error I give you, figure out exactly why it broke, and explain it to me using very simple language—like you are talking to a beginner or a child. 

CRITICAL RULE: You must STOP and wait for my explicit approval after you show me your plan. Do not change any files or run any code commands until I say "Approved" or "Proceed".

Please format your response exactly like this:

### 🔍 1. What Happened? (The Error)
* **The Oopsie:** Explain what broke in super simple, plain English. Use a fun everyday analogy (like a broken toy or a mixed-up recipe) if it helps!
* **Why It Happened:** Explain the root technical cause using easy words. No confusing jargon. 

### 🛠️ 2. The Fix-It Plan
* **The Smartest Fix:** How do real-world experts fix this perfectly? Explain it simply.
* **Other Ideas I Tossed Out:** Briefly mention one quick fix you ignored, and tell me in 1 simple sentence why it wasn't good enough.

### 📋 3. Step-by-Step To-Do List
Give me a clear, simple list of exactly what needs to change:
* Which files we need to open.
* The basic changes we need to make to the code.
* How we will test it afterwards to make sure it works.

### 🛑 STOP! WALKING GATE AHEAD
I am stopping here. Please read over my explanation and the plan. If you like it and want to fix it, just reply with the word "Approved" and I will start typing up the code for you!
--------------------------------------------------
[CONTEXT & CODE ERRORS START]
{{

================================================================
PHASE 8 RESULT — Polish & Cross-Cutting Concerns — 016-app-security
Status: DONE (code-and-test half). Reported for approval.
================================================================

TESTS (all green)
-----------------
  test/features/security/lock_accessibility_test.dart       (T070)  4 assertions
  test/features/security/no_secret_in_logs_test.dart        (T071)  6 assertions
  test/features/security/schema_migration_19_test.dart      (T072)  pre-existing, re-run green
  test/features/security/no_history_test.dart               (T078)  6 assertions
  test/features/security/no_bypass_test.dart                (T079)  5 assertions
  test/features/security/backup_exclusion_test.dart         (T080)  6 assertions

Suite: 944 passing, 1 skipped, 0 failed. (Was 917 at the start of this phase.)
Analysis: `flutter analyze --no-pub` clean.
Format: `dart format --set-exit-if-changed lib test` → 0 changed.

THE FALSE TICK IS FIXED
-----------------------
T073 was ticked while 26 files were still unformatted. I ran `dart format`,
which actually changed them, so the tick is now true rather than removed.

WHAT WAS BUILT
--------------
* lib/features/security/presentation/lock_screen.dart
    - the genuine T070 gap: the lock screen had NO Semantics at all. Added a
      spoken "Ann, locked" label for the avatar+name (as one unit, with the
      children excluded so the name is not read twice), and explicit labels on
      the Unlock and Set up PIN actions.
    - The keypad and PIN screens already carried their labels and live-region
      countdown; the test now locks that in so it cannot regress.
* android/app/src/main/AndroidManifest.xml
    - android:allowBackup="false", android:fullBackupContent, and
      android:dataExtractionRules.
* android/app/src/main/res/xml/data_extraction_rules.xml  (NEW, Android 12+)
* android/app/src/main/res/xml/backup_rules.xml           (NEW, Android 11-)
    - Both files are required: the newer format is ignored on older devices.
      Both exclude the `sharedpref` domain, which is where flutter_secure_storage
      keeps the PIN verifier and the lockout record.
    - Syntax taken from the current Android "Back up user data with Auto Backup"
      guide, not guessed.
* specs/016-app-security/quickstart.md
    - fill-in recording sheets added for §5 (T075), the SC-004 timing table
      (T077), and §6 two-phone (T076).

TESTS PROVED REAL, NOT HOLLOW
-----------------------------
* T070: removing the new "Ann, locked" label makes the test FAIL, then restoring
  it makes it pass again — so it genuinely guards the new code.
* T071: injecting a `print('LEAK pin=$pin')` into PinVerifierStore makes the
  guard FAIL — so it genuinely catches a leak.
* T078 taught me a real fact: a running wait blocks even a CORRECT PIN
  (FR-013). My first draft asserted the opposite; the code was right and my
  draft was wrong, so both halves are now asserted.

THE T077 NUMBER — YOUR DECISION APPLIED
---------------------------------------
You chose to leave the 150 ms set-side target alone. Done: no code changed.
T077's wording in tasks.md now states plainly that SC-004's 300 ms is the
UNLOCK budget and the KDF's 150 ms is a separate set-side calibration budget.
The quickstart's timing sheet repeats that note so the two are not confused
during the walk.

WHAT I DID NOT DO (and will not fake)
-------------------------------------
T075 (on-device, one phone), T076 (two phones) and T077 (the SC-004 benchmark)
need real hardware. They remain UNTICKED. I prepared the recording sheets so
the walk is fill-in-the-blank, but the observed numbers are yours to record.

Files changed are all local and uncommitted. No git command was run.
}}
[CONTEXT & CODE ERRORS END]
