import 'package:common_utils_services/services/notification_service.dart';
import 'package:diary_ai/services/app_lifecycle_service.dart';
import 'package:diary_ai/utils/permission_utils.dart';
import 'package:flutter/material.dart';
import 'tab_diary_list_page.dart';
import 'tab_diary_write_page.dart';
import 'tab_location_history_page.dart';
import 'tab_settings.dart';
import 'dart:async';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  late NotificationService _notificationService;
  int _selectedIndex = 0;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    // 앱 생명주기 관찰자 등록
    WidgetsBinding.instance.addObserver(this);

    _notificationService = NotificationService();

    _initializeAsync();
  }

  @override
  void dispose() {
    // 앱 생명주기 관찰자 해제
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _initializeAsync() async {
    await PermissionUtils.checkAndRequestPermission(context);
    await _notificationService.initialize();

    // AppLifecycleService 초기화
    AppLifecycleService().initialize(context);

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
      TabLocationHistoryPage(),
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
