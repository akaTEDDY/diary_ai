import 'dart:convert';
import 'package:flutter/services.dart';

class NativeDataService {
  static const MethodChannel _channel = MethodChannel('plengi.ai/fromFlutter');

  /// 위치 히스토리를 조회합니다.
  static Future<List<Map<String, dynamic>>> getLocationHistory() async {
    try {
      final String result = await _channel.invokeMethod('getLocationHistory');
      final List<dynamic> jsonList = json.decode(result);
      return jsonList.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error getting location history: $e');
      return [];
    }
  }

  /// 실행 내역을 조회합니다.
  static Future<List<Map<String, dynamic>>> getExecutionLogs() async {
    try {
      final String result = await _channel.invokeMethod('getExecutionLogs');
      final List<dynamic> jsonList = json.decode(result);
      return jsonList.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error getting execution logs: $e');
      return [];
    }
  }

  /// 통계 정보를 조회합니다.
  static Future<String> getStats() async {
    try {
      final String result = await _channel.invokeMethod('getStats');
      return result;
    } catch (e) {
      print('Error getting stats: $e');
      return 'Error getting stats: $e';
    }
  }

  /// 모든 데이터를 초기화합니다.
  static Future<String> clearAllData() async {
    try {
      final String result = await _channel.invokeMethod('clearAllData');
      return result;
    } catch (e) {
      print('Error clearing data: $e');
      return 'Error clearing data: $e';
    }
  }

  /// 위치 히스토리의 최근 N개 항목을 조회합니다.
  static Future<List<Map<String, dynamic>>> getRecentLocationHistory(
      int count) async {
    final history = await getLocationHistory();
    if (history.length <= count) {
      return history;
    }
    return history.sublist(history.length - count);
  }

  /// 특정 시간 이후의 실행 내역을 조회합니다.
  static Future<List<Map<String, dynamic>>> getExecutionLogsAfter(
      DateTime after) async {
    final logs = await getExecutionLogs();
    final afterTimestamp = after.millisecondsSinceEpoch;

    return logs.where((log) {
      final timestamp = log['timestamp'] as int?;
      return timestamp != null && timestamp >= afterTimestamp;
    }).toList();
  }

  /// 실패한 실행 내역만 조회합니다.
  static Future<List<Map<String, dynamic>>> getFailedExecutionLogs() async {
    final logs = await getExecutionLogs();
    return logs.where((log) {
      final success = log['success'] as bool?;
      return success == false;
    }).toList();
  }

  /// 위치 히스토리와 실행 내역을 함께 조회합니다.
  static Future<Map<String, dynamic>> getAllData() async {
    try {
      final locationHistory = await getLocationHistory();
      final executionLogs = await getExecutionLogs();
      final stats = await getStats();

      return {
        'locationHistory': locationHistory,
        'executionLogs': executionLogs,
        'stats': stats,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Error getting all data: $e');
      return {
        'locationHistory': [],
        'executionLogs': [],
        'stats': 'Error: $e',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
}
