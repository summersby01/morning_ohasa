import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';

class ZodiacSelectionScreen extends StatelessWidget {
  const ZodiacSelectionScreen({super.key});

  static const Color _background = Color(0xFFF9F4FF);
  static const Color _textPrimary = Color(0xFF33254F);
  static const Color _textSecondary = Color(0xFF7B6D9B);
  static const Color _softAccent = Color(0xFFECE3FF);
  static const Color _blush = Color(0xFFFFE2F4);

  @override
  Widget build(BuildContext context) {
    final zodiacEntries = zodiacMeta.entries.toList();

    return Scaffold(
      backgroundColor: _background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8F1FF),
              Color(0xFFFFFCFF),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        _softAccent,
                        _blush,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 24,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    size: 30,
                    color: Color(0xFF8C7BFF),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  '별자리를 선택해줘 ✨',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '너에게 맞는 오늘을 준비할게',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _textSecondary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 28),
                Expanded(
                  child: GridView.builder(
                    itemCount: zodiacEntries.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.86,
                        ),
                    itemBuilder: (BuildContext context, int index) {
                      final entry = zodiacEntries[index];
                      final meta = entry.value;

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () async {
                            final preferences =
                                await SharedPreferences.getInstance();
                            await preferences.setString(
                              zodiacPreferenceKey,
                              entry.key,
                            );

                            if (!context.mounted) {
                              return;
                            }

                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute<void>(
                                builder: (_) => HomeScreen(zodiacKey: entry.key),
                              ),
                            );
                          },
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: <Color>[
                                  Color(0xFFFFFCFF),
                                  Color(0xFFF4ECFF),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFFEAD9FF),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x14000000),
                                  blurRadius: 24,
                                  offset: Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: <Color>[
                                        Color(0xFFE8DDFF),
                                        Color(0xFFFFE7F6),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Icon(
                                    zodiacIconData(entry.key),
                                    size: 28,
                                    color: const Color(0xFF8C7BFF),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  meta.nameKo,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: _textPrimary,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _zodiacSubtitle(entry.key),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _zodiacSubtitle(String zodiacKey) {
    switch (zodiacKey) {
      case 'aries':
        return 'sun vibe';
      case 'taurus':
        return 'calm mood';
      case 'gemini':
        return 'spark talk';
      case 'cancer':
        return 'night glow';
      case 'leo':
        return 'star power';
      case 'virgo':
        return 'soft plan';
      case 'libra':
        return 'balance day';
      case 'scorpio':
        return 'bold pulse';
      case 'sagittarius':
        return 'free path';
      case 'capricorn':
        return 'steady rise';
      case 'aquarius':
        return 'fresh wave';
      case 'pisces':
        return 'dream flow';
      default:
        return 'daily mood';
    }
  }
}
