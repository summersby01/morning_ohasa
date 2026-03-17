import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'share_card.dart';
import 'zodiac_selection_screen.dart';

const String zodiacPreferenceKey = 'selected_zodiac_key';
const String appThemePreferenceKey = 'selected_app_theme';
const String appLanguagePreferenceKey = 'selected_app_language';
const String notificationEnabledPreferenceKey = 'notification_enabled';
const String notificationHourPreferenceKey = 'notification_hour';
const String notificationMinutePreferenceKey = 'notification_minute';
const String horoscopeDatePreferenceKey = 'daily_horoscope_date';
const String horoscopeZodiacPreferenceKey = 'daily_horoscope_zodiac_key';
const String horoscopeMessagePreferenceKey = 'daily_horoscope_message';
const String horoscopeScorePreferenceKey = 'daily_horoscope_score';
const String horoscopeActionPreferenceKey = 'daily_horoscope_action';
const String horoscopeRankPreferenceKey = 'daily_horoscope_rank';
const String horoscopeEmojiPreferenceKey = 'daily_horoscope_emoji';

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

IconData zodiacIconData(String zodiacKey) {
  const iconMap = <String, IconData>{
    'aries': Icons.wb_sunny_rounded,
    'taurus': Icons.spa_rounded,
    'gemini': Icons.auto_awesome_rounded,
    'cancer': Icons.nightlight_round,
    'leo': Icons.star_rounded,
    'virgo': Icons.task_alt_rounded,
    'libra': Icons.balance_rounded,
    'scorpio': Icons.bolt_rounded,
    'sagittarius': Icons.explore_rounded,
    'capricorn': Icons.terrain_rounded,
    'aquarius': Icons.water_drop_rounded,
    'pisces': Icons.water_rounded,
  };

  return iconMap[zodiacKey] ?? Icons.auto_awesome_rounded;
}

