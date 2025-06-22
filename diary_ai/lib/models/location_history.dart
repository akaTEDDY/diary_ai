import 'package:hive/hive.dart';

part 'location_history.g.dart';

@HiveType(typeId: 1)
class LocationHistory extends HiveObject {
  @HiveField(0)
  DateTime timestamp;
  @HiveField(1)
  double latitude;
  @HiveField(2)
  double longitude;

  LocationHistory({
    required this.timestamp,
    required this.latitude,
    required this.longitude,
  });
}
