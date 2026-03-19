import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';

import 'data/messages.dart';
import 'share_card.dart';
import 'zodiac_selection_screen.dart';

const String zodiacPreferenceKey = 'selected_zodiac_key';
const String appThemePreferenceKey = 'selected_app_theme';
const String appLanguagePreferenceKey = 'selected_app_language';
const String appFontPreferenceKey = 'selected_app_font';
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
final ValueNotifier<String> appFontKeyNotifier = ValueNotifier<String>(
  'notoSansKr',
);

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
    labelKo: 'Cotton Candy Dream',
    primary: Color(0xFF9B8AFB),
    secondary: Color(0xFFFFB6E6),
    background: Color(0xFFF8F2FF),
    cardColor: Color(0xFFF7EDFF),
    textColor: Color(0xFF2F2744),
  ),
  'limeYellow': AppThemeColors(
    key: 'limeYellow',
    labelKo: 'Lemon Pop',
    primary: Color(0xFF8FBE1E),
    secondary: Color(0xFFFFD95A),
    background: Color(0xFFF8FFE3),
    cardColor: Color(0xFFF2FFD6),
    textColor: Color(0xFF2F341F),
  ),
  'mintCream': AppThemeColors(
    key: 'mintCream',
    labelKo: 'Mint Soda',
    primary: Color(0xFF3FD6AF),
    secondary: Color(0xFFA8F2DE),
    background: Color(0xFFF1FFF9),
    cardColor: Color(0xFFE6FFF5),
    textColor: Color(0xFF23413B),
  ),
  'blackPink': AppThemeColors(
    key: 'blackPink',
    labelKo: 'Black Velvet',
    primary: Color(0xFFFF5BA7),
    secondary: Color(0xFF7E5CFF),
    background: Color(0xFF19181F),
    cardColor: Color(0xFF26242E),
    textColor: Color(0xFFF8F5FF),
    isDark: true,
  ),
  'oceanGlow': AppThemeColors(
    key: 'oceanGlow',
    labelKo: 'Ocean Glow',
    primary: Color(0xFF58B7FF),
    secondary: Color(0xFF8AF5FF),
    background: Color(0xFFF0FAFF),
    cardColor: Color(0xFFE7F7FF),
    textColor: Color(0xFF213748),
  ),
  'peachCream': AppThemeColors(
    key: 'peachCream',
    labelKo: 'Peach Cream',
    primary: Color(0xFFFF9B7A),
    secondary: Color(0xFFFFD3BA),
    background: Color(0xFFFFF5EE),
    cardColor: Color(0xFFFFEEE2),
    textColor: Color(0xFF4A2E2A),
  ),
  'galaxyNight': AppThemeColors(
    key: 'galaxyNight',
    labelKo: 'Galaxy Night',
    primary: Color(0xFF8D7CFF),
    secondary: Color(0xFF3ED7FF),
    background: Color(0xFF11162A),
    cardColor: Color(0xFF1A2240),
    textColor: Color(0xFFF2F5FF),
    isDark: true,
  ),
  'berryPop': AppThemeColors(
    key: 'berryPop',
    labelKo: 'Berry Pop',
    primary: Color(0xFFFF5C9F),
    secondary: Color(0xFFFFA7C8),
    background: Color(0xFFFFF1F7),
    cardColor: Color(0xFFFFE7F0),
    textColor: Color(0xFF442434),
  ),
};

const Map<String, List<Map<String, dynamic>>> zodiacVisualData =
    <String, List<Map<String, dynamic>>>{
      'aries': <Map<String, dynamic>>[
        {
          'score': 84,
          'emoji': '🔥',
        },
        {
          'score': 79,
          'emoji': '🚀',
        },
      ],
      'taurus': <Map<String, dynamic>>[
        {
          'score': 86,
          'emoji': '🌿',
        },
        {
          'score': 82,
          'emoji': '🍃',
        },
      ],
      'gemini': <Map<String, dynamic>>[
        {
          'score': 81,
          'emoji': '💬',
        },
        {
          'score': 87,
          'emoji': '🌤️',
        },
      ],
      'cancer': <Map<String, dynamic>>[
        {
          'score': 85,
          'emoji': '🌙',
        },
        {
          'score': 80,
          'emoji': '🫧',
        },
      ],
      'leo': <Map<String, dynamic>>[
        {
          'score': 90,
          'emoji': '☀️',
        },
        {
          'score': 88,
          'emoji': '🦁',
        },
      ],
      'virgo': <Map<String, dynamic>>[
        {
          'score': 83,
          'emoji': '📝',
        },
        {
          'score': 78,
          'emoji': '🌾',
        },
      ],
      'libra': <Map<String, dynamic>>[
        {
          'score': 84,
          'emoji': '⚖️',
        },
        {
          'score': 86,
          'emoji': '🌸',
        },
      ],
      'scorpio': <Map<String, dynamic>>[
        {
          'score': 89,
          'emoji': '🦂',
        },
        {
          'score': 77,
          'emoji': '🌌',
        },
      ],
      'sagittarius': <Map<String, dynamic>>[
        {
          'score': 88,
          'emoji': '🏹',
        },
        {
          'score': 82,
          'emoji': '🌍',
        },
      ],
      'capricorn': <Map<String, dynamic>>[
        {
          'score': 87,
          'emoji': '⛰️',
        },
        {
          'score': 80,
          'emoji': '🪨',
        },
      ],
      'aquarius': <Map<String, dynamic>>[
        {
          'score': 85,
          'emoji': '💡',
        },
        {
          'score': 83,
          'emoji': '🌊',
        },
      ],
      'pisces': <Map<String, dynamic>>[
        {
          'score': 84,
          'emoji': '🐟',
        },
        {
          'score': 81,
          'emoji': '🌊',
        },
      ],
    };

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotificationService.instance.initialize();
  final preferences = await SharedPreferences.getInstance();
  final savedZodiacKey = preferences.getString(zodiacPreferenceKey);
  final savedFontKey =
      preferences.getString(appFontPreferenceKey) ?? appFontKeyNotifier.value;
  appFontKeyNotifier.value =
      appFontOptions.containsKey(savedFontKey)
          ? savedFontKey
          : appFontKeyNotifier.value;
  final initialDailyHoroscopeResult =
      savedZodiacKey == null
          ? null
          : loadInitialDailyHoroscopeResult(
              preferences: preferences,
              zodiacKey: savedZodiacKey,
            );

  runApp(
    MorningOhasaApp(
      initialZodiacKey: savedZodiacKey,
      initialDailyHoroscopeResult: initialDailyHoroscopeResult,
    ),
  );
}

String normalizeDailyDateKey(String? rawDate) {
  final value = rawDate?.trim() ?? '';
  if (RegExp(r'^\d{8}$').hasMatch(value)) {
    return '${value.substring(0, 4)}-${value.substring(4, 6)}-${value.substring(6, 8)}';
  }
  if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
    return value;
  }
  return value;
}

String currentDailyDateKey() {
  final now = DateTime.now();
  final month = now.month.toString().padLeft(2, '0');
  final day = now.day.toString().padLeft(2, '0');
  return '${now.year}-$month-$day';
}

Map<String, dynamic>? loadInitialDailyHoroscopeResult({
  required SharedPreferences preferences,
  required String zodiacKey,
}) {
  final savedDate = normalizeDailyDateKey(
    preferences.getString(horoscopeDatePreferenceKey),
  );
  final savedZodiacKey = preferences.getString(horoscopeZodiacPreferenceKey);

  if (savedDate != currentDailyDateKey() || savedZodiacKey != zodiacKey) {
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
    required this.primary,
    required this.secondary,
    required this.background,
    required this.cardColor,
    required this.textColor,
    this.isDark = false,
  });

  final String key;
  final String labelKo;
  final Color primary;
  final Color secondary;
  final Color background;
  final Color cardColor;
  final Color textColor;
  final bool isDark;

  Color get cardGradientStart =>
      Color.lerp(cardColor, Colors.white, isDark ? 0.04 : 0.22) ?? cardColor;
  Color get cardGradientEnd =>
      Color.lerp(cardColor, secondary, isDark ? 0.28 : 0.42) ?? secondary;
  Color get accent => primary;
  Color get accentSoft =>
      Color.lerp(secondary, Colors.white, isDark ? 0.04 : 0.18) ?? secondary;
  Color get textPrimary => textColor;
  Color get icon =>
      Color.lerp(primary, secondary, isDark ? 0.10 : 0.20) ?? primary;
}

class AppFontOption {
  const AppFontOption({
    required this.key,
    required this.label,
    required this.preview,
  });

  final String key;
  final String label;
  final String preview;
}

const Map<String, AppFontOption> appFontOptions = <String, AppFontOption>{
  'notoSansKr': AppFontOption(
    key: 'notoSansKr',
    label: 'Noto Sans KR',
    preview: '오늘의 한마디',
  ),
  'jua': AppFontOption(
    key: 'jua',
    label: 'Jua',
    preview: '몽글한 무드',
  ),
  'gowunDodum': AppFontOption(
    key: 'gowunDodum',
    label: 'Gowun Dodum',
    preview: '가볍고 또렷하게',
  ),
  'nanumMyeongjo': AppFontOption(
    key: 'nanumMyeongjo',
    label: 'Nanum Myeongjo',
    preview: '조용하고 감성적으로',
  ),
  'gaegu': AppFontOption(
    key: 'gaegu',
    label: 'Gaegu',
    preview: '조금 더 발랄하게',
  ),
};

