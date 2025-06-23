import 'package:flutter/material.dart';
import '../models/diary_entry.dart';

class DiaryProvider extends ChangeNotifier {
  List<DiaryEntry> _diaries = [];

  List<DiaryEntry> get diaries => _diaries;

  Future<void> addDiary(DiaryEntry entry) async {
    _diaries.add(entry);
    notifyListeners();
  }

  Future<void> deleteDiary(String id) async {
    _diaries.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}
