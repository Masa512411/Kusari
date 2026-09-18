import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kusari/database/database.dart';
import 'package:kusari/providers/database_provider.dart';
import 'package:kusari/ui/home/home_screen.dart';

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  Widget buildApp() {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(
          AppDatabase(NativeDatabase.memory()),
        ),
      ],
      child: const MaterialApp(home: HomeScreen()),
    );
  }

  testWidgets('習慣が0件のとき空状態メッセージが表示される', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('習慣がまだありません'), findsOneWidget);
  });

  testWidgets('FABから習慣を追加すると一覧に現れる', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '筋トレ');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(find.text('筋トレ'), findsOneWidget);
  });

  testWidgets('トグルボタンをタップすると今日のストリークが更新される', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '筋トレ');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(find.text('0'), findsOneWidget);
    expect(find.text('タップして完了'), findsOneWidget);

    await tester.tap(find.text('タップして完了'));
    await tester.pumpAndSettle();

    expect(find.text('1'), findsOneWidget);
    expect(find.text('達成済み'), findsOneWidget);
  });

  testWidgets('カードをタップすると習慣詳細画面に遷移する', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '筋トレ');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('筋トレ'));
    await tester.pumpAndSettle();

    expect(find.text('過去最長: 0'), findsOneWidget);
  });

  testWidgets('直近7日分の曜日ラベルが表示される', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '筋トレ');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    for (final label in ['月', '火', '水', '木', '金', '土', '日']) {
      expect(find.text(label), findsWidgets);
    }
  });
}
