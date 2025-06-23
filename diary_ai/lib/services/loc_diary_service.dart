import 'package:diary_ai/provider/location_diary_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import '../models/loc_diary_entry.dart';
import 'package:provider/provider.dart';

class LocDiaryService {
  static const String boxName = 'location_diary_entries';

  Future<void> addLocDiary(BuildContext context, LocDiaryEntry entry) async {
    var box = await Hive.openBox<LocDiaryEntry>(boxName);
    await box.put(entry.id, entry);
    await context.read<LocationDiaryProvider>().addLocDiary(entry);
  }

  Future<List<LocDiaryEntry>> getLocDiariesForToday() async {
    var box = await Hive.openBox<LocDiaryEntry>(boxName);
    final today = DateTime.now();
    final todayKey =
        '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return box.values
        .where((e) =>
            '${e.createdAt.year.toString().padLeft(4, '0')}-${e.createdAt.month.toString().padLeft(2, '0')}-${e.createdAt.day.toString().padLeft(2, '0')}' ==
            todayKey)
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
}
