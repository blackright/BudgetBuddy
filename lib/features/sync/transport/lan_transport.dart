import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:basic_utils/basic_utils.dart' as bu;
import 'package:cryptography/cryptography.dart';
import 'package:nsd/nsd.dart' as nsd;

import 'transport.dart';

/// The mDNS service type devices advertise under (research R2). The first label
/// must be 1–15 chars of `A–Z a–z 0–9 -` with at least one letter.
const String kLanServiceType = '_buddybuddy._tcp';

/// The only secret ever sent before mutual pairing is the username + a random
/// nonce; no financial data ever leaves the device (SC-008).
const int _kHandshakeVersion = 1;

/// A device-local TLS identity (a self-signed certificate + its private key).
///
/// The certificate is *not* the trust anchor: peers authenticate each other by
/// signing a fresh nonce with their paired ed25519 identity key. The certificate
/// only turns the socket into an encrypted channel, so the identity key is what
/// actually pins the peer (research R2).
class LanTlsIdentity {
  LanTlsIdentity._(this.certificatePem, this.privateKeyPem);

  final String certificatePem;
  final String privateKeyPem;

  SecurityContext get context => SecurityContext()
    ..useCertificateChainBytes(utf8.encode(certificatePem))
    ..usePrivateKeyBytes(utf8.encode(privateKeyPem));

  /// Generates a fresh RSA-2048 self-signed certificate valid for two years.
  ///
  /// Generation costs a few hundred milliseconds, so callers build one per
  /// session rather than per connection.
  factory LanTlsIdentity.generate({String commonName = 'buddybuddy.local'}) {
    final keyPair = bu.CryptoUtils.generateRSAKeyPair();
    final privateKey = keyPair.privateKey as bu.RSAPrivateKey;
    final publicKey = keyPair.publicKey as bu.RSAPublicKey;
    final csr = bu.X509Utils.generateRsaCsrPem(
      {'CN': commonName, 'O': 'BudgetBuddy'},
      privateKey,
      publicKey,
    );
    final certificate = bu.X509Utils.generateSelfSignedCertificate(
      privateKey,
      csr,
      825,
    );
    final keyPem = bu.CryptoUtils.encodeRSAPrivateKeyToPem(privateKey);
    return LanTlsIdentity._(certificate, keyPem);
  }
}

/// Discovers paired peers over mDNS and opens pinned-TLS connections to them
/// (research R2, `contracts/sync-protocol.md` §3).
///
/// This is the production [Transport]. It stays payload-agnostic: callers send
/// canonical JSON envelopes and the framing (newline-delimited UTF-8) is hidden
/// here. Tests keep using the in-memory `FakeTransport`, so CI never opens a
/// socket.
class LanTransport implements Transport {
  LanTransport({
    required this.identityId,
    required this.username,
    required String Function(String identityId) pinnedPublicKey,
    String serviceType = kLanServiceType,
  })  : _pinnedPublicKey = pinnedPublicKey,
        _serviceType = serviceType;

  /// This device's identity fingerprint, announced in the handshake.
  final String identityId;

  final String username;

  final String Function(String identityId) _pinnedPublicKey;
  final String _serviceType;

  @override
  Stream<PeerAdvertisement> discover({
    Duration timeout = const Duration(seconds: 5),
  }) {
    final controller = StreamController<PeerAdvertisement>();
    nsd.Discovery? discovery;
    Timer? timer;

    controller.onListen = () async {
      discovery = await nsd.startDiscovery(_serviceType, autoResolve: true);

      void listener(nsd.Service service, nsd.ServiceStatus status) {
        if (status != nsd.ServiceStatus.found) return;
        final advertisement = _advertisementOf(service);
        if (advertisement != null && advertisement.identityId != identityId) {
          controller.add(advertisement);
        }
      }

      discovery!.addServiceListener(listener);
      for (final service in discovery!.services) {
        listener(service, nsd.ServiceStatus.found);
      }
      timer = Timer(timeout, () {
        if (!controller.isClosed) controller.close();
      });
    };

    controller.onCancel = () async {
      timer?.cancel();
      final active = discovery;
      discovery = null;
      if (active != null) await nsd.stopDiscovery(active);
    };

    return controller.stream;
  }

