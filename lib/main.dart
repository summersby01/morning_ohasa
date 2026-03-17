import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotificationService.instance.initialize();
  runApp(const MorningOhasaApp());
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
  const MorningOhasaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Morning Ohasa',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _peach = Color(0xFFFFE8D2);
  static const Color _apricot = Color(0xFFFFC88F);
  static const Color _sunrise = Color(0xFFFF9356);
  static const Color _textPrimary = Color(0xFF3D2B24);
  static const Color _textSecondary = Color(0xFF84695C);
  static const Color _cardBorder = Color(0xFFF4DCC6);
  static const double _cardRadius = 28;
  static const EdgeInsets _cardPadding = EdgeInsets.all(22);
  static const List<BoxShadow> _cardShadow = [
    BoxShadow(
      color: Color(0x12000000),
      blurRadius: 22,
      offset: Offset(0, 11),
    ),
  ];

  final List<Map<String, dynamic>> ohasaItems = [
    {
      'message': '너무 크게 하려고 하지 말고\n오늘 할 일 하나만 끝내기',
      'score': 82,
      'action': '물 한 잔 마시기',
      'emoji': '☀️',
    },
    {
      'message': '완벽하게 시작하려고 하지 말고\n일단 10분만 해보기',
      'score': 76,
      'action': '창문 열고 환기하기',
      'emoji': '🌿',
    },
    {
      'message': '기분이 애매한 날엔\n리듬부터 가볍게 바꿔보기',
      'score': 88,
      'action': '좋아하는 노래 1곡 듣기',
      'emoji': '🎵',
    },
    {
      'message': '오늘은 속도보다\n끊기지 않는 흐름이 더 중요해',
      'score': 91,
      'action': '핸드폰 10분 내려놓기',
      'emoji': '✨',
    },
    {
      'message': '잘하려고 애쓰는 것보다\n지금 하는 걸 이어가는 게 중요해',
      'score': 80,
      'action': '아침 일정 하나 적어보기',
      'emoji': '🌼',
    },
  ];

  int currentIndex = 0;
  final Random random = Random();

  void updateOhasa() {
    setState(() {
      int newIndex = random.nextInt(ohasaItems.length);

      while (newIndex == currentIndex && ohasaItems.length > 1) {
        newIndex = random.nextInt(ohasaItems.length);
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

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final currentItem = ohasaItems[currentIndex];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF5E6),
              Color(0xFFFFFAF4),
              Color(0xFFFFFDF9),
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
                  color: _apricot.withOpacity(0.22),
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
                  color: _peach.withOpacity(0.4),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(today, currentItem['emoji']),
                    const SizedBox(height: 22),
                    _buildMessageCard(currentItem['message']),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _buildScoreCard(currentItem['score']),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildActionCard(currentItem['action']),
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
                        backgroundColor: Colors.white.withOpacity(0.72),
                      ),
                      child: const Text(
                        '오늘 기록하기',
                        style: TextStyle(
                          color: Color(0xFFA35D38),
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
            Color(0xFFFFFEFC),
            Color(0xFFFFF5EA),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: _cardBorder.withOpacity(0.95),
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
                  _apricot.withOpacity(0.95),
                  _sunrise.withOpacity(0.9),
                ],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22FF9356),
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
                    color: Colors.white.withOpacity(0.72),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Morning Check-in',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFBD7B51),
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
                Text(
                  '${today.year}.${today.month}.${today.day}',
                  style: const TextStyle(
                    fontSize: 15,
                    color: _textSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
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
            Color(0xFFFFFEFB),
            Color(0xFFFFF6EE),
          ],
        ),
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(
          color: _cardBorder.withOpacity(0.92),
        ),
        boxShadow: _cardShadow,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: _peach.withOpacity(0.58),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              '오늘의 한마디',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFFB46A3B),
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
            Color(0xFFFFFCF7),
            Color(0xFFFFF2E2),
          ],
        ),
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(
          color: _cardBorder.withOpacity(0.92),
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
                  Colors.white.withOpacity(0.94),
                  const Color(0xFFFFF3E5),
                ],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withOpacity(0.7),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12A45E2E),
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
                    color: _peach.withOpacity(0.82),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 14),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFFA768),
                      Color(0xFFE5783B),
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
            Color(0xFFFFFEFB),
            Color(0xFFFFF4E8),
          ],
        ),
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(
          color: _cardBorder.withOpacity(0.92),
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
              color: _peach.withOpacity(0.58),
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
