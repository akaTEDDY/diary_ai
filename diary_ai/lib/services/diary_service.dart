import 'package:hive/hive.dart';
import 'package:collection/collection.dart';
import '../models/diary_entry.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../provider/diary_provider.dart';

class DiaryService {
  static const String boxName = 'diary_entries';

  Future<void> addDiary(BuildContext context, DiaryEntry entry) async {
    var box = await Hive.openBox<DiaryEntry>(boxName);
    final dateTimeKey = entry.dateTime;
    await box.put(dateTimeKey, entry);
    await context.read<DiaryProvider>().addDiary(entry);
  }

  Future<void> deleteDiary(
      BuildContext context, String dateTime, String id) async {
    var box = await Hive.openBox<DiaryEntry>(boxName);
    await box.delete(dateTime);
    await context.read<DiaryProvider>().deleteDiary(id);
  }

  Future<DiaryEntry?> getDiaryByDateTime(String dateTime) async {
    var box = await Hive.openBox<DiaryEntry>(boxName);
    return box.get(dateTime);
  }

  Future<Map<String, DiaryEntry>> getAllDiariesGroupedByDateTime() async {
    var box = await Hive.openBox<DiaryEntry>(boxName);
    Map<String, DiaryEntry> result = {};
    for (var key in box.keys) {
      final entry = box.get(key);
      if (entry != null) result[key] = entry;
    }
    return result;
  }

  Future<void> addDiaryDirect(DiaryEntry entry) async {
    var box = await Hive.openBox<DiaryEntry>(boxName);
    final dateTimeKey = entry.dateTime;
    await box.put(dateTimeKey, entry);
  }

  Future<void> deleteDiaryDirect(String id) async {
    var box = await Hive.openBox<DiaryEntry>(boxName);
    for (var key in box.keys) {
      final entry = box.get(key);
      if (entry != null && entry.id == id) {
        await box.delete(key);
      }
    }
  }

  /// DiaryEntry에서 모든 사진 경로를 추출
  static List<String> getAllPhotoPaths(DiaryEntry diary) {
    return diary.locationDiaries
        .expand((locDiary) => locDiary.photoPaths)
        .toList();
  }

  /// DiaryEntry에서 특정 위치의 사진 경로를 추출
  static List<String> getPhotoPathsByLocation(
      DiaryEntry diary, String locationDisplayName) {
    final locationDiary = diary.locationDiaries.firstWhereOrNull(
      (locDiary) => locDiary.location.displayName == locationDisplayName,
    );
    return locationDiary?.photoPaths ?? [];
  }
}
