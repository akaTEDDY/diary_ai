import 'package:common_utils_services/utils/location_utils.dart';
import 'package:diary_ai/models/location_history.dart';
import 'package:diary_ai/utils/permission_utils.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
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
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    _locationHistoryManager = LocationHistoryManager();

    Future.microtask(() async {
      await PermissionUtils.checkAndRequestPermission(context);
      await _locationHistoryManager.initialize((location) {
        // 위치 업데이트, 일기 추가 작성할 지 물어보기
        // 알림?
      });
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
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
