import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:essay/models/essay.dart';
import 'package:essay/pages/edit_page.dart';
import 'package:essay/storage/essay_store.dart';

void main() {
  test('存储层单测', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EssayStore().upsert(
      const Essay(dateKey: '2026-11-26', text: '存储层直写'),
    );
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('essays'), contains('存储层直写'));
  });

  testWidgets('返回箭头退出后写入 essays', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const EditPage(dateKey: '2026-11-26'),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '今天写了第一行');
    await tester.pump();

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('essays'), contains('今天写了第一行'));
  });

  testWidgets('系统返回（dispose）也会写入 essays', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const EditPage(dateKey: '2026-11-26'),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '系统返回也要保存');
    await tester.pump();

    // 模拟系统返回：直接移除整棵页面树，触发 dispose。
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('essays'), contains('系统返回也要保存'));
  });
}
