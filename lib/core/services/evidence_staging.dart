import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'expense_evidence.dart';

/// Only app-created staging files are ever removed. Gallery originals and
/// picker-owned files are never moved or deleted.
abstract final class EvidenceStaging {
  static final _active = <String>{};
  static Future<Directory>? _root;
  static Future<Directory> root() async {
    try {
      return await (_root ??= _initialize());
    } catch (_) {
      _root = null;
      rethrow;
    }
  }

  static Future<Directory> _initialize() async {
    final temporary = await getTemporaryDirectory();
    await for (final entity in temporary.list(followLinks: false)) {
      if (entity is File &&
          entity.uri.pathSegments.last.startsWith('payment-preview-') &&
          entity.path.endsWith('.pdf')) {
        await entity.delete();
      }
    }
    final directory = Directory(
        '${temporary.path}${Platform.pathSeparator}expense_evidence_staging');
    await directory.create(recursive: true);
    // A fresh process has no active in-memory drafts. These are abandoned
    // uploads from a previous process, never committed evidence.
    await for (final entity in directory.list(followLinks: false)) {
      if (entity is File && entity.path.endsWith('.stage')) {
        await entity.delete();
      }
    }
    return directory;
  }

  static Future<PreparedEvidence> stage(PreparedEvidence prepared) async {
    final directory = await root();
    final file = File(
        '${directory.path}${Platform.pathSeparator}${prepared.document.guid}.stage');
    try {
      await file.writeAsBytes(prepared.bytes, flush: true);
      _active.add(file.path);
      return PreparedEvidence(prepared.document, Uint8List(0),
          stagedPath: file.path);
    } catch (_) {
      if (await file.exists()) await file.delete();
      rethrow;
    }
  }

  static Future<Uint8List> read(String path) async {
    final directory = await root();
    final file = File(path);
    final resolvedRoot = await directory.resolveSymbolicLinks();
    final resolved = await file.resolveSymbolicLinks();
    if (!_active.contains(path) ||
        !resolved.startsWith('$resolvedRoot${Platform.pathSeparator}') ||
        !resolved.endsWith('.stage') ||
        await file.length() > evidenceMaximumBytes) {
      throw const FormatException(
          'Temporary payment document is unavailable. Choose it again.');
    }
    return file.readAsBytes();
  }

  static Future<void> discard(String? path) async {
    if (path == null || !_active.remove(path)) return;
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}
