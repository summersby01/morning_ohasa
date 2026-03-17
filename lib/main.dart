import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'zodiac_selection_screen.dart';

const String zodiacPreferenceKey = 'selected_zodiac_key';

const Map<String, ZodiacMeta> zodiacMeta = <String, ZodiacMeta>{
  'aries': ZodiacMeta(nameKo: '양자리', emoji: '♈️'),
  'taurus': ZodiacMeta(nameKo: '황소자리', emoji: '♉️'),
  'gemini': ZodiacMeta(nameKo: '쌍둥이자리', emoji: '♊️'),
  'cancer': ZodiacMeta(nameKo: '게자리', emoji: '♋️'),
  'leo': ZodiacMeta(nameKo: '사자자리', emoji: '♌️'),
  'virgo': ZodiacMeta(nameKo: '처녀자리', emoji: '♍️'),
  'libra': ZodiacMeta(nameKo: '천칭자리', emoji: '♎️'),
  'scorpio': ZodiacMeta(nameKo: '전갈자리', emoji: '♏️'),
  'sagittarius': ZodiacMeta(nameKo: '사수자리', emoji: '♐️'),
  'capricorn': ZodiacMeta(nameKo: '염소자리', emoji: '♑️'),
  'aquarius': ZodiacMeta(nameKo: '물병자리', emoji: '♒️'),
  'pisces': ZodiacMeta(nameKo: '물고기자리', emoji: '♓️'),
};

