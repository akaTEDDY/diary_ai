import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:common_utils_services/models/location_history.dart';
import '../models/loc_diary_entry.dart';
import '../services/loc_diary_service.dart';
import 'package:uuid/uuid.dart';
import '../services/diary_service.dart';
import 'package:intl/intl.dart';

extension FirstWhereOrNullExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

class LocDiaryWritePage extends StatefulWidget {
  final LocationHistory location;
  const LocDiaryWritePage({Key? key, required this.location}) : super(key: key);

  @override
  State<LocDiaryWritePage> createState() => _LocDiaryWritePageState();
}

class _LocDiaryWritePageState extends State<LocDiaryWritePage> {
  final TextEditingController _controller = TextEditingController();
  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  LocDiaryEntry? _existingEntry;
  bool _isLoading = true;
  final List<String> _moodEmojis = [
    '😊',
    '😍',
    '😢',
    '😡',
    '😱',
    '😴',
    '🤩',
    '😌'
  ];
  String? _selectedMood;

  @override
  void initState() {
    super.initState();
    _checkIfMergedToTodayDiary();
    _selectedMood = null;
  }

  Future<void> _checkIfMergedToTodayDiary() async {
    final diaries = await DiaryService().getAllDiariesGroupedByDate();
    final todayDiary = LocDiaryService.getTodayDiary(diaries);
    final isAlreadyMerged = LocDiaryService.isLocationAlreadyInDiary(
      widget.location,
      todayDiary,
    );
    if (isAlreadyMerged && mounted) {
      await Future.delayed(Duration.zero);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('수정 불가'),
          content: Text('이 위치의 위치 일기는 오늘의 일기에 병합되어 더 이상 수정할 수 없습니다.'),
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
    } else {
      _loadExistingLocDiary();
    }
  }

  Future<void> _loadExistingLocDiary() async {
    final locDiaries = await LocDiaryService().getLocDiariesForToday();

    // 새로운 효율적인 함수 사용
    final existingEntry = LocDiaryService.findLocationDiaryByLocation(
      widget.location,
      locDiaries,
    );

    if (existingEntry != null) {
      _existingEntry = existingEntry;
      _controller.text = existingEntry.content;
      _selectedImages.addAll(existingEntry.photoPaths.map((p) => File(p)));
      _selectedMood = existingEntry.mood;
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _selectedImages.add(File(image.path));
      });
    }
  }

  Future<void> _pickImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null && images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images.map((x) => File(x.path)));
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
              ListTile(
                leading: Icon(Icons.collections),
                title: Text('갤러리에서 여러 장 선택'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImages();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveLocDiary() async {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('일기 내용을 입력해주세요.')),
      );
      return;
    }
    final diaries = await DiaryService().getAllDiariesGroupedByDate();
    final todayDiary = LocDiaryService.getTodayDiary(diaries);
    final isAlreadyMerged = LocDiaryService.isLocationAlreadyInDiary(
      widget.location,
      todayDiary,
    );
    if (isAlreadyMerged && mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('저장 불가'),
          content: Text('이 위치의 위치 일기는 오늘의 일기에 병합되어 더 이상 작성할 수 없습니다.'),
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
    final entry = LocDiaryEntry(
      id: _existingEntry?.id ?? Uuid().v4(),
      content: _controller.text.trim(),
      photoPaths: _selectedImages.map((f) => f.path).toList(),
      location: widget.location,
      createdAt: _existingEntry?.createdAt ?? now,
      mood: _selectedMood,
    );
    await LocDiaryService().addLocDiary(context, entry);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('위치 일기가 저장되었습니다.')),
    );
    Navigator.pop(context, true);
  }

  Future<void> _deleteLocDiary() async {
    if (_existingEntry == null) return;
    await LocDiaryService().deleteLocDiary(context, _existingEntry!.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('위치 일기가 삭제되었습니다.')),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('위치 일기 작성/수정')),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFF),
        title: Text('위치 일기 작성/수정'),
        actions: [
          if (_existingEntry != null)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _deleteLocDiary,
              tooltip: '위치 일기 삭제',
            ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveLocDiary,
            tooltip: '저장',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Color(0xFFF3E8FF),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Color(0xFFE9D5FF),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: _buildLocationIcon(widget.location),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.location.simpleName,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    color: Color(0xFF5B21B6))),
                            SizedBox(height: 4),
                            Text(_getLocationAddress(widget.location),
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey[700])),
                            SizedBox(height: 4),
                            Text(
                                '방문 시간: ' +
                                    DateFormat('yyyy-MM-dd HH:mm')
                                        .format(widget.location.timestamp),
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.purple[700],
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text('방문 당시 기분', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Wrap(
                spacing: 12,
                children: _moodEmojis.map((emoji) {
                  final isSelected = _selectedMood == emoji;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMood = emoji;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? Colors.purple[100] : Colors.grey[100],
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.purple, width: 2)
                            : null,
                      ),
                      child: Text(emoji, style: TextStyle(fontSize: 18)),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('사진 (${_selectedImages.length})',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  ElevatedButton.icon(
                    onPressed: _showImageSourceDialog,
                    icon: Icon(Icons.camera_alt, color: Colors.purple),
                    label:
                        Text('사진 추가', style: TextStyle(color: Colors.purple)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[100],
                      minimumSize: Size(0, 40),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              if (_selectedImages.isNotEmpty)
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _selectedImages.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _selectedImages[index],
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
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
                              child: Icon(Icons.close,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                )
              else
                Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.grey[300]!,
                        style: BorderStyle.solid,
                        width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, color: Colors.grey, size: 32),
                        SizedBox(height: 8),
                        Text('사진을 추가해보세요',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              SizedBox(height: 16),
              TextField(
                controller: _controller,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: '이 위치에서의 기록을 남겨보세요...',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveLocDiary,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[600],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('저장하기',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationIcon(LocationHistory location) {
    String? emoji =
        location.place != null ? location.place!['icon'] as String? : null;
    if (emoji != null && emoji.isNotEmpty) {
      return Text(emoji, style: TextStyle(fontSize: 28));
    }
    return Icon(Icons.location_on, color: Color(0xFF7C3AED), size: 28);
  }

  String _getLocationAddress(LocationHistory location) {
    if (location.place != null) {
      final road = location.place!['address_road'] as String?;
      if (road != null && road.isNotEmpty) return road;
      final addr = location.place!['address'] as String?;
      if (addr != null && addr.isNotEmpty) return addr;
    }
    return '';
  }
}
