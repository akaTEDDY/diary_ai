import 'package:diary_ai/provider/diary_provider.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/diary_entry.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/loc_diary_entry.dart';
import 'package:diary_ai/provider/settings_provider.dart';
import 'package:common_utils_services/services/ai_services.dart';
import 'package:diary_ai/utils/prompt_utils.dart';
import '../services/diary_service.dart';

class TabDiaryListPage extends StatefulWidget {
  const TabDiaryListPage({Key? key}) : super(key: key);

  @override
  State<TabDiaryListPage> createState() => _TabDiaryListPageState();
}

class _TabDiaryListPageState extends State<TabDiaryListPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<DiaryProvider>().loadDiaries();
      _requestAIFeedbackIfNeeded();
    });
  }

  void _requestAIFeedbackIfNeeded() {
    final diaryProvider = context.read<DiaryProvider>();
    final todayDate =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final todayDiary = diaryProvider.groupedByDate[todayDate];
    if (todayDiary != null && canRequestAIFeedback(todayDiary)) {
      if (todayDiary.hasFeedback) {
        // 이미 피드백 받음
        return;
      }
      _requestAIFeedback(todayDiary);
    }
  }

  DiaryEntry? _getDiaryForDayEntry(BuildContext context, DateTime day) {
    final diaryProvider = context.watch<DiaryProvider>();
    final grouped = diaryProvider.groupedByDate;
    final dayDate = DateTime(day.year, day.month, day.day);
    return grouped[dayDate];
  }

  Map<DateTime, DiaryEntry> _getGroupedDiaries(BuildContext context) {
    final diaryProvider = context.watch<DiaryProvider>();
    return diaryProvider.groupedByDate;
  }

  List<DateTime> _getSortedDates(Map<DateTime, DiaryEntry> grouped) {
    final dates = grouped.keys.toList();
    dates.sort((a, b) => b.compareTo(a));
    return dates;
  }

  List<DiaryEntry> _getDiaryForDay(BuildContext context, DateTime day) {
    final entry = _getDiaryForDayEntry(context, day);
    if (entry != null) {
      return [entry];
    } else {
      return [];
    }
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
                    Text(
                        '방문: ' +
                            DateFormat('yyyy-MM-dd HH:mm')
                                .format(location.timestamp),
                        style:
                            TextStyle(fontSize: 13, color: Colors.grey[700])),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.edit, size: 16, color: Colors.purple[200]),
                    SizedBox(width: 4),
                    Text(
                        '작성: ' +
                            DateFormat('yyyy-MM-dd HH:mm')
                                .format(entry.createdAt),
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFF),
        title: Text('일기 목록',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            )),
      ),
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
                color: Colors.purple[200],
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
                final idx =
                    sortedDates.indexWhere((d) => isSameDay(d, selectedDay));
                if (idx != -1) {
                  // ScrollController가 연결되어 있을 때만 animateTo 호출
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      idx * 340.0,
                      duration: Duration(milliseconds: 400),
                      curve: Curves.ease,
                    );
                  }
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
                : (_selectedDay != null &&
                        _getDiaryForDay(context, _selectedDay!).isEmpty)
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info_outline,
                                size: 48, color: Colors.purple[200]),
                            SizedBox(height: 12),
                            Text(
                              _isToday(_selectedDay!)
                                  ? '아직 오늘 일기를 작성하지 않았네요.\n일기를 작성해보세요.'
                                  : '이 날짜에는 작성된 일기가 없습니다',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: sortedDates.length,
                        itemBuilder: (context, idx) {
                          final dateObj = sortedDates[idx];
                          final entry = grouped[dateObj]!;
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
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(_formatDateHeader(dateObj),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Colors.white)),
                                            SizedBox(height: 2),
                                            Text(
                                                DateFormat('yyyy년 M월 d일')
                                                    .format(dateObj),
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.white
                                                        .withOpacity(0.8))),
                                          ],
                                        ),
                                      ),
                                      // AI 답장 아이콘 (우체통/편지)
                                      GestureDetector(
                                        onTap: () => _handleAIFeedback(entry),
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: entry.hasFeedback
                                                ? Colors.yellow.withOpacity(0.3)
                                                : Colors.white.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            entry.hasFeedback
                                                ? Icons.mail
                                                : Icons.local_post_office,
                                            color: entry.hasFeedback
                                                ? Colors.yellow[700]
                                                : Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
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
                                      // 최신 방문 순서로 정렬
                                      itemCount: entry.locationDiaries.length,
                                      separatorBuilder: (_, __) =>
                                          SizedBox(height: 10),
                                      itemBuilder: (context, entryIdx) {
                                        final sortedLocDiaries =
                                            List<LocDiaryEntry>.from(
                                                entry.locationDiaries)
                                              ..sort((a, b) => b.createdAt
                                                  .compareTo(a.createdAt));
                                        final locDiary =
                                            sortedLocDiaries[entryIdx];
                                        final location = locDiary.location;
                                        final place = (location as dynamic)
                                            .place as Map<String, dynamic>?;
                                        final photos = locDiary.photoPaths;
                                        return InkWell(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          onTap: () =>
                                              _showDiaryDetail(locDiary),
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
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              place?['name'] ??
                                                                  '',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 15,
                                                                  color: Colors
                                                                      .black87),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 2),
                                                      Text(
                                                          '${DateFormat('HH:mm').format(location.timestamp)} 작성 ',
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color: Colors
                                                                  .grey[600])),
                                                      SizedBox(height: 4),
                                                      Text(
                                                        locDiary.content,
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors
                                                                .grey[800]),
                                                      ),
                                                      if (photos.isNotEmpty)
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 4.0),
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                  Icons
                                                                      .camera_alt,
                                                                  size: 14,
                                                                  color: Colors
                                                                          .grey[
                                                                      500]),
                                                              SizedBox(
                                                                  width: 2),
                                                              Text(
                                                                  '${photos.length}장',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          11,
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

  // AI 피드백 요청 가능 여부(22~23시, 작성일이 오늘인지)
  bool canRequestAIFeedback(DiaryEntry entry) {
    final now = DateTime.now();
    final isSameDay = now.year == entry.createdAt.year &&
        now.month == entry.createdAt.month &&
        now.day == entry.createdAt.day;
    return (now.hour >= 22 && now.hour <= 23) && isSameDay;
  }

  void _handleAIFeedback(DiaryEntry entry) {
    if (entry.hasFeedback) {
      // 피드백이 있으면 피드백 내용을 보여줌
      _showAIFeedback(entry);
    } else {
      // 피드백이 없으면 시간 제한 확인 후 AI에게 요청
      if (canRequestAIFeedback(entry)) {
        _requestAIFeedback(entry);
      } else {
        // 시간 제한 외에는 안내 메시지 표시
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('피드백 시간'),
            content: Text('AI 피드백은 오늘 작성한 일기에 한해 오후 10시~11시에만 요청할 수 있습니다.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('확인'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _showAIFeedback(DiaryEntry entry) {
    final characterPreset =
        Provider.of<SettingsProvider>(context, listen: false).characterPreset;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  if (characterPreset.imagePath.isNotEmpty)
                    CircleAvatar(
                      backgroundImage: AssetImage(characterPreset.imagePath),
                      radius: 22,
                    )
                  else if (characterPreset.emoji.isNotEmpty)
                    Text(
                      characterPreset.emoji,
                      style: TextStyle(fontSize: 36),
                    )
                  else
                    Icon(Icons.person, size: 36, color: Colors.purple[300]),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        characterPreset.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.purple[800],
                        ),
                      ),
                      if (characterPreset.description.isNotEmpty)
                        Text(
                          characterPreset.description,
                          style:
                              TextStyle(fontSize: 13, color: Colors.grey[700]),
                        ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (characterPreset.imagePath.isNotEmpty)
                    CircleAvatar(
                      backgroundImage: AssetImage(characterPreset.imagePath),
                      radius: 18,
                    )
                  else if (characterPreset.emoji.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(
                        characterPreset.emoji,
                        style: TextStyle(fontSize: 28),
                      ),
                    )
                  else
                    Icon(Icons.person, size: 28, color: Colors.purple[200]),
                  SizedBox(width: 10),
                  Flexible(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                      decoration: BoxDecoration(
                        color: Colors.purple[50],
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(18),
                          topRight: Radius.circular(18),
                          bottomRight: Radius.circular(18),
                        ),
                        border: Border.all(color: Colors.purple[100]!),
                      ),
                      child: Text(
                        entry.aiFeedback ?? '피드백 내용이 없습니다.',
                        style:
                            TextStyle(fontSize: 16, color: Colors.purple[900]),
                      ),
                    ),
                  ),
                ],
              ),
              if (entry.feedbackCreatedAt != null) ...[
                SizedBox(height: 12),
                Text(
                  '작성: ${DateFormat('yyyy년 M월 d일 HH:mm').format(entry.feedbackCreatedAt!)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    '닫기',
                    style: TextStyle(
                      color: Colors.purple[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _requestAIFeedback(DiaryEntry entry) async {
    final characterPreset =
        Provider.of<SettingsProvider>(context, listen: false).characterPreset;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.purple[600]),
              SizedBox(height: 16),
              Text(
                '${characterPreset.name}가 일기를 분석하고 있습니다...',
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
            ],
          ),
        ),
      ),
    );

    // AI 프롬프트 생성
    final prompt = PromptUtils.buildPrompt(
      context: context,
      entry: entry,
    );

    // AI 호출
    final aiServices = AIServices.instance;
    await aiServices.initialize();
    final aiFeedback = await aiServices.getAIResponse(
      prompt,
      [], // 대화 이력 없음(단일 프롬프트)
    );

    Navigator.of(context).pop(); // 로딩 다이얼로그 닫기

    // 결과 저장 및 UI 갱신
    entry.aiFeedback = aiFeedback;
    entry.feedbackCreatedAt = DateTime.now();
    entry.hasFeedback = true;

    // Hive에 직접 저장
    final diaryService = DiaryService();
    await diaryService.addDiaryDirect(entry);

    // Provider 데이터 갱신
    await context.read<DiaryProvider>().loadDiaries();

    setState(() {});
    _showAIFeedback(entry);
  }

  // 오늘 날짜인지 확인하는 함수 추가
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
