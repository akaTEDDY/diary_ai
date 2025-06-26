import 'package:hive/hive.dart';
import '../models/diary_entry.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../provider/diary_provider.dart';

class DiaryService {
  static const String boxName = 'diary_entries';

  Future<void> addDiary(BuildContext context, DiaryEntry entry) async {
    var box = await Hive.openBox<List>(boxName);
    final dateTimeKey = entry.dateTime;
    List<DiaryEntry> diaries = (box.get(dateTimeKey)?.cast<DiaryEntry>()) ?? [];
    diaries.add(entry);
    await box.put(dateTimeKey, diaries);
    await context.read<DiaryProvider>().addDiary(entry);
  }

  Future<void> deleteDiary(
      BuildContext context, String dateTime, String id) async {
    var box = await Hive.openBox<List>(boxName);
    List<DiaryEntry> diaries = (box.get(dateTime)?.cast<DiaryEntry>()) ?? [];
    diaries.removeWhere((e) => e.id == id);
    await box.put(dateTime, diaries);
    await context.read<DiaryProvider>().deleteDiary(id);
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

  Future<void> addDiaryDirect(DiaryEntry entry) async {
    var box = await Hive.openBox<List>(boxName);
    final dateTimeKey = entry.dateTime;
    List<DiaryEntry> diaries = (box.get(dateTimeKey)?.cast<DiaryEntry>()) ?? [];
    diaries.add(entry);
    await box.put(dateTimeKey, diaries);
  }

  Future<void> deleteDiaryDirect(String id) async {
    var box = await Hive.openBox<List>(boxName);
    for (var key in box.keys) {
      List<DiaryEntry> diaries = (box.get(key)?.cast<DiaryEntry>()) ?? [];
      diaries.removeWhere((e) => e.id == id);
      await box.put(key, diaries);
    }
  }
}
