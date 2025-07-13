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
  @HiveField(3)
  String? aiFeedback; // AI 피드백 내용
  @HiveField(4)
  DateTime? feedbackCreatedAt; // 피드백 생성 시간
  @HiveField(5)
  bool hasFeedback; // 피드백 존재 여부

  DiaryEntry({
    required this.id,
    required this.createdAt,
    required this.locationDiaries,
    this.aiFeedback,
    this.feedbackCreatedAt,
    this.hasFeedback = false,
  });

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: json['id'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      locationDiaries: (json['locationDiaries'] as List?)
              ?.map((e) => LocDiaryEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      aiFeedback: json['aiFeedback'] as String?,
      feedbackCreatedAt: json['feedbackCreatedAt'] != null
          ? DateTime.tryParse(json['feedbackCreatedAt'])
          : null,
      hasFeedback: json['hasFeedback'] == true,
    );
  }

  String get dateTime => DateFormat('yyyy-MM-dd HH:mm').format(createdAt);

  // 모든 사진 경로를 가져오는 getter
  List<String> get allPhotoPaths {
    return locationDiaries.expand((diary) => diary.photoPaths).toList();
  }
}
