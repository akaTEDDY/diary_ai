import 'package:flutter/material.dart';

class CharacterPreset {
  final String id;
  final String name;
  final int age;
  final String gender;
  final int kindnessLevel;

  CharacterPreset({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.kindnessLevel,
  });
}

class CharacterPresetProvider extends ChangeNotifier {
  CharacterPreset _selectedPreset = CharacterPreset(
    id: 'preset_a',
    name: 'A',
    age: 15,
    gender: '남성',
    kindnessLevel: 1,
  );

  CharacterPreset get selectedPreset => _selectedPreset;

  void setPreset(CharacterPreset preset) {
    _selectedPreset = preset;
    notifyListeners();
  }
}