TextTheme buildAppTextTheme(String fontKey, TextTheme base) {
  switch (fontKey) {
    case 'gaegu':
      return GoogleFonts.gaeguTextTheme(base);
    case 'jua':
      return GoogleFonts.juaTextTheme(base);
    case 'gowunDodum':
      return GoogleFonts.gowunDodumTextTheme(base);
    case 'nanumMyeongjo':
      return GoogleFonts.nanumMyeongjoTextTheme(base);
    case 'notoSansKr':
    default:
      return GoogleFonts.notoSansKrTextTheme(base);
  }
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
  const MorningOhasaApp({
    super.key,
    this.initialZodiacKey,
    this.initialDailyHoroscopeResult,
  });

  final String? initialZodiacKey;
  final Map<String, dynamic>? initialDailyHoroscopeResult;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appFontKeyNotifier,
      builder: (BuildContext context, String fontKey, Widget? child) {
        final baseTheme = ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF7C5CFA),
          ),
        );

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Morning Ohasa',
          theme: baseTheme.copyWith(
            textTheme: buildAppTextTheme(fontKey, baseTheme.textTheme),
            primaryTextTheme: buildAppTextTheme(
              fontKey,
              baseTheme.primaryTextTheme,
            ),
          ),
          home:
              initialZodiacKey == null
                  ? const ZodiacSelectionScreen()
                  : HomeScreen(
                      zodiacKey: initialZodiacKey!,
                      initialDailyHoroscopeResult: initialDailyHoroscopeResult,
                    ),
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.zodiacKey,
    this.initialDailyHoroscopeResult,
  });

  final String zodiacKey;
  final Map<String, dynamic>? initialDailyHoroscopeResult;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const double _cardRadius = 30;
  static const String _appShareUrl = 'https://morning-ohasa.vercel.app';

  final GlobalKey _visibleCaptureKey = GlobalKey();
  final ScreenshotController _shareCardScreenshotController =
      ScreenshotController();
  Map<String, dynamic>? _dailyHoroscopeResult;
  Map<String, Map<String, dynamic>> _remoteRankingsByZodiac =
      <String, Map<String, dynamic>>{};
  bool _isDailyHoroscopeLoading = true;
  String _selectedThemeKey = 'lavenderPink';
  String _selectedLanguageCode = 'ko';
  String _selectedFontKey = appFontKeyNotifier.value;
  bool _notificationsEnabled = false;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 7, minute: 0);
  String? _interactiveMessageOverride;
  bool _cardsVisible = false;
  late final List<double> _sparkleJitter = List<double>.generate(
    9,
    (_) => (Random().nextDouble() * 2) - 1,
  );

  AppThemeColors get _theme =>
      appThemes[_selectedThemeKey] ?? appThemes['lavenderPink']!;
  bool get _isDarkTheme => _theme.isDark;
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
      color: _theme.accentSoft.withValues(alpha: _isDarkTheme ? 0.10 : 0.14),
      blurRadius: 18,
      spreadRadius: 0.4,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: _accent.withValues(alpha: _isDarkTheme ? 0.05 : 0.08),
      blurRadius: 28,
      spreadRadius: 0.2,
      offset: const Offset(0, 10),
    ),
  ];

  List<BoxShadow> _softGlow(Color color, {double baseOpacity = 0.18}) {
    final primaryOpacity = _isDarkTheme ? baseOpacity * 0.9 : baseOpacity;

    return <BoxShadow>[
      BoxShadow(
        color: color.withValues(alpha: primaryOpacity * 0.8),
        blurRadius: 20,
        spreadRadius: 0.4,
        offset: const Offset(0, 8),
      ),
    ];
  }

  String _tr(String ko, String en) => _isEnglish ? en : ko;
  String get _formattedNotificationTime {
    final hour = _notificationTime.hour.toString().padLeft(2, '0');
    final minute = _notificationTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  ZodiacMeta get _currentZodiac =>
      zodiacMeta[widget.zodiacKey] ?? zodiacMeta['aries']!;
  List<Map<String, dynamic>> get _currentZodiacVisualItems =>
      zodiacVisualData[widget.zodiacKey] ?? zodiacVisualData['aries']!;
  int get _currentDay => DateTime.now().day;

  int _fallbackGeneratedRankForZodiac(String zodiacKey) {
    final zodiacIndex = zodiacMeta.keys.toList().indexOf(zodiacKey);
    final safeIndex = zodiacIndex == -1 ? 0 : zodiacIndex;
    return (_currentDay + safeIndex) % zodiacMeta.length + 1;
  }

  Map<String, int> get _resolvedRankingsByZodiac {
    final resolved = <String, int>{};

    for (final entry in _remoteRankingsByZodiac.entries) {
      final remoteRank = entry.value['rank'];
      if (remoteRank is int) {
        resolved[entry.key] = remoteRank;
      }
    }

    final selectedDailyRank = _dailyHoroscopeResult?['rank'];
    if (selectedDailyRank is int) {
      resolved[widget.zodiacKey] = selectedDailyRank;
    }

    for (final zodiacKey in zodiacMeta.keys) {
      resolved.putIfAbsent(
        zodiacKey,
        () => _fallbackGeneratedRankForZodiac(zodiacKey),
      );
    }

    return resolved;
  }

  int _rankForZodiac(String zodiacKey) {
    return _resolvedRankingsByZodiac[zodiacKey] ??
        _fallbackGeneratedRankForZodiac(zodiacKey);
  }

  int get _currentZodiacRank => _rankForZodiac(widget.zodiacKey);

  void _logRankConsistencyAudit(String stage) {
    final resolvedRankings = _resolvedRankingsByZodiac;
    final sourceRank = _dailyHoroscopeResult?['rank'];
    final mainRank = _currentZodiacRank;
    final modalRank = resolvedRankings[widget.zodiacKey];
    final remoteRank = _remoteRankingsByZodiac[widget.zodiacKey]?['rank'];

    debugPrint(
      '[rank-audit] $stage | date=${_todayString()} | zodiac=${widget.zodiacKey} | '
      'sourceRank=$sourceRank | remoteRank=$remoteRank | mainRank=$mainRank | '
      'modalRank=$modalRank | remoteCount=${_remoteRankingsByZodiac.length}',
    );

    assert(() {
      if (modalRank != null && mainRank != modalRank) {
        debugPrint(
          '[rank-audit] ASSERT mainRank != modalRank | '
          'zodiac=${widget.zodiacKey} | mainRank=$mainRank | modalRank=$modalRank',
        );
      }
      return true;
    }());
  }

  void _logDailyResultAudit(
    String stage, {
    Map<String, dynamic>? result,
    Map<String, Object?> extra = const <String, Object?>{},
  }) {
    debugPrint(
      '[daily-audit] $stage | now=${DateTime.now().toIso8601String()} | '
      'today=${_todayString()} | zodiac=${widget.zodiacKey} | '
      'date=${result?['date']} | rank=${result?['rank']} | '
      'message=${result?['message']} | action=${result?['action']} | '
      'extra=$extra',
    );
  }

  @override
  void initState() {
    super.initState();
    _dailyHoroscopeResult = widget.initialDailyHoroscopeResult;
    _isDailyHoroscopeLoading = widget.initialDailyHoroscopeResult == null;
    _logDailyResultAudit(
      'initState.initial_state',
      result: _dailyHoroscopeResult,
      extra: <String, Object?>{
        'hasInitialCachedResult': widget.initialDailyHoroscopeResult != null,
      },
    );
    _loadSavedTheme();
    _loadSavedLanguage();
    _loadSavedFont();
    _loadNotificationSettings();
    _loadOrCreateDailyHoroscope();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _cardsVisible = true;
      });
    });
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

  Future<void> _loadSavedFont() async {
    final preferences = await SharedPreferences.getInstance();
    final savedFontKey =
        preferences.getString(appFontPreferenceKey) ?? appFontKeyNotifier.value;

    if (!mounted || !appFontOptions.containsKey(savedFontKey)) {
      return;
    }

    setState(() {
      _selectedFontKey = savedFontKey;
    });
    appFontKeyNotifier.value = savedFontKey;
  }

  Future<void> _saveFont(String fontKey) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(appFontPreferenceKey, fontKey);
    appFontKeyNotifier.value = fontKey;
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
    return currentDailyDateKey();
  }

  int _dailySeed({int salt = 0}) {
    final now = DateTime.now();
    final zodiacIndex = zodiacMeta.keys.toList().indexOf(widget.zodiacKey);
    final safeIndex = zodiacIndex == -1 ? 0 : zodiacIndex;
    return now.year * 1000000 +
        now.month * 10000 +
        now.day * 100 +
        safeIndex * 7 +
        salt;
  }

  String _pickDailyMessage() {
    final specificMessages = zodiacSpecificMessages[widget.zodiacKey] ?? const <String>[];
    final messagePool = <String>[
      ...todayMessages,
      ...specificMessages,
    ];
    final random = Random(_dailySeed(salt: 11));
    return messagePool[random.nextInt(messagePool.length)];
  }

  List<String> _messageCandidatesForCurrentZodiac() {
    final currentMessage =
        _normalizeDisplayText(
          _interactiveMessageOverride ?? _currentDisplayResult['rawMessage'],
        );
    final candidates = <String>[
      ...todayMessages,
      ...(zodiacSpecificMessages[widget.zodiacKey] ?? const <String>[]),
    ].map(_normalizeDisplayText).where((String item) => item.isNotEmpty).toSet().toList();

    if (currentMessage.isNotEmpty && !candidates.contains(currentMessage)) {
      candidates.insert(0, currentMessage);
    }

    return candidates;
  }

  Future<void> _showAlternateTodayMessage() async {
    final candidates = _messageCandidatesForCurrentZodiac();
    final currentMessage =
        _normalizeDisplayText(
          _interactiveMessageOverride ?? _currentDisplayResult['rawMessage'],
        );
    final alternatives = candidates
        .where((String item) => item.isNotEmpty && item != currentMessage)
        .toList();

    if (alternatives.isEmpty) {
      _showDelightSnackBar(
        '오늘은 이 한마디 무드로 가도 좋아',
        'This message already fits today pretty well',
      );
      return;
    }

    final random = Random(
      DateTime.now().microsecondsSinceEpoch + widget.zodiacKey.hashCode,
    );
    final nextMessage = alternatives[random.nextInt(alternatives.length)];

    if (!mounted) {
      return;
    }

    setState(() {
      _interactiveMessageOverride = nextMessage;
    });
    _showDelightSnackBar(
      '✨ 다른 한마디로 살짝 바꿔봤어',
      '✨ Swapped in another little message',
    );
  }

  Future<void> _copyCurrentMessage() async {
    final currentMessage =
        _normalizeDisplayText(_currentDisplayResult['message']);
    await Clipboard.setData(ClipboardData(text: currentMessage));
    _showDelightSnackBar(
      '복사됨. 마음에 들면 저장해둬',
      'Copied. Keep it if it feels right',
    );
  }

  String _pickDailyAction() {
    final random = Random(_dailySeed(salt: 29));
    return actionRecommendations[
      random.nextInt(actionRecommendations.length)
    ];
  }

  Map<String, dynamic> _generateDailyHoroscope() {
    final zodiacItems = _currentZodiacVisualItems;
    final random = Random(_dailySeed());
    final selectedItem = zodiacItems[random.nextInt(zodiacItems.length)];
    final result = <String, dynamic>{
      'date': _todayString(),
      'zodiacKey': widget.zodiacKey,
      'message': _pickDailyMessage(),
      'score': selectedItem['score'],
      'action': _pickDailyAction(),
      'rank': _currentZodiacRank,
      'emoji': selectedItem['emoji'],
    };

    _logDailyResultAudit(
      'generate_local',
      result: result,
      extra: <String, Object?>{
        'seedBase': _dailySeed(),
        'messageSeed': _dailySeed(salt: 11),
        'actionSeed': _dailySeed(salt: 29),
      },
    );
    return result;
  }

  Uri _ohaasaApiUri() {
    if (kIsWeb) {
      return Uri.parse('${Uri.base.origin}/api/ohaasa');
    }

    return Uri.parse('$_appShareUrl/api/ohaasa');
  }

  Map<String, Map<String, dynamic>> _normalizeRemoteRankings(dynamic rankings) {
    if (rankings is! List) {
      return <String, Map<String, dynamic>>{};
    }

    final normalized = <String, Map<String, dynamic>>{};

    for (final dynamic item in rankings) {
      if (item is! Map) {
        continue;
      }

      final ranking = Map<String, dynamic>.from(item);
      final zodiacKey = ranking['zodiacKey'];
      if (zodiacKey is! String || zodiacKey.isEmpty) {
        continue;
      }

      normalized[zodiacKey] = ranking;
    }

    return normalized;
  }

  bool _containsJapanese(String text) {
    return RegExp(r'[\u3040-\u30ff\u3400-\u9fff]').hasMatch(text);
  }

  String _normalizeDisplayText(dynamic text) {
    if (text is! String) {
      return '';
    }

    return text
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', '\'')
        .replaceAll('&apos;', '\'')
        .replaceAll(RegExp(r'[ \t]+\n'), '\n')
        .replaceAll(RegExp(r'\n[ \t]+'), '\n')
        .replaceAll(RegExp(r'[ \t]{2,}'), ' ')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  String _fallbackKoreanMessageText() {
    final candidate = _normalizeDisplayText(_pickDailyMessage());
    return candidate.isEmpty ? '오늘은 무리하지 않고 내 페이스로 가도 좋아' : candidate;
  }

  String _fallbackKoreanActionText() {
    final candidate = _normalizeDisplayText(_pickDailyAction());
    return candidate.isEmpty ? '물 한 잔 마시기' : candidate;
  }

  String _sanitizeMessageForKoreanDisplay(
    dynamic localizedText, {
    dynamic originalText,
  }) {
    final localized = _normalizeDisplayText(localizedText);
    final original = _normalizeDisplayText(originalText);

    if (localized.isNotEmpty &&
        !_containsJapanese(localized) &&
        localized != original) {
      return localized;
    }

    debugPrint(
      '[translation-audit] message sanitized to Korean fallback | '
      'localized="$localized" | original="$original"',
    );
    return _fallbackKoreanMessageText();
  }

  String _sanitizeActionForKoreanDisplay(
    dynamic localizedText, {
    dynamic originalText,
  }) {
    final localized = _normalizeDisplayText(localizedText);
    final original = _normalizeDisplayText(originalText);

    if (localized.isNotEmpty &&
        !_containsJapanese(localized) &&
        localized != original) {
      return localized;
    }

    debugPrint(
      '[translation-audit] action sanitized to Korean fallback | '
      'localized="$localized" | original="$original"',
    );
    return _formatActionForDisplay(_fallbackKoreanActionText());
  }

  String _normalizeSourceText(dynamic text) {
    return _normalizeDisplayText(text)
        .replaceAll('◎', '좋음')
        .replaceAll('○', '무난')
        .replaceAll('△', '주의')
        .replaceAll('×', '주의')
        .replaceAll('♪', '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Set<String> _extractMeaningTags({
    required String rawMessage,
    required String rawAction,
  }) {
    final source = '${_normalizeSourceText(rawMessage)} ${_normalizeSourceText(rawAction)}';
    final tags = <String>{};

    void addTagIfMatches(String tag, List<String> keywords) {
      if (keywords.any(source.contains)) {
        tags.add(tag);
      }
    }

    addTagIfMatches('social', <String>[
      '대화', '연락', '답장', '사람', '인기', '듣', '말', '소통',
      '会話', '連絡', '人気', '聞き上手',
    ]);
    addTagIfMatches('saving', <String>[
      '절약', '지출', '금전', '통신비', '돈', '가계부',
      '節約', '金運', '通信費',
    ]);
    addTagIfMatches('rest', <String>[
      '휴식', '회복', '느긋', '천천히', '컨디션', '쉬',
      '休', 'リフレッシュ', '気楽',
    ]);
    addTagIfMatches('outing', <String>[
      '산책', '드라이브', '외출', '햇빛', '공기', '나가',
      '散歩', 'ドライブ', '外', 'テーマパーク',
    ]);
    addTagIfMatches('focus', <String>[
      '집중', '정리', '확인', '체크', '루틴', '마무리', '우선순위',
      '集中', '確認', '効率', '作業',
    ]);
    addTagIfMatches('caution', <String>[
      '주의', '실수', '조심', '흔들', '과로', '무리',
      '注意', 'ミス', '振り回', '気をつけ',
    ]);
    addTagIfMatches('good_flow', <String>[
      '좋', '기회', '흐름', '잘 풀', '찬스', '무난',
      'チャンス', '広がる', '順調',
    ]);
    addTagIfMatches('home', <String>[
      '집', '방', '책상', '정리', '꽃', '환기',
      '部屋', '花', 'レジ',
    ]);
    addTagIfMatches('food', <String>[
      '먹', '간식', '물', '차', '닭', '해조',
      '食べ', 'ひじき', '鶏肉',
    ]);

    return tags;
  }

  String _generateTodayMessageText({
    required Set<String> tags,
    required int rank,
    required int score,
  }) {
    if (rank <= 3 || score >= 90) {
      if (tags.contains('social')) {
        return '가볍게 건넨 말도\n좋은 흐름으로 이어질 수 있어';
      }
      if (tags.contains('good_flow')) {
        return '오늘은 흐름이 꽤 좋아.\n하고 싶던 걸 꺼내봐도 괜찮아';
      }
      return '기분 좋은 장면이\n생각보다 쉽게 열릴 수 있어';
    }

    if (tags.contains('caution')) {
      return '조금만 천천히 가도 돼.\n서두르지 않으면 더 깔끔해져';
    }
    if (tags.contains('focus')) {
      return '하나만 또렷하게 잡아도\n오늘 무드는 충분히 좋아져';
    }
    if (tags.contains('saving')) {
      return '사소한 선택 하나가\n오늘 컨디션을 더 가볍게 해줘';
    }
    if (tags.contains('rest')) {
      return '억지로 끌어올리지 않아도 괜찮아.\n내 리듬을 믿어봐';
    }
    if (rank >= 9 || score < 74) {
      return '오늘은 무리하지 않는 쪽이 좋아.\n페이스만 지켜도 충분해';
    }
    return '잔잔하지만 괜찮은 흐름이야.\n작은 선택이 분위기를 바꿔줄 수 있어';
  }

  String _generateActionLabel({
    required Set<String> tags,
  }) {
    if (tags.contains('saving')) {
      return '지출 한 번만 체크하기';
    }
    if (tags.contains('social')) {
      return '미뤄둔 답장 보내기';
    }
    if (tags.contains('rest')) {
      return '잠깐 숨 고르기';
    }
    if (tags.contains('outing')) {
      return '가볍게 바람 쐬기';
    }
    if (tags.contains('focus')) {
      return '중요한 일 하나만 끝내기';
    }
    if (tags.contains('home')) {
      return '책상 한 곳만 정리하기';
    }
    if (tags.contains('food')) {
      return '물 먼저 챙기기';
    }
    if (tags.contains('caution')) {
      return '서두르지 말고 한 번 더 보기';
    }
    return '오늘 페이스 먼저 챙기기';
  }

  String _generateResultInsightText({
    required Set<String> tags,
    required int rank,
    required int score,
  }) {
    if (rank <= 3 || score >= 90) {
      return '전체 흐름은 꽤 좋은 편이야.\n가볍게 밀어붙여도 괜찮아';
    }
    if (tags.contains('saving')) {
      return '무난한 흐름이지만\n지출은 조금 신경 쓰는 편이 좋아';
    }
    if (tags.contains('caution')) {
      return '기세보다 조절감이 중요해.\n사소한 실수만 줄이면 충분해';
    }
    if (tags.contains('rest')) {
      return '오늘은 회복 쪽에 점수를 줘도 좋아.\n리듬만 지켜도 괜찮아';
    }
    if (tags.contains('focus')) {
      return '한 가지에 집중할수록\n체감이 더 좋아질 수 있어';
    }
    if (rank >= 9 || score < 74) {
      return '조금 잔잔한 날이야.\n무리하지 않으면 흐름은 지켜져';
    }
    return '전반적으론 무난한 편이야.\n작은 선택이 결과를 더 예쁘게 만들어줘';
  }

  Map<String, String> _buildDisplayCopy({
    required dynamic rawMessage,
    required dynamic rawAction,
    required int rank,
    required int score,
  }) {
    final safeRawMessage = _sanitizeMessageForKoreanDisplay(rawMessage);
    final safeRawAction = _sanitizeActionForKoreanDisplay(rawAction);
    final tags = _extractMeaningTags(
      rawMessage: safeRawMessage,
      rawAction: safeRawAction,
    );

    return <String, String>{
      'rawMessage': safeRawMessage,
      'rawAction': safeRawAction,
      'message': _formatTodayMessageForDisplay(
        _generateTodayMessageText(
          tags: tags,
          rank: rank,
          score: score,
        ),
      ),
      'action': _formatActionForDisplay(
        _generateActionLabel(tags: tags),
      ),
      'insight': _formatTodayMessageForDisplay(
        _generateResultInsightText(
          tags: tags,
          rank: rank,
          score: score,
        ),
      ),
    };
  }

  List<String> _splitDisplayTextIntoChunks(
    String normalized, {
    required int targetLength,
    required int maxLines,
  }) {
    if (normalized.isEmpty) {
      return <String>[];
    }

    final preferredSeparators = <String>['\n', '. ', '? ', '! ', '· ', ' / ', ', '];

    for (final separator in preferredSeparators) {
      if (!normalized.contains(separator)) {
        continue;
      }

      final parts = normalized
          .split(separator)
          .map((String part) => part.trim())
          .where((String part) => part.isNotEmpty)
          .toList();

      if (parts.length > 1 && parts.every((String part) => part.length <= targetLength + 6)) {
        return parts.take(maxLines).toList();
      }
    }

    final tokens = normalized.split(RegExp(r'\s+')).where((String token) => token.isNotEmpty);
    final lines = <String>[];
    final buffer = StringBuffer();

    for (final token in tokens) {
      final candidate = buffer.isEmpty ? token : '${buffer.toString()} $token';
      if (candidate.length > targetLength && buffer.isNotEmpty) {
        lines.add(buffer.toString());
        buffer
          ..clear()
          ..write(token);
      } else {
        if (buffer.isNotEmpty) {
          buffer.write(' ');
        }
        buffer.write(token);
      }
    }

    if (buffer.isNotEmpty) {
      lines.add(buffer.toString());
    }

    return lines.take(maxLines).toList();
  }

  int _bestKoreanBreakIndex(String text, int minIndex, int maxIndex) {
    if (text.length <= minIndex) {
      return -1;
    }

    final safeMax = maxIndex.clamp(0, text.length - 1);
    const preferredEnds = <String>[
      ' 좋아',
      ' 괜찮아',
      ' 해봐',
      ' 해도 돼',
      ' 할 수 있어',
      ' 거야',
      ' 있어',
      ' 보자',
      ' 보자고',
      ' 먼저',
      ' 하나만',
      ' 오늘은',
      ' 지금은',
    ];

    for (final ending in preferredEnds) {
      final index = text.lastIndexOf(ending, safeMax);
      if (index >= minIndex) {
        return index + ending.length;
      }
    }

    const particles = <String>[
      ' 그리고 ',
      ' 하지만 ',
      ' 그래서 ',
      ' 지금 ',
      ' 오늘 ',
      ' 먼저 ',
      ' 조금 ',
      ' 하나만 ',
    ];

    for (final particle in particles) {
      final index = text.lastIndexOf(particle, safeMax);
      if (index >= minIndex) {
        return index + particle.length - 1;
      }
    }

    final punctuationMatches = RegExp(r'[.!?]').allMatches(text);
    for (final match in punctuationMatches.toList().reversed) {
      if (match.end >= minIndex && match.end <= safeMax + 1) {
        return match.end;
      }
    }

    final spaceIndex = text.lastIndexOf(' ', safeMax);
    if (spaceIndex >= minIndex) {
      return spaceIndex;
    }

    return -1;
  }

  String _formatTodayMessageForDisplay(String rawText) {
    final normalized = _normalizeDisplayText(rawText);
    if (normalized.isEmpty) {
      return normalized;
    }

    if (_isEnglish) {
      return _splitDisplayTextIntoChunks(
        normalized,
        targetLength: 24,
        maxLines: 3,
      ).join('\n');
    }

    if (normalized.contains('\n')) {
      final lines = normalized
          .split('\n')
          .map((String line) => line.trim())
          .where((String line) => line.isNotEmpty)
          .toList();
      return lines.take(3).join('\n');
    }

    if (normalized.length <= 16) {
      return normalized;
    }

    final compact = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
    final desiredBreak = _bestKoreanBreakIndex(compact, 10, 18);
    if (desiredBreak != -1 && desiredBreak < compact.length - 2) {
      final first = compact.substring(0, desiredBreak).trim();
      final second = compact.substring(desiredBreak).trim();
      if (first.isNotEmpty && second.isNotEmpty) {
        return '$first\n$second';
      }
    }

    final lines = _splitDisplayTextIntoChunks(
      compact,
      targetLength: 13,
      maxLines: 3,
    );
    return lines.join('\n');
  }

  String _shortenActionLabel(String text) {
    var output = text;
    const replacements = <MapEntry<String, String>>[
      MapEntry('천천히 ', ''),
      MapEntry('가볍게 ', ''),
      MapEntry('잠깐 ', ''),
      MapEntry('오늘 ', ''),
      MapEntry('먼저 ', ''),
      MapEntry('다시 ', ''),
      MapEntry('하나만 ', ''),
      MapEntry('한 줄만 ', '한 줄 '),
      MapEntry('한 군데만 ', '한 곳 '),
      MapEntry('자리에서 ', ''),
      MapEntry('좋아하는 ', ''),
      MapEntry('내일 할 일 ', '내일 일정 '),
      MapEntry('오늘 일정 ', '일정 '),
      MapEntry('머릿속 걱정 하나 ', '걱정 하나 '),
      MapEntry('편한 자세로 ', ''),
      MapEntry('달달한 간식보다 물 먼저 마시기', '물 먼저 마시기'),
      MapEntry('핸드폰 10분 내려놓기', '핸드폰 잠깐 내려놓기'),
      MapEntry('산책 10분만 다녀오기', '산책 잠깐 다녀오기'),
      MapEntry('가방이나 책상 한 군데만 정리하기', '책상 한 곳 정리하기'),
      MapEntry('메일이나 문자 하나만 처리하기', '메일 하나 처리하기'),
      MapEntry('오늘 나한테 친절한 선택 하나 하기', '나한테 친절한 선택'),
      MapEntry('오늘의 우선순위 하나만 정하기', '우선순위 하나 정하기'),
      MapEntry('오늘 한 일 하나 적어두기', '오늘 한 일 적기'),
    ];

    for (final replacement in replacements) {
      output = output.replaceAll(replacement.key, replacement.value);
    }

    return output.trim();
  }

  String _formatActionForDisplay(String rawText) {
    final normalized = _normalizeDisplayText(rawText).replaceAll('\n', ' ').trim();
    if (normalized.isEmpty) {
      return normalized;
    }

    var compact = _shortenActionLabel(normalized);
    compact = compact
        .replaceAll(RegExp(r'[.!?]+$'), '')
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .trim();

    if (compact.length <= (_isEnglish ? 30 : 18)) {
      return compact;
    }

    final lines = _splitDisplayTextIntoChunks(
      compact,
      targetLength: _isEnglish ? 16 : 10,
      maxLines: 2,
    );
    return lines.join('\n');
  }

  String _buildResultInsight({
    required int rank,
    required int score,
  }) {
    if (_isEnglish) {
      if (rank <= 3 || score >= 90) {
        return 'The vibe is bright today.\nTry leaning into what feels easy.';
      }
      if (rank <= 6 || score >= 82) {
        return 'The flow feels pretty steady.\nA small push could land well.';
      }
      if (rank <= 9 || score >= 74) {
        return 'It is a softer day.\nKeep your pace a little lighter.';
      }
      return 'The mood may feel a bit shaky.\nKeep spending and energy gentle.';
    }

    if (rank <= 3 || score >= 90) {
      return '흐름이 꽤 좋은 날이야.\n마음 가는 쪽으로 가도 좋아';
    }
    if (rank <= 6 || score >= 82) {
      return '무난하게 풀릴 가능성이 커.\n작은 시도 하나쯤은 괜찮아';
    }
    if (rank <= 9 || score >= 74) {
      return '조금 천천히 가는 편이 좋아.\n리듬만 지켜도 충분해';
    }
    return '컨디션과 지출은 살짝 아껴가자.\n오늘은 무리하지 않는 쪽이 좋아';
  }

  Widget _buildAnimatedCardEntry({
    required int index,
    required Widget child,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: _cardsVisible ? 1 : 0),
      duration: Duration(milliseconds: 210 + (index * 38)),
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double value, Widget? animatedChild) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * (18 + (index * 5))),
            child: animatedChild,
          ),
        );
      },
      child: child,
    );
  }

  String? _resolveRemoteLocalizedText({
    required Map<String, dynamic>? remoteEntry,
    required String localizedField,
    required String originalField,
  }) {
    final localized = _normalizeDisplayText(remoteEntry?[localizedField]);
    final original = _normalizeDisplayText(remoteEntry?[originalField]);

    if (localized.isEmpty) {
      debugPrint(
        '[translation-audit] $localizedField missing',
      );
      return null;
    }

    if (_containsJapanese(localized)) {
      debugPrint(
        '[translation-audit] $localizedField contains Japanese',
      );
      return null;
    }

    if (original.isNotEmpty && localized == original) {
      debugPrint(
        '[translation-audit] $localizedField equals original',
      );
      return null;
    }

    return localized;
  }

  Future<Map<String, dynamic>?> _fetchRemoteDailyHoroscope() async {
    final fallbackResult = _generateDailyHoroscope();
    final uri = _ohaasaApiUri();
    final fetchStartedAt = DateTime.now().toIso8601String();

    try {
      debugPrint(
        '[daily-audit] remote_fetch.start | at=$fetchStartedAt | '
        'cacheDate=${_todayString()} | zodiac=${widget.zodiacKey} | uri=$uri',
      );
      final response = await http
          .get(
            uri,
            headers: <String, String>{'accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 8));

      debugPrint(
        '[daily-audit] remote_fetch.status | at=$fetchStartedAt | '
        'status=${response.statusCode}',
      );
      if (response.statusCode != 200) {
        return null;
      }

      final dynamic payload = jsonDecode(response.body);
      if (payload is! Map<String, dynamic>) {
        debugPrint('_fetchRemoteDailyHoroscope: invalid payload shape');
        return null;
      }

      final remoteRankings = _normalizeRemoteRankings(payload['rankings']);
      if (remoteRankings.isEmpty) {
        debugPrint('_fetchRemoteDailyHoroscope: rankings empty');
        return null;
      }

      debugPrint(
        '[rank-audit] remote_rankings.normalized | date=${normalizeDailyDateKey(payload['date'] as String?)} | '
        'zodiac=${widget.zodiacKey} | selectedEntryRank=${remoteRankings[widget.zodiacKey]?['rank']} | '
        'count=${remoteRankings.length}',
      );

      final remoteEntry = remoteRankings[widget.zodiacKey];
      final message = _sanitizeMessageForKoreanDisplay(
        _resolveRemoteLocalizedText(
          remoteEntry: remoteEntry,
          localizedField: 'messageKo',
          originalField: 'messageJa',
        ),
        originalText: remoteEntry?['messageJa'],
      );
      final action = _sanitizeActionForKoreanDisplay(
        _resolveRemoteLocalizedText(
          remoteEntry: remoteEntry,
          localizedField: 'actionKo',
          originalField: 'actionJa',
        ),
        originalText: remoteEntry?['actionJa'],
      );
      final rank = remoteEntry?['rank'];
      final remoteDate = normalizeDailyDateKey(payload['date'] as String?);
      final result = <String, dynamic>{
        ...fallbackResult,
        'date': remoteDate.isNotEmpty
            ? remoteDate
            : fallbackResult['date'],
        'message': _sanitizeMessageForKoreanDisplay(
          message,
          originalText: remoteEntry?['messageJa'],
        ),
        'action': _sanitizeActionForKoreanDisplay(
          action,
          originalText: remoteEntry?['actionJa'],
        ),
        'rank': rank is int ? rank : fallbackResult['rank'],
        'remoteRankings': remoteRankings,
      };

      _logDailyResultAudit(
        'remote_fetch.result',
        result: result,
        extra: <String, Object?>{
          'fetchStartedAt': fetchStartedAt,
          'sourceDate': payload['date'],
          'parsedDailyDate': result['date'],
          'remoteRankingsCount': remoteRankings.length,
          'remoteEntryFound': remoteEntry != null,
          'usedRemoteMessage': message.trim().isNotEmpty,
          'usedRemoteAction': action.trim().isNotEmpty,
        },
      );

      return result;
    } catch (error, stackTrace) {
      debugPrint(
        '[daily-audit] remote_fetch.error | at=$fetchStartedAt | error=$error',
      );
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }

  Future<void> _saveDailyHoroscope(Map<String, dynamic> result) async {
    final sanitizedMessage = _sanitizeMessageForKoreanDisplay(result['message']);
    final sanitizedAction = _sanitizeActionForKoreanDisplay(result['action']);
    final persistableResult = <String, dynamic>{
      ...result,
      'message': sanitizedMessage,
      'action': sanitizedAction,
    };
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      horoscopeDatePreferenceKey,
      persistableResult['date'] as String,
    );
    await preferences.setString(
      horoscopeZodiacPreferenceKey,
      persistableResult['zodiacKey'] as String,
    );
    await preferences.setString(
      horoscopeMessagePreferenceKey,
      sanitizedMessage,
    );
    await preferences.setInt(
      horoscopeScorePreferenceKey,
      persistableResult['score'] as int,
    );
    await preferences.setString(
      horoscopeActionPreferenceKey,
      sanitizedAction,
    );
    await preferences.setInt(
      horoscopeRankPreferenceKey,
      persistableResult['rank'] as int,
    );
    await preferences.setString(
      horoscopeEmojiPreferenceKey,
      persistableResult['emoji'] as String,
    );
    _logDailyResultAudit(
      'local_cache.saved',
      result: persistableResult,
      extra: <String, Object?>{
        'cacheDate': persistableResult['date'],
      },
    );
  }

  Future<Map<String, dynamic>?> _loadSavedDailyHoroscope() async {
    final preferences = await SharedPreferences.getInstance();
    final savedDate = preferences.getString(horoscopeDatePreferenceKey);
    final savedZodiacKey = preferences.getString(horoscopeZodiacPreferenceKey);

    debugPrint(
      '[daily-audit] local_cache.load_check | now=${DateTime.now().toIso8601String()} | '
      'today=${_todayString()} | savedDate=${normalizeDailyDateKey(savedDate)} | '
      'savedZodiac=$savedZodiacKey | currentZodiac=${widget.zodiacKey}',
    );

    if (normalizeDailyDateKey(savedDate) != _todayString() ||
        savedZodiacKey != widget.zodiacKey) {
      debugPrint(
        '[daily-audit] local_cache.miss | reason=date_or_zodiac_mismatch',
      );
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
      debugPrint(
        '[daily-audit] local_cache.miss | reason=incomplete_saved_payload',
      );
      return null;
    }

    final result = <String, dynamic>{
      'date': normalizeDailyDateKey(savedDate),
      'zodiacKey': savedZodiacKey,
      'message': _sanitizeMessageForKoreanDisplay(savedMessage),
      'score': savedScore,
      'action': _sanitizeActionForKoreanDisplay(savedAction),
      'rank': savedRank,
      'emoji': savedEmoji,
    };

    _logDailyResultAudit(
      'local_cache.hit',
      result: result,
      extra: <String, Object?>{
        'cacheDate': savedDate,
        'usedCachedResult': true,
      },
    );
    return result;
  }

  Future<void> _loadOrCreateDailyHoroscope() async {
    final savedResult =
        widget.initialDailyHoroscopeResult ?? await _loadSavedDailyHoroscope();

    if (savedResult != null) {
      debugPrint(
        '[daily-audit] source_resolution | savedAvailable=true | '
        'remoteAvailable=skipped | generatedAvailable=true | winner=local_cache_locked',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _dailyHoroscopeResult = Map<String, dynamic>.from(savedResult);
        _isDailyHoroscopeLoading = false;
        _interactiveMessageOverride = null;
      });
      _logRankConsistencyAudit('local_cache_applied');

      _logDailyResultAudit(
        'ui_state.updated',
        result: _dailyHoroscopeResult,
        extra: <String, Object?>{
          'usedRemoteApiResult': false,
          'usedCachedLocalResult': true,
          'usedGeneratedLocalResult': false,
          'dedupeRule': 'cache_wins_for_same_normalized_day',
        },
      );
      return;
    }

    final remoteResult = await _fetchRemoteDailyHoroscope();
    final generatedResult = _generateDailyHoroscope();
    final result = remoteResult ?? generatedResult;
    final remoteRankings =
        remoteResult?['remoteRankings'] as Map<String, Map<String, dynamic>>? ??
        <String, Map<String, dynamic>>{};

    debugPrint(
      '[daily-audit] source_resolution | '
      'savedAvailable=false | '
      'remoteAvailable=${remoteResult != null} | '
      'generatedAvailable=true | '
      'winner=${remoteResult != null ? 'remote' : 'generated_local'}',
    );

    final persistableResult = Map<String, dynamic>.from(result)
      ..remove('remoteRankings');
    await _saveDailyHoroscope(persistableResult);

    if (!mounted) {
      return;
    }

    setState(() {
      if (remoteRankings.isNotEmpty) {
        _remoteRankingsByZodiac = remoteRankings;
      }
      _isDailyHoroscopeLoading = false;
      _interactiveMessageOverride = null;
      _dailyHoroscopeResult = Map<String, dynamic>.from(result)
        ..remove('remoteRankings');
    });
    _logRankConsistencyAudit(
      remoteRankings.isNotEmpty
          ? 'remote_result_applied'
          : 'generated_result_applied',
    );

    _logDailyResultAudit(
      'ui_state.updated',
      result: Map<String, dynamic>.from(result)..remove('remoteRankings'),
      extra: <String, Object?>{
        'usedRemoteApiResult': remoteResult != null,
        'usedCachedLocalResult': remoteResult == null && savedResult != null,
        'usedGeneratedLocalResult': remoteResult == null && savedResult == null,
        'remoteRankingsCount': remoteRankings.length,
      },
    );
  }

  Future<void> _persistAndApplyNotificationState(bool enabled) async {
    await _saveNotificationSettings();

    if (enabled) {
      await LocalNotificationService.instance.scheduleDailyNotification(
        hour: _notificationTime.hour,
        minute: _notificationTime.minute,
      );
    } else {
      await LocalNotificationService.instance.cancelDailyNotification();
    }
  }

  Future<void> _setNotificationsEnabledFromSheet(
    bool enabled,
    StateSetter modalSetState,
  ) async {
    modalSetState(() {
      _notificationsEnabled = enabled;
    });
    if (mounted) {
      setState(() {
        _notificationsEnabled = enabled;
      });
    }

    await _persistAndApplyNotificationState(enabled);

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

  Future<void> _pickNotificationTimeFromSheet(
    StateSetter modalSetState,
  ) async {
    final initialTime = _notificationTime;
    var draftHour = initialTime.hour;
    var draftMinute = initialTime.minute;
    final hourController = FixedExtentScrollController(initialItem: draftHour);
    final minuteController = FixedExtentScrollController(
      initialItem: draftMinute,
    );

    final pickedTime = await showModalBottomSheet<TimeOfDay>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter pickerSetState) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    _cardStart,
                    Color.lerp(_cardEnd, _accentSoft, 0.18) ?? _cardEnd,
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                border: Border.all(
                  color: _accentSoft.withValues(alpha: 0.92),
                ),
                boxShadow: _softGlow(_accent, baseOpacity: 0.12),
              ),
              padding: EdgeInsets.fromLTRB(
                20,
                14,
                20,
                20 + MediaQuery.of(context).viewPadding.bottom,
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: _accentSoft.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _tr('알림 시간', 'Notification Time'),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: _textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${draftHour.toString().padLeft(2, '0')} / ${draftMinute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _accent,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      height: 208,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[
                            Colors.white.withValues(alpha: _isDarkTheme ? 0.06 : 0.82),
                            _accentSoft.withValues(alpha: _isDarkTheme ? 0.08 : 0.24),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: _accentSoft.withValues(alpha: 0.78),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 52,
                            margin: const EdgeInsets.symmetric(horizontal: 18),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: <Color>[
                                  _blush.withValues(alpha: 0.68),
                                  _accentSoft.withValues(alpha: 0.36),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: _accentSoft.withValues(alpha: 0.82),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: CupertinoPicker(
                                  scrollController: hourController,
                                  itemExtent: 44,
                                  selectionOverlay: const SizedBox.shrink(),
                                  onSelectedItemChanged: (int value) {
                                    pickerSetState(() {
                                      draftHour = value;
                                    });
                                  },
                                  children: List<Widget>.generate(
                                    24,
                                    (int index) => _buildTimeWheelItem(
                                      value: index.toString().padLeft(2, '0'),
                                      isSelected: index == draftHour,
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                ':',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: _accent,
                                ),
                              ),
                              Expanded(
                                child: CupertinoPicker(
                                  scrollController: minuteController,
                                  itemExtent: 44,
                                  selectionOverlay: const SizedBox.shrink(),
                                  onSelectedItemChanged: (int value) {
                                    pickerSetState(() {
                                      draftMinute = value;
                                    });
                                  },
                                  children: List<Widget>.generate(
                                    60,
                                    (int index) => _buildTimeWheelItem(
                                      value: index.toString().padLeft(2, '0'),
                                      isSelected: index == draftMinute,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              foregroundColor: _textSecondary,
                              backgroundColor: Colors.white.withValues(
                                alpha: _isDarkTheme ? 0.05 : 0.72,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Text(
                              _tr('취소', 'Cancel'),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(
                                TimeOfDay(hour: draftHour, minute: draftMinute),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              foregroundColor: Colors.white,
                              backgroundColor: _accent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Text(
                              _tr('저장', 'Save'),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (pickedTime == null) {
      return;
    }

    modalSetState(() {
      _notificationTime = pickedTime;
    });
    if (mounted) {
      setState(() {
        _notificationTime = pickedTime;
      });
    }

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

  Widget _buildTimeWheelItem({
    required String value,
    required bool isSelected,
  }) {
    return Center(
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        style: TextStyle(
          fontSize: isSelected ? 28 : 22,
          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
          color: isSelected ? _textPrimary : _textSecondary,
          letterSpacing: -0.4,
        ),
        child: Text(value),
      ),
    );
  }

  Map<String, dynamic> get _currentDisplayResult {
    final baseResult =
        _dailyHoroscopeResult ??
        <String, dynamic>{
          'date': _todayString(),
          'zodiacKey': widget.zodiacKey,
          'message': _tr(
            '오늘 무드 불러오는 중이야...',
            'Getting today\'s vibe ready...',
          ),
          'score': 0,
          'action': _tr('잠깐만, 곧 보여줄게', 'Hold on, almost there'),
          'rank': _currentZodiacRank,
          'emoji': _currentZodiac.emoji,
        };
    final resolvedRank = _currentZodiacRank;
    final resolvedScore = (baseResult['score'] as int?) ?? 0;
    final rawMessage = _interactiveMessageOverride ?? baseResult['message'];
    final displayCopy = _buildDisplayCopy(
      rawMessage: rawMessage,
      rawAction: baseResult['action'],
      rank: resolvedRank,
      score: resolvedScore,
    );

    final resolvedResult = <String, dynamic>{
      ...baseResult,
      'rawMessage': displayCopy['rawMessage'],
      'rawAction': displayCopy['rawAction'],
      'message': displayCopy['message'],
      'action': displayCopy['action'],
      'insight': displayCopy['insight'],
      'rank': resolvedRank,
    };
    return resolvedResult;
  }

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

  void _showDelightSnackBar(String ko, String en) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor:
              Color.lerp(_cardEnd, _accentSoft, _isDarkTheme ? 0.22 : 0.46) ??
              _cardEnd,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          content: Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 18,
                color: _isDarkTheme ? Colors.white : _accent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _tr(ko, en),
                  style: TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  bool get _isIosWeb =>
      kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  Future<void> _openImageShareSheet({
    required Uint8List bytes,
    required String filename,
  }) async {
    await SharePlus.instance.share(
      ShareParams(
        files: <XFile>[
          XFile.fromData(
            bytes,
            mimeType: 'image/png',
            name: filename,
          ),
        ],
        sharePositionOrigin: _shareOriginRect(),
        downloadFallbackEnabled: false,
      ),
    );
  }

  String _buildXShareText() {
    final currentItem = _currentDisplayResult;
    final rank = (currentItem['rank'] as int?) ?? _currentZodiacRank;
    final message = (currentItem['message'] as String).replaceAll('\n', ' ').trim();
    final appLink = _appShareUrl;

    return _isEnglish
        ? 'Today’s Morning Ohasa ✨\n'
            '${_currentZodiac.nameKo} ranked #$rank today\n'
            '“$message”\n\n'
            '$appLink'
        : '오늘의 오하아사 결과 ✨\n'
            '${_currentZodiac.nameKo} 오늘 $rank위\n'
            '“$message”\n\n'
            '$appLink';
  }

  Future<void> saveCurrentScreenImage() async {
    final bytes = await _captureVisibleContent();
    if (bytes == null || !mounted) {
      return;
    }

    final filename =
        'morning_ohasa_${DateTime.now().millisecondsSinceEpoch}.png';

    try {
      debugPrint('saveCurrentScreenImage: opening share sheet for image');
      await _openImageShareSheet(bytes: bytes, filename: filename);

      if (!mounted) {
        return;
      }

      _showDelightSnackBar(
        _isIosWeb ? '✨ 저장 준비 완료! 공유 시트에서 사진으로 남겨봐' : '✨ 저장 준비 완료! 지금 바로 공유하거나 간직해봐',
        _isIosWeb
            ? '✨ Ready to save. Keep it in Photos from the share sheet'
            : '✨ Ready to save. Share it now or keep it for later',
      );
    } catch (error, stackTrace) {
      debugPrint('saveCurrentScreenImage error: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (kIsWeb) {
        try {
          debugPrint(
            'saveCurrentScreenImage: falling back to web share text only',
          );
          await SharePlus.instance.share(
            ShareParams(
              text: _tr(
                '이미지 공유가 지원되지 않는 브라우저예요. 앱 링크를 먼저 공유해볼게요 ✨\n$_appShareUrl',
                'This browser does not support image sharing. Sharing the app link instead ✨\n$_appShareUrl',
              ),
              sharePositionOrigin: _shareOriginRect(),
              downloadFallbackEnabled: false,
            ),
          );

          if (!mounted) {
            return;
          }

          _showDelightSnackBar(
            '✨ 이 브라우저에선 링크 공유로 이어서 열어줄게',
            '✨ This browser switched to a link share instead',
          );
          return;
        } catch (fallbackError, fallbackStackTrace) {
          debugPrint('saveCurrentScreenImage fallback error: $fallbackError');
          debugPrintStack(stackTrace: fallbackStackTrace);
        }
      }

      if (!mounted) {
        return;
      }

      _showDelightSnackBar(
        '이미지 공유를 열지 못했어. 한 번만 더 시도해줘',
        'Could not open the image share sheet. Try once more',
      );
    }
  }

  Future<void> shareWithShareCard() async {
    debugPrint('shareWithShareCard tapped');
    if (mounted) {
      _showDelightSnackBar(
        '✨ 공유 준비 중이야',
        '✨ Getting your share ready',
      );
    }

    try {
      final bytes = await _captureShareCardImage();
      if (bytes == null) {
        debugPrint('shareWithShareCard: capture returned null');
        if (mounted) {
          _showDelightSnackBar(
            '공유 이미지를 아직 못 만들었어',
            'Could not create the share image yet',
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
        _showDelightSnackBar(
          '공유 창을 열지 못했어',
          'Could not open the share sheet',
        );
      }
    }
  }

  Future<void> shareToX() async {
    debugPrint('shareToX tapped');

    final shareText = _buildXShareText();
    debugPrint('shareToX text: $shareText');
    final appUri = Uri.parse(
      'twitter://post?message=${Uri.encodeComponent(shareText)}',
    );
    final webUri = Uri.https(
      'twitter.com',
      '/intent/tweet',
      <String, String>{'text': shareText},
    );
    debugPrint('shareToX appUri: $appUri');
    debugPrint('shareToX webUri: $webUri');

    try {
      if (await canLaunchUrl(appUri)) {
        debugPrint('shareToX: launching app uri $appUri');
        final launched = await launchUrl(
          appUri,
          mode: LaunchMode.externalApplication,
        );
        if (launched) {
          return;
        }
        debugPrint('shareToX: app uri launch returned false');
      } else {
        debugPrint('shareToX: app uri unavailable, falling back to web');
      }

      final launchedWeb = await launchUrl(
        webUri,
        mode: LaunchMode.externalApplication,
      );
      debugPrint('shareToX: web fallback result $launchedWeb');

      if (!launchedWeb && mounted) {
        _showDelightSnackBar(
          'X 공유를 열지 못했어',
          'Could not open the X share flow',
        );
      }
    } catch (error, stackTrace) {
      debugPrint('shareToX error: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        _showDelightSnackBar(
          'X 공유를 열지 못했어',
          'Could not open the X share flow',
        );
      }
    }
  }

  Future<void> shareAppLink() async {
    debugPrint('shareAppLink tapped');
    final shareText = _tr(
      '오늘의 오하아사 앱 구경하기 ✨ $_appShareUrl',
      'Take a look at the Morning Ohasa app ✨ $_appShareUrl',
    );
    debugPrint('shareAppLink text: $shareText');
    if (mounted) {
      _showDelightSnackBar(
        '✨ 링크 공유 열어볼게',
        '✨ Opening your link share',
      );
    }

    try {
      await SharePlus.instance.share(
        ShareParams(
          text: shareText,
          sharePositionOrigin: _shareOriginRect(),
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('shareAppLink error: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        _showDelightSnackBar(
          '링크 공유를 열지 못했어',
          'Could not open the link share',
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
        width: 1.3,
      ),
      boxShadow: _cardShadow,
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
          offset: Offset(
            (8 + (_sparkleJitter[0] * 5)) * scale,
            (-4 + (_sparkleJitter[1] * 4)) * scale,
          ),
          child: Icon(
            Icons.auto_awesome_rounded,
            size: (18 + (_sparkleJitter[2] * 2)) * scale,
            color: _accentSoft.withValues(alpha: 0.88),
          ),
        ),
      ),
      Align(
        alignment: alignment,
        child: Transform.translate(
          offset: Offset(
            (-14 + (_sparkleJitter[3] * 5)) * scale,
            (8 + (_sparkleJitter[4] * 5)) * scale,
          ),
          child: Icon(
            Icons.star_rounded,
            size: (13 + (_sparkleJitter[5] * 2)) * scale,
            color: _iconColor.withValues(alpha: 0.75),
          ),
        ),
      ),
      Align(
        alignment: alignment,
        child: Transform.translate(
          offset: Offset(
            (18 + (_sparkleJitter[6] * 6)) * scale,
            (14 + (_sparkleJitter[7] * 6)) * scale,
          ),
          child: Container(
            width: (6 + _sparkleJitter[8]) * scale,
            height: (6 + _sparkleJitter[8]) * scale,
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
    _logRankConsistencyAudit('rankings_sheet.open');
    debugPrint(
      '[rank-audit] rankings_sheet.order | '
      'selectedZodiac=${widget.zodiacKey} | '
      'selectedRank=${_rankForZodiac(widget.zodiacKey)} | '
      'selectedIndex=${_rankedZodiacs.indexWhere((entry) => entry.key == widget.zodiacKey)}',
    );
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
              'font': _tr('폰트', 'Font'),
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
                          title: _tr('폰트', 'Font'),
                          subtitle: appFontOptions[_selectedFontKey]?.label ?? 'Noto Sans KR',
                          icon: Icons.text_fields_rounded,
                          onTap: () => modalSetState(() => activeSection = 'font'),
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
                      else if (activeSection == 'font') ..._buildFontSettingsContent()
                      else if (activeSection == 'language') ..._buildLanguageSettingsContent()
                      else if (activeSection == 'notification')
                        ..._buildNotificationSettingsContent(modalSetState)
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
              boxShadow: _softGlow(_accent, baseOpacity: 0.12),
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
    return <Widget>[
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Choose your vibe ✨',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: _textPrimary,
              letterSpacing: -0.3,
            ),
          ),
        ),
      ),
      SizedBox(
        height: 228,
        child: ListView.separated(
          clipBehavior: Clip.none,
          padding: const EdgeInsets.symmetric(vertical: 10),
          scrollDirection: Axis.horizontal,
          itemCount: appThemes.length,
          separatorBuilder: (BuildContext context, int index) =>
              const SizedBox(width: 12),
          itemBuilder: (BuildContext context, int index) {
            final entry = appThemes.entries.elementAt(index);
            final theme = entry.value;
            final isSelected = entry.key == _selectedThemeKey;

            return _buildThemeStoryCard(
              theme: theme,
              isSelected: isSelected,
              onTap: () async {
                setState(() {
                  _selectedThemeKey = entry.key;
                });
                await _saveTheme(entry.key);
              },
            );
          },
        ),
      ),
    ];
  }

  Widget _buildThemeStoryCard({
    required AppThemeColors theme,
    required bool isSelected,
    required Future<void> Function() onTap,
  }) {
    return AnimatedScale(
      scale: isSelected ? 1.02 : 1,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: 152,
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
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected
                    ? theme.accent.withValues(alpha: 0.95)
                    : theme.accentSoft.withValues(alpha: 0.7),
                width: isSelected ? 2 : 1.2,
              ),
              boxShadow: _softGlow(
                theme.accent,
                baseOpacity: isSelected ? 0.14 : 0.06,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 18,
                  right: 16,
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    size: 18,
                    color: theme.secondary.withValues(alpha: 0.92),
                  ),
                ),
                Positioned(
                  top: 44,
                  left: 16,
                  child: _buildThemePreviewDot(theme.primary, 16),
                ),
                Positioned(
                  top: 68,
                  left: 38,
                  child: _buildThemePreviewDot(theme.secondary, 14),
                ),
                Positioned(
                  top: 34,
                  left: 62,
                  child: _buildThemePreviewDot(theme.textColor, 10),
                ),
                Positioned(
                  bottom: 18,
                  left: 14,
                  right: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        theme.labelKo,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          height: 1.1,
                          fontWeight: FontWeight.w900,
                          color: theme.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedOpacity(
                        opacity: isSelected ? 1 : 0.72,
                        duration: const Duration(milliseconds: 180),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(
                              alpha: theme.isDark ? 0.06 : 0.18,
                            ),
                            border: Border.all(
                              color: theme.accentSoft.withValues(alpha: 0.68),
                            ),
                          ),
                          child: Icon(
                            isSelected
                                ? Icons.check_rounded
                                : Icons.arrow_forward_rounded,
                            color: theme.icon,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

Widget _buildThemePreviewDot(Color color, double size) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: color.withValues(alpha: 0.16),
          blurRadius: 4,
          spreadRadius: 0.1,
        ),
      ],
    ),
  );
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
                boxShadow: _softGlow(
                  _accent,
                  baseOpacity: isSelected ? 0.16 : 0.10,
                ),
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

  List<Widget> _buildFontSettingsContent() {
    return appFontOptions.entries.map((MapEntry<String, AppFontOption> entry) {
      final font = entry.value;
      final isSelected = entry.key == _selectedFontKey;

      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () async {
              setState(() {
                _selectedFontKey = entry.key;
              });
              await _saveFont(entry.key);
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
                  width: isSelected ? 1.7 : 1.1,
                ),
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
                      Icons.text_fields_rounded,
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
                          font.label,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          font.preview,
                          style: buildAppTextTheme(
                            entry.key,
                            Theme.of(context).textTheme,
                          ).bodyMedium?.copyWith(
                                fontSize: 14,
                                color: _textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
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

  List<Widget> _buildNotificationSettingsContent(StateSetter modalSetState) {
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
          boxShadow: _softGlow(_accent, baseOpacity: 0.12),
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
                  onChanged: (bool value) =>
                      _setNotificationsEnabledFromSheet(value, modalSetState),
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
                onTap: () => _pickNotificationTimeFromSheet(modalSetState),
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
          boxShadow: _softGlow(_accent, baseOpacity: 0.12),
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
    if (_isDailyHoroscopeLoading && _dailyHoroscopeResult == null) {
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
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: _glassCardDecoration(
                colors: <Color>[
                  Color.lerp(_cardStart, Colors.white, _isDarkTheme ? 0.04 : 0.24) ??
                      _cardStart,
                  Color.lerp(_cardEnd, _accentSoft, _isDarkTheme ? 0.10 : 0.24) ??
                      _cardEnd,
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(_accent),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _tr('오늘의 오하아사 불러오는 중...', 'Loading today\'s Ohasa...'),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

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
                    child: _PressableScale(
                      borderRadius: BorderRadius.circular(999),
                      onTap: _showSettingsSheet,
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
                          boxShadow: _softGlow(_accent, baseOpacity: 0.14),
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
            SafeArea(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final content = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildResultCards(today, currentItem),
                      const SizedBox(height: 9),
                      _buildUtilityButtons(),
                    ],
                  );

                  final framedContent = Padding(
                    padding: const EdgeInsets.fromLTRB(16, 34, 16, 8),
                    child: kIsWeb
                        ? Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 460),
                            child: content,
                          ),
                        )
                        : content,
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
              child: RepaintBoundary(
                key: _visibleCaptureKey,
                child: SizedBox(
                  width: 460,
                  child: _buildExportCaptureSection(today, currentItem),
                ),
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

  Widget _buildResultCards(DateTime today, Map<String, dynamic> currentItem) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAnimatedCardEntry(
          index: 0,
          child: _buildHeader(today, currentItem['emoji'] as String),
        ),
        const SizedBox(height: 8),
        _buildAnimatedCardEntry(
          index: 1,
          child: _buildRankCard(),
        ),
        const SizedBox(height: 9),
        _buildAnimatedCardEntry(
          index: 2,
          child: _buildMessageCard(currentItem['message'] as String),
        ),
        const SizedBox(height: 9),
        _buildAnimatedCardEntry(
          index: 3,
          child: SizedBox(
            height: 184,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
          ),
        ),
      ],
    );
  }

  Widget _buildExportCaptureSection(
    DateTime today,
    Map<String, dynamic> currentItem,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 26, 18, 24),
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
        borderRadius: BorderRadius.circular(36),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -26,
            right: -18,
            child: Container(
              width: 148,
              height: 148,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[
                    _blush.withValues(alpha: 0.58),
                    _blush.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: -34,
            top: 132,
            child: Container(
              width: 124,
              height: 124,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[
                    _accentSoft.withValues(alpha: 0.28),
                    _accentSoft.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 18,
            bottom: 42,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 24,
              color: _accentSoft.withValues(alpha: 0.82),
            ),
          ),
          Positioned(
            left: 22,
            bottom: 84,
            child: Icon(
              Icons.star_rounded,
              size: 18,
              color: _iconColor.withValues(alpha: 0.72),
            ),
          ),
          _buildResultCards(today, currentItem),
        ],
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
    final displayedRank = _currentZodiacRank;
    final score = (_currentDisplayResult['score'] as int?) ?? 0;
    final insight =
        (_currentDisplayResult['insight'] as String?) ??
        _buildResultInsight(
          rank: displayedRank,
          score: score,
        );

    return _PressableScale(
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
              ..._buildSparkleCluster(
                alignment: Alignment.centerRight,
                scale: 0.8,
              ),
              ..._buildSparkleCluster(
                alignment: Alignment.centerLeft,
                scale: 0.55,
              ),
              Column(
                children: [
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
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 2, right: 24),
                    child: Text(
                      insight,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.34,
                        color: _textSecondary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.15,
                      ),
                    ),
                  ),
                ],
              ),
            ],
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
    final displayMessage =
        (_currentDisplayResult['message'] as String?) ??
        _formatTodayMessageForDisplay(message);

    return _PressableScale(
      borderRadius: BorderRadius.circular(_cardRadius),
      onTap: _showAlternateTodayMessage,
      onLongPress: _copyCurrentMessage,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
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
                      ..._softGlow(_accent, baseOpacity: 0.10),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 278),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.08),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          displayMessage,
                          key: ValueKey<String>(displayMessage),
                          textAlign: TextAlign.center,
                          textWidthBasis: TextWidthBasis.longestLine,
                          maxLines: 3,
                          overflow: TextOverflow.visible,
                          style: TextStyle(
                            fontSize: _isEnglish ? 19 : 20,
                            height: _isEnglish ? 1.38 : 1.56,
                            fontWeight: FontWeight.w800,
                            color: _textPrimary,
                            letterSpacing: _isEnglish ? -0.18 : -0.48,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _tr(
                    '탭해서 다른 한마디 보기',
                    'Tap to see another little message',
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.2,
                    color: _textSecondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.12,
                  ),
                ),
              ],
            ),
          ],
        ),
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _tr('오늘 점수', 'Today\'s Score'),
                style: TextStyle(
                  fontSize: 12,
                  color: _textSecondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Center(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(10, 12, 10, 14),
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          _isDarkTheme
                              ? Colors.white.withValues(alpha: 0.06)
                              : Colors.white.withValues(alpha: 0.92),
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
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 4),
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
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String action) {
    final displayAction =
        (_currentDisplayResult['action'] as String?) ??
        _formatActionForDisplay(action);

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              boxShadow: _softGlow(_accent, baseOpacity: 0.12),
            ),
            child: Icon(
              Icons.wb_sunny_rounded,
              size: 22,
              color: _iconColor,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Center(
              child: Text(
                displayAction,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: _isEnglish ? 14 : 15,
                  height: _isEnglish ? 1.3 : 1.36,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary,
                  letterSpacing: _isEnglish ? -0.1 : -0.22,
                ),
              ),
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
          icon: Icons.ios_share,
          tooltip: _tr('이미지 저장/공유', 'Save / Share Image'),
          onTap: saveCurrentScreenImage,
          accent: _sky,
        ),
        _buildUtilityButton(
          icon: null,
          tooltip: _tr('공유하기', 'Share to X'),
          onTap: shareToX,
          accent: _blush,
        ),
        _buildUtilityButton(
          icon: Icons.reply_all_rounded,
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
    final isXButton = tooltip == '공유하기' || tooltip == 'Share to X';
    final iconColor =
        isXButton ? Colors.white : _iconColor;

    return Tooltip(
      message: tooltip,
      child: _PressableScale(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
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
              ..._softGlow(accent, baseOpacity: 0.16),
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
                                  alpha: _isDarkTheme ? 0.10 : 0.28,
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
                          width: 38,
                          height: 38,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: <Color>[
                                Colors.white.withValues(
                                  alpha: _isDarkTheme ? 0.18 : 0.48,
                                ),
                                accent.withValues(alpha: _isDarkTheme ? 0.96 : 0.90),
                              ],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(
                                alpha: _isDarkTheme ? 0.34 : 0.72,
                              ),
                              width: 1.2,
                            ),
                            boxShadow: <BoxShadow>[
                              ..._softGlow(accent, baseOpacity: 0.14),
                              BoxShadow(
                                color: Colors.white.withValues(
                                  alpha: _isDarkTheme ? 0.10 : 0.16,
                                ),
                                blurRadius: 10,
                                spreadRadius: 0.4,
                              ),
                            ],
                          ),
                          child: Container(
                            width: 24,
                            height: 24,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(
                                alpha: _isDarkTheme ? 0.12 : 0.20,
                              ),
                            ),
                            child: Text(
                              'X',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: iconColor,
                                height: 1,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                        )),
            ],
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

class _PressableScale extends StatefulWidget {
  const _PressableScale({
    required this.child,
    required this.onTap,
    required this.borderRadius,
    this.onLongPress,
  });

  final Widget child;
  final FutureOr<void> Function() onTap;
  final BorderRadius borderRadius;
  final VoidCallback? onLongPress;

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.96 : 1,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutBack,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => unawaited(Future<void>.sync(widget.onTap)),
          onLongPress: widget.onLongPress,
          onHighlightChanged: (bool value) {
            if (_pressed == value) {
              return;
            }
            setState(() {
              _pressed = value;
            });
          },
          borderRadius: widget.borderRadius,
          child: widget.child,
        ),
      ),
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
