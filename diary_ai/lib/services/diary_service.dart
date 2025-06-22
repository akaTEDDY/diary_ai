import 'package:hive/hive.dart';
import '../models/diary_entry.dart';

class DiaryService {
  static const String boxName = 'diary_entries';

  Future<void> addDiary(DiaryEntry entry) async {
    var box = await Hive.openBox<List>(boxName);
    final dateTimeKey = entry.dateTime;
    List<DiaryEntry> diaries = (box.get(dateTimeKey)?.cast<DiaryEntry>()) ?? [];
    diaries.add(entry);
    await box.put(dateTimeKey, diaries);
  }

  Future<List<DiaryEntry>> getDiariesByDateTime(String dateTime) async {
    var box = await Hive.openBox<List>(boxName);
    return (box.get(dateTime)?.cast<DiaryEntry>()) ?? [];
  }

  Future<Map<String, List<DiaryEntry>>> getAllDiariesGroupedByDateTime() async {
    var box = await Hive.openBox<List>(boxName);
    Map<String, List<DiaryEntry>> result = {};
    for (var key in box.keys) {
      result[key] = (box.get(key)?.cast<DiaryEntry>()) ?? [];
    }
    return result;
  }
}
