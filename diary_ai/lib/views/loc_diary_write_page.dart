import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:common_utils_services/models/location_history.dart';
import '../models/loc_diary_entry.dart';
import '../services/loc_diary_service.dart';
import 'package:uuid/uuid.dart';
import '../services/diary_service.dart';
import 'package:provider/provider.dart';
import '../provider/location_diary_provider.dart';

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

  @override
  void initState() {
    super.initState();
    _checkIfMergedToTodayDiary();
  }

  Future<void> _checkIfMergedToTodayDiary() async {
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
    final entry = locDiaries.firstWhereOrNull(
      (e) => e.location.displayName == widget.location.displayName,
    );
    if (entry != null) {
      _existingEntry = entry;
      _controller.text = entry.content;
      _selectedImages.addAll(entry.photoPaths.map((p) => File(p)));
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
      appBar: AppBar(
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('위치 정보',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text(widget.location.simpleName),
                      Text('작성 시간: ${widget.location.formattedTime}'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
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
              if (_selectedImages.isNotEmpty)
                Container(
                  height: 100,
                  margin: EdgeInsets.only(bottom: 16),
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
              TextField(
                controller: _controller,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: '이 위치에서의 위치 일기를 작성하세요...',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveLocDiary,
                  child: Text('저장'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
