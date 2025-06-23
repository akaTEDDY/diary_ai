import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/diary_entry.dart';
import '../services/diary_service.dart';
import 'dart:io';

class TabDiaryListPage extends StatefulWidget {
  const TabDiaryListPage({Key? key}) : super(key: key);

  @override
  State<TabDiaryListPage> createState() => _TabDiaryListPageState();
}

class _TabDiaryListPageState extends State<TabDiaryListPage> {
  Map<String, DiaryEntry> _todayDiaryMap = {};
  bool _isLoading = true;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _loadDiaries();
  }

  Future<void> _loadDiaries() async {
    setState(() {
      _isLoading = true;
    });
    final grouped = await DiaryService().getAllDiariesGroupedByDateTime();
    // 하루에 하나(가장 최근)만 남기기
    Map<String, DiaryEntry> todayDiaryMap = {};
    for (var entry in grouped.entries) {
      // key: yyyy-MM-dd HH:mm
      final dateKey = entry.key.substring(0, 10); // yyyy-MM-dd
      final diaries = entry.value;
      diaries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (!todayDiaryMap.containsKey(dateKey) && diaries.isNotEmpty) {
        todayDiaryMap[dateKey] = diaries.first;
      } else if (diaries.isNotEmpty &&
          diaries.first.createdAt.isAfter(todayDiaryMap[dateKey]!.createdAt)) {
        todayDiaryMap[dateKey] = diaries.first;
      }
    }
    setState(() {
      _todayDiaryMap = todayDiaryMap;
      _isLoading = false;
    });
  }

  List<DiaryEntry> _getDiaryForDay(DateTime day) {
    final key =
        '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    if (_todayDiaryMap.containsKey(key)) {
      return [_todayDiaryMap[key]!];
    }
    return [];
  }

  void _showMergedDetail(DiaryEntry diary) {
    final contents = diary.content.split('\n\n');
    final photos = diary.photoPaths;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('병합된 위치 일기 전체'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: contents.length,
            itemBuilder: (context, idx) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('위치 일기 ${idx + 1}',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(contents[idx]),
                  if (photos.length > idx && photos[idx].isNotEmpty) ...[
                    SizedBox(height: 8),
                    Image.file(File(photos[idx]),
                        width: 80, height: 80, fit: BoxFit.cover),
                  ],
                  Divider(),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('닫기'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('일기 목록')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TableCalendar<DiaryEntry>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2100, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  eventLoader: _getDiaryForDay,
                  calendarStyle: CalendarStyle(
                    markerDecoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _selectedDay == null
                      ? Center(child: Text('날짜를 선택하세요.'))
                      : Builder(
                          builder: (context) {
                            final diaries = _getDiaryForDay(_selectedDay!);
                            if (diaries.isEmpty) {
                              return Center(child: Text('이 날 작성된 일기가 없습니다.'));
                            }
                            final diary = diaries.first;
                            return Card(
                              margin: EdgeInsets.all(16),
                              child: InkWell(
                                onTap: () => _showMergedDetail(diary),
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        diary.dateTime,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      SizedBox(height: 8),
                                      Text(diary.content),
                                      if (diary.photoPaths.isNotEmpty) ...[
                                        SizedBox(height: 8),
                                        Wrap(
                                          spacing: 8,
                                          children: diary.photoPaths
                                              .map((path) => Image.file(
                                                    File(path),
                                                    width: 60,
                                                    height: 60,
                                                    fit: BoxFit.cover,
                                                  ))
                                              .toList(),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
