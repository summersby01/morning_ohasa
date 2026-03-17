import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';

class ZodiacSelectionScreen extends StatelessWidget {
  const ZodiacSelectionScreen({super.key});

  static const Color _background = Color(0xFFF9F4FF);
  static const Color _cardBackground = Colors.white;
  static const Color _textPrimary = Color(0xFF33254F);
  static const Color _textSecondary = Color(0xFF7B6D9B);
  static const Color _softAccent = Color(0xFFECE3FF);

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
                    color: _softAccent,
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
                  child: const Text(
                    '✨',
                    style: TextStyle(fontSize: 30),
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
                              color: _cardBackground,
                              borderRadius: BorderRadius.circular(24),
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
                                Text(
                                  meta.emoji,
                                  style: const TextStyle(fontSize: 30),
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
}
