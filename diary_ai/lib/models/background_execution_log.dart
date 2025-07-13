import 'package:hive/hive.dart';

part 'background_execution_log.g.dart';

@HiveType(typeId: 4)
class BackgroundExecutionLog extends HiveObject {
  @HiveField(0)
  final String type; // 'workmanager' 또는 'location_saver'

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  final String? additionalInfo; // 추가 정보 (예: 앱 상태, 위치 정보 등)

  BackgroundExecutionLog({
    required this.type,
    required this.timestamp,
    this.additionalInfo,
  });

  factory BackgroundExecutionLog.fromJson(Map<String, dynamic> json) {
    return BackgroundExecutionLog(
      type: json['type'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      additionalInfo: json['additionalInfo'] as String?,
    );
  }

  @override
  String toString() {
    return 'BackgroundExecutionLog(type: $type, timestamp: $timestamp, additionalInfo: $additionalInfo)';
  }
}