const Map<String, AppThemeColors> appThemes = <String, AppThemeColors>{
  'lavenderPink': AppThemeColors(
    key: 'lavenderPink',
    labelKo: '라벤더핑크',
    background: Color(0xFFF6F1FF),
    cardGradientStart: Color(0xFFF3ECFF),
    cardGradientEnd: Color(0xFFE9DFFF),
    accent: Color(0xFF9B8AFB),
    accentSoft: Color(0xFFD6CBFF),
    textPrimary: Color(0xFF2E2A3B),
    icon: Color(0xFF8C7BFF),
  ),
  'limeYellow': AppThemeColors(
    key: 'limeYellow',
    labelKo: '연두노랑',
    background: Color(0xFFF8FFE3),
    cardGradientStart: Color(0xFFF0FFD0),
    cardGradientEnd: Color(0xFFFFF0A3),
    accent: Color(0xFF8FBE1E),
    accentSoft: Color(0xFFDDF28C),
    textPrimary: Color(0xFF2F341F),
    icon: Color(0xFF7EAE18),
  ),
  'mintCream': AppThemeColors(
    key: 'mintCream',
    labelKo: '민트크림',
    background: Color(0xFFF2FFFB),
    cardGradientStart: Color(0xFFE0FFF6),
    cardGradientEnd: Color(0xFFD6F5EA),
    accent: Color(0xFF4DD4AC),
    accentSoft: Color(0xFFB8F3DF),
    textPrimary: Color(0xFF2C3E3A),
    icon: Color(0xFF3CCFA2),
  ),
  'blackPink': AppThemeColors(
    key: 'blackPink',
    labelKo: '블랙핑크',
    background: Color(0xFF1C1C1E),
    cardGradientStart: Color(0xFF2A2A2D),
    cardGradientEnd: Color(0xFF1F1F22),
    accent: Color(0xFFFF4FA3),
    accentSoft: Color(0xFFFFA6CF),
    textPrimary: Color(0xFFF5F5F7),
    icon: Color(0xFFFF4FA3),
  ),
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

class AppThemeColors {
  const AppThemeColors({
    required this.key,
    required this.labelKo,
    required this.background,
    required this.cardGradientStart,
    required this.cardGradientEnd,
    required this.accent,
    required this.accentSoft,
    required this.textPrimary,
    required this.icon,
  });

  final String key;
  final String labelKo;
  final Color background;
  final Color cardGradientStart;
  final Color cardGradientEnd;
  final Color accent;
  final Color accentSoft;
  final Color textPrimary;
  final Color icon;
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

  Future<void> scheduleDailyNotification({
    required int hour,
    required int minute,
  }) async {
    await _requestPermissions();
    await _configureLocalTimezone();

    final scheduledTime = _nextInstanceOfTime(hour: hour, minute: minute);

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

  Future<void> cancelDailyNotification() async {
    await _notifications.cancel(_dailyNotificationId);
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

  tz.TZDateTime _nextInstanceOfTime({
    required int hour,
    required int minute,
  }) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

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
  static const double _cardRadius = 30;

  final GlobalKey _visibleCaptureKey = GlobalKey();
  final ScreenshotController _shareCardScreenshotController =
      ScreenshotController();
  Map<String, dynamic>? _dailyHoroscopeResult;
  String _selectedThemeKey = 'lavenderPink';
  String _selectedLanguageCode = 'ko';
  bool _notificationsEnabled = false;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 7, minute: 0);

  AppThemeColors get _theme =>
      appThemes[_selectedThemeKey] ?? appThemes['lavenderPink']!;
  bool get _isDarkTheme => _selectedThemeKey == 'blackPink';
  bool get _isEnglish => _selectedLanguageCode == 'en';
  Color get _backgroundColor => _theme.background;
  Color get _cardStart => _theme.cardGradientStart;
  Color get _cardEnd => _theme.cardGradientEnd;
  Color get _accent => _theme.accent;
  Color get _accentSoft => _theme.accentSoft;
  Color get _textPrimary => _theme.textPrimary;
  Color get _textSecondary =>
      _isDarkTheme ? _theme.accentSoft : _theme.textPrimary.withValues(alpha: 0.58);
  Color get _iconColor => _theme.icon;
  Color get _peach =>
      _isDarkTheme ? _theme.accent.withValues(alpha: 0.16) : _theme.accentSoft;
  Color get _blush =>
      _isDarkTheme ? _theme.accent.withValues(alpha: 0.22) : _theme.accentSoft.withValues(alpha: 0.62);
  Color get _sky =>
      _isDarkTheme ? _theme.accentSoft.withValues(alpha: 0.28) : _theme.accentSoft.withValues(alpha: 0.55);
  List<BoxShadow> get _cardShadow => <BoxShadow>[
    BoxShadow(
      color: _theme.accent.withValues(alpha: _isDarkTheme ? 0.18 : 0.10),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
    BoxShadow(
      color: _theme.accentSoft.withValues(alpha: _isDarkTheme ? 0.10 : 0.18),
      blurRadius: 30,
      offset: const Offset(0, 14),
    ),
  ];

  String _tr(String ko, String en) => _isEnglish ? en : ko;
  String get _formattedNotificationTime {
    final hour = _notificationTime.hour.toString().padLeft(2, '0');
    final minute = _notificationTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

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

  @override
  void initState() {
    super.initState();
    _dailyHoroscopeResult = _generateDailyHoroscope();
    _loadSavedTheme();
    _loadSavedLanguage();
    _loadNotificationSettings();
    _loadOrCreateDailyHoroscope();
  }

  Future<void> _loadSavedTheme() async {
    final preferences = await SharedPreferences.getInstance();
    final savedThemeKey = preferences.getString(appThemePreferenceKey);

    if (!mounted || savedThemeKey == null || !appThemes.containsKey(savedThemeKey)) {
      return;
    }

    setState(() {
      _selectedThemeKey = savedThemeKey;
    });
  }

  Future<void> _saveTheme(String themeKey) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(appThemePreferenceKey, themeKey);
  }

  Future<void> _loadSavedLanguage() async {
    final preferences = await SharedPreferences.getInstance();
    final savedLanguageCode = preferences.getString(appLanguagePreferenceKey);

    if (!mounted ||
        savedLanguageCode == null ||
        (savedLanguageCode != 'ko' && savedLanguageCode != 'en')) {
      return;
    }

    setState(() {
      _selectedLanguageCode = savedLanguageCode;
    });
  }

  Future<void> _saveLanguage(String languageCode) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(appLanguagePreferenceKey, languageCode);
  }

  Future<void> _loadNotificationSettings() async {
    final preferences = await SharedPreferences.getInstance();
    final savedEnabled =
        preferences.getBool(notificationEnabledPreferenceKey) ?? false;
    final savedHour = preferences.getInt(notificationHourPreferenceKey) ?? 7;
    final savedMinute = preferences.getInt(notificationMinutePreferenceKey) ?? 0;

    if (!mounted) {
      return;
    }

    setState(() {
      _notificationsEnabled = savedEnabled;
      _notificationTime = TimeOfDay(hour: savedHour, minute: savedMinute);
    });

    if (savedEnabled) {
      await LocalNotificationService.instance.scheduleDailyNotification(
        hour: savedHour,
        minute: savedMinute,
      );
    }
  }

  Future<void> _saveNotificationSettings() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(
      notificationEnabledPreferenceKey,
      _notificationsEnabled,
    );
    await preferences.setInt(
      notificationHourPreferenceKey,
      _notificationTime.hour,
    );
    await preferences.setInt(
      notificationMinutePreferenceKey,
      _notificationTime.minute,
    );
  }

  String _todayString() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }

  Map<String, dynamic> _generateDailyHoroscope() {
    final zodiacItems = _currentZodiacItems;
    final zodiacIndex = zodiacMeta.keys.toList().indexOf(widget.zodiacKey);
    final seed =
        DateTime.now().year * 10000 +
        DateTime.now().month * 100 +
        DateTime.now().day +
        (zodiacIndex == -1 ? 0 : zodiacIndex);
    final selectedItem = zodiacItems[seed % zodiacItems.length];

    return <String, dynamic>{
      'date': _todayString(),
      'zodiacKey': widget.zodiacKey,
      'message': selectedItem['message'],
      'score': selectedItem['score'],
      'action': selectedItem['action'],
      'rank': _currentZodiacRank,
      'emoji': selectedItem['emoji'],
    };
  }

  Future<void> _saveDailyHoroscope(Map<String, dynamic> result) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      horoscopeDatePreferenceKey,
      result['date'] as String,
    );
    await preferences.setString(
      horoscopeZodiacPreferenceKey,
      result['zodiacKey'] as String,
    );
    await preferences.setString(
      horoscopeMessagePreferenceKey,
      result['message'] as String,
    );
    await preferences.setInt(
      horoscopeScorePreferenceKey,
      result['score'] as int,
    );
    await preferences.setString(
      horoscopeActionPreferenceKey,
      result['action'] as String,
    );
    await preferences.setInt(
      horoscopeRankPreferenceKey,
      result['rank'] as int,
    );
    await preferences.setString(
      horoscopeEmojiPreferenceKey,
      result['emoji'] as String,
    );
  }

  Future<Map<String, dynamic>?> _loadSavedDailyHoroscope() async {
    final preferences = await SharedPreferences.getInstance();
    final savedDate = preferences.getString(horoscopeDatePreferenceKey);
    final savedZodiacKey = preferences.getString(horoscopeZodiacPreferenceKey);

    if (savedDate != _todayString() || savedZodiacKey != widget.zodiacKey) {
      return null;
    }

    final savedMessage = preferences.getString(horoscopeMessagePreferenceKey);
    final savedScore = preferences.getInt(horoscopeScorePreferenceKey);
    final savedAction = preferences.getString(horoscopeActionPreferenceKey);
    final savedRank = preferences.getInt(horoscopeRankPreferenceKey);
    final savedEmoji = preferences.getString(horoscopeEmojiPreferenceKey);

    if (savedMessage == null ||
        savedScore == null ||
        savedAction == null ||
        savedRank == null ||
        savedEmoji == null) {
      return null;
    }

    return <String, dynamic>{
      'date': savedDate,
      'zodiacKey': savedZodiacKey,
      'message': savedMessage,
      'score': savedScore,
      'action': savedAction,
      'rank': savedRank,
      'emoji': savedEmoji,
    };
  }

  Future<void> _loadOrCreateDailyHoroscope() async {
    final savedResult = await _loadSavedDailyHoroscope();
    final result = savedResult ?? _generateDailyHoroscope();

    if (savedResult == null) {
      await _saveDailyHoroscope(result);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _dailyHoroscopeResult = result;
    });
  }

  Future<void> _setNotificationsEnabled(bool enabled) async {
    setState(() {
      _notificationsEnabled = enabled;
    });
    await _saveNotificationSettings();

    if (enabled) {
      await LocalNotificationService.instance.scheduleDailyNotification(
        hour: _notificationTime.hour,
        minute: _notificationTime.minute,
      );
    } else {
      await LocalNotificationService.instance.cancelDailyNotification();
    }

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          enabled
              ? _tr(
                  '매일 $_formattedNotificationTime에 알림을 보내드릴게요.',
                  'Daily notification set for $_formattedNotificationTime.',
                )
              : _tr(
                  '아침 알림이 꺼졌어요.',
                  'Daily notification turned off.',
                ),
        ),
      ),
    );
  }

  Future<void> _pickNotificationTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _notificationTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _accent,
              onPrimary: Colors.white,
              surface: _cardStart,
              onSurface: _textPrimary,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: _cardEnd,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (pickedTime == null) {
      return;
    }

    setState(() {
      _notificationTime = pickedTime;
    });
    await _saveNotificationSettings();

    if (_notificationsEnabled) {
      await LocalNotificationService.instance.scheduleDailyNotification(
        hour: pickedTime.hour,
        minute: pickedTime.minute,
      );
    }

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _tr(
            '알림 시간이 $_formattedNotificationTime로 변경됐어요.',
            'Notification time changed to $_formattedNotificationTime.',
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> get _currentDisplayResult =>
      _dailyHoroscopeResult ?? _generateDailyHoroscope();

  Future<Uint8List?> _captureVisibleContent() async {
    final boundary = _visibleCaptureKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) {
      return null;
    }

    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  Future<Uint8List?> _captureShareCardImage() async {
    final capturedFile = await _shareCardScreenshotController.capture(
      delay: const Duration(milliseconds: 120),
      pixelRatio: 3,
    );
    return capturedFile;
  }

  Future<File> _createCapturedImageFile(Uint8List bytes) async {
    final directory = await getTemporaryDirectory();
    final file = File(
      '${directory.path}/morning_ohasa_share_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  Rect? _shareOriginRect() {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      return null;
    }

    return box.localToGlobal(Offset.zero) & box.size;
  }

  Future<void> saveCurrentScreenImage() async {
    final bytes = await _captureVisibleContent();
    if (bytes == null || !mounted) {
      return;
    }

    final result = await ImageGallerySaver.saveImage(
      bytes,
      quality: 100,
      name: 'morning_ohasa_${DateTime.now().millisecondsSinceEpoch}',
    );
    final isSuccess =
        result is Map && (result['isSuccess'] == true || result['filePath'] != null);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isSuccess
              ? _tr('이미지가 저장되었어요 📸', 'Image saved successfully 📸')
              : _tr('이미지 저장에 실패했어요', 'Failed to save image'),
        ),
      ),
    );
  }

  Future<void> shareWithShareCard() async {
    debugPrint('shareWithShareCard tapped');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 900),
          content: Text(
            _tr('공유 시트를 여는 중이에요...', 'Opening share sheet...'),
          ),
        ),
      );
    }

    try {
      final bytes = await _captureShareCardImage();
      if (bytes == null) {
        debugPrint('shareWithShareCard: capture returned null');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _tr('공유 이미지를 만들지 못했어요.', 'Could not create share image.'),
              ),
            ),
          );
        }
        return;
      }

      final file = await _createCapturedImageFile(bytes);
      debugPrint('shareWithShareCard: sharing file ${file.path}');
      await SharePlus.instance.share(
        ShareParams(
          files: <XFile>[XFile(file.path)],
          text: _tr(
            '오늘의 오하아사 결과를 확인해봤어요 ✨',
            'I checked my Morning Ohasa result today ✨',
          ),
          sharePositionOrigin: _shareOriginRect(),
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('shareWithShareCard error: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _tr('공유를 열지 못했어요.', 'Could not open share sheet.'),
            ),
          ),
        );
      }
    }
  }

  Future<void> shareAppLink() async {
    debugPrint('shareAppLink tapped');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 900),
          content: Text(
            _tr('링크 공유를 여는 중이에요...', 'Opening link share...'),
          ),
        ),
      );
    }

    try {
      await SharePlus.instance.share(
        ShareParams(
          text: _tr(
            '오늘의 오하아사 앱 구경하기 ✨ https://example.com/morning-ohasa',
            'Take a look at the Morning Ohasa app ✨ https://example.com/morning-ohasa',
          ),
          sharePositionOrigin: _shareOriginRect(),
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('shareAppLink error: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _tr('링크 공유를 열지 못했어요.', 'Could not open link share.'),
            ),
          ),
        );
      }
    }
  }

  Future<void> _changeZodiacFromSettings(String zodiacKey) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(zodiacPreferenceKey, zodiacKey);

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => HomeScreen(zodiacKey: zodiacKey),
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

  BoxDecoration _glassCardDecoration({
    List<Color>? colors,
    double radius = _cardRadius,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors:
            colors ??
            <Color>[
              _cardStart,
              _cardEnd,
            ],
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: _accentSoft.withValues(alpha: _isDarkTheme ? 0.28 : 0.92),
        width: 1.6,
      ),
      boxShadow: <BoxShadow>[
        ..._cardShadow,
        BoxShadow(
          color: _accent.withValues(alpha: _isDarkTheme ? 0.10 : 0.12),
          blurRadius: 36,
          offset: const Offset(0, 18),
        ),
      ],
    );
  }

  List<Widget> _buildSparkleCluster({
    required Alignment alignment,
    double scale = 1,
  }) {
    return <Widget>[
      Align(
        alignment: alignment,
        child: Transform.translate(
          offset: Offset(8 * scale, -4 * scale),
          child: Icon(
            Icons.auto_awesome_rounded,
            size: 18 * scale,
            color: _accentSoft.withValues(alpha: 0.92),
          ),
        ),
      ),
      Align(
        alignment: alignment,
        child: Transform.translate(
          offset: Offset(-14 * scale, 8 * scale),
          child: Icon(
            Icons.star_rounded,
            size: 13 * scale,
            color: _iconColor.withValues(alpha: 0.75),
          ),
        ),
      ),
      Align(
        alignment: alignment,
        child: Transform.translate(
          offset: Offset(18 * scale, 14 * scale),
          child: Container(
            width: 6 * scale,
            height: 6 * scale,
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    ];
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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                _cardStart,
                _cardEnd,
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: _accentSoft.withValues(alpha: 0.92)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: _accentSoft.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                _tr('오늘의 오하아사 전체 순위', 'Today\'s Full Ohasa Ranking'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _tr('내 별자리는 강조되어 보여요', 'Your zodiac is highlighted'),
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

  Future<void> _showSettingsSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        String activeSection = 'menu';

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            final titles = <String, String>{
              'menu': _tr('설정', 'Settings'),
              'theme': _tr('테마', 'Theme'),
              'language': _tr('언어', 'Language'),
              'notification': _tr('알림', 'Notifications'),
              'zodiac': _tr('별자리 변경', 'Change Zodiac'),
            };

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.88,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    _cardStart,
                    _cardEnd,
                  ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(
                  color: _accentSoft.withValues(alpha: 0.92),
                ),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    14,
                    20,
                    24 + MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: _accentSoft.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildSettingsSheetHeader(
                        title: titles[activeSection]!,
                        showBack: activeSection != 'menu',
                        onBack: () => modalSetState(() => activeSection = 'menu'),
                        onClose: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(height: 14),
                      if (activeSection == 'menu') ...<Widget>[
                        Text(
                          _tr(
                            '바꾸고 싶은 설정을 골라보세요',
                            'Choose what you want to change',
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            color: _textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _buildSettingsMenuItem(
                          title: _tr('테마', 'Theme'),
                          subtitle: _theme.labelKo,
                          icon: Icons.palette_rounded,
                          onTap: () => modalSetState(() => activeSection = 'theme'),
                        ),
                        _buildSettingsMenuItem(
                          title: _tr('언어', 'Language'),
                          subtitle: _selectedLanguageCode == 'ko'
                              ? '한국어'
                              : 'English',
                          icon: Icons.translate_rounded,
                          onTap: () => modalSetState(() => activeSection = 'language'),
                        ),
                        _buildSettingsMenuItem(
                          title: _tr('알림', 'Notifications'),
                          subtitle: _notificationsEnabled
                              ? _formattedNotificationTime
                              : _tr('꺼짐', 'Off'),
                          icon: Icons.notifications_active_rounded,
                          onTap: () => modalSetState(() => activeSection = 'notification'),
                        ),
                        _buildSettingsMenuItem(
                          title: _tr('별자리 변경', 'Change Zodiac'),
                          subtitle: _currentZodiac.nameKo,
                          icon: zodiacIconData(widget.zodiacKey),
                          onTap: () => modalSetState(() => activeSection = 'zodiac'),
                        ),
                      ] else if (activeSection == 'theme') ..._buildThemeSettingsContent()
                      else if (activeSection == 'language') ..._buildLanguageSettingsContent()
                      else if (activeSection == 'notification') ..._buildNotificationSettingsContent()
                      else if (activeSection == 'zodiac') ..._buildZodiacSettingsContent(),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSettingsSheetHeader({
    required String title,
    required bool showBack,
    required VoidCallback onBack,
    required VoidCallback onClose,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: showBack
              ? IconButton(
                  onPressed: onBack,
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: _textPrimary,
                  ),
                  tooltip: _tr('뒤로', 'Back'),
                )
              : const SizedBox.shrink(),
        ),
        Expanded(
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _textPrimary,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 40,
          child: IconButton(
            onPressed: onClose,
            icon: Icon(
              Icons.close_rounded,
              color: _textPrimary,
            ),
            tooltip: _tr('닫기', 'Close'),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsMenuItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  _cardStart,
                  Color.lerp(_cardEnd, _accentSoft, 0.18) ?? _cardEnd,
                ],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: _accentSoft.withValues(alpha: 0.82),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: _accent.withValues(alpha: 0.10),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        _accentSoft.withValues(alpha: 0.72),
                        _blush.withValues(alpha: 0.72),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: _iconColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: _textSecondary,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildThemeSettingsContent() {
    return appThemes.entries.map((MapEntry<String, AppThemeColors> entry) {
      final theme = entry.value;
      final isSelected = entry.key == _selectedThemeKey;

      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () async {
              setState(() {
                _selectedThemeKey = entry.key;
              });
              await _saveTheme(entry.key);
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    theme.cardGradientStart,
                    theme.cardGradientEnd,
                  ],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected ? theme.accent : theme.accentSoft,
                  width: isSelected ? 1.8 : 1.2,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: theme.accent.withValues(alpha: 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(
                        colors: <Color>[
                          theme.background,
                          theme.accentSoft,
                        ],
                      ),
                      border: Border.all(
                        color: theme.accentSoft.withValues(alpha: 0.95),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      theme.labelKo,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: theme.textPrimary,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle_rounded,
                      color: theme.icon,
                      size: 22,
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildLanguageSettingsContent() {
    return <Map<String, String>>[
      <String, String>{'code': 'ko', 'label': '한국어'},
      <String, String>{'code': 'en', 'label': 'English'},
    ].map((Map<String, String> language) {
      final isSelected = language['code'] == _selectedLanguageCode;

      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () async {
              setState(() {
                _selectedLanguageCode = language['code']!;
              });
              await _saveLanguage(language['code']!);
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    _cardStart,
                    Color.lerp(_cardEnd, _accentSoft, 0.16) ?? _cardEnd,
                  ],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected ? _accent : _accentSoft,
                  width: isSelected ? 1.8 : 1.2,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: _accent.withValues(alpha: 0.10),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[
                          _accentSoft.withValues(alpha: 0.72),
                          _blush.withValues(alpha: 0.72),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.translate_rounded,
                      color: _iconColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      language['label']!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _textPrimary,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle_rounded,
                      color: _iconColor,
                      size: 22,
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildNotificationSettingsContent() {
    return <Widget>[
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              _cardStart,
              Color.lerp(_cardEnd, _accentSoft, 0.16) ?? _cardEnd,
            ],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: _accentSoft.withValues(alpha: 0.82),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: _accent.withValues(alpha: 0.10),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        _accentSoft.withValues(alpha: 0.72),
                        _blush.withValues(alpha: 0.72),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.notifications_active_rounded,
                    color: _iconColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _tr('아침 알림 받기', 'Daily Morning Alert'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _notificationsEnabled
                            ? _tr(
                                '매일 $_formattedNotificationTime에 알려드려요',
                                'Alert every day at $_formattedNotificationTime',
                              )
                            : _tr(
                                '지금은 알림이 꺼져 있어요',
                                'Notifications are currently off',
                              ),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _notificationsEnabled,
                  onChanged: _setNotificationsEnabled,
                  activeThumbColor: _accent,
                  activeTrackColor: _accentSoft,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: _pickNotificationTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        Colors.white.withValues(alpha: _isDarkTheme ? 0.05 : 0.72),
                        _accentSoft.withValues(alpha: _isDarkTheme ? 0.08 : 0.18),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _accentSoft.withValues(alpha: 0.82),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _tr('알림 시간', 'Notification Time'),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: _textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formattedNotificationTime,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: _accent,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: _textSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildZodiacSettingsContent() {
    return <Widget>[
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              _cardStart,
              Color.lerp(_cardEnd, _accentSoft, 0.18) ?? _cardEnd,
            ],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: _accentSoft.withValues(alpha: 0.82),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: _accent.withValues(alpha: 0.10),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        _accentSoft.withValues(alpha: 0.72),
                        _blush.withValues(alpha: 0.72),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    zodiacIconData(widget.zodiacKey),
                    color: _iconColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _tr('현재 별자리', 'Current Zodiac'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _textSecondary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _currentZodiac.nameKo,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: _textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: zodiacMeta.entries.map((MapEntry<String, ZodiacMeta> entry) {
                final isSelected = entry.key == widget.zodiacKey;

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () => _changeZodiacFromSettings(entry.key),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: <Color>[
                            isSelected
                                ? _accentSoft.withValues(alpha: 0.9)
                                : Colors.white.withValues(
                                    alpha: _isDarkTheme ? 0.06 : 0.72,
                                  ),
                            isSelected
                                ? _blush.withValues(alpha: 0.68)
                                : _accentSoft.withValues(
                                    alpha: _isDarkTheme ? 0.06 : 0.18,
                                  ),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isSelected ? _accent : _accentSoft,
                          width: isSelected ? 1.5 : 1.1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            zodiacIconData(entry.key),
                            size: 15,
                            color: isSelected ? _accent : _iconColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            entry.value.nameKo,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? _accent : _textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final currentItem = _currentDisplayResult;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              _backgroundColor,
              Color.lerp(_backgroundColor, _accentSoft, 0.42) ?? _backgroundColor,
              Color.lerp(_backgroundColor, Colors.white, _isDarkTheme ? 0.05 : 0.55) ??
                  _backgroundColor,
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _KitschBackgroundPainter(
                    accent: _accent,
                    accentSoft: _accentSoft,
                    iconColor: _iconColor,
                    darkMode: _isDarkTheme,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.45),
                    radius: 1.1,
                    colors: <Color>[
                      _accentSoft.withValues(alpha: _isDarkTheme ? 0.12 : 0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -60,
              right: -40,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _blush.withValues(alpha: 0.72),
                      _blush.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 96,
              left: -70,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _accentSoft.withValues(alpha: 0.34),
                      _accentSoft.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              right: -20,
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: <Color>[
                      _iconColor.withValues(alpha: _isDarkTheme ? 0.09 : 0.14),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 248,
              right: -28,
              child: Transform.rotate(
                angle: 0.3,
                child: Container(
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        _blush.withValues(alpha: 0.42),
                        _accentSoft.withValues(alpha: 0.18),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 90,
              right: 46,
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 24,
                color: _accentSoft.withValues(alpha: 0.92),
              ),
            ),
            Positioned(
              top: 78,
              left: 42,
              child: Icon(
                Icons.star_rounded,
                size: 20,
                color: _blush.withValues(alpha: 0.82),
              ),
            ),
            Positioned(
              top: 154,
              left: 26,
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 16,
                color: _sky.withValues(alpha: 0.9),
              ),
            ),
            Positioned(
              left: 18,
              bottom: 168,
              child: Icon(
                Icons.star_rounded,
                size: 22,
                color: _iconColor.withValues(alpha: 0.6),
              ),
            ),
            Positioned(
              right: 30,
              bottom: 116,
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 26,
                color: _accentSoft.withValues(alpha: 0.76),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, right: 16),
                  child: Tooltip(
                    message: _tr('설정', 'Settings'),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _showSettingsSheet,
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: <Color>[
                                Colors.white.withValues(alpha: _isDarkTheme ? 0.10 : 0.86),
                                _accentSoft.withValues(alpha: _isDarkTheme ? 0.10 : 0.36),
                              ],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _accentSoft.withValues(alpha: 0.78),
                            ),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: _accent.withValues(alpha: _isDarkTheme ? 0.10 : 0.14),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.tune_rounded,
                            size: 18,
                            color: _iconColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final content = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(today, currentItem['emoji'] as String),
                      const SizedBox(height: 8),
                      _buildRankCard(),
                      const SizedBox(height: 9),
                      _buildMessageCard(currentItem['message'] as String),
                      const SizedBox(height: 9),
                      Row(
                        children: [
                          Expanded(
                            child: _buildScoreCard(currentItem['score'] as int),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildActionCard(
                              currentItem['action'] as String,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 9),
                      _buildUtilityButtons(),
                    ],
                  );

                  final framedContent = Padding(
                    padding: const EdgeInsets.fromLTRB(16, 34, 16, 8),
                    child: RepaintBoundary(
                      key: _visibleCaptureKey,
                      child:
                          kIsWeb
                              ? Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 460),
                                  child: content,
                                ),
                              )
                              : content,
                    ),
                  );

                  return Column(
                    children: [
                      const Spacer(flex: 3),
                      framedContent,
                      const Spacer(flex: 2),
                    ],
                  );
                },
              ),
            ),
            Positioned(
              left: -9999,
              top: 0,
              child: Screenshot(
                controller: _shareCardScreenshotController,
                child: Material(
                  color: Colors.transparent,
                  child: ShareCard(
                    zodiacName: _currentZodiac.nameKo,
                    zodiacIcon: zodiacIconData(widget.zodiacKey),
                    rank: (currentItem['rank'] as int?) ?? _currentZodiacRank,
                    message: currentItem['message'] as String,
                    score: currentItem['score'] as int,
                    action: currentItem['action'] as String,
                    backgroundStart: _cardStart,
                    backgroundEnd: _cardEnd,
                    accent: _accent,
                    accentSoft: _accentSoft,
                    textPrimary: _textPrimary,
                    textSecondary: _textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(DateTime today, String _) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: _glassCardDecoration(
        radius: 34,
        colors: <Color>[
          Color.lerp(_cardStart, Colors.white, _isDarkTheme ? 0.04 : 0.28) ??
              _cardStart,
          Color.lerp(_cardEnd, _accentSoft, _isDarkTheme ? 0.12 : 0.26) ??
              _cardEnd,
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -14,
            left: 24,
            right: 24,
            child: Container(
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  colors: <Color>[
                    Colors.white.withValues(alpha: _isDarkTheme ? 0.05 : 0.48),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -24,
            child: Container(
              width: 160,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  colors: <Color>[
                    _accentSoft.withValues(alpha: _isDarkTheme ? 0.12 : 0.28),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: -8,
            bottom: -6,
            child: Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[
                    _accent.withValues(alpha: _isDarkTheme ? 0.12 : 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          ..._buildSparkleCluster(
            alignment: Alignment.topRight,
            scale: 1.0,
          ),
          ..._buildSparkleCluster(
            alignment: Alignment.bottomLeft,
            scale: 0.9,
          ),
          Positioned(
            top: 18,
            right: 28,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 14,
              color: _blush.withValues(alpha: 0.86),
            ),
          ),
          Positioned(
            top: 14,
            left: 78,
            child: Icon(
              Icons.star_rounded,
              size: 12,
              color: _sky.withValues(alpha: 0.95),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      _accentSoft,
                      _accent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _accent.withValues(alpha: 0.24),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: 14,
                      bottom: 12,
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.26),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 14,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.24),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.question_mark_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: <Color>[
                            Colors.white.withValues(alpha: _isDarkTheme ? 0.08 : 0.92),
                            _accentSoft.withValues(alpha: _isDarkTheme ? 0.06 : 0.22),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: _accentSoft.withValues(alpha: 0.9),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildZodiacIcon(
                            widget.zodiacKey,
                            size: 14,
                            color: _accent,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _currentZodiac.nameKo,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: _accent,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _tr('오늘의 오하아사', 'Today\'s Ohasa'),
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                        color: _textPrimary,
                        height: 1.05,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${today.year}.${today.month}.${today.day}',
                          style: TextStyle(
                            fontSize: 13,
                            color: _textSecondary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankCard() {
    final displayedRank =
        (_dailyHoroscopeResult?['rank'] as int?) ?? _currentZodiacRank;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: _showRankingsSheet,
        child: Ink(
          decoration: _glassCardDecoration(
            radius: 26,
            colors: <Color>[
              Color.lerp(_cardStart, Colors.white, _isDarkTheme ? 0.03 : 0.20) ??
                  _cardStart,
              Color.lerp(_cardEnd, _accentSoft, _isDarkTheme ? 0.10 : 0.22) ??
                  _cardEnd,
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 12, 14, 12),
            child: Stack(
              children: [
                Positioned(
                  top: -12,
                  left: 18,
                  right: 56,
                  child: Container(
                    height: 22,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: LinearGradient(
                        colors: <Color>[
                          Colors.white.withValues(alpha: _isDarkTheme ? 0.04 : 0.34),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                ..._buildSparkleCluster(
                  alignment: Alignment.centerRight,
                  scale: 0.8,
                ),
                ..._buildSparkleCluster(
                  alignment: Alignment.centerLeft,
                  scale: 0.55,
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: <Color>[
                            _accentSoft.withValues(alpha: 0.82),
                            _blush.withValues(alpha: 0.55),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _tr('오늘의 오하아사 순위', 'Today\'s Ohasa Rank'),
                        style: TextStyle(
                          fontSize: 11,
                          color: _accent,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _accentSoft.withValues(alpha: 0.34),
                      ),
                      child: _buildZodiacIcon(
                        widget.zodiacKey,
                        size: 18,
                        color: _accent,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _isEnglish
                            ? '${_currentZodiac.nameKo} today #$displayedRank'
                            : '${_currentZodiac.nameKo} 오늘 $displayedRank위',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: _textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: _textSecondary,
                      size: 20,
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
        isCurrent
            ? _peach.withValues(alpha: _isDarkTheme ? 0.92 : 0.68)
            : (_isDarkTheme
                ? _cardStart.withValues(alpha: 0.98)
                : Colors.white.withValues(alpha: 0.94));
    final borderColor = isCurrent ? _accent : _accentSoft.withValues(alpha: 0.9);
    final rankBackground =
        isCurrent ? _accent : _peach.withValues(alpha: 0.7);
    final rankTextColor = isCurrent ? Colors.white : _accent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            backgroundColor,
            _isDarkTheme
                ? _cardEnd.withValues(alpha: 0.96)
                : Colors.white.withValues(alpha: 0.94),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor, width: isCurrent ? 1.6 : 1.1),
        boxShadow: _cardShadow,
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
          _buildZodiacIcon(
            zodiacKey,
            size: 22,
            color: isCurrent ? _accent : _textSecondary,
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
              child: Text(
                _tr('내 별자리', 'My Zodiac'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _accent,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageCard(String message) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: _glassCardDecoration(
        colors: <Color>[
          Color.lerp(_cardStart, Colors.white, _isDarkTheme ? 0.04 : 0.30) ??
              _cardStart,
          Color.lerp(_cardEnd, _blush, _isDarkTheme ? 0.12 : 0.34) ?? _cardEnd,
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -10,
            left: 20,
            right: 20,
            child: Container(
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  colors: <Color>[
                    Colors.white.withValues(alpha: _isDarkTheme ? 0.05 : 0.44),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: -12,
            right: -12,
            bottom: -6,
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  colors: <Color>[
                    _accentSoft.withValues(alpha: 0.00),
                    _accentSoft.withValues(alpha: _isDarkTheme ? 0.08 : 0.20),
                    _accentSoft.withValues(alpha: 0.00),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: -18,
            bottom: 18,
            child: Transform.rotate(
              angle: 0.45,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      _blush.withValues(alpha: 0.42),
                      _accentSoft.withValues(alpha: 0.12),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
          ..._buildSparkleCluster(
            alignment: Alignment.topRight,
            scale: 1.05,
          ),
          ..._buildSparkleCluster(
            alignment: Alignment.bottomLeft,
            scale: 1.15,
          ),
          ..._buildSparkleCluster(
            alignment: Alignment.centerRight,
            scale: 0.85,
          ),
          Positioned(
            top: 2,
            right: 6,
            child: Icon(
              Icons.star_rounded,
              size: 18,
              color: _sky.withValues(alpha: 0.95),
            ),
          ),
          Positioned(
            top: 28,
            right: 26,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 18,
              color: _blush.withValues(alpha: 0.9),
            ),
          ),
          Positioned(
            left: 2,
            top: 18,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 17,
              color: _blush.withValues(alpha: 0.95),
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      _blush.withValues(alpha: 0.95),
                      _accentSoft.withValues(alpha: 0.55),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: _accent.withValues(alpha: _isDarkTheme ? 0.08 : 0.10),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  _tr('오늘의 한마디', 'Today\'s Message'),
                  style: TextStyle(
                    fontSize: 14,
                    color: _accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 23,
                  height: 1.32,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(int score) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _glassCardDecoration(
        colors: <Color>[
          Color.lerp(_cardStart, Colors.white, _isDarkTheme ? 0.03 : 0.22) ??
              _cardStart,
          Color.lerp(_cardEnd, _accentSoft, _isDarkTheme ? 0.12 : 0.24) ??
              _cardEnd,
        ],
      ),
      child: Stack(
        children: [
          ..._buildSparkleCluster(
            alignment: Alignment.bottomRight,
            scale: 0.82,
          ),
          Column(
            children: [
          Text(
            _tr('오늘 점수', 'Today\'s Score'),
            style: TextStyle(
              fontSize: 12,
              color: _textSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(10, 12, 10, 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  _isDarkTheme
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.white.withValues(alpha: 0.94),
                  Color.lerp(_cardEnd, _accentSoft, 0.18) ?? _cardEnd,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color:
                    _isDarkTheme
                        ? _accentSoft.withValues(alpha: 0.22)
                        : Colors.white.withValues(alpha: 0.95),
              ),
              boxShadow: _cardShadow,
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: _accentSoft.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: LinearGradient(
                      colors: <Color>[
                        _accentSoft.withValues(alpha: 0.22),
                        Colors.white.withValues(alpha: 0.0),
                        _blush.withValues(alpha: 0.22),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      _accentSoft,
                      _accent,
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
        ],
      ),
    );
  }

  Widget _buildActionCard(String action) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _glassCardDecoration(
        colors: <Color>[
          Color.lerp(_cardStart, Colors.white, _isDarkTheme ? 0.03 : 0.22) ??
              _cardStart,
          Color.lerp(_cardEnd, _blush, _isDarkTheme ? 0.12 : 0.24) ?? _cardEnd,
        ],
      ),
      child: Stack(
        children: [
          ..._buildSparkleCluster(
            alignment: Alignment.topRight,
            scale: 0.82,
          ),
          Column(
            children: [
          Text(
            _tr('추천 행동', 'Suggested Action'),
            style: TextStyle(
              fontSize: 12,
              color: _textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  _blush.withValues(alpha: 0.95),
                  _accentSoft.withValues(alpha: 0.45),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: _accent.withValues(alpha: _isDarkTheme ? 0.10 : 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              Icons.wb_sunny_rounded,
              size: 22,
              color: _iconColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            action,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.3,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
              letterSpacing: -0.2,
            ),
          ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUtilityButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildUtilityButton(
          icon: Icons.download_rounded,
          tooltip: _tr('이미지 저장', 'Save Image'),
          onTap: saveCurrentScreenImage,
          accent: _sky,
        ),
        _buildUtilityButton(
          icon: null,
          tooltip: _tr('공유하기', 'Share to X'),
          onTap: shareWithShareCard,
          accent: _blush,
        ),
        _buildUtilityButton(
          icon: Icons.reply_rounded,
          tooltip: _tr('링크 공유', 'Share Link'),
          onTap: shareAppLink,
          accent: const Color(0xFFFFE8F7),
        ),
      ],
    );
  }

  Widget _buildUtilityButton({
    IconData? icon,
    required String tooltip,
    required Future<void> Function() onTap,
    required Color accent,
    Widget? child,
  }) {
    final backgroundColor = Colors.white;
    final borderColor = _accentSoft.withValues(alpha: 0.82);
    final iconColor =
        tooltip == '공유하기' || tooltip == 'Share to X' ? _accent : _iconColor;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            width: 76,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Color.lerp(backgroundColor, accent, _isDarkTheme ? 0.10 : 0.22) ??
                      backgroundColor,
                  accent.withValues(alpha: _isDarkTheme ? 0.22 : 0.56),
                ],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: borderColor,
                width: 1.4,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: _accent.withValues(alpha: _isDarkTheme ? 0.10 : 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
                BoxShadow(
                  color: accent.withValues(alpha: _isDarkTheme ? 0.12 : 0.18),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Positioned(
                  top: 6,
                  left: 10,
                  right: 10,
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: LinearGradient(
                        colors: <Color>[
                          Colors.white.withValues(alpha: _isDarkTheme ? 0.06 : 0.42),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 12,
                  child: Icon(
                    Icons.star_rounded,
                    size: 10,
                    color: Colors.white.withValues(alpha: 0.44),
                  ),
                ),
                child ??
                    (icon != null
                        ? Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(
                                    alpha: _isDarkTheme ? 0.08 : 0.22,
                                  ),
                                ),
                              ),
                              Icon(
                                icon,
                                color: iconColor,
                                size: 28,
                              ),
                            ],
                          )
                        : Container(
                            width: 34,
                            height: 34,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: <Color>[
                                  _blush.withValues(alpha: 0.98),
                                  accent.withValues(alpha: 0.88),
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: accent.withValues(alpha: 0.22),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              'X',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: iconColor,
                                height: 1,
                              ),
                            ),
                          )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildZodiacIcon(
    String zodiacKey, {
    required double size,
    required Color color,
  }) {
    const iconMap = <String, IconData>{
      'aries': Icons.wb_sunny_rounded,
      'taurus': Icons.spa_rounded,
      'gemini': Icons.auto_awesome_rounded,
      'cancer': Icons.nightlight_round,
      'leo': Icons.star_rounded,
      'virgo': Icons.task_alt_rounded,
      'libra': Icons.balance_rounded,
      'scorpio': Icons.bolt_rounded,
      'sagittarius': Icons.explore_rounded,
      'capricorn': Icons.terrain_rounded,
      'aquarius': Icons.water_drop_rounded,
      'pisces': Icons.water_rounded,
    };

    return Icon(
      iconMap[zodiacKey] ?? Icons.auto_awesome_rounded,
      size: size,
      color: color,
    );
  }
}

class _KitschBackgroundPainter extends CustomPainter {
  const _KitschBackgroundPainter({
    required this.accent,
    required this.accentSoft,
    required this.iconColor,
    required this.darkMode,
  });

  final Color accent;
  final Color accentSoft;
  final Color iconColor;
  final bool darkMode;

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint =
        Paint()
          ..color = accent.withValues(alpha: darkMode ? 0.12 : 0.18)
          ..style = PaintingStyle.fill;
    final softPaint =
        Paint()
          ..color = accentSoft.withValues(alpha: darkMode ? 0.10 : 0.20)
          ..style = PaintingStyle.fill;
    final starPaint =
        Paint()
          ..color = iconColor.withValues(alpha: darkMode ? 0.12 : 0.22)
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;

    final dots = <Offset>[
      Offset(size.width * 0.05, size.height * 0.16),
      Offset(size.width * 0.12, size.height * 0.74),
      Offset(size.width * 0.22, size.height * 0.88),
      Offset(size.width * 0.84, size.height * 0.18),
      Offset(size.width * 0.92, size.height * 0.52),
      Offset(size.width * 0.78, size.height * 0.84),
    ];
    for (final dot in dots) {
      canvas.drawCircle(dot, 4.5, dotPaint);
    }

    final softDots = <Offset>[
      Offset(size.width * 0.18, size.height * 0.22),
      Offset(size.width * 0.32, size.height * 0.64),
      Offset(size.width * 0.64, size.height * 0.34),
      Offset(size.width * 0.88, size.height * 0.72),
    ];
    for (final dot in softDots) {
      canvas.drawCircle(dot, 7.5, softPaint);
    }

    void drawSparkle(Offset center, double extent) {
      canvas.drawLine(
        Offset(center.dx - extent, center.dy),
        Offset(center.dx + extent, center.dy),
        starPaint,
      );
      canvas.drawLine(
        Offset(center.dx, center.dy - extent),
        Offset(center.dx, center.dy + extent),
        starPaint,
      );
    }

    drawSparkle(Offset(size.width * 0.08, size.height * 0.82), 7);
    drawSparkle(Offset(size.width * 0.16, size.height * 0.28), 5);
    drawSparkle(Offset(size.width * 0.90, size.height * 0.28), 8);
    drawSparkle(Offset(size.width * 0.84, size.height * 0.86), 6);
  }

  @override
  bool shouldRepaint(covariant _KitschBackgroundPainter oldDelegate) {
    return accent != oldDelegate.accent ||
        accentSoft != oldDelegate.accentSoft ||
        iconColor != oldDelegate.iconColor ||
        darkMode != oldDelegate.darkMode;
  }
}
