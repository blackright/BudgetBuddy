/// First-launch baseline rate table, referenced to USD (research R11).
///
/// Ships in the binary so a brand-new install has *a* table offline; every
/// value it produces is labelled `bundled` (≈ approximate) until the first
/// real fetch replaces it. Numbers are approximate on purpose — the seal
/// machinery upgrades them as soon as the device is online.
library;

import '../models/currency_code.dart';

/// Units of [code] per 1 USD.
const Map<CurrencyCode, double> kBundledUsdRates = {
  CurrencyCode.usd: 1.0,
  CurrencyCode.eur: 0.86,
  CurrencyCode.huf: 345.0,
  CurrencyCode.cad: 1.36,
};
