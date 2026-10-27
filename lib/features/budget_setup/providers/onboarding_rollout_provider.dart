import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Phase 3 is deliberately inactive in production. Disposable test hosts can
/// override this single gate for the form, coordinator and category-read policy.
/// No preference, hidden route or user toggle enables it before later safeguards.
final unifiedOnboardingEnabledProvider = Provider<bool>((ref) => false);
