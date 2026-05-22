import 'package:shared_preferences/shared_preferences.dart';

import '../models/saved_dhikr.dart';

class SavedDhikrStore {
  static const _key = 'saved_dhikrs';

  Future<List<SavedDhikr>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final values = prefs.getStringList(_key) ?? const [];
    final records = <SavedDhikr>[];

    for (final value in values) {
      try {
        records.add(SavedDhikr.decode(value));
      } catch (_) {
        // Ignore stale records if the saved shape changes.
      }
    }

    records.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return records;
  }

  Future<SavedDhikr> add(String text) async {
    final cleanText = text.trim();
    final record = SavedDhikr(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: cleanText,
      createdAt: DateTime.now(),
    );
    final records = [record, ...await load()];
    await _save(records);
    return record;
  }

  Future<void> remove(String id) async {
    final records = await load();
    records.removeWhere((record) => record.id == id);
    await _save(records);
  }

  Future<void> _save(List<SavedDhikr> records) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, records.map((r) => r.encode()).toList());
  }
}
