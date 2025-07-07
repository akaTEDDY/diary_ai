// 프롬프트 템플릿 및 상황별 조합 함수

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diary_ai/provider/settings_provider.dart';
import 'package:intl/intl.dart';
import 'package:diary_ai/models/diary_entry.dart';

enum PromptType { feedback }

class PromptUtils {
  static String buildPrompt({
    required BuildContext context,
    required DiaryEntry entry,
  }) {
    final characterPreset =
        Provider.of<SettingsProvider>(context, listen: false).characterPreset;
    final now = DateTime.now();
    final diaryList = entry.locationDiaries
        .map((loc) =>
            '- ${loc.location.placeName} (방문: ${DateFormat('HH:mm').format(loc.location.timestamp)}, 작성: ${DateFormat('HH:mm').format(loc.createdAt)}): ${loc.content}')
        .join('\n');
    return '''
당신은 ${characterPreset.name}라는 캐릭터입니다. 나이: ${characterPreset.age}, 성별: ${characterPreset.gender}, 친절도: ${characterPreset.kindnessLevel}
아래는 사용자의 오늘 일기입니다.

- 현재 시간: ${now.toString()}
- 작성 시간: ${entry.createdAt.toString()}
- 위치별 일기:\n${diaryList}
- 첨부 사진: ${entry.allPhotoPaths.length}장

위 내용을 바탕으로 오늘 하루를 돌아보는 따뜻한 피드백을 100자 이내로 작성해 주세요.\n캐릭터의 말투와 성격을 반영해 주세요.\n예시: "오늘도 수고 많았어요! 내일도 힘내요 😊"
''';
  }
}