  @override
  Future<TransportConnection> connect(PeerAdvertisement peer) async {
    final socket = await SecureSocket.connect(
      peer.host,
      peer.port,
      onBadCertificate: (_) => true,
    );

    try {
      final incoming = StreamController<String>();
      final proof = Completer<String>();
      bool sawFirstLine = false;

      socket
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
        (line) {
          if (!sawFirstLine) {
            sawFirstLine = true;
            proof.complete(line);
          } else {
            incoming.add(line);
          }
        },
        onError: incoming.addError,
        onDone: incoming.close,
      );

      final nonce = _newNonce();
      socket.write('${jsonEncode({
            'v': _kHandshakeVersion,
            'type': 'hello',
            'identityId': identityId,
            'nonce': nonce,
          })}\n');
      await socket.flush();

      final proofLine = await proof.future.timeout(const Duration(seconds: 10));
      await _verifyProof(proofLine, peer, nonce);

      return _LanConnection(peer.identityId, socket, incoming.stream);
    } on Object {
      await socket.close();
      rethrow;
    }
  }

  Future<void> _verifyProof(
    String proofLine,
    PeerAdvertisement peer,
    String nonce,
  ) async {
    final Map<String, dynamic> proof;
    try {
      proof = jsonDecode(proofLine) as Map<String, dynamic>;
    } on Object {
      throw const TransportHandshakeException('The peer replied with junk.');
    }
    if (proof['type'] != 'proof' || proof['identityId'] != peer.identityId) {
      throw const TransportHandshakeException(
        'The peer on the LAN is not the one we paired with.',
      );
    }
    final signature = proof['signature'];
    if (signature is! String) {
      throw const TransportHandshakeException('The peer sent no proof.');
    }
    final pinned = _pinnedPublicKey(peer.identityId);
    if (pinned.isEmpty) {
      throw const TransportHandshakeException(
        'We have no key pinned for this peer.',
      );
    }
    final verified = await Ed25519().verify(
      utf8.encode('buddy-proof:$nonce'),
      signature: Signature(
        base64Decode(signature),
        publicKey: SimplePublicKey(
          base64Decode(pinned),
          type: KeyPairType.ed25519,
        ),
      ),
    );
    if (!verified) {
      throw const TransportHandshakeException(
        'The peer could not prove it holds the paired key.',
      );
    }
  }

  PeerAdvertisement? _advertisementOf(nsd.Service service) {
    final id = _txtString(service.txt, 'id');
    if (id == null || id.isEmpty) return null;
    final host = service.addresses?.isNotEmpty == true
        ? service.addresses!.first.address
        : service.host;
    final port = service.port;
    if (host == null || port == null) return null;
    return PeerAdvertisement(
      identityId: id,
      username: _txtString(service.txt, 'name') ?? 'A paired device',
      host: host,
      port: port,
    );
  }

  static String? _txtString(Map<String, Uint8List?>? txt, String key) {
    final bytes = txt?[key];
    return bytes == null ? null : utf8.decode(bytes);
  }

  static String _newNonce() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }
}

/// Advertises this device over mDNS and serves pinned-TLS connections from
/// paired peers (research R2).
///
/// The app constructs one while a pairing or exchange screen is open, holding
/// the identity key that was just unlocked; there is no background service, so
/// nothing signs while the phone is locked.
class LanTransportHost {
  LanTransportHost({
    required this.identityId,
    required this.username,
    required SimpleKeyPair signingKey,
    String serviceType = kLanServiceType,
    Ed25519? algorithm,
    LanTlsIdentity? tlsIdentity,
  })  : _signingKey = signingKey,
        _ed25519 = algorithm ?? Ed25519(),
        _serviceType = serviceType,
        _tls = tlsIdentity ?? LanTlsIdentity.generate();

