import 'package:flutter/material.dart';

class CharacterPreset {
  final String id;
  final String name;
  final int age;
  final String gender;
  final int kindnessLevel;
  final String imagePath;
  final String description;
  final String emoji;
  final String personality;
  final String speechStyle;
  final String feedbackStyle;
  final String promptTemplate;

  CharacterPreset({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.kindnessLevel,
    required this.imagePath,
    required this.description,
    required this.emoji,
    required this.personality,
    required this.speechStyle,
    required this.feedbackStyle,
    required this.promptTemplate,
  });
}

class CharacterPresetProvider extends ChangeNotifier {
  CharacterPreset _selectedPreset = CharacterPreset(
    id: 'preset_aunt_marge',
    name: 'Aunt Marge',
    age: 52,
    gender: '여성',
    kindnessLevel: 5,
    imagePath: '',
    description: '',
    emoji: '',
    personality: '',
    speechStyle: '',
    feedbackStyle: '',
    promptTemplate: '',
  );

  CharacterPreset get selectedPreset => _selectedPreset;

  void setPreset(CharacterPreset preset) {
    _selectedPreset = preset;
    notifyListeners();
  }
}
