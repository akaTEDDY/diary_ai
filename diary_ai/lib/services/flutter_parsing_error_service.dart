import 'dart:convert';

class FlutterParsingError {
  final String errorType;
  final String errorMessage;
  final String? dataContext;
  final DateTime timestamp;

  FlutterParsingError({
    required this.errorType,
    required this.errorMessage,
    this.dataContext,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'errorType': errorType,
      'errorMessage': errorMessage,
      'dataContext': dataContext,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory FlutterParsingError.fromJson(Map<String, dynamic> json) {
    return FlutterParsingError(
      errorType: json['errorType'] ?? '',
      errorMessage: json['errorMessage'] ?? '',
      dataContext: json['dataContext'],
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class FlutterParsingErrorService {
  static final FlutterParsingErrorService _instance =
      FlutterParsingErrorService._internal();
  factory FlutterParsingErrorService() => _instance;
  FlutterParsingErrorService._internal();

  final List<FlutterParsingError> _errors = [];

  /// 플러터 파싱 에러를 추가합니다.
  void addError(String errorType, String errorMessage, [String? dataContext]) {
    final error = FlutterParsingError(
      errorType: errorType,
      errorMessage: errorMessage,
      dataContext: dataContext,
      timestamp: DateTime.now(),
    );

    _errors.add(error);
    print('Flutter parsing error logged: $errorType - $errorMessage');
  }

  /// 모든 파싱 에러를 가져옵니다.
  List<FlutterParsingError> getAllErrors() {
    return List.from(_errors);
  }

  /// 최근 파싱 에러들을 가져옵니다 (기본값: 최근 50개).
  List<FlutterParsingError> getRecentErrors([int count = 50]) {
    final sortedErrors = _errors.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return sortedErrors.take(count).toList();
  }

  /// 특정 시간 이후의 파싱 에러들을 가져옵니다.
  List<FlutterParsingError> getErrorsAfter(DateTime after) {
    return _errors.where((error) => error.timestamp.isAfter(after)).toList();
  }

  /// 실패한 파싱 에러들만 가져옵니다 (현재는 모든 에러가 실패로 간주).
  List<FlutterParsingError> getFailedErrors() {
    return List.from(_errors);
  }

  /// 모든 파싱 에러를 삭제합니다.
  void clearAllErrors() {
    _errors.clear();
  }

  /// 에러 개수를 가져옵니다.
  int get errorCount => _errors.length;
}
