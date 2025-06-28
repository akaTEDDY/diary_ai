import 'package:flutter/material.dart';
import '../models/loc_diary_entry.dart';
import '../services/loc_diary_service.dart';

class LocationDiaryProvider extends ChangeNotifier {
  List<LocDiaryEntry> _locDiaries = [];

  List<LocDiaryEntry> get locDiaries => _locDiaries;

  LocationDiaryProvider() {
    // Provider 생성 시 초기 데이터 로드
    loadLocDiaries();
  }

  Future<void> loadLocDiaries() async {
    _locDiaries = await LocDiaryService().getLocDiariesForToday();
    notifyListeners();
  }

  Future<void> addLocDiary(LocDiaryEntry entry) async {
    _locDiaries.add(entry);
    await loadLocDiaries();
  }

  Future<void> deleteLocDiary(String id) async {
    _locDiaries.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}
