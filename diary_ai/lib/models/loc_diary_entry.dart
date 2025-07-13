import 'package:hive/hive.dart';
import 'package:common_utils_services/models/location_history.dart';

part 'loc_diary_entry.g.dart';

@HiveType(typeId: 11)
class LocDiaryEntry extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String content;
  @HiveField(2)
  List<String> photoPaths;
  @HiveField(3)
  LocationHistory location;
  @HiveField(4)
  DateTime createdAt;
  @HiveField(5)
  String? mood;

  LocDiaryEntry({
    required this.id,
    required this.content,
    required this.photoPaths,
    required this.location,
    required this.createdAt,
    this.mood,
  });

  factory LocDiaryEntry.fromJson(Map<String, dynamic> json) {
    return LocDiaryEntry(
      id: json['id'] as String? ?? '',
      content: json['content'] as String? ?? '',
      photoPaths:
          (json['photoPaths'] as List?)?.map((e) => e as String).toList() ?? [],
      location: json['location'] is Map<String, dynamic>
          ? LocationHistory.fromJson(json['location'] as Map<String, dynamic>)
          : LocationHistory.fromJson({}),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      mood: json['mood'] as String?,
    );
  }
}
