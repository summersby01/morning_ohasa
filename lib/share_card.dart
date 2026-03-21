import 'package:flutter/material.dart';

class ShareCard extends StatelessWidget {
  const ShareCard({
    super.key,
    required this.zodiacName,
    required this.isEnglish,
    required this.zodiacIcon,
    required this.rank,
    required this.message,
    required this.score,
    required this.action,
    required this.backgroundStart,
    required this.backgroundEnd,
    required this.accent,
    required this.accentSoft,
    required this.textPrimary,
    required this.textSecondary,
  });

  final String zodiacName;
  final bool isEnglish;
  final IconData zodiacIcon;
  final int rank;
  final String message;
  final int score;
  final String action;
  final Color backgroundStart;
  final Color backgroundEnd;
  final Color accent;
  final Color accentSoft;
  final Color textPrimary;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            backgroundStart,
            Color.lerp(backgroundStart, accentSoft, 0.35) ?? backgroundStart,
            backgroundEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: accent.withValues(alpha: 0.16),
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
        ],
        border: Border.all(
          color: accentSoft,
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.82),
                ),
                alignment: Alignment.center,
                child: Icon(
                  zodiacIcon,
                  size: 24,
                  color: accent,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEnglish
                          ? '$zodiacName today #$rank'
                          : '$zodiacName 오늘 $rank위',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: textPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEnglish ? 'Today\'s Ohasa' : '오늘의 오하아사',
                      style: TextStyle(
                        fontSize: 13,
                        color: textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                isEnglish ? 'Today\'s Message' : '오늘의 한마디',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25,
              height: 1.42,
              fontWeight: FontWeight.w800,
              color: textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _InfoBox(
                  label: isEnglish ? 'Today\'s Score' : '오늘 점수',
                  value: '$score',
                  accentSoft: accentSoft,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoBox(
                  label: isEnglish ? 'Suggested Action' : '추천 행동',
                  value: action,
                  accentSoft: accentSoft,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            isEnglish
                ? 'Morning Ohasa ✦ Save today\'s result'
                : 'Morning Ohasa ✦ 오늘의 운세를 저장해보세요',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({
    required this.label,
    required this.value,
    required this.accentSoft,
    required this.textPrimary,
    required this.textSecondary,
  });

  final String label;
  final String value;
  final Color accentSoft;
  final Color textPrimary;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentSoft,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              height: 1.25,
              color: textPrimary,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
