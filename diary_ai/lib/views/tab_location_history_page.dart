import 'package:common_utils_services/models/location_history.dart';
import 'package:common_utils_services/utils/location_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'loc_diary_write_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class TabLocationHistoryPage extends StatefulWidget {
  final LocationHistoryManager _locationHistoryManager;

  const TabLocationHistoryPage(this._locationHistoryManager, {Key? key})
      : super(key: key);

  @override
  State<TabLocationHistoryPage> createState() => _TabLocationHistoryPageState();
}

class _TabLocationHistoryPageState extends State<TabLocationHistoryPage> {
  bool _isLoading = true;
  List<LocationHistory> _locationHistory = [];
  final platform = MethodChannel('plengi.ai/fromFlutter');

  @override
  void initState() {
    super.initState();
    _loadLocationHistory();
  }

  Future<void> _loadLocationHistory() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var currentHistory = widget._locationHistoryManager.locationHistory;
      if (currentHistory.isEmpty) {
        String? locationJson = await LocationUtils.getCurrentLocation();
        if (locationJson != null && mounted) {
          widget._locationHistoryManager.addLocationHistory(locationJson);
          currentHistory = widget._locationHistoryManager.locationHistory;
        }
      }
      if (mounted) {
        setState(() {
          _locationHistory = List.from(currentHistory)
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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

  Future<void> _openMap(LocationHistory location) async {
    final coordinates = _getCoordinates(location);
    final lat = coordinates['lat'];
    final lng = coordinates['lng'];
    final placeName = location.place?['name'] ?? '';
    final naverUrl =
        Uri.parse('nmap://place?lat=$lat&lng=$lng&name=$placeName');
    final googleUrl =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(naverUrl)) {
      await launchUrl(naverUrl, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 날짜별로 그룹핑
    Map<String, List<LocationHistory>> groupedByDate = {};
    for (var entry in _locationHistory) {
      final dateKey = DateFormat('yyyy-MM-dd').format(entry.timestamp);
      groupedByDate.putIfAbsent(dateKey, () => []).add(entry);
    }
    final sortedDateKeys = groupedByDate.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // 최신 날짜가 위로

    return Scaffold(
      appBar: AppBar(
        title: Text('내 추억의 장소들'),
        actions: [
          IconButton(
            icon: Icon(Icons.power),
            onPressed: () async {
              await platform.invokeMethod('plengiStartStop');
            },
          ),
          Tooltip(
            message: '현재 위치 추가하기',
            child: IconButton(
              icon: Icon(Icons.pin_drop_sharp),
              onPressed: () async {
                String location = await platform.invokeMethod('searchPlace');
                widget._locationHistoryManager.addLocationHistory(location);
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadLocationHistory,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _locationHistory.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('저장된 위치 히스토리가 없습니다.'),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadLocationHistory,
                        child: Text('현재 위치로 추가하기'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: sortedDateKeys.length,
                  itemBuilder: (context, dateIdx) {
                    final dateKey = sortedDateKeys[dateIdx];
                    final entries = groupedByDate[dateKey]!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 날짜 헤더
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 16),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.purple[100],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  DateFormat('yyyy년 M월 d일')
                                      .format(DateTime.parse(dateKey)),
                                  style: TextStyle(
                                    color: Colors.purple[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                  child: Divider(
                                      thickness: 1,
                                      color: Colors.grey[300],
                                      indent: 12)),
                            ],
                          ),
                        ),
                        // 타임라인
                        ...List.generate(entries.length, (idx) {
                          final location = entries[idx];
                          // 아이콘(이모지 또는 대표 아이콘)
                          String? emoji = location.place != null
                              ? location.place!['icon'] as String?
                              : null;
                          Widget iconWidget;
                          if (emoji != null && emoji.isNotEmpty) {
                            iconWidget = GestureDetector(
                              onTap: () => _openMap(location),
                              child: Text(
                                emoji,
                                style: TextStyle(fontSize: 28),
                                textAlign: TextAlign.center,
                              ),
                            );
                          } else {
                            iconWidget = GestureDetector(
                              onTap: () => _openMap(location),
                              child: Icon(Icons.location_on,
                                  color: Colors.purple, size: 28),
                            );
                          }
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 타임라인 점 + 선
                              Container(
                                width: 56,
                                child: Column(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            color: Colors.purple[300]!,
                                            width: 4),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.purple.withOpacity(0.08),
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      alignment: Alignment.center,
                                      child: iconWidget,
                                    ),
                                    if (idx != entries.length - 1)
                                      Container(
                                        width: 4,
                                        height: 60,
                                        color: Colors.purple[100],
                                      ),
                                  ],
                                ),
                              ),
                              // 내용 카드
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LocDiaryWritePage(
                                            location: location),
                                      ),
                                    );
                                    await _loadLocationHistory();
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 32, top: 4),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 18),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.07),
                                          blurRadius: 12,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                location.place?['name'] ??
                                                    location.simpleName,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 17,
                                                    color: Colors.black87),
                                              ),
                                              SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  Icon(Icons.place,
                                                      size: 16,
                                                      color:
                                                          Colors.purple[200]),
                                                  SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      (location.place?['address_road']
                                                                      as String?)
                                                                  ?.isNotEmpty ==
                                                              true
                                                          ? location.place![
                                                              'address_road']
                                                          : (location.place?['address']
                                                                          as String?)
                                                                      ?.isNotEmpty ==
                                                                  true
                                                              ? location.place![
                                                                  'address']
                                                              : '',
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          color:
                                                              Colors.grey[600]),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        // 방문 시간 컬러 배지
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.purple[50],
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Text(
                                            DateFormat('hh:mm a')
                                                .format(location.timestamp),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.purple[700],
                                                fontSize: 13),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    );
                  },
                ),
    );
  }
}
