import 'package:diary_ai/provider/location_diary_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../models/loc_diary_entry.dart';
import '../models/diary_entry.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:common_utils_services/models/location_history.dart';

class LocDiaryService {
  static const String boxName = 'location_diary_entries';
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _timeFormat = DateFormat('HH:mm');

  Future<void> addLocDiary(BuildContext context, LocDiaryEntry entry) async {
    var box = await Hive.openBox<LocDiaryEntry>(boxName);
    await box.put(entry.id, entry);
    await context.read<LocationDiaryProvider>().addLocDiary(entry);
  }

  Future<List<LocDiaryEntry>> getLocDiariesForToday() async {
    var box = await Hive.openBox<LocDiaryEntry>(boxName);
    final todayKey = _dateFormat.format(DateTime.now());
    return box.values
        .where((e) => _dateFormat.format(e.createdAt) == todayKey)
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

  /// 특정 위치가 오늘의 일기에 이미 포함되어 있는지 확인 (displayName 기반)
  static bool isLocationDisplayNameAlreadyInTodayDiary(
    String displayName,
    List<DiaryEntry> todayDiaries,
  ) {
    for (final diary in todayDiaries) {
      if (diary.locationDiaries
          .any((locDiary) => locDiary.location.displayName == displayName)) {
        return true;
      }
    }
    return false;
  }

  /// 위치 일기 목록에서 특정 displayName의 일기를 찾기
  static LocDiaryEntry? findLocationDiaryByDisplayName(
    String displayName,
    List<LocDiaryEntry> locDiaries,
  ) {
    return locDiaries.firstWhereOrNull(
      (locDiary) => locDiary.location.displayName == displayName,
    );
  }

  /// 그룹화된 일기 맵에서 오늘 날짜의 일기 리스트만 추출
  static List<DiaryEntry> getTodayLocDiaries(
      Map<String, List<DiaryEntry>> groupedDiaries) {
    final today = DateTime.now();
    final todayKey = DateFormat('yyyy-MM-dd').format(today);
    return groupedDiaries.entries
        .where((e) => e.key.startsWith(todayKey))
        .expand((e) => e.value)
        .toList();
  }
}
