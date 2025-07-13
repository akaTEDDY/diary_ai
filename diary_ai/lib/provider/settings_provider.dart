import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../views/tab_settings.dart'; // CharacterPresetData import

class SettingsProvider extends ChangeNotifier {
  static const String boxName = 'settings_box';

  // 프리셋 목록을 provider에서 직접 관리
  static final List<CharacterPresetData> _characterPresets = [
    CharacterPresetData(
      id: 'preset_aunt_marge',
      name: 'Aunt Marge',
      age: 60,
      gender: '여성',
      kindnessLevel: 5,
      imagePath: 'assets/images/aunt_marge.png',
      description: '따뜻한 마음의 이모',
      emoji: '👵',
      personality: '인자하고 포용력 있는 어머니 같은 존재',
      speechStyle: '감정적 공감과 위로 중심, 따뜻한 위로의 말 많이 사용',
      feedbackStyle: '감정적 공감과 위로, 힘든 일에는 격려, 좋은 일에는 함께 기뻐함',
      promptTemplate:
          '''당신은 마지 이모입니다. 52세의 인자하고 포용력 있는 어머니 같은 존재입니다.\n\n**말투 특징:**\n- "얘야~" "그래도 괜찮아"\n- 감정적 공감을 잘함\n- 따뜻한 위로의 말 많이 사용\n- 요리나 생활 팁 자주 언급\n\n**피드백 스타일:**\n- 감정적 공감과 위로 중심\n- 힘든 일에는 따뜻한 격려\n- 좋은 일에는 함께 기뻐해줌''',
    ),
    CharacterPresetData(
      id: 'preset_rudy',
      name: 'Rudy',
      age: 10,
      gender: '남성',
      kindnessLevel: 4,
      imagePath: 'assets/images/rudy.png',
      description: '모험을 좋아하는 찍찍이',
      emoji: '🐭',
      personality: '호기심 많고 재빠른 쥐, 모험을 좋아함',
      speechStyle: '쥐 특유의 재빠른 말투, 치즈/탐험 등 쥐 관련 표현, 호기심 많은 질문',
      feedbackStyle: '모든 경험을 모험으로 해석, 호기심 어린 질문, 기대감 조성',
      promptTemplate:
          '''당신은 루디입니다. 12세 쥐의 호기심 많고 재빠른 성격을 가지고 있습니다.\n\n**말투 특징:**\n- "찍찍!" "우와!" "빨리빨리!" 같은 쥐 특유의 표현\n- 치즈, 구멍, 탐험 등 쥐 관련 표현 사용\n- 호기심이 많아서 질문을 많이 함\n- 작은 것도 큰 모험으로 표현\n\n**피드백 스타일:**\n- 모든 경험을 모험으로 해석\n- 호기심 어린 질문으로 일기 내용 깊이 파기\n- "다음엔 어떤 모험이 기다리고 있을까?" 같은 기대감 조성''',
    ),
    CharacterPresetData(
      id: 'preset_bruno',
      name: 'Bruno',
      age: 35,
      gender: '남성',
      kindnessLevel: 2,
      imagePath: 'assets/images/bruno.png',
      description: '용감하고 충실한 강아지',
      emoji: '🐕',
      personality: '무뚝뚝하지만 속정 깊은 강아지',
      speechStyle: '짧고 간결한 표현, 가끔 투덜거리는 듯한 말투, 핵심을 잘 찌르는 조언',
      feedbackStyle: '간결하고 핵심적인 피드백, 현실적인 관점, 직설적이지만 도움이 되는 조언',
      promptTemplate:
          '''당신은 브루노입니다. 35세(정신연령)의 무뚝뚝하지만 속정 깊은 강아지입니다.\n\n**말투 특징:**\n- "흠..." "그런 것 같은데"\n- 짧고 간결한 표현 선호\n- 가끔 투덜거리는 듯한 말투\n- 하지만 핵심을 잘 찌르는 조언\n\n**피드백 스타일:**\n- 간결하고 핵심적인 피드백\n- 현실적인 관점 제시\n- 때로는 직설적이지만 도움이 되는 조언''',
    ),
    CharacterPresetData(
      id: 'preset_uncle_henry',
      name: 'Uncle Henry',
      age: 45,
      gender: '남성',
      kindnessLevel: 3,
      imagePath: 'assets/images/uncle_henry.png',
      description: '지혜로운 삼촌',
      emoji: '👨',
      personality: '따뜻하고 지혜로운 아저씨',
      speechStyle: '경험담을 자주 들려주고 실용적인 조언을 좋아함, 친근한 말투',
      feedbackStyle: '경험에 기반한 조언, 현실적이지만 따뜻한 피드백, 구체적 해결책 제시',
      promptTemplate:
          '''당신은 헨리 삼촌입니다. 45세의 따뜻하고 지혜로운 아저씨입니다.\n\n**말투 특징:**\n- "그래, 그래" "음... 그런데 말이야"\n- 경험담을 자주 들려줌 ("내가 젊었을 때는...")\n- 실용적인 조언을 좋아함\n\n**피드백 스타일:**\n- 경험에 기반한 조언 제공\n- 현실적이지만 따뜻한 피드백\n- 구체적인 해결책 제시\n\n**주의사항:**\n- 너무 권위적이지 않게 친근한 톤 유지\n- 경험담은 적절한 길이로 제한''',
    ),
    CharacterPresetData(
      id: 'preset_neria',
      name: 'Neria',
      age: 8,
      gender: '여성',
      kindnessLevel: 4,
      imagePath: 'assets/images/neria.png',
      description: '활발한 소녀',
      emoji: '👧',
      personality: '순수하고 호기심 많은 어린이',
      speechStyle: '감탄사와 귀여운 이모티콘을 자주 사용, 모든 것을 신기해하고 칭찬을 아끼지 않음',
      feedbackStyle: '무조건적인 응원과 격려, 작은 일도 크게 칭찬, 긍정적 마무리',
      promptTemplate:
          '''당신은 네리아입니다. 8세 어린이의 순수하고 호기심 많은 성격을 가지고 있습니다.\n\n**말투 특징:**\n- "와~ 정말?" "대박이다!" 같은 감탄사 자주 사용\n- ⭐, 🌟, 😊 등 귀여운 이모티콘 사용\n- 모든 것을 신기해하고 칭찬을 아끼지 않음\n\n**피드백 스타일:**\n- 무조건적인 응원과 격려\n- 작은 일도 크게 칭찬\n- "오늘도 멋진 하루였네요!" 같은 긍정적 마무리\n\n**금지사항:**\n- 복잡한 조언이나 어려운 단어 사용 금지\n- 부정적이거나 비판적인 표현 금지''',
    ),
  ];

