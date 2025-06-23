import 'package:diary_ai/provider/location_diary_provider.dart';
import 'package:flutter/material.dart';
import '../models/loc_diary_entry.dart';
import '../models/diary_entry.dart';
import '../services/loc_diary_service.dart';
import '../services/diary_service.dart';
import 'loc_diary_write_page.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';

class TabDiaryWritePage extends StatefulWidget {
  const TabDiaryWritePage({Key? key}) : super(key: key);

  @override
  State<TabDiaryWritePage> createState() => _TabDiaryWritePageState();
}

class _TabDiaryWritePageState extends State<TabDiaryWritePage> {
  List<LocDiaryEntry> _locDiaries = [];
  bool _isLoading = true;
  Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _loadLocDiaries();
  }

  Future<void> _loadLocDiaries() async {
    setState(() {
      _isLoading = true;
    });
    final locDiaries = await LocDiaryService().getLocDiariesForToday();
    setState(() {
      _locDiaries = locDiaries;
      _isLoading = false;
      _selectedIds.removeWhere((id) => !_locDiaries.any((e) => e.id == id));
    });
  }

  void _onSelectLocDiary(LocDiaryEntry entry) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocDiaryWritePage(location: entry.location),
      ),
    );
    await _loadLocDiaries();
  }

  void _onCheckChanged(bool? checked, String id) {
    setState(() {
      if (checked == true) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(id);
      }
    });
  }

  Future<void> _onSaveTodayDiary() async {
    final selected =
        _locDiaries.where((e) => _selectedIds.contains(e.id)).toList();
    if (selected.isEmpty) return;
    final now = DateTime.now();
    final dateTimeStr =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final content = selected.map((e) => e.content).join('\n\n');
    final photoPaths = selected.expand((e) => e.photoPaths).toList();
    final location = selected.first.location;
    final diaryEntry = DiaryEntry(
      id: Uuid().v4(),
      content: content,
      photoPaths: photoPaths,
      location: location,
      dateTime: dateTimeStr,
      createdAt: now,
    );
    await DiaryService().addDiary(context, diaryEntry);
    for (final e in selected) {
      await LocDiaryService().deleteLocDiary(context, e.id);
    }
    setState(() {
      _selectedIds.clear();
    });
    await _loadLocDiaries();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('오늘의 일기가 저장되었습니다.')),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadLocDiaries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('오늘의 일기 쓰기')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Consumer<LocationDiaryProvider>(
              builder: (context, provider, child) {
                final locDiaries = provider.locDiaries;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('오늘의 위치 일기',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: locDiaries.length,
                        itemBuilder: (context, index) {
                          final entry = locDiaries[index];
                          return Card(
                            margin: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: ListTile(
                              onTap: () => _onSelectLocDiary(entry),
                              leading: Checkbox(
                                value: _selectedIds.contains(entry.id),
                                onChanged: (checked) =>
                                    _onCheckChanged(checked, entry.id),
                              ),
                              title: Text(entry.content,
                                  maxLines: 2, overflow: TextOverflow.ellipsis),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('위치: ${entry.location.simpleName}',
                                      style: TextStyle(fontSize: 12)),
                                  Text(
                                      '작성 시간: ${entry.createdAt.hour}:${entry.createdAt.minute.toString().padLeft(2, '0')}',
                                      style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _selectedIds.isNotEmpty
                              ? _onSaveTodayDiary
                              : null,
                          child: Text('오늘의 일기 작성하기'),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
