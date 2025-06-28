import 'package:diary_ai/provider/location_diary_provider.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../models/loc_diary_entry.dart';
import '../models/diary_entry.dart';
import '../services/loc_diary_service.dart';
import '../services/diary_service.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class TabDiaryWritePage extends StatefulWidget {
  const TabDiaryWritePage({Key? key}) : super(key: key);

  @override
  State<TabDiaryWritePage> createState() => _TabDiaryWritePageState();
}

class _TabDiaryWritePageState extends State<TabDiaryWritePage> {
  List<LocDiaryEntry> _locDiaries = [];
  bool _isLoading = true;
  Set<String> _selectedIds = {};

  // 카드 슬라이더 관련
  late PageController _cardPageController;
  late PageController _photoPageController;
  int _currentCardIndex = 0;
  int _currentPhotoIndex = 0;

  @override
  void initState() {
    super.initState();
    _cardPageController = PageController();
    _photoPageController = PageController();
    _loadLocDiaries();
  }

  @override
  void dispose() {
    _cardPageController.dispose();
    _photoPageController.dispose();
    super.dispose();
  }

  Future<void> _loadLocDiaries() async {
    setState(() {
      _isLoading = true;
    });
    final locDiaries = await LocDiaryService().getLocDiariesForToday();
    // 시간순으로 정렬 (최신 시간이 위로)
    locDiaries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    setState(() {
      _locDiaries = locDiaries;
      _isLoading = false;
      _selectedIds.removeWhere((id) => !_locDiaries.any((e) => e.id == id));
    });
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _onSaveTodayDiary() async {
    final selected =
        _locDiaries.where((e) => _selectedIds.contains(e.id)).toList();
    if (selected.isEmpty) return;

    final now = DateTime.now();
    final dateTimeStr = DateFormat('yyyy-MM-dd HH:mm').format(now);

    // 선택된 위치 일기들의 내용을 합치기
    final content = selected.map((e) => e.content).join('\n\n');

    final diaryEntry = DiaryEntry(
      id: Uuid().v4(),
      content: content,
      dateTime: dateTimeStr,
      createdAt: now,
      locationDiaries: selected, // 선택된 위치 일기들을 모두 포함
    );

    try {
      await DiaryService().addDiary(context, diaryEntry);

      // 선택된 위치 일기들 삭제
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
    } catch (e) {
      print('일기 저장 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('일기 저장에 실패했습니다. 다시 시도해주세요.')),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Provider에서 데이터 로드
    context.read<LocationDiaryProvider>().loadLocDiaries();
    _loadLocDiaries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text('소중한 순간들을 모아서'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Consumer<LocationDiaryProvider>(
              builder: (context, provider, child) {
                // Provider 데이터와 로컬 데이터를 함께 사용
                final locDiaries = provider.locDiaries.isNotEmpty
                    ? provider.locDiaries
                    : _locDiaries;

                if (locDiaries.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          '아직 위치 일기가 없습니다',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '위치를 방문하면 자동으로 일기가 생성됩니다',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // 헤더
                    Container(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        '오늘의 소중한 일기가 될 순간을 선택해주세요',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    // 카드 슬라이더
                    Expanded(
                      child: PageView.builder(
                        controller: _cardPageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentCardIndex = index;
                            _currentPhotoIndex = 0;
                          });
                        },
                        itemCount: locDiaries.length,
                        itemBuilder: (context, index) {
                          final entry = locDiaries[index];
                          return _buildDiaryCard(entry, index);
                        },
                      ),
                    ),

                    // 카드 인디케이터
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          locDiaries.length,
                          (index) => GestureDetector(
                            onTap: () {
                              _cardPageController.animateToPage(
                                index,
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Container(
                              width: 12,
                              height: 12,
                              margin: EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: index == _currentCardIndex
                                    ? Colors.blue[600]
                                    : Colors.grey[300],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 하단 버튼
                    Container(
                      padding: EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _selectedIds.isNotEmpty
                              ? _onSaveTodayDiary
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedIds.isNotEmpty
                                ? Colors.blue[600]
                                : Colors.grey[300],
                            foregroundColor: _selectedIds.isNotEmpty
                                ? Colors.white
                                : Colors.grey[500],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: _selectedIds.isNotEmpty ? 4 : 0,
                          ),
                          child: Text(
                            _selectedIds.isNotEmpty
                                ? '${_selectedIds.length}개의 순간으로 일기 만들기'
                                : '순간을 선택해주세요',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildDiaryCard(LocDiaryEntry entry, int cardIndex) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Card(
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            // 카드 헤더
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo[500]!, Colors.purple[600]!],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.location.simpleName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _toggleSelection(entry.id),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        color: _selectedIds.contains(entry.id)
                            ? Colors.white
                            : Colors.transparent,
                      ),
                      child: _selectedIds.contains(entry.id)
                          ? Icon(Icons.check,
                              color: Colors.indigo[600], size: 20)
                          : null,
                    ),
                  ),
                ],
              ),
            ),

            // 스크롤 가능한 하단부
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 시간 정보
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Icon(Icons.access_time,
                              color: Colors.grey[600], size: 16),
                          SizedBox(width: 4),
                          Text(
                            LocDiaryService.formatTime(entry.createdAt),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 사진 영역
                    if (entry.photoPaths.isNotEmpty)
                      Container(
                        height: 200,
                        child: Stack(
                          children: [
                            PageView.builder(
                              controller: cardIndex == _currentCardIndex
                                  ? _photoPageController
                                  : null,
                              onPageChanged: (index) {
                                if (cardIndex == _currentCardIndex) {
                                  setState(() {
                                    _currentPhotoIndex = index;
                                  });
                                }
                              },
                              itemCount: entry.photoPaths.length,
                              itemBuilder: (context, photoIndex) {
                                return Container(
                                  margin: EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      File(entry.photoPaths[photoIndex]),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  ),
                                );
                              },
                            ),

                            // 사진 인디케이터
                            if (entry.photoPaths.length > 1)
                              Positioned(
                                bottom: 16,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    entry.photoPaths.length,
                                    (index) => Container(
                                      width: 8,
                                      height: 8,
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 2),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: cardIndex == _currentCardIndex &&
                                                index == _currentPhotoIndex
                                            ? Colors.white
                                            : Colors.white.withOpacity(0.6),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                            // 사진 카운터
                            if (entry.photoPaths.length > 1)
                              Positioned(
                                top: 16,
                                right: 32,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${(cardIndex == _currentCardIndex ? _currentPhotoIndex : 0) + 1} / ${entry.photoPaths.length}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                    // 일기 내용
                    Container(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${entry.location.placeName}의 기록',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            entry.content,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
