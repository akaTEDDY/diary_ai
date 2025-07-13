import 'dart:convert';
import 'dart:ui';

import 'package:common_utils_services/services/notification_service.dart';
import 'package:common_utils_services/utils/location_utils.dart';
import 'package:common_utils_services/models/location_history.dart';
import 'package:diary_ai/provider/location_history_update_provider.dart';
import 'package:diary_ai/services/workmanager_service.dart';
import 'package:diary_ai/utils/permission_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'tab_diary_list_page.dart';
import 'tab_diary_write_page.dart';
import 'tab_location_history_page.dart';
import 'tab_settings.dart';

@pragma('vm:entry-point')
void backgroundLocationSaver() {
  print("백그라운드 위치 저장을 위해 일시적으로 엔진 실행");

  // 실행 내역 저장
  WorkManagerService.saveExecutionLogSimple('location_saver',
      additionalInfo: '위치 저장 작업 실행');
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  late LocationHistoryManager _locationHistoryManager;
  late NotificationService _notificationService;
  int _selectedIndex = 0;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    // 앱 생명주기 관찰자 등록
    WidgetsBinding.instance.addObserver(this);

    _locationHistoryManager = LocationHistoryManager();
    _notificationService = NotificationService();

    _initializeAsync();
  }

  @override
  void dispose() {
    // 앱 생명주기 관찰자 해제
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        // 앱이 포그라운드로 돌아옴
        WorkManagerService.instance.onAppForeground();
        print('MainPage: 앱 포그라운드로 전환');
        break;
      case AppLifecycleState.inactive:
        // 앱이 비활성화됨 (전화 수신 등)
        print('MainPage: 앱 비활성화');
        break;
      case AppLifecycleState.paused:
        // 앱이 백그라운드로 전환됨
        WorkManagerService.instance.onAppBackground();
        print('MainPage: 앱 백그라운드로 전환');
        break;
      case AppLifecycleState.detached:
        // 앱이 완전히 종료됨
        WorkManagerService.instance.onAppTerminated();
        print('MainPage: 앱 완전 종료');
        break;
      case AppLifecycleState.hidden:
        // 앱이 숨겨짐 (Android 12+)
        WorkManagerService.instance.onAppBackground();
        print('MainPage: 앱 숨겨짐');
        break;
    }
  }

  Future<void> _initializeAsync() async {
    await PermissionUtils.checkAndRequestPermission(context);
    await _notificationService.initialize();

    final handle = PluginUtilities.getCallbackHandle(
      backgroundLocationSaver,
    )?.toRawHandle();

    print("handle: $handle");

    await _locationHistoryManager.initialize(50, handle, (location) {
      try {
        // 위치가 업데이트 되었다는 걸 위치 히스토리 탭에 알려줌
        Provider.of<LocationHistoryUpdateProvider>(context, listen: false)
            .setUpdated(true);

        final Map<String, dynamic> curLocation = json.decode(location);
        LocationHistory locationHistory = LocationHistory.fromJson(curLocation);

        String title = "";
        if (locationHistory.place != null) {
          if (!locationHistory.place!.containsKey("accuracy") ||
              !locationHistory.place!.containsKey("threshold")) {
            return;
          }

          final accuracy = locationHistory.place!["accuracy"];
          final threshold = locationHistory.place!["threshold"];

          if (accuracy < threshold) {
            return;
          }

          if (locationHistory.place!.containsKey("name")) {
            title += locationHistory.place!["name"];
          }
          if (locationHistory.place!.containsKey("tags")) {
            if (title.isNotEmpty) {
              title += " ";
            }
            title += "(${locationHistory.place!["tags"]})";
          }

          if (title.isNotEmpty) {
            _notificationService.showNotification(
                title: title, body: locationHistory.simpleName);
          }
        }
      } catch (e) {
        print(e.toString());
      }
    });
    setState(() {
      _initialized = true;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      // 초기화 중에는 로딩 화면
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final List<Widget> pages = [
      TabDiaryListPage(),
      TabDiaryWritePage(),
      TabLocationHistoryPage(_locationHistoryManager),
      TabSettingsPage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: '일기 목록'),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: '기록 모으기'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: '내가 지난 장소들'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Color(0xFF7C3AED),
        unselectedItemColor: Color(0xFFBDB5E2),
        backgroundColor: Color(0xFFF8FAFF),
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
