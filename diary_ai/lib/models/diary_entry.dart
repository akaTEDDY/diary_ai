import 'package:hive/hive.dart';
import 'package:common_utils_services/models/location_history.dart';

part 'diary_entry.g.dart';

@HiveType(typeId: 10)
class DiaryEntry extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String content;
  @HiveField(2)
  List<String> photoPaths;
  @HiveField(3)
  LocationHistory location;
  @HiveField(4)
  String dateTime; // yyyy-MM-dd HH:mm
  @HiveField(5)
  DateTime createdAt;

  DiaryEntry({
    required this.id,
    required this.content,
    required this.photoPaths,
    required this.location,
    required this.dateTime,
    required this.createdAt,
  });
}
