import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/identity_provider.dart';
import '../repositories/consent_service.dart';

/// The plain-language consent notice shown before the optional device-auth
/// toggle (FR-002). Bumping [kConsentNoticeVersion] re-asks the question.
const String kDeviceAuthConsentNotice =
    'BudgetBuddy can use your phone\'s own PIN or biometrics to protect your '
    'identity key. It never creates or stores a PIN of its own, and your choice '
    'is optional, stored on this phone only, and can be changed any time.';

/// US1 (FR-001/002/016): the onboarding screen that turns a chosen username into
/// a local identity.
///
/// No account, no email, no password and no server: the username is a label and
/// the real identity is the device-generated keypair (`IdentityService`). The
/// screen also records the user's voluntary consent about using the phone's own
/// authentication. It pops `true` once the identity exists.
class IdentityOnboardingScreen extends ConsumerStatefulWidget {
  const IdentityOnboardingScreen({super.key});

  @override
  ConsumerState<IdentityOnboardingScreen> createState() =>
      _IdentityOnboardingScreenState();
}

class _IdentityOnboardingScreenState
    extends ConsumerState<IdentityOnboardingScreen> {
  final _username = TextEditingController();
  bool _deviceAuth = false;
  bool _busy = false;

  @override
  void dispose() {
    _username.dispose();
    super.dispose();
  }

  /// Prompts the phone's own authentication before enabling the gate, so the
  /// user only turns it on after a successful unlock (FR-002 AC2). A declined
  /// prompt leaves the toggle off and the app fully usable.
  Future<void> _setDeviceAuth(bool value) async {
    if (!value) {
      setState(() => _deviceAuth = false);
      return;
    }
    final ok = await ref
        .read(deviceAuthenticatorProvider)
        .authenticate(reason: 'Enable device authentication for BudgetBuddy');
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Device authentication was not set up.'),
        ),
      );
      return;
    }
    setState(() => _deviceAuth = true);
  }

  Future<void> _create() async {
    final username = _username.text.trim();
    if (username.isEmpty) return;

    final activeProfileId = ref.read(actingProfileIdProvider);
    if (activeProfileId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create a profile first, then retry.')),
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    try {
      await ref.read(identityServiceProvider).createIdentity(
            username: username,
            localProfileId: activeProfileId,
          );
      await ref.read(consentServiceProvider).record(
            noticeVersion: kConsentNoticeVersion,
            deviceAuthGranted: _deviceAuth,
          );
      if (!mounted) return;
      navigator.pop(true);
    } on ArgumentError {
      if (!mounted) return;
      setState(() => _busy = false);
      messenger.showSnackBar(
        const SnackBar(content: Text('Please choose a username.')),
      );
    } on StateError {
      if (!mounted) return;
      setState(() => _busy = false);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('This device already has an identity.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canCreate = _username.text.trim().isNotEmpty && !_busy;

    return Scaffold(
      appBar: AppBar(title: const Text('Your identity')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'No account, no email, no sign-up.',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Pick a name for yourself. Sharing with another device uses a key '
            'created and kept on this phone.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          TextField(
            key: const Key('identityUsernameField'),
            controller: _username,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Username',
              hintText: 'e.g. Ava',
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                kDeviceAuthConsentNotice,
                key: const Key('consentNotice'),
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            key: const Key('deviceAuthToggle'),
            value: _deviceAuth,
            onChanged: _busy ? null : _setDeviceAuth,
            title: const Text('Use my phone\'s PIN or biometrics'),
            subtitle: const Text('Recommended'),
          ),
          if (!_deviceAuth)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded,
                      size: 18, color: theme.colorScheme.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Without your phone\'s PIN or biometrics, your data is '
                      'less protected.',
                      key: const Key('deviceAuthWarning'),
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.error),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          FilledButton(
            key: const Key('createIdentityButton'),
            onPressed: canCreate ? _create : null,
            child: const Text('Create my identity'),
          ),
        ],
      ),
    );
  }
}
