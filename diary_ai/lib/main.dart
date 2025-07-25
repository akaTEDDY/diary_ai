import 'package:common_utils_services/models/location_history.dart';
import 'package:diary_ai/models/loc_diary_entry.dart';
import 'package:diary_ai/models/background_execution_log.dart';
import 'package:diary_ai/provider/location_diary_provider.dart';
import 'package:diary_ai/services/diary_notification_service.dart';
import 'package:diary_ai/services/workmanager_service.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/diary_entry.dart';
import 'views/main_page.dart';
import 'package:provider/provider.dart';
import 'provider/diary_provider.dart';
import 'provider/location_history_update_provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'provider/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);
  await Hive.initFlutter();
  Hive.registerAdapter(DiaryEntryAdapter());
  Hive.registerAdapter(LocDiaryEntryAdapter());
  Hive.registerAdapter(LocationHistoryAdapter());
  Hive.registerAdapter(BackgroundExecutionLogAdapter());

  // 알림 서비스 초기화
  final diaryNotificationService = DiaryNotificationService();
  await diaryNotificationService.initialize();

  // WorkManager 서비스 초기화
  await WorkManagerService.instance.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DiaryProvider()),
        ChangeNotifierProvider(create: (_) => LocationDiaryProvider()),
        ChangeNotifierProvider(create: (_) => LocationHistoryUpdateProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI 일기장',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MainPage(),
    );
  }
}
