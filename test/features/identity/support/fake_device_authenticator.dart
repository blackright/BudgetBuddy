import 'package:budget_buddy/features/identity/repositories/device_authenticator.dart';

/// A programmable stand-in for the phone's PIN/biometrics (research R1/R8).
///
/// Tests never touch real hardware: [allow] decides the verdict, [available]
/// the capability, and every prompt is counted so a test can prove the app
/// actually asked before releasing the identity key.
class FakeDeviceAuthenticator implements DeviceAuthenticator {
  FakeDeviceAuthenticator({this.available = true, this.allow = true});

  bool available;

  /// The verdict returned by [authenticate] (also used while [available] is
  /// true). Kept mutable so a test can flip a decline into a grant.
  bool allow;

  int authenticateCalls = 0;
  final List<String> reasons = [];

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<bool> authenticate({required String reason}) async {
    authenticateCalls++;
    reasons.add(reason);
    return available && allow;
  }
}
