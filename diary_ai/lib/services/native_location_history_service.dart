import 'dart:convert';
import 'package:diary_ai/models/location_history.dart';
import 'package:diary_ai/services/native_data_service.dart';
import 'package:diary_ai/services/flutter_parsing_error_service.dart';

class NativeLocationHistoryService {
  static final NativeLocationHistoryService _instance =
      NativeLocationHistoryService._internal();
  factory NativeLocationHistoryService() => _instance;
  NativeLocationHistoryService._internal();

  List<LocationHistory> _locationHistory = [];

  List<LocationHistory> get locationHistory =>
      List.unmodifiable(_locationHistory);

  /// 네이티브에서 위치 히스토리를 로드하고 변환합니다.
  Future<List<LocationHistory>> loadLocationHistory() async {
    try {
      final nativeData = await NativeDataService.getLocationHistory();
      _locationHistory = _convertNativeDataToLocationHistory(nativeData);
      return _locationHistory;
    } catch (e) {
      FlutterParsingErrorService().addError(
        'loadLocationHistory',
        e.toString(),
        'Failed to load location history from native',
      );
      print('Error loading location history from native: $e');
      return [];
    }
  }

  /// 네이티브 데이터를 LocationHistory 모델로 변환합니다.
  List<LocationHistory> _convertNativeDataToLocationHistory(
      List<Map<String, dynamic>> nativeData) {
    return nativeData.map((data) {
      if (data['rawResponse'] != null) {
        final rawResponse = json.decode(data['rawResponse']);
        return LocationHistory.fromJson(data['timestamp'], rawResponse);
      }

      // 기본 LocationHistory 객체 반환
      try {
        final timestamp =
            DateTime.fromMillisecondsSinceEpoch(data['timestamp'] ?? 0);
        final formattedTime =
            '${timestamp.year}/${timestamp.month}/${timestamp.day} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';

        return LocationHistory(
          timestamp: timestamp,
          formattedTime: formattedTime,
          location: null,
        );
      } catch (fallbackError) {
        FlutterParsingErrorService().addError(
          'FALLBACK_CONVERSION',
          fallbackError.toString(),
          'fallback data: ${data.toString()}',
        );
        // 최후의 수단으로 현재 시간으로 기본 객체 생성
        final now = DateTime.now();
        final formattedTime =
            '${now.year}/${now.month}/${now.day} ${now.hour}:${now.minute.toString().padLeft(2, '0')}';

        return LocationHistory(
          timestamp: now,
          formattedTime: formattedTime,
          location: null,
        );
      }
    }).toList();
  }

  /// 특정 시간 이후의 위치 히스토리를 반환합니다.
  List<LocationHistory> getLocationHistoryAfter(DateTime after) {
    return _locationHistory
        .where((location) => location.timestamp.isAfter(after))
        .toList();
  }

  /// 오늘의 위치 히스토리를 반환합니다.
  List<LocationHistory> getTodayLocationHistory() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(Duration(days: 1));

    return _locationHistory
        .where((location) =>
            location.timestamp.isAfter(startOfDay) &&
            location.timestamp.isBefore(endOfDay))
        .toList();
  }

  /// 위치 히스토리를 시간순으로 정렬합니다.
  List<LocationHistory> getSortedLocationHistory() {
    final sorted = List<LocationHistory>.from(_locationHistory);
    sorted.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted;
  }

  /// 위치 히스토리 개수를 반환합니다.
  int get locationHistoryCount => _locationHistory.length;

  /// 위치 히스토리를 초기화합니다.
  void clearLocationHistory() {
    _locationHistory.clear();
  }
}
