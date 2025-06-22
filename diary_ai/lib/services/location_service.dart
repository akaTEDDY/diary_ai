import 'package:geolocator/geolocator.dart';
import 'package:diary_ai/models/location_history.dart';

class LocationService {
  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<Position?> getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      return null;
    }
  }

  Future<List<LocationHistory>> getLocationHistory() async {
    // TODO: 위치 히스토리 불러오기 구현
    return [];
  }

  Future<void> saveLocationHistory(LocationHistory history) async {
    // TODO: 위치 히스토리 저장 구현
  }
}
