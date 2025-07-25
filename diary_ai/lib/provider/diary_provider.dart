import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import '../services/diary_service.dart';

class DiaryProvider extends ChangeNotifier {
  List<DiaryEntry> _diaries = [];
  bool _isLoading = false;

  List<DiaryEntry> get diaries => _diaries;
  bool get isLoading => _isLoading;

  // 날짜별 그룹핑 getter
  Map<DateTime, DiaryEntry> get groupedByDate {
    Map<DateTime, DiaryEntry> result = {};
    for (var entry in _diaries) {
      final dateOnly = DateTime(
          entry.createdAt.year, entry.createdAt.month, entry.createdAt.day);
      result[dateOnly] = entry;
    }
    return result;
  }

  // 오늘 일기만 반환
  DiaryEntry? get todayDiary {
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    return groupedByDate[todayDate];
  }

  Future<void> loadDiaries() async {
    _isLoading = true;
    notifyListeners();

    try {
      final service = DiaryService();
      final grouped = await service.getAllDiariesGroupedByDate();
      _diaries = grouped.values.toList();
    } catch (e) {
      print('일기 로드 실패: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addDiary(DiaryEntry entry) async {
    final service = DiaryService();
    await service.addDiaryDirect(entry); // addDiaryDirect는 context 없이 Hive에만 저장
    await loadDiaries();
  }

  Future<void> deleteDiary(String id) async {
    final service = DiaryService();
    await service
        .deleteDiaryDirect(id); // deleteDiaryDirect는 context 없이 Hive에만 삭제
    await loadDiaries();
  }
}
