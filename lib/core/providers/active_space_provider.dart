import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/isar_helper.dart';
import '../models/shared_space.dart';

/// The selected shared space's id. `null` means personal context; non-null means
/// the router resolves through a shared space (context-router §2). Selecting a
/// space writes this marker; selecting a profile clears it (T037).
final activeSpaceIdProvider = StateProvider<int?>((ref) => null);

/// The selected [SharedSpace] row, `null` in personal context.
final activeSpaceProvider = StreamProvider<SharedSpace?>((ref) {
  final spaceId = ref.watch(activeSpaceIdProvider);
  if (spaceId == null) return Stream.value(null);
  final isar = IsarHelper.instance;
  return isar.sharedSpaces.watchObject(spaceId, fireImmediately: true);
});
