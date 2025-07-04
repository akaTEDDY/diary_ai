import 'dart:convert';

import 'package:common_utils_services/services/notification_service.dart';
import 'package:common_utils_services/utils/location_utils.dart';
import 'package:common_utils_services/models/location_history.dart';
import 'package:diary_ai/provider/location_history_update_provider.dart';
import 'package:diary_ai/utils/permission_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'tab_diary_list_page.dart';
import 'tab_diary_write_page.dart';
import 'tab_location_history_page.dart';
import 'tab_settings.dart';

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
    await _locationHistoryManager.initialize(50, (location) {
      try {
        // 위치가 업데이트 되었다는 걸 위치 히스토리 탭에 알려줌
        Provider.of<LocationHistoryUpdateProvider>(context, listen: false).setUpdated(true);
        
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
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: '추억 모으기'),
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
