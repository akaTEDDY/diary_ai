import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:diary_ai/views/permission_dialog.dart';

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
  static final List<PermissionInfo> requiredPermissions = [
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

  // 위치, 알림, 백그라운드 위치 권한 확인
  static Future<bool> checkPermission() async {
    try {
      final locationStatus = await Permission.location.status;
      final notificationStatus = await Permission.notification.status;
      final backgroundLocationStatus = await Permission.locationAlways.status;
      return locationStatus.isGranted &&
          notificationStatus.isGranted &&
          backgroundLocationStatus.isGranted;
    } catch (e) {
      print('권한 확인 오류: $e');
      return false;
    }
  }

  // 위치, 알림, 백그라운드 위치 권한 요청
  static Future<bool> requestPermission() async {
    try {
      final locationStatus = await Permission.location.request();
      final notificationStatus = await Permission.notification.request();
      final backgroundLocationStatus =
          await Permission.locationAlways.request();
      return locationStatus.isGranted &&
          notificationStatus.isGranted &&
          backgroundLocationStatus.isGranted;
    } catch (e) {
      print('권한 요청 오류: $e');
      return false;
    }
  }

  static Future<bool> showPermissionDialog(
    BuildContext context,
  ) async {
    // 필수 및 선택 권한 목록 분리
    final requiredItems = requiredPermissions.map((p) {
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
