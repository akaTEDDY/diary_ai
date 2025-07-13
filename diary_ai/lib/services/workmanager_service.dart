import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import '../models/background_execution_log.dart';
import 'dart:convert';

class WorkManagerService {
  static const String _keepAliveTaskName = "diary-keep-alive";
  static const String _keepAliveTaskTag = "diaryKeepAliveTask";

  static WorkManagerService? _instance;
  static WorkManagerService get instance =>
      _instance ??= WorkManagerService._();

  WorkManagerService._();

  bool _isInitialized = false;
  bool _isAppInForeground = true;

  /// WorkManager 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    await Workmanager().initialize(callbackDispatcher);
    _isInitialized = true;
    print('WorkManagerService: 초기화 완료');
  }

  /// 앱이 포그라운드로 전환될 때 호출
  void onAppForeground() {
    _isAppInForeground = true;
    // 앱이 포그라운드에 있으면 주기적 작업 중지
    _stopKeepAliveTask();
    print('WorkManagerService: 앱 포그라운드 - 주기적 작업 중지');
  }

  /// 앱이 백그라운드로 전환될 때 호출
  void onAppBackground() {
    _isAppInForeground = false;
    // 앱이 백그라운드로 가면 주기적 작업 시작
    _startKeepAliveTask();
    print('WorkManagerService: 앱 백그라운드 - 주기적 작업 시작');
  }

  /// 앱이 완전히 종료될 때 호출
  void onAppTerminated() {
    // 앱이 종료되면 주기적 작업 시작 (앱이 다시 시작될 때까지 유지)
    _startKeepAliveTask();
    print('WorkManagerService: 앱 종료 - 주기적 작업 유지');
  }

  /// Keep Alive 작업 시작
  Future<void> _startKeepAliveTask() async {
    if (!_isInitialized) return;

    try {
      await Workmanager().registerPeriodicTask(
        _keepAliveTaskName,
        _keepAliveTaskTag,
        frequency: Duration(minutes: 15), // 최소 간격
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
        existingWorkPolicy: ExistingWorkPolicy.replace,
        inputData: {
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'appState': _isAppInForeground ? 'foreground' : 'background',
        },
      );
      print('WorkManagerService: Keep Alive 작업 등록 완료');
    } catch (e) {
      print('WorkManagerService: Keep Alive 작업 등록 실패 - $e');
    }
  }

  /// Keep Alive 작업 중지
  Future<void> _stopKeepAliveTask() async {
    if (!_isInitialized) return;

    try {
      await Workmanager().cancelByUniqueName(_keepAliveTaskName);
      print('WorkManagerService: Keep Alive 작업 중지 완료');
    } catch (e) {
      print('WorkManagerService: Keep Alive 작업 중지 실패 - $e');
    }
  }

  /// 모든 작업 취소
  Future<void> cancelAllTasks() async {
    if (!_isInitialized) return;

    try {
      await Workmanager().cancelAll();
      print('WorkManagerService: 모든 작업 취소 완료');
    } catch (e) {
      print('WorkManagerService: 작업 취소 실패 - $e');
    }
  }

  /// 현재 등록된 작업 확인
  Future<void> checkRegisteredTasks() async {
    if (!_isInitialized) return;

    try {
      // WorkManager는 등록된 작업을 직접 확인하는 API가 없으므로
      // 로그로 확인할 수 있도록 함
      print('WorkManagerService: 등록된 작업 확인 - Keep Alive 작업이 활성화되어 있음');
    } catch (e) {
      print('WorkManagerService: 작업 확인 실패 - $e');
    }
  }

  /// 실행 내역 저장 (WorkManager 콜백용 - SharedPreferences 사용)
  static Future<void> saveExecutionLogSimple(String type,
      {String? additionalInfo}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logs = prefs.getStringList('background_execution_logs') ?? [];

      final logData = {
        'type': type,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'additionalInfo': additionalInfo,
      };

      logs.add(jsonEncode(logData));

      // 최근 50개만 유지
      if (logs.length > 50) {
        logs.removeRange(0, logs.length - 50);
      }

      await prefs.setStringList('background_execution_logs', logs);
      print('WorkManagerService: 간단한 실행 내역 저장 완료 - $type');
    } catch (e) {
      print('WorkManagerService: 간단한 실행 내역 저장 실패 - $e');
    }
  }

  /// 실행 내역 저장 (앱 내용 - Hive 사용)
  static Future<void> saveExecutionLog(String type,
      {String? additionalInfo}) async {
    try {
      final box = await Hive.openBox<BackgroundExecutionLog>(
          'background_execution_logs');
      final log = BackgroundExecutionLog(
        type: type,
        timestamp: DateTime.now(),
        additionalInfo: additionalInfo,
      );
      await box.add(log);

      // 최근 100개만 유지
      if (box.length > 100) {
        final keysToDelete = box.keys.take(box.length - 100).toList();
        await box.deleteAll(keysToDelete);
      }

      print('WorkManagerService: 실행 내역 저장 완료 - $type');
    } catch (e) {
      print('WorkManagerService: 실행 내역 저장 실패 - $e');
    }
  }

  /// 실행 내역 조회 (SharedPreferences와 Hive 데이터 통합)
  static Future<List<BackgroundExecutionLog>> getExecutionLogs() async {
    try {
      final List<BackgroundExecutionLog> allLogs = [];

      // Hive에서 가져오기
      try {
        final box = await Hive.openBox<BackgroundExecutionLog>(
            'background_execution_logs');
        allLogs.addAll(box.values);
      } catch (e) {
        print('WorkManagerService: Hive 로그 조회 실패 - $e');
      }

      // SharedPreferences에서 가져오기
      try {
        final prefs = await SharedPreferences.getInstance();
        final logs = prefs.getStringList('background_execution_logs') ?? [];

        for (final logString in logs) {
          try {
            final logData = jsonDecode(logString) as Map<String, dynamic>;
            final log = BackgroundExecutionLog(
              type: logData['type'] as String,
              timestamp: DateTime.fromMillisecondsSinceEpoch(
                  logData['timestamp'] as int),
              additionalInfo: logData['additionalInfo'] as String?,
            );
            allLogs.add(log);
          } catch (e) {
            print('WorkManagerService: SharedPreferences 로그 파싱 실패 - $e');
          }
        }
      } catch (e) {
        print('WorkManagerService: SharedPreferences 로그 조회 실패 - $e');
      }

      // 최신순 정렬
      allLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return allLogs;
    } catch (e) {
      print('WorkManagerService: 실행 내역 조회 실패 - $e');
      return [];
    }
  }

  /// 실행 내역 삭제 (SharedPreferences와 Hive 모두 정리)
  static Future<void> clearExecutionLogs() async {
    try {
      // Hive 정리
      try {
        final box = await Hive.openBox<BackgroundExecutionLog>(
            'background_execution_logs');
        await box.clear();
      } catch (e) {
        print('WorkManagerService: Hive 로그 삭제 실패 - $e');
      }

      // SharedPreferences 정리
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('background_execution_logs');
      } catch (e) {
        print('WorkManagerService: SharedPreferences 로그 삭제 실패 - $e');
      }

      print('WorkManagerService: 실행 내역 삭제 완료');
    } catch (e) {
      print('WorkManagerService: 실행 내역 삭제 실패 - $e');
    }
  }
}

/// WorkManager 콜백 디스패처
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final executedAt = DateTime.now(); // 실제 실행 시각
    print('WorkManager: 백그라운드 작업 실행 - $task');
    print('WorkManager: 입력 데이터 - $inputData');

    // 실행 내역 저장
    final appState = inputData?['appState'] ?? 'unknown';
    final additionalInfo = '앱 상태: $appState, 작업: $task, 실행시각: $executedAt';

    await WorkManagerService.saveExecutionLogSimple('workmanager',
        additionalInfo: additionalInfo);

    print('WorkManager: 앱을 깨우는 작업 완료');
    print('WorkManager: 실제 실행 시각 - $executedAt');
    print('WorkManager: 앱 상태 - $appState');

    // 여기에 실제로 앱을 깨우는 로직을 추가할 수 있습니다
    // 예: 알림 표시, 데이터 동기화 등

    return Future.value(true);
  });
}
