import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:common_utils_services/models/location_history.dart';
import '../models/diary_entry.dart';
import '../services/diary_service.dart';
import '../models/loc_diary_entry.dart';
import '../services/loc_diary_service.dart';
import 'package:uuid/uuid.dart';

class DiaryWriteFromLocationPage extends StatefulWidget {
  final LocationHistory location;

  const DiaryWriteFromLocationPage(this.location, {Key? key}) : super(key: key);

  @override
  State<DiaryWriteFromLocationPage> createState() =>
      _DiaryWriteFromLocationPageState();
}

class _DiaryWriteFromLocationPageState
    extends State<DiaryWriteFromLocationPage> {
  final TextEditingController _diaryController = TextEditingController();
  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  // 위경도 정보를 추출하는 헬퍼 메서드
  Map<String, double> _getCoordinates(LocationHistory location) {
    // place > location > district 순서로 확인
    if (location.place != null &&
        location.place!['lat'] != null &&
        location.place!['lng'] != null) {
      return {
        'lat': location.place!['lat'].toDouble(),
        'lng': location.place!['lng'].toDouble(),
      };
    }

    if (location.location != null &&
        location.location!['lat'] != null &&
        location.location!['lng'] != null) {
      return {
        'lat': location.location!['lat'].toDouble(),
        'lng': location.location!['lng'].toDouble(),
      };
    }

    if (location.district != null &&
        location.district!['lat'] != null &&
        location.district!['lng'] != null) {
      return {
        'lat': location.district!['lat'].toDouble(),
        'lng': location.district!['lng'].toDouble(),
      };
    }

    // 기본값 (위경도 정보가 없는 경우)
    return {'lat': 0.0, 'lng': 0.0};
  }

  @override
  void dispose() {
    _diaryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _selectedImages.add(File(image.path));
      });
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('사진 선택'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('카메라로 촬영'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('갤러리에서 선택'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveDiary() async {
    if (_diaryController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('일기 내용을 입력해주세요.')),
      );
      return;
    }
    final diaries = await DiaryService().getAllDiariesGroupedByDateTime();
    final today = DateTime.now();
    final todayKey =
        '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}';
    final todayDiaries = diaries.entries
        .where((e) => e.key.startsWith(todayKey))
        .expand((e) => e.value)
        .toList();
    final merged = todayDiaries
        .any((d) => d.location.displayName == widget.location.displayName);
    if (merged && mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('저장 불가'),
          content: Text('이 위치의 임시 일기는 오늘의 일기에 병합되어 더 이상 작성할 수 없습니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('확인'),
            ),
          ],
        ),
      );
      return;
    }

    final now = DateTime.now();
    final locDiaryEntry = LocDiaryEntry(
      id: Uuid().v4(),
      content: _diaryController.text.trim(),
      photoPaths: _selectedImages.map((f) => f.path).toList(),
      location: widget.location,
      createdAt: now,
    );
    await LocDiaryService().addLocDiary(locDiaryEntry);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('임시 일기가 저장되었습니다.')),
    );
    Navigator.pop(context, true);
  }

  void _cancelDiary() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('작성 취소'),
          content: Text('작성 중인 일기를 취소하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('계속 작성'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, false);
              },
              child: Text('취소'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final coordinates = _getCoordinates(widget.location);

    return Scaffold(
      appBar: AppBar(
        title: Text('위치 일기 작성'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveDiary,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 위치 정보 표시
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '위치 정보',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('위도: ${coordinates['lat']!.toStringAsFixed(6)}'),
                      Text('경도: ${coordinates['lng']!.toStringAsFixed(6)}'),
                      Text('시간: ${widget.location.formattedTime}'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              // 사진 첨부 버튼
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _showImageSourceDialog,
                    icon: Icon(Icons.add_a_photo),
                    label: Text('사진 첨부'),
                  ),
                  SizedBox(width: 8),
                  Text('${_selectedImages.length}장 선택됨'),
                ],
              ),
              SizedBox(height: 16),

              // 선택된 사진들 표시
              if (_selectedImages.isNotEmpty)
                Container(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            Image.file(
                              _selectedImages[index],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedImages.removeAt(index);
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              SizedBox(height: 16),

              // 일기 작성 텍스트 필드
              TextField(
                controller: _diaryController,
                maxLines: 10,
                expands: false,
                decoration: InputDecoration(
                  hintText: '이 위치에서 있었던 일을 기록해보세요...',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              // 하단 버튼들
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _cancelDiary,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                      child: Text('취소'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveDiary,
                      child: Text('저장'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
