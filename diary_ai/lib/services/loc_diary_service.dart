import 'package:diary_ai/provider/location_diary_provider.dart';
import 'package:diary_ai/services/diary_service.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../models/loc_diary_entry.dart';
import '../models/diary_entry.dart';
import 'package:provider/provider.dart';

class LocDiaryService {
  static const String boxName = 'location_diary_entries';
  static final DateFormat _timeFormat = DateFormat('HH:mm');

  Future<void> addLocDiary(BuildContext context, LocDiaryEntry entry) async {
    var box = await Hive.openBox<LocDiaryEntry>(boxName);
    await box.put(entry.id, entry);
    await context.read<LocationDiaryProvider>().addLocDiary(entry);
  }

  Future<List<LocDiaryEntry>> getLocDiariesForToday() async {
    var box = await Hive.openBox<LocDiaryEntry>(boxName);
    final todayKey = DiaryService.getDateKey(DateTime.now());
    return box.values
        .where((e) => DiaryService.getDateKey(e.createdAt) == todayKey)
        .toList();
  }

  Future<void> deleteLocDiary(BuildContext context, String id) async {
    var box = await Hive.openBox<LocDiaryEntry>(boxName);
    await box.delete(id);
    await context.read<LocationDiaryProvider>().deleteLocDiary(id);
  }

  Future<void> clearAll() async {
    var box = await Hive.openBox<LocDiaryEntry>(boxName);
    await box.clear();
  }

  // 시간을 포맷팅
  static String formatTime(DateTime time) {
    return _timeFormat.format(time);
  }

  /// 그룹화된 일기 맵에서 오늘 날짜의 일기만 추출
  static DiaryEntry? getTodayDiary(Map<DateTime, DiaryEntry> groupedDiaries) {
    final todayDate =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return groupedDiaries[todayDate];
  }

  /// 특정 위치 히스토리가 일기(병합 포함)에 이미 포함되어 있는지 확인 (displayName + formattedTime 기준)
  static bool isLocationAlreadyInDiary(
    dynamic locationHistory, // LocationHistory 타입 객체
    DiaryEntry? diary,
  ) {
    if (diary == null) return false;
    final displayName = locationHistory.displayName;
    final formattedTime = locationHistory.formattedTime;
    return diary.locationDiaries.any((locDiary) =>
        locDiary.location.displayName == displayName &&
        locDiary.location.formattedTime == formattedTime);
  }

  /// 위치 히스토리와 displayName + formattedTime이 일치하는 위치 일기 찾기
  static LocDiaryEntry? findLocationDiaryByLocation(
    dynamic locationHistory, // LocationHistory 타입 객체
    List<LocDiaryEntry> locDiaries,
  ) {
    final displayName = locationHistory.displayName;
    final formattedTime = locationHistory.formattedTime;
    return locDiaries.firstWhereOrNull((locDiary) =>
        locDiary.location.displayName == displayName &&
        locDiary.location.formattedTime == formattedTime);
  }
}
