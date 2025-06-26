import 'package:diary_ai/provider/diary_provider.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/diary_entry.dart';
import '../services/diary_service.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class TabDiaryListPage extends StatefulWidget {
  const TabDiaryListPage({Key? key}) : super(key: key);

  @override
  State<TabDiaryListPage> createState() => _TabDiaryListPageState();
}

class _TabDiaryListPageState extends State<TabDiaryListPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DiaryProvider>().loadDiaries();
    });
  }

  List<DiaryEntry> _getDiaryForDay(BuildContext context, DateTime day) {
    final diaryProvider = context.watch<DiaryProvider>();
    final grouped = diaryProvider.groupedByDate;
    final key = DateFormat('yyyy-MM-dd').format(day);
    return grouped[key] ?? [];
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
    final diaryProvider = context.watch<DiaryProvider>();
    final grouped = diaryProvider.groupedByDate;

    return Scaffold(
      appBar: AppBar(title: Text('일기 목록')),
      body: diaryProvider.diaries.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TableCalendar<DiaryEntry>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2100, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  eventLoader: (day) => _getDiaryForDay(context, day),
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
                            final diaries =
                                _getDiaryForDay(context, _selectedDay!);
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
