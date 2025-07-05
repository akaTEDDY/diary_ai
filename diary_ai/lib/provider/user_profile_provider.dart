import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class UserProfile {
  final int age;
  final String gender;

  UserProfile({required this.age, required this.gender});
}

class UserProfileProvider extends ChangeNotifier {
  UserProfile _profile = UserProfile(age: 0, gender: '');

  UserProfile get profile => _profile;

  Future<void> setProfile(UserProfile profile) async {
    _profile = profile;
    var box = await Hive.openBox('user_profile');
    await box.put('profile', {'age': profile.age, 'gender': profile.gender});
    notifyListeners();
  }

  Future<void> loadProfile() async {
    var box = await Hive.openBox('user_profile');
    final data = box.get('profile');
    if (data != null) {
      _profile = UserProfile(age: data['age'], gender: data['gender']);
      notifyListeners();
    }
  }
}
