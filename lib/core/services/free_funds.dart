/// Shared monthly definition. Integer inputs are authoritative minor-unit
/// accounting; doubles are supported only for the legacy display projection.
int sumFinancialMinor(Iterable<int> values) {
  final bound = BigInt.from(9007199254740991);
  var total = BigInt.zero;
  for (final value in values) {
    final integer = BigInt.from(value);
    if (integer.abs() > bound) {
      throw const FormatException('A monthly amount needs review.');
    }
    total += integer;
  }
  if (total.abs() > bound) {
    throw const FormatException('Monthly funds exceed the supported range.');
  }
  return total.toInt();
}

num freeToSpend(
    {required num income,
    required num paid,
    required num returned,
    required num unused,
    num carry = 0,
    num incoming = 0,
    num released = 0,
    num transfers = 0}) {
  final values = [
    income,
    -paid,
    returned,
    -unused,
    -carry,
    incoming,
    released,
    transfers
  ];
  if (values.every((v) => v is int)) {
    return sumFinancialMinor(values.cast<int>());
  }
  if (values.any((v) => !v.isFinite)) {
    throw const FormatException('A monthly amount needs review.');
  }
  return values.fold<double>(0, (sum, value) => sum + value);
}
