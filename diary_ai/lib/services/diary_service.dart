import 'package:hive/hive.dart';
import 'package:collection/collection.dart';
import '../models/diary_entry.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../provider/diary_provider.dart';
import 'package:intl/intl.dart';

class DiaryService {
  static const String boxName = 'diary_entries';

  /// DiaryEntry 저장/조회/삭제에 사용할 키 생성 (yyyy-MM-dd)
  static String getDateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> addDiary(BuildContext context, DiaryEntry entry) async {
    var box = await Hive.openBox<DiaryEntry>(boxName);
    await box.put(entry.id, entry);
    await context.read<DiaryProvider>().addDiary(entry);
  }

  Future<void> deleteDiary(
      BuildContext context, String dateKey, String id) async {
    var box = await Hive.openBox<DiaryEntry>(boxName);
    await box.delete(id);
    await context.read<DiaryProvider>().deleteDiary(id);
  }

  Future<DiaryEntry?> getDiaryByDateKey(String dateKey) async {
    var box = await Hive.openBox<DiaryEntry>(boxName);
    for (var key in box.keys) {
      final entry = box.get(key);
      if (entry != null && getDateKey(entry.createdAt) == dateKey) {
        return entry;
      }
    }
    return null;
  }

  Future<Map<DateTime, DiaryEntry>> getAllDiariesGroupedByDate() async {
    var box = await Hive.openBox<DiaryEntry>(boxName);
    Map<DateTime, DiaryEntry> result = {};
    for (var key in box.keys) {
      final entry = box.get(key);
      if (entry != null) {
        final dateOnly = DateTime(
            entry.createdAt.year, entry.createdAt.month, entry.createdAt.day);
        result[dateOnly] = entry;
      }
    }
    return result;
  }

  Future<void> addDiaryDirect(DiaryEntry entry) async {
    var box = await Hive.openBox<DiaryEntry>(boxName);
    await box.put(entry.id, entry);
  }

  Future<void> deleteDiaryDirect(String id) async {
    var box = await Hive.openBox<DiaryEntry>(boxName);
    await box.delete(id);
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
