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

  LocDiaryEntry({
    required this.id,
    required this.content,
    required this.photoPaths,
    required this.location,
    required this.createdAt,
  });
}
