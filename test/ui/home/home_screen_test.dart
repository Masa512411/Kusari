import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kusari/database/database.dart';
import 'package:kusari/providers/database_provider.dart';
import 'package:kusari/repositories/habit_repository.dart';
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

  testWidgets('カードのどこを長押しドラッグしても表示順が入れ替わる', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    for (final name in ['習慣A', '習慣B']) {
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), name);
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();
    }

    expect(
      tester.getTopLeft(find.text('習慣A')).dy <
          tester.getTopLeft(find.text('習慣B')).dy,
      isTrue,
    );

    // アイコンではなく習慣名（カード本体）を起点に長押し→ドラッグする。
    final from = tester.getCenter(find.text('習慣A'));
    final to = tester.getCenter(find.text('習慣B'));

    final gesture = await tester.startGesture(from);
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 100));

    final delta = (to - from) + const Offset(0, 40);
    const steps = 10;
    for (var i = 0; i < steps; i++) {
      await gesture.moveBy(delta / steps.toDouble());
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(find.text('習慣B')).dy <
          tester.getTopLeft(find.text('習慣A')).dy,
      isTrue,
    );
  });

  testWidgets('アーカイブ済みの習慣はホームに表示されない', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    final repository = HabitRepository(db);
    await repository.addHabit('表示される習慣');
    await repository.addHabit('アーカイブ済み習慣');
    final archivedId = (await repository.getHabits())
        .firstWhere((h) => h.name == 'アーカイブ済み習慣')
        .id;
    await repository.setArchived(archivedId, true);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('表示される習慣'), findsOneWidget);
    expect(find.text('アーカイブ済み習慣'), findsNothing);
  });

  testWidgets('AppBarのアイコンからアーカイブ一覧画面に遷移する', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.archive_outlined));
    await tester.pumpAndSettle();

    expect(find.text('アーカイブ済み'), findsOneWidget);
  });

  testWidgets('詳細画面からアーカイブして保存するとホームまで戻る', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '筋トレ');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('筋トレ'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(SwitchListTile));
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.text('習慣がまだありません'), findsOneWidget);
  });

  testWidgets('アーカイブ一覧から編集して保存するとアーカイブ一覧に戻る（ホームに飛ばない）', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '休止中の習慣');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('休止中の習慣'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SwitchListTile));
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.archive_outlined));
    await tester.pumpAndSettle();

    await tester.tap(find.text('休止中の習慣'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(find.text('アーカイブ済み'), findsOneWidget);
  });
}
