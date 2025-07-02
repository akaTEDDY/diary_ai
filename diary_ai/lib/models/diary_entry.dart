import 'package:hive/hive.dart';
import 'loc_diary_entry.dart';
import 'package:intl/intl.dart';

part 'diary_entry.g.dart';

@HiveType(typeId: 10)
class DiaryEntry extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  DateTime createdAt; // 오늘 일기 구분 및 시간 표시용
  @HiveField(2)
  List<LocDiaryEntry> locationDiaries; // 각 위치의 일기들 (사진 포함)

  DiaryEntry({
    required this.id,
    required this.createdAt,
    required this.locationDiaries,
  });

  String get dateTime => DateFormat('yyyy-MM-dd HH:mm').format(createdAt);

  // 모든 사진 경로를 가져오는 getter
  List<String> get allPhotoPaths {
    return locationDiaries.expand((diary) => diary.photoPaths).toList();
  }
}
