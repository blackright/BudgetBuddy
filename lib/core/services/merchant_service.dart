/// Normalize only whitespace/case. Do not guess aliases or remove accents.
String merchantDisplayName(String name) =>
    name.trim().replaceAll(RegExp(r'\s+'), ' ');
String merchantKey(String name) => merchantDisplayName(name).toLowerCase();

List<String> normalizeExpenseTags(Iterable<String> tags) {
  final seen = <String>{};
  return [
    for (final tag in tags.map(merchantDisplayName))
      if (tag.isNotEmpty && seen.add(tag.toLowerCase())) tag
  ];
}

const expensePaymentMethods = {
  'cash': 'Cash',
  'card': 'Card',
  'bankTransfer': 'Bank transfer',
  'other': 'Other',
};
