import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:diary_ai/views/permission_dialog.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class PermissionInfo {
  final String name;
  final String description;
  final bool isRequired;
  final String permissionType;

  const PermissionInfo({
    required this.name,
    required this.description,
    required this.permissionType,
    this.isRequired = true,
  });
}

class PermissionUtils {
  static List<PermissionInfo> getRequiredPermissions() {
    final List<PermissionInfo> base = [
      const PermissionInfo(
        name: '위치 권한',
        description: '사용자의 위치 기반 서비스 제공 및 주변 정보 표시',
        permissionType: 'location',
      ),
      const PermissionInfo(
        name: '알림 권한',
        description: '위치 기반 서비스 상태 및 중요 알림 수신',
        permissionType: 'notification',
      ),
    ];
    // Android 12 이상에서만 정확한 알람 권한 추가
    if (Platform.isAndroid) {
      // device_info_plus로 버전 체크
      // (이 함수는 async가 아니므로, 실제 체크는 팝업 띄우기 전에 별도 처리 필요)
      // 여기서는 일단 무조건 추가해두고, 팝업에서 실제로는 12 이상에서만 보이게 처리할 수도 있음
      base.add(const PermissionInfo(
        name: '정확한 알람 권한',
        description: '정확한 시간에 알림을 받기 위해 필요합니다. Android 12 이상 필수.',
        permissionType: 'exact_alarm',
      ));
    }
    return base;
  }

  static final List<PermissionInfo> optionalPermissions = [
    const PermissionInfo(
      name: '백그라운드 위치 권한',
      description: '백그라운드에서 사용자의 위치 기반 서비스 제공',
      permissionType: 'background_location',
      isRequired: false,
    ),
    // const PermissionInfo(
    //   name: '알림 권한',
    //   description: '위치 기반 서비스 상태 및 중요 알림 수신',
    //   permissionType: 'notification',
    //   isRequired: false,
    // ),
    // Android 10+ 백그라운드 위치 권한은 별도 요청 시 고려
    // const PermissionInfo(
    //   name: '백그라운드 위치 권한',
    //   description: '앱이 백그라운드에 있을 때도 위치 기반 서비스 제공',
    //   permissionType: 'background_location',
    //   isRequired: false,
    // ),
  ];

  // 위치 권한 확인 및 요청
  static Future<bool> checkAndRequestPermission(BuildContext context) async {
    final status = await checkPermission();
    if (status) return true;

    final result = await showPermissionDialog(context);
    if (result) {
      return await requestPermission();
    }
    return false;
  }

  // 위치, 알림, 백그라운드 위치, 정확한 알람 권한 확인
  static Future<bool> checkPermission() async {
    try {
      final locationStatus = await Permission.location.status;
      final notificationStatus = await Permission.notification.status;
      final backgroundLocationStatus = await Permission.locationAlways.status;
      bool exactAlarmGranted = true;
      if (Platform.isAndroid) {
        final deviceInfoPlugin = DeviceInfoPlugin();
        final androidInfo = await deviceInfoPlugin.androidInfo;
        if (androidInfo.version.sdkInt >= 31) {
          exactAlarmGranted = await Permission.scheduleExactAlarm.isGranted;
        }
      }
      return locationStatus.isGranted &&
          notificationStatus.isGranted &&
          backgroundLocationStatus.isGranted &&
          exactAlarmGranted;
    } catch (e) {
      print('권한 확인 오류: $e');
      return false;
    }
  }

  // 위치, 알림, 백그라운드 위치, 정확한 알람 권한 요청
  static Future<bool> requestPermission() async {
    try {
      final locationStatus = await Permission.location.request();
      final notificationStatus = await Permission.notification.request();
      final backgroundLocationStatus =
          await Permission.locationAlways.request();
      bool exactAlarmGranted = true;
      if (Platform.isAndroid) {
        final deviceInfoPlugin = DeviceInfoPlugin();
        final androidInfo = await deviceInfoPlugin.androidInfo;
        if (androidInfo.version.sdkInt >= 31) {
          final result = await Permission.scheduleExactAlarm.request();
          exactAlarmGranted = result.isGranted;
        }
      }
      return locationStatus.isGranted &&
          notificationStatus.isGranted &&
          backgroundLocationStatus.isGranted &&
          exactAlarmGranted;
    } catch (e) {
      print('권한 요청 오류: $e');
      return false;
    }
  }

  static Future<bool> showPermissionDialog(
    BuildContext context,
  ) async {
    // 필수 및 선택 권한 목록 분리
    final requiredItems = getRequiredPermissions().map((p) {
      IconData icon;
      Color color;
      switch (p.permissionType) {
        case 'location':
          icon = Icons.location_on;
          color = Colors.green;
          break;
        case 'background_location':
          icon = Icons.my_location;
          color = Colors.orange;
          break;
        case 'notification':
          icon = Icons.notifications;
          color = Colors.blue;
          break;
        case 'exact_alarm':
          icon = Icons.alarm_on;
          color = Colors.redAccent;
          break;
        default:
          icon = Icons.security;
          color = Colors.grey;
      }
      return PermissionDialogItem(
        icon: icon,
        title: p.name,
        description: p.description,
        color: color,
      );
    }).toList();
    final optionalItems = optionalPermissions.map((p) {
      IconData icon;
      Color color;
      switch (p.permissionType) {
        case 'location':
          icon = Icons.location_on;
          color = Colors.green;
          break;
        case 'background_location':
          icon = Icons.my_location;
          color = Colors.orange;
          break;
        case 'notification':
          icon = Icons.notifications;
          color = Colors.blue;
          break;
        default:
          icon = Icons.security;
          color = Colors.grey;
      }
      return PermissionDialogItem(
        icon: icon,
        title: p.name,
        description: p.description,
        color: color,
      );
    }).toList();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PermissionDialog(
        requiredItems: requiredItems,
        optionalItems: optionalItems,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
    return result ?? false;
  }
}