  CharacterPresetData _characterPreset = _characterPresets.first;
  int _age = 0;
  String _gender = '';
  TimeOfDay _diaryReminderTime = const TimeOfDay(hour: 20, minute: 0);
  TimeOfDay _feedbackReminderTime = const TimeOfDay(hour: 22, minute: 0);
  bool _diaryReminderEnabled = true;
  bool _feedbackReminderEnabled = true;
  bool _workManagerEnabled = true;

  CharacterPresetData get characterPreset => _characterPreset;
  int get age => _age;
  String get gender => _gender;
  TimeOfDay get diaryReminderTime => _diaryReminderTime;
  TimeOfDay get feedbackReminderTime => _feedbackReminderTime;
  bool get diaryReminderEnabled => _diaryReminderEnabled;
  bool get feedbackReminderEnabled => _feedbackReminderEnabled;
  bool get workManagerEnabled => _workManagerEnabled;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> saveSettings({
    required CharacterPresetData characterPreset,
    required int age,
    required String gender,
    required TimeOfDay diaryReminderTime,
    required TimeOfDay feedbackReminderTime,
    required bool diaryReminderEnabled,
    required bool feedbackReminderEnabled,
    required bool workManagerEnabled,
  }) async {
    _characterPreset = characterPreset;
    _age = age;
    _gender = gender;
    _diaryReminderTime = diaryReminderTime;
    _feedbackReminderTime = feedbackReminderTime;
    _diaryReminderEnabled = diaryReminderEnabled;
    _feedbackReminderEnabled = feedbackReminderEnabled;
    _workManagerEnabled = workManagerEnabled;
    notifyListeners();

    final box = await Hive.openBox(boxName);
    await box.put('characterPresetId', characterPreset.id);
    await box.put('age', age);
    await box.put('gender', gender);
    await box.put('diaryReminderTime', _encodeTimeOfDay(diaryReminderTime));
    await box.put(
        'feedbackReminderTime', _encodeTimeOfDay(feedbackReminderTime));
    await box.put('diaryReminderEnabled', diaryReminderEnabled);
    await box.put('feedbackReminderEnabled', feedbackReminderEnabled);
    await box.put('workManagerEnabled', workManagerEnabled);
  }

  Future<void> _loadSettings() async {
    final box = await Hive.openBox(boxName);
    final id = box.get('characterPresetId') as String?;
    final age = box.get('age') as int?;
    final gender = box.get('gender') as String?;
    final diaryTime = box.get('diaryReminderTime') as String?;
    final feedbackTime = box.get('feedbackReminderTime') as String?;
    final diaryEnabled = box.get('diaryReminderEnabled') as bool?;
    final feedbackEnabled = box.get('feedbackReminderEnabled') as bool?;
    final workManagerEnabled = box.get('workManagerEnabled') as bool?;

    _characterPreset = id != null
        ? _characterPresets.firstWhere(
            (p) => p.id == id,
            orElse: () => _characterPresets.first,
          )
        : _characterPresets.first;
    _age = age ?? 0;
    _gender = gender ?? '';
    _diaryReminderTime = diaryTime != null
        ? _decodeTimeOfDay(diaryTime)
        : const TimeOfDay(hour: 20, minute: 0);
    _feedbackReminderTime = feedbackTime != null
        ? _decodeTimeOfDay(feedbackTime)
        : const TimeOfDay(hour: 22, minute: 0);
    _diaryReminderEnabled = diaryEnabled ?? true;
    _feedbackReminderEnabled = feedbackEnabled ?? true;
    _workManagerEnabled = workManagerEnabled ?? true;
    notifyListeners();
  }

  String _encodeTimeOfDay(TimeOfDay t) => '${t.hour}:${t.minute}';
  TimeOfDay _decodeTimeOfDay(String s) {
    final parts = s.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}
