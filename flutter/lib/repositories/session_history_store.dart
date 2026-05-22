import 'package:shared_preferences/shared_preferences.dart';

import '../models/session_record.dart';

class SessionHistoryStore {
  static const _key = 'session_history';
  static const _maxRecords = 100;

  Future<List<SessionRecord>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final values = prefs.getStringList(_key) ?? const [];
    final records = <SessionRecord>[];

    for (final value in values) {
      try {
        records.add(SessionRecord.decode(value));
      } catch (_) {
        // Ignore stale records if the saved shape changes.
      }
    }

    records.sort((a, b) => b.date.compareTo(a.date));
    return records;
  }

  Future<void> add(SessionRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final records = [record, ...await load()];
    final trimmed = records.take(_maxRecords).map((r) => r.encode()).toList();
    await prefs.setStringList(_key, trimmed);
  }
}
