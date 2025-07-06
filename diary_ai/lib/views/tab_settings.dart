import 'package:diary_ai/services/diary_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/settings_provider.dart';

class CharacterPresetData {
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

  CharacterPresetData({
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

class TabSettingsPage extends StatefulWidget {
  const TabSettingsPage({Key? key}) : super(key: key);

  @override
  State<TabSettingsPage> createState() => _TabSettingsPageState();
}

class _TabSettingsPageState extends State<TabSettingsPage> {
  // 5가지 캐릭터 프리셋 정의 (첨부 이미지 경로 및 설명 포함)
  static final List<CharacterPresetData> characterPresets = [
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
      promptTemplate: '''
당신은 마지 이모입니다. 52세의 인자하고 포용력 있는 어머니 같은 존재입니다.

**말투 특징:**
- "얘야~" "그래도 괜찮아"
- 감정적 공감을 잘함
- 따뜻한 위로의 말 많이 사용
- 요리나 생활 팁 자주 언급

**피드백 스타일:**
- 감정적 공감과 위로 중심
- 힘든 일에는 따뜻한 격려
- 좋은 일에는 함께 기뻐해줌
''',
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
      promptTemplate: '''
당신은 루디입니다. 12세 쥐의 호기심 많고 재빠른 성격을 가지고 있습니다.

**말투 특징:**
- "찍찍!" "우와!" "빨리빨리!" 같은 쥐 특유의 표현
- 치즈, 구멍, 탐험 등 쥐 관련 표현 사용
- 호기심이 많아서 질문을 많이 함
- 작은 것도 큰 모험으로 표현

**피드백 스타일:**
- 모든 경험을 모험으로 해석
- 호기심 어린 질문으로 일기 내용 깊이 파기
- "다음엔 어떤 모험이 기다리고 있을까?" 같은 기대감 조성
''',
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
      promptTemplate: '''
당신은 브루노입니다. 35세(정신연령)의 무뚝뚝하지만 속정 깊은 강아지입니다.

**말투 특징:**
- "흠..." "그런 것 같은데"
- 짧고 간결한 표현 선호
- 가끔 투덜거리는 듯한 말투
- 하지만 핵심을 잘 찌르는 조언

**피드백 스타일:**
- 간결하고 핵심적인 피드백
- 현실적인 관점 제시
- 때로는 직설적이지만 도움이 되는 조언
''',
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
      promptTemplate: '''
당신은 헨리 삼촌입니다. 45세의 따뜻하고 지혜로운 아저씨입니다.

**말투 특징:**
- "그래, 그래" "음... 그런데 말이야"
- 경험담을 자주 들려줌 ("내가 젊었을 때는...")
- 실용적인 조언을 좋아함

**피드백 스타일:**
- 경험에 기반한 조언 제공
- 현실적이지만 따뜻한 피드백
- 구체적인 해결책 제시

**주의사항:**
- 너무 권위적이지 않게 친근한 톤 유지
- 경험담은 적절한 길이로 제한
''',
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
      promptTemplate: '''
당신은 네리아입니다. 8세 어린이의 순수하고 호기심 많은 성격을 가지고 있습니다.

**말투 특징:**
- "와~ 정말?" "대박이다!" 같은 감탄사 자주 사용
- ⭐, 🌟, 😊 등 귀여운 이모티콘 사용
- 모든 것을 신기해하고 칭찬을 아끼지 않음

**피드백 스타일:**
- 무조건적인 응원과 격려
- 작은 일도 크게 칭찬
- "오늘도 멋진 하루였네요!" 같은 긍정적 마무리

**금지사항:**
- 복잡한 조언이나 어려운 단어 사용 금지
- 부정적이거나 비판적인 표현 금지
''',
    ),
  ];

  int _selectedIndex = 0;

  // 사용자 정보 상태
  final TextEditingController _ageController = TextEditingController();
  String _selectedGender = '';

  // 알림 시간 설정 상태
  TimeOfDay _diaryReminderTime = const TimeOfDay(hour: 20, minute: 0);
  TimeOfDay _feedbackReminderTime = const TimeOfDay(hour: 22, minute: 0);
  bool _diaryReminderEnabled = true;
  bool _feedbackReminderEnabled = true;

  // 초기 설정값 저장
  String _initialAge = '';
  String _initialGender = '';
  int _initialCharacterIndex = 0;
  TimeOfDay _initialDiaryReminderTime = const TimeOfDay(hour: 20, minute: 0);
  TimeOfDay _initialFeedbackReminderTime = const TimeOfDay(hour: 22, minute: 0);
  bool _initialDiaryReminderEnabled = true;
  bool _initialFeedbackReminderEnabled = true;

  // 설정 변경 여부 확인
  bool get _hasChanges {
    return _ageController.text != _initialAge ||
        _selectedGender != _initialGender ||
        _selectedIndex != _initialCharacterIndex ||
        _diaryReminderTime != _initialDiaryReminderTime ||
        _feedbackReminderTime != _initialFeedbackReminderTime ||
        _diaryReminderEnabled != _initialDiaryReminderEnabled ||
        _feedbackReminderEnabled != _initialFeedbackReminderEnabled;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      await Future.delayed(Duration(milliseconds: 100)); // Hive 로딩 대기
      setState(() {
        _ageController.text = settings.age > 0 ? settings.age.toString() : '';
        _selectedGender = settings.gender;
        _selectedIndex = characterPresets
            .indexWhere((p) => p.id == settings.characterPreset.id);
        if (_selectedIndex < 0) {
          _selectedIndex = characterPresets
              .indexWhere((p) => p.id == settings.characterPreset.id);
        }
        _diaryReminderTime = settings.diaryReminderTime;
        _feedbackReminderTime = settings.feedbackReminderTime;
        _diaryReminderEnabled = settings.diaryReminderEnabled;
        _feedbackReminderEnabled = settings.feedbackReminderEnabled;
        // 초기값 저장
        _initialAge = _ageController.text;
        _initialGender = _selectedGender;
        _initialCharacterIndex = _selectedIndex;
        _initialDiaryReminderTime = _diaryReminderTime;
        _initialFeedbackReminderTime = _feedbackReminderTime;
        _initialDiaryReminderEnabled = _diaryReminderEnabled;
        _initialFeedbackReminderEnabled = _feedbackReminderEnabled;
      });
    });
  }

