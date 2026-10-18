import 'dart:convert';
import 'dart:io';

import 'package:budget_buddy/features/sync/transport/lan_transport.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';

/// The one production transport that cannot be faked without losing the bug:
/// `main.dart` reuses a single [LanTransportHost] across every
/// foreground/background cycle (`start` on resume, `stop` on pause). If `stop`
/// leaves the connection controller permanently closed, every later inbound
/// connection is silently swallowed — which is exactly why a phone that was
/// briefly backgrounded never sees its peer's space.
void main() {
  test('an inbound connection is accepted again after stop() then start()',
      () async {
    final host = LanTransportHost(
      identityId: 'host-id',
      username: 'Host',
      signingKey: await Ed25519().newKeyPair(),
    );
    addTearDown(host.stop);

    Future<void> expectAccept(int port) async {
      final accepted =
          host.connections.first.timeout(const Duration(seconds: 10));
      final socket = await SecureSocket.connect(
        '127.0.0.1',
        port,
        onBadCertificate: (_) => true,
      );
      socket.write('${jsonEncode({
            'v': 1,
            'type': 'hello',
            'identityId': 'peer-id',
            'nonce': 'nonce',
          })}\n');
      await socket.flush();

      final connection = await accepted;
      expect(connection.peerIdentityId, 'peer-id');
      await socket.close();
    }

    final firstPort = await host.start();
    await expectAccept(firstPort);

    // The foreground → background → foreground cycle the lifecycle observer runs.
    await host.stop();
    final secondPort = await host.start();
    await expectAccept(secondPort);
  });
}
