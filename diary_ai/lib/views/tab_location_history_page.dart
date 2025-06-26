import 'package:common_utils_services/models/location_history.dart';
import 'package:common_utils_services/utils/location_utils.dart';
import 'package:flutter/material.dart';
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
        title: Text('위치 히스토리'),
        actions: [
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
                    return ExpansionTile(
                      title: Text(
                        dateKey,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey),
                      ),
                      children: entries
                          .map((location) => ListTile(
                                leading: GestureDetector(
                                  onTap: () => _openMap(location),
                                  child: Icon(Icons.location_on,
                                      color: Colors.red),
                                ),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        DateFormat('yyyy-MM-dd HH:mm')
                                            .format(location.timestamp),
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.black87)),
                                    if (location.place != null &&
                                        location.place!['name'] != null)
                                      Text(
                                        location.place!['tags'] != null &&
                                                (location.place!['tags']
                                                        as String)
                                                    .isNotEmpty
                                            ? '${location.place!['name']} (${location.place!['tags']})'
                                            : '${location.place!['name']}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                    Builder(
                                      builder: (context) {
                                        String address = '';
                                        if (location.place != null &&
                                            location.place!['address_road'] !=
                                                null) {
                                          address =
                                              location.place!['address_road'];
                                        } else if (location.district != null) {
                                          final lv1 =
                                              location.district!['lv1_name'] ??
                                                  '';
                                          final lv2 =
                                              location.district!['lv2_name'] ??
                                                  '';
                                          final lv3 =
                                              location.district!['lv3_name'] ??
                                                  '';
                                          address = [lv1, lv2, lv3]
                                              .where((e) => e.isNotEmpty)
                                              .join(' ');
                                        }
                                        return Text(address,
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.black87));
                                      },
                                    ),
                                  ],
                                ),
                                trailing: Icon(Icons.arrow_forward_ios),
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          LocDiaryWritePage(location: location),
                                    ),
                                  );
                                  await _loadLocationHistory();
                                },
                              ))
                          .toList(),
                    );
                  },
                ),
    );
  }
}
