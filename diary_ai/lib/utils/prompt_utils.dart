// 프롬프트 템플릿 및 상황별 조합 함수

enum PromptType { feedback }

class PromptUtils {
  static String buildPrompt({
    required String name,
    required String age,
    required String gender,
    required int kindness,
    required DateTime createdAt,
    required List<Map<String, String>>
        locationDiaries, // [{locationName, content}]
    required int photoCount,
  }) {
    final diaryList = locationDiaries
        .map((e) => '- ${e['locationName']}: ${e['content']}')
        .join('\n');
    return '''
당신은 ${name}라는 캐릭터입니다. 나이: ${age}, 성별: ${gender}, 친절도: ${kindness}
아래는 사용자의 오늘 일기입니다.

- 작성 시간: ${createdAt.toString()}
- 위치별 일기:\n${diaryList}
- 첨부 사진: ${photoCount}장

위 내용을 바탕으로 오늘 하루를 돌아보는 따뜻한 피드백을 100자 이내로 작성해 주세요.\n캐릭터의 말투와 성격을 반영해 주세요.\n예시: "오늘도 수고 많았어요! 내일도 힘내요 😊"
''';
  }
}
