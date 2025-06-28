import 'package:hive/hive.dart';
import 'loc_diary_entry.dart';

part 'diary_entry.g.dart';

@HiveType(typeId: 10)
class DiaryEntry extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String content; // 모든 위치 일기 내용을 합친 텍스트
  @HiveField(2)
  String dateTime; // yyyy-MM-dd HH:mm (Hive 키용, UI 표시용)
  @HiveField(3)
  DateTime createdAt; // 정확한 시간 계산용
  @HiveField(4)
  List<LocDiaryEntry> locationDiaries; // 각 위치의 일기들 (사진 포함)

  DiaryEntry({
    required this.id,
    required this.content,
    required this.dateTime,
    required this.createdAt,
    required this.locationDiaries,
  });

  // 모든 사진 경로를 가져오는 getter
  List<String> get allPhotoPaths {
    return locationDiaries.expand((diary) => diary.photoPaths).toList();
  }
}
