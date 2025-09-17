# AI 일기장 (Diary AI)

AI와 함께하는 스마트 일기장 앱입니다. 위치 기반 일기 작성, AI 피드백, 알림 기능을 통해 더 풍부한 일기 경험을 제공합니다.

## 주요 기능

### 일기 작성
- **일반 일기**: 자유로운 텍스트로 일상 기록
- **위치 기반 일기**: 방문한 장소와 함께 일기 작성
- **사진 첨부**: 추억을 담은 사진과 함께 일기 작성
- **캘린더 뷰**: 날짜별 일기 관리 및 조회

### AI 기능
- **AI 피드백**: 작성한 일기에 대한 AI의 따뜻한 피드백
- **AI 채팅**: 위치 기반 일기 작성 시 AI와 대화하며 일기 완성
- **캐릭터 피드백**: 다양한 캐릭터(이모, 친구)의 관점에서 피드백 제공
- **Anthropic Claude API** 연동으로 고품질 AI 서비스

### 위치 서비스
- **자동 위치 추적**: 방문한 장소 자동 기록
- **위치 히스토리**: 과거 방문 기록 조회
- **Google Maps** 연동으로 정확한 위치 정보
- **위치별 일기**: 특정 장소에서의 경험 기록

### 알림 및 리마인더
- **일기 작성 알림**: 정기적인 일기 작성 리마인더
- **AI 피드백 알림**: 22-23시 시간대 AI 피드백 요청 알림
- **백그라운드 서비스**: 앱 종료 후에도 알림 서비스 동작
- **WorkManager** 기반 안정적인 백그라운드 처리

### 데이터 관리
- **Hive 데이터베이스**: 빠르고 안정적인 로컬 데이터 저장
- **자동 백업**: 데이터 손실 방지
- **오프라인 지원**: 인터넷 연결 없이도 기본 기능 사용 가능

## 기술 스택

### 프론트엔드
- **Flutter**: 크로스 플랫폼 모바일 앱 개발
- **Provider**: 상태 관리
- **Hive**: 로컬 데이터베이스

### 백엔드 & AI
- **Anthropic Claude API**: AI 서비스
- **HTTP**: API 통신
- **Dart**: 서버사이드 로직

### 플랫폼 서비스
- **Google Maps Flutter**: 지도 서비스
- **Geolocator**: 위치 정보 수집
- **Flutter Local Notifications**: 로컬 알림
- **WorkManager**: 백그라운드 작업

### 개발 도구
- **Build Runner**: 코드 생성
- **Hive Generator**: 모델 코드 생성
- **Flutter Launcher Icons**: 앱 아이콘 생성

## 화면 구성

1. **메인 페이지**: 탭 기반 네비게이션
   - 일기 목록 탭
   - 일기 작성 탭
   - 위치 히스토리 탭
   - 설정 탭

2. **일기 목록**: 캘린더 뷰로 날짜별 일기 관리
3. **일기 작성**: 텍스트 입력 및 사진 첨부
4. **위치 히스토리**: 방문한 장소별 일기 조회
5. **AI 채팅**: 위치 기반 일기 작성 시 AI와 대화

## 시작하기

### 사전 요구사항
- Flutter SDK (>=3.0.0)
- Dart SDK (>=2.17.0)
- Android Studio / VS Code
- Android/iOS 개발 환경

### 설치 및 실행

1. **저장소 클론**
```bash
git clone <repository-url>
cd diary_ai
```

2. **의존성 설치**
```bash
flutter pub get
```

3. **환경 변수 설정**
```bash
# .env 파일 생성
ANTHROPIC_API_KEY=your_api_key_here
```

4. **코드 생성**
```bash
flutter packages pub run build_runner build
```

5. **앱 실행**
```bash
flutter run
```

### 빌드

**Android APK 빌드**
```bash
flutter build apk --release
```

**iOS 빌드**
```bash
flutter build ios --release
```

## 설정

### 권한 설정
앱 사용을 위해 다음 권한이 필요합니다:
- 위치 정보 접근 권한
- 알림 권한
- 저장소 접근 권한 (사진 첨부용)

### API 키 설정
`.env` 파일에 Anthropic API 키를 설정해야 AI 기능을 사용할 수 있습니다.

## 주요 의존성

```yaml
dependencies:
  flutter: sdk
  provider: ^6.0.5          # 상태 관리
  hive: ^2.2.3              # 로컬 데이터베이스
  geolocator: ^10.0.1       # 위치 서비스
  google_maps_flutter: ^2.5.0  # 지도 서비스
  http: ^1.1.0              # HTTP 통신
  workmanager: ^0.8.0       # 백그라운드 작업
  flutter_local_notifications: ^19.4.2  # 알림
  # ... 기타 의존성들
```

## 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 `LICENSE` 파일을 참조하세요.

## 문의

프로젝트에 대한 문의사항이나 버그 리포트는 Issues를 통해 제출해 주세요.

---

**Made with Flutter**