  final String identityId;
  final String username;

  final SimpleKeyPair _signingKey;
  final Ed25519 _ed25519;
  final String _serviceType;
  final LanTlsIdentity _tls;

  final StreamController<TransportConnection> _connections =
      StreamController<TransportConnection>.broadcast();

  SecureServerSocket? _server;
  nsd.Registration? _registration;
  StreamSubscription<SecureSocket>? _subscription;

  /// Connections from peers that just proved they hold their paired key.
  Stream<TransportConnection> get connections => _connections.stream;

  /// The port the socket is bound to (useful for tests and diagnostics).
  int? get port => _server?.port;

  /// Binds an ephemeral TLS port and starts advertising. Returns that port.
  Future<int> start() async {
    final server = await SecureServerSocket.bind(
      InternetAddress.anyIPv4,
      0,
      _tls.context,
    );
    _server = server;
    _subscription = server.listen(_handleSocket, onError: (_) {});
    try {
      _registration = await nsd.register(
        nsd.Service(
          name: 'Buddy ${identityId.substring(0, 6)}',
          type: _serviceType,
          port: server.port,
          txt: {
            'id': Uint8List.fromList(utf8.encode(identityId)),
            'name': Uint8List.fromList(utf8.encode(username)),
          },
        ),
      );
    } on Object {
      await server.close();
      rethrow;
    }
    return server.port;
  }

  Future<void> _handleSocket(SecureSocket socket) async {
    try {
      final incoming = StreamController<String>();
      final hello = Completer<Map<String, dynamic>>();
      bool sawFirstLine = false;

      socket
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
        (line) {
          if (!sawFirstLine) {
            sawFirstLine = true;
            try {
              hello.complete(jsonDecode(line) as Map<String, dynamic>);
            } on Object {
              hello.completeError(
                const TransportHandshakeException('The peer sent junk.'),
              );
            }
          } else {
            incoming.add(line);
          }
        },
        onError: incoming.addError,
        onDone: incoming.close,
      );

      final helloData = await hello.future.timeout(const Duration(seconds: 10));
      final peerIdentityId = helloData['identityId'];
      final nonce = helloData['nonce'];
      if (peerIdentityId is! String || nonce is! String) {
        throw const TransportHandshakeException('The peer sent no identity.');
      }

      final signature = await _ed25519.sign(
        utf8.encode('buddy-proof:$nonce'),
        keyPair: _signingKey,
      );
      socket.write('${jsonEncode({
            'v': _kHandshakeVersion,
            'type': 'proof',
            'identityId': identityId,
            'signature': base64Encode(signature.bytes),
          })}\n');
      await socket.flush();

      _connections.add(_LanConnection(peerIdentityId, socket, incoming.stream));
    } on Object {
      await socket.close();
    }
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    final registration = _registration;
    _registration = null;
    if (registration != null) {
      try {
        await nsd.unregister(registration);
      } on Object {
        // Unregistering a service the OS already dropped must not throw.
      }
    }
    await _server?.close();
    _server = null;
    await _connections.close();
  }
}

/// A live connection to one paired peer over a pinned-TLS socket.
class _LanConnection implements TransportConnection {
  _LanConnection(this.peerIdentityId, this._socket, this._incoming);

  @override
  final String peerIdentityId;

  final SecureSocket _socket;
  final Stream<String> _incoming;

  @override
  Stream<String> get incoming => _incoming;

  @override
  Future<void> send(String message) async {
    _socket.write('$message\n');
    await _socket.flush();
  }

  @override
  Future<void> close() => _socket.close();
}

/// Raised when a LAN peer cannot prove it holds the key we paired with.
class TransportHandshakeException implements Exception {
  const TransportHandshakeException(this.message);

  final String message;

  @override
  String toString() => 'TransportHandshakeException: $message';
}
