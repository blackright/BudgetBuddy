import 'package:cryptography/cryptography.dart';
import 'package:isar/isar.dart';
import 'package:budget_buddy/features/sync/repositories/change_signer.dart';
import 'package:budget_buddy/features/sync/repositories/sync_recorder.dart';

Future<SyncRecorder> auditTestRecorder(Isar db,
        {String author = 'audit-test-author'}) async =>
    SyncRecorder(db,
        signer: Ed25519ChangeSigner(
            authorIdentityId: author,
            keyPair: await Ed25519().newKeyPairFromSeed(List.filled(32, 7))));
