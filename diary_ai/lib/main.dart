import 'package:common_utils_services/models/location_history.dart';
import 'package:diary_ai/models/loc_diary_entry.dart';
import 'package:diary_ai/provider/location_diary_provider.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/diary_entry.dart';
import 'views/main_page.dart';
import 'package:provider/provider.dart';
import 'provider/diary_provider.dart';
import 'provider/location_history_update_provider.dart';
import 'provider/character_preset_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(DiaryEntryAdapter());
  Hive.registerAdapter(LocDiaryEntryAdapter());
  Hive.registerAdapter(LocationHistoryAdapter());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DiaryProvider()),
        ChangeNotifierProvider(create: (_) => LocationDiaryProvider()),
        ChangeNotifierProvider(create: (_) => LocationHistoryUpdateProvider()),
        ChangeNotifierProvider(create: (_) => CharacterPresetProvider()),
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