const Map<String, List<Map<String, dynamic>>> zodiacData =
    <String, List<Map<String, dynamic>>>{
      'aries': <Map<String, dynamic>>[
        {
          'message': '속도를 내기보다\n첫 단추를 차분히 끼우는 날',
          'score': 84,
          'action': '오늘 시작할 일 1개만 정하기',
          'emoji': '🔥',
        },
        {
          'message': '밀어붙이는 힘보다\n방향을 다시 보는 게 더 중요해',
          'score': 79,
          'action': '해야 할 일 우선순위 다시 쓰기',
          'emoji': '🚀',
        },
      ],
      'taurus': <Map<String, dynamic>>[
        {
          'message': '익숙한 리듬을 지키면\n마음도 같이 안정될 거야',
          'score': 86,
          'action': '따뜻한 물 한 잔 천천히 마시기',
          'emoji': '🌿',
        },
        {
          'message': '조금 느려도 괜찮아\n꾸준함이 오늘의 강점이야',
          'score': 82,
          'action': '책상 위 한 구역만 정리하기',
          'emoji': '🍃',
        },
      ],
      'gemini': <Map<String, dynamic>>[
        {
          'message': '생각이 많아지는 날엔\n한 문장으로 정리해보자',
          'score': 81,
          'action': '떠오른 생각 메모 3개 남기기',
          'emoji': '💬',
        },
        {
          'message': '가볍게 움직이면\n막혔던 흐름도 풀리기 시작해',
          'score': 87,
          'action': '짧은 산책 10분 다녀오기',
          'emoji': '🌤️',
        },
      ],
      'cancer': <Map<String, dynamic>>[
        {
          'message': '감정이 예민한 날일수록\n나를 먼저 챙겨야 해',
          'score': 85,
          'action': '좋아하는 음악 한 곡 듣기',
          'emoji': '🌙',
        },
        {
          'message': '조용한 안정감이\n오늘 하루를 지켜줄 거야',
          'score': 80,
          'action': '아침 기분 한 줄 기록하기',
          'emoji': '🫧',
        },
      ],
      'leo': <Map<String, dynamic>>[
        {
          'message': '빛나야 한다는 부담보다\n즐기는 마음이 더 필요해',
          'score': 90,
          'action': '오늘 기대되는 일 하나 적기',
          'emoji': '☀️',
        },
        {
          'message': '자신감은 크게 외치기보다\n작게 실천할 때 더 단단해져',
          'score': 88,
          'action': '미뤄둔 연락 하나 보내기',
          'emoji': '🦁',
        },
      ],
      'virgo': <Map<String, dynamic>>[
        {
          'message': '정리된 마음이 필요하다면\n할 일을 반으로 줄여보자',
          'score': 83,
          'action': '체크리스트 3개만 남기기',
          'emoji': '📝',
        },
        {
          'message': '완벽함보다 마무리가\n오늘의 만족감을 만들어줄 거야',
          'score': 78,
          'action': '진행 중인 일 하나 끝내기',
          'emoji': '🌾',
        },
      ],
      'libra': <Map<String, dynamic>>[
        {
          'message': '균형을 찾고 싶다면\n선택지를 조금 줄여도 좋아',
          'score': 84,
          'action': '오늘 약속 하나만 확정하기',
          'emoji': '⚖️',
        },
        {
          'message': '부드러운 분위기가\n좋은 흐름을 만들어줄 거야',
          'score': 86,
          'action': '주변에 고마운 마음 전하기',
          'emoji': '🌸',
        },
      ],
      'scorpio': <Map<String, dynamic>>[
        {
          'message': '깊게 몰입할 힘이 있으니\n하나에 집중해보자',
          'score': 89,
          'action': '집중 시간 20분 확보하기',
          'emoji': '🦂',
        },
        {
          'message': '감춰둔 피로는\n짧은 휴식으로 먼저 풀어야 해',
          'score': 77,
          'action': '화면 없이 5분 쉬기',
          'emoji': '🌌',
        },
      ],
      'sagittarius': <Map<String, dynamic>>[
        {
          'message': '답답함이 느껴진다면\n조금 새로운 걸 더해보자',
          'score': 88,
          'action': '가보지 않은 길로 잠깐 걷기',
          'emoji': '🏹',
        },
        {
          'message': '마음이 앞서가도\n오늘 할 수 있는 만큼이면 충분해',
          'score': 82,
          'action': '오늘 목표를 한 줄로 줄이기',
          'emoji': '🌍',
        },
      ],
      'capricorn': <Map<String, dynamic>>[
        {
          'message': '꾸준함이 쌓이는 날이니\n작아도 계속 가는 게 중요해',
          'score': 87,
          'action': '가장 중요한 일부터 15분 하기',
          'emoji': '⛰️',
        },
        {
          'message': '책임감이 무거울 땐\n혼자 다 안아야 한다는 생각을 내려놔',
          'score': 80,
          'action': '도움이 필요한 일 체크하기',
          'emoji': '🪨',
        },
      ],
      'aquarius': <Map<String, dynamic>>[
        {
          'message': '새로운 관점이 떠오르는 날\n평소와 다른 방식도 괜찮아',
          'score': 85,
          'action': '아이디어 하나 메모앱에 남기기',
          'emoji': '💡',
        },
        {
          'message': '조금 엉뚱해도 좋아\n오늘은 신선함이 힘이 돼',
          'score': 83,
          'action': '루틴 하나 바꿔보기',
          'emoji': '🌊',
        },
      ],
      'pisces': <Map<String, dynamic>>[
        {
          'message': '감각이 섬세한 날이니\n나를 편하게 만드는 것부터 챙기자',
          'score': 84,
          'action': '좋아하는 향이나 차 준비하기',
          'emoji': '🐟',
        },
        {
          'message': '흐름을 믿고 가도 좋지만\n현실적인 한 걸음도 같이 필요해',
          'score': 81,
          'action': '오늘 일정 하나 캘린더에 고정하기',
          'emoji': '🌊',
        },
      ],
    };

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotificationService.instance.initialize();
  final preferences = await SharedPreferences.getInstance();
  final savedZodiacKey = preferences.getString(zodiacPreferenceKey);

  runApp(MorningOhasaApp(initialZodiacKey: savedZodiacKey));
}

class ZodiacMeta {
  const ZodiacMeta({
    required this.nameKo,
    required this.emoji,
  });

  final String nameKo;
  final String emoji;
}

class LocalNotificationService {
  LocalNotificationService._();

