import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:morning_ohasa/main.dart';

void main() {
  testWidgets('renders the morning ohasa home screen', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(
          zodiacKey: 'aries',
          initialDailyHoroscopeResult: <String, dynamic>{
            'date': '2026-03-21',
            'zodiacKey': 'aries',
            'message': '테스트 메시지',
            'score': 88,
            'action': '테스트 액션',
            'rank': 6,
            'emoji': '✨',
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('오늘의 오하아사'), findsWidgets);
  });
}
