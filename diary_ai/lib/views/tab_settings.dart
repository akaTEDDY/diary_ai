import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/character_preset_provider.dart';

class TabSettingsPage extends StatefulWidget {
  const TabSettingsPage({Key? key}) : super(key: key);

  @override
  State<TabSettingsPage> createState() => _TabSettingsPageState();
}

class _TabSettingsPageState extends State<TabSettingsPage> {
  // 프리셋 정의
  static const Map<String, Map<String, dynamic>> characterPresets = {
    'A': {
      'id': 'preset_a',
      'name': 'A',
      'age': 15,
      'gender': '남성',
      'kindnessLevel': 1,
    },
    'B': {
      'id': 'preset_b',
      'name': 'B',
      'age': 25,
      'gender': '남성',
      'kindnessLevel': 3,
    },
    'C': {
      'id': 'preset_c',
      'name': 'C',
      'age': 35,
      'gender': '여성',
      'kindnessLevel': 5,
    },
  };

  String _selectedPreset = 'A';

  void _onPresetChanged(String? value) {
    if (value != null) {
      setState(() {
        _selectedPreset = value;
      });
      // Provider에 반영
      final presetMap = characterPresets[value]!;
      final preset = CharacterPreset(
        id: presetMap['id'],
        name: presetMap['name'],
        age: presetMap['age'],
        gender: presetMap['gender'],
        kindnessLevel: presetMap['kindnessLevel'],
      );
      Provider.of<CharacterPresetProvider>(context, listen: false)
          .setPreset(preset);
    }
  }

  @override
  Widget build(BuildContext context) {
    final preset = characterPresets[_selectedPreset]!;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFF),
        title: const Text('설정'),
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AI 캐릭터 프리셋 선택',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: characterPresets.keys.map((key) {
                return Expanded(
                  child: RadioListTile<String>(
                    title: Text(characterPresets[key]!['name']),
                    value: key,
                    groupValue: _selectedPreset,
                    onChanged: _onPresetChanged,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text('선택된 프리셋 정보',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            _buildReadOnlyField('ID', preset['id'].toString()),
            _buildReadOnlyField('이름', preset['name'].toString()),
            _buildReadOnlyField('나이', preset['age'].toString()),
            _buildReadOnlyField('성별', preset['gender'].toString()),
            _buildReadOnlyField('친절도', preset['kindnessLevel'].toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
              width: 80,
              child: Text(label, style: TextStyle(color: Colors.grey[700]))),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(value, style: const TextStyle(fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}
