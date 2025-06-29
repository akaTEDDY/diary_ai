import 'package:diary_ai/provider/diary_provider.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/diary_entry.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/loc_diary_entry.dart';

class TabDiaryListPage extends StatefulWidget {
  const TabDiaryListPage({Key? key}) : super(key: key);

  @override
  State<TabDiaryListPage> createState() => _TabDiaryListPageState();
}

class _TabDiaryListPageState extends State<TabDiaryListPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final ScrollController _scrollController = ScrollController();

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

  Map<String, List<DiaryEntry>> _getGroupedDiaries(BuildContext context) {
    final diaryProvider = context.watch<DiaryProvider>();
    return diaryProvider.groupedByDate;
  }

  List<String> _getSortedDates(Map<String, List<DiaryEntry>> grouped) {
    final keys = grouped.keys.toList();
    keys.sort((a, b) => b.compareTo(a));
    return keys;
  }

  void _showDiaryDetail(LocDiaryEntry entry) {
    final photos = entry.photoPaths;
    final location = entry.location;
    final place = (location as dynamic).place as Map<String, dynamic>?;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    _buildDiaryIcon(place),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        place?['name'] ?? '',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.purple[800]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                if ((place?['address_road'] ?? place?['address']) != null &&
                    (place?['address_road'] ?? place?['address'])
                        .toString()
                        .isNotEmpty)
                  Row(
                    children: [
                      Icon(Icons.place, size: 16, color: Colors.purple[200]),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                            (place?['address_road'] ?? place?['address']) ?? '',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[700]),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time,
                        size: 16, color: Colors.purple[200]),
                    SizedBox(width: 4),
                    Text(DateFormat('HH:mm').format(location.timestamp),
                        style:
                            TextStyle(fontSize: 13, color: Colors.grey[700])),
                  ],
                ),
                SizedBox(height: 16),
                Text(entry.content,
                    style: TextStyle(fontSize: 15, color: Colors.grey[900])),
                if (photos.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Text('사진 (${photos.length}장)',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: photos
                        .map((path) => ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(File(path),
                                  width: 80, height: 80, fit: BoxFit.cover),
                            ))
                        .toList(),
                  ),
                ],
                SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('닫기',
                        style: TextStyle(
                            color: Colors.purple[700],
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDiaryIcon(Map<String, dynamic>? place) {
    if (place != null &&
        place['icon'] != null &&
        place['icon'].toString().isNotEmpty) {
      return Text(place['icon'].toString(), style: TextStyle(fontSize: 28));
    }
    return Icon(Icons.location_on, color: Color(0xFF7C3AED), size: 28);
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _getGroupedDiaries(context);
    final sortedDates = _getSortedDates(grouped);
    final today = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: Text('일기 목록')),
      body: Column(
        children: [
          // 달력
          TableCalendar<DiaryEntry>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: (day) => _getDiaryForDay(context, day),
            calendarStyle: CalendarStyle(
              markerDecoration: BoxDecoration(
                color: Colors.purple[400],
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.blue[500],
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.purple[600],
                shape: BoxShape.circle,
              ),
              markerSize: 7,
              markersAlignment: Alignment.bottomCenter,
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronIcon:
                  Icon(Icons.chevron_left, color: Colors.purple[700]),
              rightChevronIcon:
                  Icon(Icons.chevron_right, color: Colors.purple[700]),
              titleTextStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                // 가로 스크롤 카드로 이동
                final idx = sortedDates
                    .indexOf(DateFormat('yyyy-MM-dd').format(selectedDay));
                if (idx != -1) {
                  _scrollController.animateTo(
                    idx * 340.0,
                    duration: Duration(milliseconds: 400),
                    curve: Curves.ease,
                  );
                }
              });
            },
          ),
          const SizedBox(height: 8),
          // 가로 스크롤 카드
          Expanded(
            child: sortedDates.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today,
                            size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('작성된 일기가 없습니다',
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey[600])),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: sortedDates.length,
                    itemBuilder: (context, idx) {
                      final date = sortedDates[idx];
                      final entry = grouped[date]!;
                      final dateObj = DateTime.parse(date);
                      return Container(
                        width: 320,
                        margin: EdgeInsets.only(
                            left: idx == 0 ? 16 : 8,
                            right: idx == sortedDates.length - 1 ? 16 : 8,
                            top: 8,
                            bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 날짜 헤더
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(18)),
                                gradient: LinearGradient(colors: [
                                  Colors.purple[500]!,
                                  Colors.blue[500]!
                                ]),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_formatDateHeader(dateObj),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white)),
                                  SizedBox(height: 2),
                                  Text(
                                      DateFormat('yyyy년 M월 d일').format(dateObj),
                                      style: TextStyle(
                                          fontSize: 13,
                                          color:
                                              Colors.white.withOpacity(0.8))),
                                ],
                              ),
                            ),
                            // 일기 리스트
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.vertical(
                                      bottom: Radius.circular(18)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                child: ListView.separated(
                                  itemCount: entry.first.locationDiaries.length,
                                  separatorBuilder: (_, __) =>
                                      SizedBox(height: 10),
                                  itemBuilder: (context, entryIdx) {
                                    final locDiary =
                                        entry.first.locationDiaries[entryIdx];
                                    final location = locDiary.location;
                                    final place = (location as dynamic).place
                                        as Map<String, dynamic>?;
                                    final photos = locDiary.photoPaths;
                                    return InkWell(
                                      borderRadius: BorderRadius.circular(14),
                                      onTap: () => _showDiaryDetail(locDiary),
                                      child: Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[50],
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.04),
                                                    blurRadius: 2,
                                                    offset: Offset(0, 1),
                                                  ),
                                                ],
                                              ),
                                              alignment: Alignment.center,
                                              child: _buildDiaryIcon(place),
                                            ),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          place?['name'] ?? '',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .black87),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 2),
                                                  Text(
                                                      DateFormat('HH:mm')
                                                          .format(location
                                                              .timestamp),
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors
                                                              .grey[600])),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    locDiary.content,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            Colors.grey[800]),
                                                  ),
                                                  if (photos.isNotEmpty)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 4.0),
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.camera_alt,
                                                              size: 14,
                                                              color: Colors
                                                                  .grey[500]),
                                                          SizedBox(width: 2),
                                                          Text(
                                                              '${photos.length}장',
                                                              style: TextStyle(
                                                                  fontSize: 11,
                                                                  color: Colors
                                                                          .grey[
                                                                      600])),
                                                        ],
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatDateHeader(DateTime date) {
    final today = DateTime.now();
    final yesterday = today.subtract(Duration(days: 1));
    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return '오늘';
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return '어제';
    } else {
      return DateFormat('M월 d일 (E)', 'ko_KR').format(date);
    }
  }
}
