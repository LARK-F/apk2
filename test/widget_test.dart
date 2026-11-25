import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:essay/main.dart';

void main() {
  testWidgets('封面显示书名', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(const EssayApp());
    await tester.pump();

    expect(find.text('随笔'), findsOneWidget);
  });
}