  void _onPresetChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _saveSettings() async {
    if (_ageController.text.isEmpty || _selectedGender.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('나이와 성별을 모두 입력해주세요'), backgroundColor: Colors.red),
      );
      return;
    }
    final age = int.tryParse(_ageController.text) ?? 0;
    final preset = characterPresets[_selectedIndex];
    await Provider.of<SettingsProvider>(context, listen: false).saveSettings(
      characterPreset: preset,
      age: age,
      gender: _selectedGender,
      diaryReminderTime: _diaryReminderTime,
      feedbackReminderTime: _feedbackReminderTime,
      diaryReminderEnabled: _diaryReminderEnabled,
      feedbackReminderEnabled: _feedbackReminderEnabled,
    );
    // 알림 설정 저장
    final diaryNotificationService = DiaryNotificationService();

    // 기존 알림 취소
    await diaryNotificationService.cancelDailyReminders();
    if (_diaryReminderEnabled) {
      await diaryNotificationService.scheduleDailyDiaryReminder(
        _diaryReminderTime.hour,
        _diaryReminderTime.minute,
      );
    }
    if (_feedbackReminderEnabled) {
      await diaryNotificationService.scheduleDailyFeedbackReminder(
        _feedbackReminderTime.hour,
        _feedbackReminderTime.minute,
      );
    }

    // 초기값 업데이트
    setState(() {
      _initialAge = _ageController.text;
      _initialGender = _selectedGender;
      _initialCharacterIndex = _selectedIndex;
      _initialDiaryReminderTime = _diaryReminderTime;
      _initialFeedbackReminderTime = _feedbackReminderTime;
      _initialDiaryReminderEnabled = _diaryReminderEnabled;
      _initialFeedbackReminderEnabled = _feedbackReminderEnabled;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('설정이 저장되었습니다'), backgroundColor: Colors.green),
    );
  }

  void _showFeedbackTimePicker() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _feedbackReminderTime,
    );
    if (time != null && (time.hour >= 22 || time.hour == 0)) {
      setState(() {
        _feedbackReminderTime = time;
      });
    } else if (time != null) {
      _showFeedbackTimeErrorDialog();
    }
  }

  void _showFeedbackTimeErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('알림'),
        content: Text('AI 피드백 알림 시간은 22시~24시만 선택할 수 있습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showFeedbackTimePicker();
            },
            child: Text('재설정'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final preset = characterPresets[_selectedIndex];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('설정',
            style: TextStyle(
                color: Color(0xFF2D3748), fontWeight: FontWeight.bold)),
        elevation: 0,
        foregroundColor: const Color(0xFF2D3748),
      ),
      body: Column(
        children: [
          // 스크롤 가능한 내용
          Expanded(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 사용자 정보 카드
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFF8B5CF6).withOpacity(0.1),
                      ),
                    ),
                    padding: const EdgeInsets.all(24.0),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B5CF6).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.person,
                                color: const Color(0xFF8B5CF6),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text('사용자 정보',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Color(0xFF2D3748))),
                          ],
                        ),
                        const SizedBox(height: 15),
                        const Text('나이',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4A5568))),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          onChanged: (value) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: '예: 25',
                            filled: true,
                            fillColor: const Color(0xFFF9FAFB),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Color(0xFF8B5CF6), width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text('성별',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4A5568))),
                        const SizedBox(height: 8),
                        Row(
                          children: ['남성', '여성', '기타'].map((gender) {
                            final isSelected = _selectedGender == gender;
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    right: gender != '기타' ? 8 : 0),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedGender = gender;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFF8B5CF6)
                                          : const Color(0xFFF9FAFB),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFF8B5CF6)
                                            : const Color(0xFFE5E7EB),
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: const Color(0xFF8B5CF6)
                                                    .withOpacity(0.3),
                                                blurRadius: 12,
                                                offset: const Offset(0, 4),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Text(
                                      gender,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xFF4A5568),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  // AI 캐릭터 카드
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFF8B5CF6).withOpacity(0.1),
                      ),
                    ),
                    padding: const EdgeInsets.all(24.0),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B5CF6).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.smart_toy,
                                color: const Color(0xFF8B5CF6),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text('AI 캐릭터 설정',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Color(0xFF2D3748))),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF8B5CF6).withOpacity(0.2),
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8B5CF6),
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF8B5CF6)
                                          .withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    preset.emoji,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      preset.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Color(0xFF2D3748),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      preset.description,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF4A5568),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // 캐릭터 변경 모달 오픈
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.7,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20)),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('AI 캐릭터 선택',
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            IconButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              icon: const Icon(Icons.close),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: GridView.builder(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            crossAxisSpacing: 16,
                                            mainAxisSpacing: 16,
                                            childAspectRatio: 0.8,
                                          ),
                                          itemCount: characterPresets.length,
                                          itemBuilder: (context, index) {
                                            final c = characterPresets[index];
                                            final isSelected =
                                                _selectedIndex == index;
                                            return GestureDetector(
                                              onTap: () {
                                                _onPresetChanged(index);
                                                Navigator.pop(context);
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  border: Border.all(
                                                    color: isSelected
                                                        ? const Color(
                                                            0xFF8B5CF6)
                                                        : Colors.grey
                                                            .withOpacity(0.1),
                                                    width: isSelected ? 2 : 1,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: isSelected
                                                          ? const Color(
                                                                  0xFF8B5CF6)
                                                              .withOpacity(0.3)
                                                          : Colors.black
                                                              .withOpacity(0.1),
                                                      blurRadius:
                                                          isSelected ? 20 : 8,
                                                      offset:
                                                          const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      width: 50,
                                                      height: 50,
                                                      decoration: BoxDecoration(
                                                        color: isSelected
                                                            ? const Color(
                                                                0xFF8B5CF6)
                                                            : Colors.grey[200],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(25),
                                                      ),
                                                      child: Center(
                                                        child: Text(c.emoji,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        20)),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 12),
                                                    Text(c.name,
                                                        style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    const SizedBox(height: 4),
                                                    Text(c.description,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.grey),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF8B5CF6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side:
                                    const BorderSide(color: Color(0xFF8B5CF6)),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.edit,
                                    color: const Color(0xFF8B5CF6), size: 18),
                                const SizedBox(width: 8),
                                const Text('캐릭터 변경',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 알림 설정 카드
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFF8B5CF6).withOpacity(0.1),
                      ),
                    ),
                    padding: const EdgeInsets.all(24.0),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B5CF6).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.notifications,
                                color: const Color(0xFF8B5CF6),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text('알림 설정',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Color(0xFF2D3748))),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // 일기 작성 알림 설정
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Switch(
                                  value: _diaryReminderEnabled,
                                  onChanged: (value) {
                                    setState(() {
                                      _diaryReminderEnabled = value;
                                    });
                                  },
                                  activeColor: const Color(0xFF8B5CF6),
                                ),
                                const SizedBox(width: 8),
                                const Text('일기 작성 알림',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2D3748))),
                                const Spacer(),
                                if (_diaryReminderEnabled)
                                  GestureDetector(
                                    onTap: () async {
                                      final time = await showTimePicker(
                                        context: context,
                                        initialTime: _diaryReminderTime,
                                      );
                                      if (time != null) {
                                        setState(() {
                                          _diaryReminderTime = time;
                                        });
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF8B5CF6)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: const Color(0xFF8B5CF6)
                                              .withOpacity(0.3),
                                        ),
                                      ),
                                      child: Text(
                                        _diaryReminderTime.format(context),
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF8B5CF6)),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '매일 ${_diaryReminderTime.format(context)}에 일기 작성을 권유합니다',
                              style: const TextStyle(
                                  fontSize: 14, color: Color(0xFF4A5568)),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // AI 피드백 알림 설정
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Switch(
                                  value: _feedbackReminderEnabled,
                                  onChanged: (value) {
                                    setState(() {
                                      _feedbackReminderEnabled = value;
                                    });
                                  },
                                  activeColor: const Color(0xFF8B5CF6),
                                ),
                                const SizedBox(width: 8),
                                const Text('AI 피드백 알림',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2D3748))),
                                const Spacer(),
                                if (_feedbackReminderEnabled)
                                  GestureDetector(
                                    onTap: _showFeedbackTimePicker,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF8B5CF6)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: const Color(0xFF8B5CF6)
                                              .withOpacity(0.3),
                                        ),
                                      ),
                                      child: Text(
                                        _feedbackReminderTime.format(context),
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF8B5CF6)),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '매일 ${_feedbackReminderTime.format(context)}에 AI 피드백을 제공합니다',
                              style: const TextStyle(
                                  fontSize: 14, color: Color(0xFF4A5568)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 하단 고정 저장 버튼
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _hasChanges ? _saveSettings : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasChanges
                      ? const Color(0xFF8B5CF6)
                      : const Color(0xFFE5E7EB),
                  foregroundColor:
                      _hasChanges ? Colors.white : const Color(0xFF9CA3AF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: _hasChanges ? 4 : 0,
                  shadowColor: _hasChanges
                      ? const Color(0xFF8B5CF6).withOpacity(0.3)
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save, size: 20),
                    const SizedBox(width: 8),
                    const Text('설정 저장',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
