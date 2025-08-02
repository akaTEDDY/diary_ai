import 'dart:async';
import 'package:flutter/material.dart';
import 'package:diary_ai/services/native_location_history_service.dart';
import 'package:diary_ai/provider/location_history_update_provider.dart';
import 'package:provider/provider.dart';

class AppLifecycleService {
  static final AppLifecycleService _instance = AppLifecycleService._internal();
  factory AppLifecycleService() => _instance;
  AppLifecycleService._internal();

  Timer? _debounceTimer;
  bool _isInitialized = false;

  void initialize(BuildContext context) {
    if (_isInitialized) return;

    // 앱 생명주기 변화 감지
    WidgetsBinding.instance.addObserver(
      _AppLifecycleObserver(
        onForeground: () => _handleAppForeground(context),
      ),
    );

    _isInitialized = true;
    print('AppLifecycleService initialized');
  }

  void _handleAppForeground(BuildContext context) {
    // 디바운스 타이머로 중복 호출 방지
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: 500), () {
      _loadLocationHistory(context);
    });
  }

  Future<void> _loadLocationHistory(BuildContext context) async {
    try {
      print(
          'AppLifecycleService: Loading location history from native SharedPreferences...');

      // 네이티브에서 위치 히스토리 로드
      final nativeLocationHistoryService = NativeLocationHistoryService();
      final locationHistoryData =
          await nativeLocationHistoryService.loadLocationHistory();

      if (locationHistoryData.isNotEmpty) {
        print(
            'AppLifecycleService: Loaded ${locationHistoryData.length} location history entries from native');

        // Provider를 통해 UI 업데이트 알림
        if (context.mounted) {
          final provider = Provider.of<LocationHistoryUpdateProvider>(context,
              listen: false);
          provider.setUpdated(true);
          print(
              'AppLifecycleService: Notified LocationHistoryUpdateProvider to update UI');
        }
      } else {
        print(
            'AppLifecycleService: No location history data found in native SharedPreferences');
      }
    } catch (e) {
      print(
          'AppLifecycleService: Error loading location history from native: $e');
    }
  }

  void dispose() {
    _debounceTimer?.cancel();
    _isInitialized = false;
  }
}

class _AppLifecycleObserver extends WidgetsBindingObserver {
  final VoidCallback onForeground;

  _AppLifecycleObserver({required this.onForeground});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      print(
          'AppLifecycleService: App resumed, triggering location history load');
      onForeground();
    }
  }
}
