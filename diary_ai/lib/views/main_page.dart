import 'package:common_utils_services/services/notification_service.dart';
import 'package:common_utils_services/utils/location_utils.dart';
import 'package:diary_ai/utils/permission_utils.dart';
import 'package:flutter/material.dart';
import 'tab_diary_list_page.dart';
import 'tab_diary_write_page.dart';
import 'tab_location_history_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late LocationHistoryManager _locationHistoryManager;
  late NotificationService _notificationService;
  int _selectedIndex = 0;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    _locationHistoryManager = LocationHistoryManager();
    _notificationService = NotificationService();

    _initializeAsync();
  }

  Future<void> _initializeAsync() async {
    await PermissionUtils.checkAndRequestPermission(context);
    await _notificationService.initialize();
    await _locationHistoryManager.initialize((location) {
      _notificationService.showNotification(
          title: location["place"], body: location["tags"]);
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
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: '일기 목록'),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: '일기 쓰기'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: '위치 히스토리'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
