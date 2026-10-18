import 'dart:convert';
import 'dart:io';

import 'package:budget_buddy/features/sync/transport/lan_transport.dart';
import 'package:budget_buddy/features/sync/transport/transport.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';

/// US4 (T055a): confidentiality & authentication of the link (FR-015, SC-008).
///
/// The socket is TLS, so a passive Wi-Fi listener recovers nothing (see quickstart
/// Scenario E, the laptop packet-capture step); and the dialer only opens a
/// session once the far end proves it holds the **pinned** paired key. These drive
/// the real production transport (`LanTransport`/`LanTransportHost`) over
/// loopback sockets, because that is exactly the code the in-memory
/// `FakeTransport` cannot cover.
///
/// A stand-in peer that completes the TLS socket, reads the dialer's `hello`, and
/// answers with a `proof`. [signWith] decides whose key it proves — the pinned one
/// (a genuine peer) or a different one (an impostor).
Future<({SecureServerSocket server, List<String> received})> _startResponder({
  required SimpleKeyPair signWith,
  required String identityId,
}) async {
  final received = <String>[];
  final server = await SecureServerSocket.bind(
    '127.0.0.1',
    0,
    LanTlsIdentity.generate().context,
  );
  server.listen((socket) {
    socket
        .cast<List<int>>()
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
      (line) async {
        received.add(line);
        if (received.length != 1) return; // only answer the first hello
        final hello = jsonDecode(line) as Map<String, dynamic>;
        final signature = await Ed25519().sign(
          utf8.encode('buddy-proof:${hello['nonce']}'),
          keyPair: signWith,
        );
        socket.write('${jsonEncode({
              'v': 1,
              'type': 'proof',
              'identityId': identityId,
              'signature': base64Encode(signature.bytes),
            })}\n');
        await socket.flush();
      },
      onError: (_) {},
      onDone: () {},
    );
  });
  return (server: server, received: received);
}

void main() {
  test(
      'a peer that cannot prove the pinned key is refused, and gets zero '
      'payload bytes (FR-015, SC-008)', () async {
    final pinnedKeys = await Ed25519().newKeyPair();
    final pinned = base64Encode((await pinnedKeys.extractPublicKey()).bytes);
    final impostorKeys = await Ed25519().newKeyPair();
    final responder =
        await _startResponder(signWith: impostorKeys, identityId: 'idB');
    addTearDown(() => responder.server.close());

    final transport = LanTransport(
      identityId: 'idA',
      username: 'A',
      pinnedPublicKey: (_) => pinned,
    );
    final advertisement = PeerAdvertisement(
      identityId: 'idB',
      username: 'B',
      host: '127.0.0.1',
      port: responder.server.port,
    );

    await expectLater(
      transport.connect(advertisement),
      throwsA(isA<TransportHandshakeException>()),
    );
    // Give any (wrongly) queued payload a chance to arrive before we assert.
    await Future<void>.delayed(const Duration(milliseconds: 150));

    // Only the handshake hello crossed the wire. No snapshot, no envelope.
    expect(responder.received, hasLength(1),
        reason: 'a failed proof never yields a session, so no payload follows');
    expect(responder.received.single, contains('"type":"hello"'));
  });

  test('a peer that does prove the pinned key opens the session (FR-015)',
      () async {
    final pinnedKeys = await Ed25519().newKeyPair();
    final pinned = base64Encode((await pinnedKeys.extractPublicKey()).bytes);
    final responder =
        await _startResponder(signWith: pinnedKeys, identityId: 'idB');
    addTearDown(() => responder.server.close());

    final transport = LanTransport(
      identityId: 'idA',
      username: 'A',
      pinnedPublicKey: (_) => pinned,
    );
    final connection = await transport.connect(PeerAdvertisement(
      identityId: 'idB',
      username: 'B',
      host: '127.0.0.1',
      port: responder.server.port,
    ));

    expect(connection.peerIdentityId, 'idB');
    await connection.close();
  });

  test('the channel is TLS: a plain client cannot open a session (SC-008)',
      () async {
    final host = LanTransportHost(
      identityId: 'host-id',
      username: 'Host',
      signingKey: await Ed25519().newKeyPair(),
      tlsIdentity: LanTlsIdentity.generate(),
    );
    addTearDown(host.stop);
    final port = await host.start();

    final sawSession = host.connections.first
        .then((_) => true)
        .timeout(const Duration(milliseconds: 800), onTimeout: () => false);

    // A passive listener / non-TLS client speaks plain bytes; the TLS socket
    // never completes a handshake, so no session is ever yielded to the engine.
    final plain = await Socket.connect('127.0.0.1', port);
    plain.write('hello not-a-tls-handshake\n');
    await plain.flush();

    expect(await sawSession, isFalse,
        reason: 'a non-TLS client never yields a session');
    await plain.close();
  });
}
