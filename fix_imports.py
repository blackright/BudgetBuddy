files = [
  'test/features/security/away_time_test.dart',
  'test/features/security/lock_lifecycle_observer_test.dart',
  'test/features/security/subject_switch_test.dart',
  'test/features/security/lock_drops_session_key_test.dart',
]
old = "import 'package:budget_buddy/features/identity/repositories/device_authenticator.dart';"
new = "import 'package:budget_buddy/features/identity/repositories/device_authenticator.dart';\nimport 'package:budget_buddy/features/identity/repositories/local_auth_outcome.dart';"
for f in files:
    s = open(f).read()
    if 'local_auth_outcome' not in s:
        s = s.replace(old, new)
    open(f, 'w').write(s)
print('done')
