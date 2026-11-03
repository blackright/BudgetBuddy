/// In-memory drafts for management sheets, scoped to one bill/action.
///
/// A draft lives only for the app session; it never enters the database. It is
/// cleared when the command succeeds, so a dismissed sheet can still be
/// resumed after the screen rebuilds or the bill's stage changes.
class MedicalManagementDrafts {
  MedicalManagementDrafts._();

  static final Map<String, String> _text = {};
  static final Map<String, DateTime> _dates = {};
  static final Map<String, List<String>> _documents = {};

  static String _key(int billId, String action, String field) =>
      '$billId:$action:$field';

  static String? text(int billId, String action, String field) =>
      _text[_key(billId, action, field)];

  static void setText(int billId, String action, String field, String? value) {
    final key = _key(billId, action, field);
    if (value == null || value.isEmpty) {
      _text.remove(key);
    } else {
      _text[key] = value;
    }
  }

  static DateTime? date(int billId, String action, String field) =>
      _dates[_key(billId, action, field)];

  static void setDate(int billId, String action, String field, DateTime value) {
    _dates[_key(billId, action, field)] = value;
  }

  static List<String> documents(int billId, String action) =>
      List.of(_documents[_key(billId, action, 'documents')] ?? const []);

  static void setDocuments(int billId, String action, List<String> documents) {
    final key = _key(billId, action, 'documents');
    if (documents.isEmpty) {
      _documents.remove(key);
    } else {
      _documents[key] = List.of(documents);
    }
  }

  static void clear(int billId, String action) {
    final prefix = '$billId:$action:';
    _text.removeWhere((key, _) => key.startsWith(prefix));
    _dates.removeWhere((key, _) => key.startsWith(prefix));
    _documents.removeWhere((key, _) => key.startsWith(prefix));
  }
}
