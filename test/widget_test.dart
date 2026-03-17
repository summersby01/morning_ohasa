import 'package:flutter_test/flutter_test.dart';

import 'package:morning_ohasa/main.dart';

void main() {
  testWidgets('renders the morning ohasa home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const HomeScreen(selectedZodiac: 'Aries'));

    expect(find.text('오늘의 오하아사'), findsOneWidget);
    expect(find.text('다시 뽑기'), findsOneWidget);
    expect(find.text('오늘 기록하기'), findsOneWidget);
  });
}
