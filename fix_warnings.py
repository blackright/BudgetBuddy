files = ['test/features/security/away_time_test.dart','test/features/security/lock_drops_session_key_test.dart','test/features/security/lock_lifecycle_observer_test.dart','test/features/security/subject_switch_test.dart']
for f in files:
    s = open(f).read()
    s = s.replace("import 'package:budget_buddy/features/security/domain/lock_state.dart';\n", '')
    # Fix unused variable in lock_drops_session_key_test.dart
    s = s.replace("    final controller = container.read(lockControllerProvider.notifier);\n    // Never unlocked", "    // Never unlocked")
    open(f,'w').write(s)
print('done')