  static const MethodChannel _timezoneChannel = MethodChannel(
    'morning_ohasa/timezone',
  );
  static const int _dailyNotificationId = 700;
  static final LocalNotificationService instance = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
  }

  Future<void> scheduleDailyMorningNotification() async {
    await _requestPermissions();
    await _configureLocalTimezone();

    final scheduledTime = _nextInstanceOfSevenAm();

    const androidDetails = AndroidNotificationDetails(
      'morning_ohasa_daily_channel',
      'Morning Ohasa Daily',
      channelDescription: 'Daily reminder for checking Morning Ohasa at 7 AM.',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      _dailyNotificationId,
      '오늘의 오하아사',
      '오늘의 오하아사 확인해볼 시간이에요 ☀️',
      scheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _requestPermissions() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.requestNotificationsPermission();

    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _configureLocalTimezone() async {
    try {
      final timezoneName = await _timezoneChannel.invokeMethod<String>(
        'getLocalTimezone',
      );

      if (timezoneName != null && timezoneName.isNotEmpty) {
        tz.setLocalLocation(tz.getLocation(timezoneName));
      }
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
  }

  tz.TZDateTime _nextInstanceOfSevenAm() {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, 7);

    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }
}

class MorningOhasaApp extends StatelessWidget {
  const MorningOhasaApp({super.key, this.initialZodiacKey});

  final String? initialZodiacKey;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Morning Ohasa',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C5CFA),
        ),
      ),
      home:
          initialZodiacKey == null
              ? const ZodiacSelectionScreen()
              : HomeScreen(zodiacKey: initialZodiacKey!),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.zodiacKey});

  final String zodiacKey;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _peach = Color(0xFFE7DEFF);
  static const Color _apricot = Color(0xFFB69CFF);
  static const Color _sunrise = Color(0xFF7C5CFA);
  static const Color _textPrimary = Color(0xFF2D1F4D);
  static const Color _textSecondary = Color(0xFF6D6290);
  static const Color _cardBorder = Color(0xFFD9CCFF);
  static const double _cardRadius = 28;
  static const EdgeInsets _cardPadding = EdgeInsets.all(22);
  static const List<BoxShadow> _cardShadow = [
    BoxShadow(
      color: Color(0x12000000),
      blurRadius: 22,
      offset: Offset(0, 11),
    ),
  ];

  int currentIndex = 0;
  final Random random = Random();

  ZodiacMeta get _currentZodiac =>
      zodiacMeta[widget.zodiacKey] ?? zodiacMeta['aries']!;
  List<Map<String, dynamic>> get _currentZodiacItems =>
      zodiacData[widget.zodiacKey] ?? zodiacData['aries']!;
  int get _currentDay => DateTime.now().day;

  int _rankForZodiac(String zodiacKey) {
    final zodiacIndex = zodiacMeta.keys.toList().indexOf(zodiacKey);
    final safeIndex = zodiacIndex == -1 ? 0 : zodiacIndex;
    return (_currentDay + safeIndex) % zodiacMeta.length + 1;
  }

  int get _currentZodiacRank => _rankForZodiac(widget.zodiacKey);

  void updateOhasa() {
    setState(() {
      final zodiacItems = _currentZodiacItems;
      int newIndex = random.nextInt(zodiacItems.length);

      while (newIndex == currentIndex && zodiacItems.length > 1) {
        newIndex = random.nextInt(zodiacItems.length);
      }

      currentIndex = newIndex;
    });
  }

  Future<void> _scheduleMorningNotification() async {
    await LocalNotificationService.instance.scheduleDailyMorningNotification();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('매일 오전 7시에 오하아사 알림을 보내드릴게요.'),
      ),
    );
  }

  void _changeZodiac() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const ZodiacSelectionScreen(),
      ),
    );
  }

  List<MapEntry<String, ZodiacMeta>> get _rankedZodiacs {
    final entries = zodiacMeta.entries.toList();
    entries.sort(
      (MapEntry<String, ZodiacMeta> a, MapEntry<String, ZodiacMeta> b) =>
          _rankForZodiac(a.key).compareTo(_rankForZodiac(b.key)),
    );
    return entries;
  }

  Future<void> _showRankingsSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.78,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFFFFFCFF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: _cardBorder,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                '오늘의 오하아사 전체 순위',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '내 별자리는 강조되어 보여요',
                style: TextStyle(
                  fontSize: 14,
                  color: _textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  itemCount: _rankedZodiacs.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 10),
                  itemBuilder: (BuildContext context, int index) {
                    final entry = _rankedZodiacs[index];
                    final isCurrent = entry.key == widget.zodiacKey;

                    return _buildRankingListItem(
                      zodiacKey: entry.key,
                      zodiac: entry.value,
                      isCurrent: isCurrent,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final zodiacItems = _currentZodiacItems;
    final safeIndex = currentIndex.clamp(0, zodiacItems.length - 1);
    final currentItem = zodiacItems[safeIndex];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF4EEFF),
              Color(0xFFFBF8FF),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -40,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _apricot.withValues(alpha: 0.22),
                ),
              ),
            ),
            Positioned(
              top: 140,
              left: -70,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _peach.withValues(alpha: 0.4),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(today, currentItem['emoji'] as String),
                    const SizedBox(height: 18),
                    _buildRankCard(),
                    const SizedBox(height: 22),
                    _buildMessageCard(currentItem['message'] as String),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _buildScoreCard(currentItem['score'] as int),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildActionCard(
                            currentItem['action'] as String,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: updateOhasa,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        backgroundColor: _sunrise,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 19),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: const Text(
                        '다시 뽑기',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton(
                      onPressed: _scheduleMorningNotification,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 19),
                        side: const BorderSide(
                          color: _cardBorder,
                          width: 1.4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        backgroundColor: Colors.white.withValues(alpha: 0.72),
                      ),
                      child: const Text(
                        '아침 알림 켜기',
                        style: TextStyle(
                          color: Color(0xFF6A4FE0),
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(DateTime today, String emoji) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 22, 22, 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFDFCFF),
            Color(0xFFF2ECFF),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: _cardBorder.withValues(alpha: 0.95),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _apricot.withValues(alpha: 0.95),
                  _sunrise.withValues(alpha: 0.9),
                ],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x227C5CFA),
                  blurRadius: 22,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${_currentZodiac.emoji} ${_currentZodiac.nameKo}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6E57C8),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '오늘의 오하아사',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: _textPrimary,
                    height: 1.05,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${today.year}.${today.month}.${today.day}',
                      style: const TextStyle(
                        fontSize: 15,
                        color: _textSecondary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: _changeZodiac,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: _sunrise,
                      ),
                      child: const Text(
                        '별자리 변경',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankCard() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(_cardRadius),
        onTap: _showRankingsSheet,
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFCFAFF),
                Color(0xFFF2ECFF),
              ],
            ),
            borderRadius: BorderRadius.circular(_cardRadius),
            border: Border.all(
              color: _cardBorder.withValues(alpha: 0.92),
            ),
            boxShadow: _cardShadow,
          ),
          child: Padding(
            padding: _cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '오늘의 오하아사 순위',
                  style: TextStyle(
                    fontSize: 15,
                    color: _textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _peach.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _currentZodiac.emoji,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        '${_currentZodiac.nameKo} 오늘 $_currentZodiacRank위',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: _textSecondary,
                      size: 24,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRankingListItem({
    required String zodiacKey,
    required ZodiacMeta zodiac,
    required bool isCurrent,
  }) {
    final rank = _rankForZodiac(zodiacKey);
    final backgroundColor =
        isCurrent ? _peach.withValues(alpha: 0.68) : Colors.white;
    final borderColor = isCurrent ? _sunrise : _cardBorder.withValues(alpha: 0.9);
    final rankBackground =
        isCurrent ? _sunrise : _peach.withValues(alpha: 0.7);
    final rankTextColor = isCurrent ? Colors.white : _sunrise;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: isCurrent ? 1.6 : 1.1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: rankBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: rankTextColor,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            zodiac.emoji,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              zodiac.nameKo,
              style: TextStyle(
                fontSize: 17,
                fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w700,
                color: _textPrimary,
                letterSpacing: -0.2,
              ),
            ),
          ),
          if (isCurrent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                '내 별자리',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _sunrise,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageCard(String message) {
    return Container(
      padding: _cardPadding,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFCFAFF),
            Color(0xFFF3EEFF),
          ],
        ),
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(
          color: _cardBorder.withValues(alpha: 0.92),
        ),
        boxShadow: _cardShadow,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: _peach.withValues(alpha: 0.58),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              '오늘의 한마디',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6A4FE0),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 25,
              height: 1.5,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(int score) {
    return Container(
      padding: _cardPadding,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFCFAFF),
            Color(0xFFF0E9FF),
          ],
        ),
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(
          color: _cardBorder.withValues(alpha: 0.92),
        ),
        boxShadow: _cardShadow,
      ),
      child: Column(
        children: [
          const Text(
            '오늘 점수',
            style: TextStyle(
              fontSize: 15,
              color: _textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.94),
                  const Color(0xFFF1E9FF),
                ],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.7),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x126A4FE0),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _peach.withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 14),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFA88BFF),
                      Color(0xFF6A4FE0),
                    ],
                  ).createShader(bounds),
                  child: Text(
                    '$score',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1,
                      letterSpacing: -1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String action) {
    return Container(
      padding: _cardPadding,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFCFAFF),
            Color(0xFFF2ECFF),
          ],
        ),
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(
          color: _cardBorder.withValues(alpha: 0.92),
        ),
        boxShadow: _cardShadow,
      ),
      child: Column(
        children: [
          const Text(
            '추천 행동',
            style: TextStyle(
              fontSize: 15,
              color: _textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _peach.withValues(alpha: 0.58),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.wb_sunny_rounded,
              size: 28,
              color: _sunrise,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            action,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              height: 1.45,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
