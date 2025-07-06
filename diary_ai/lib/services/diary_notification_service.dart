import 'package:common_utils_services/services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'dart:math';

class DiaryNotificationService {
  static final DiaryNotificationService _instance =
      DiaryNotificationService._internal();
  factory DiaryNotificationService() => _instance;
  DiaryNotificationService._internal();

  final NotificationService _notificationService = NotificationService();

  final List<String> _aiFeedbackMessages = [
    // 호기심 유발
    "친구가 당신의 일기를 어떻게 볼지 궁금하지 않나요? 🤖",
    "이모에게 일기 보여주고 새로운 관점을 받아보세요 👀",
    "캐릭터 피드백으로 색다른 시각을 경험해보세요 ✨",
    // 부드러운 제안
    "친구와 함께 일기를 되돌아보는 시간 어때요? 💬",
    "일기 쓰셨다면 이모 피드백도 받아보세요 🎁",
    "캐릭터가 따뜻한 피드백을 준비했어요 😊",
    // 재치있는 권유
    "일기 완성! 이제 친구에게 보여줄 차례예요 📚",
    "혼자 쓴 일기, 이모와 함께 읽어보세요 🔍",
    "캐릭터가 당신 일기에 대해 할 말이 있다는데요? 🤔",
  ];

  final List<String> _diaryReminderMessages = [
    // 부드러운 권유
    "오늘 하루는 어땠나요? 친구에게 들려주세요 📝",
    "하루를 마무리하는 일기 시간 어때요? 이모가 기다릴게요 ✨",
    "오늘의 순간들을 남겨보세요. 캐릭터가 함께할게요 🌟",
    // 친근한 스타일
    "일기 쓸 시간이에요! 친구에게 오늘 하루 어떠셨는지 말해주세요 😊",
    "당신의 하루 이야기를 들려주세요. 이모가 들을게요 💭",
    "잠깐, 캐릭터가 당신을 기다리고 있어요 📖",
    // 동기부여 스타일
    "3분이면 충분해요! 친구와 함께 오늘을 기록해보세요 ⏰",
    "작은 일상도 소중한 추억이 되어요. 이모가 함께 간직할게요 💫",
    "하루를 정리하는 시간을 가져보세요. 캐릭터가 도와드릴게요 🕯️",
  ];

  String _getRandomAIFeedbackMessage() {
    final rand = Random();
    return _aiFeedbackMessages[rand.nextInt(_aiFeedbackMessages.length)];
  }

  String _getRandomDiaryReminderMessage() {
    final rand = Random();
    return _diaryReminderMessages[rand.nextInt(_diaryReminderMessages.length)];
  }

  // 알림 서비스 초기화
  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
    await _notificationService.initialize();
  }

  // 매일 일기 작성 권유 알림 스케줄링
  Future<void> scheduleDailyDiaryReminder(int hour, int minute) async {
    final scheduledDate = _nextInstanceOfTime(hour, minute);
    final message = _getRandomDiaryReminderMessage();
    await _notificationService.scheduleNotification(
      id: 2001,
      title: '📝 오늘 하루는 어떠셨나요?',
      body: message,
      scheduledDate: scheduledDate,
      channelId: 'daily_diary_reminder',
      channelName: '일기 작성 알림',
      channelDescription: '매일 일기 작성을 권유하는 알림',
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // 매일 일기 피드백 알림 스케줄링
  Future<void> scheduleDailyFeedbackReminder(int hour, int minute) async {
    final scheduledDate = _nextInstanceOfTime(hour, minute);
    final message = _getRandomAIFeedbackMessage();
    await _notificationService.scheduleNotification(
      id: 2002,
      title: '친구에게 있었던 일을 공유해보세요!',
      body: message,
      scheduledDate: scheduledDate,
      channelId: 'daily_feedback',
      channelName: 'AI 피드백 알림',
      channelDescription: '매일 AI 피드백을 제공하는 알림',
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // 다음 지정 시간 계산
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final koreaLocation = tz.getLocation('Asia/Seoul');
    final now = tz.TZDateTime.now(koreaLocation);

    tz.TZDateTime scheduledDate = tz.TZDateTime(
      koreaLocation,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // 이미 오늘 해당 시간이 지났으면 내일로 설정
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  // 일기 관련 알림 취소
  Future<void> cancelDailyReminders() async {
    await _notificationService.cancelNotifications([2001, 2002]);
  }
}
