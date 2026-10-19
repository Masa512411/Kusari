import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kusari/database/database.dart';
import 'package:kusari/providers/database_provider.dart';
import 'package:kusari/ui/app_shell.dart';

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
      child: const MaterialApp(home: AppShell()),
    );
  }

  testWidgets('初期状態はホームタブが表示される', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('kusari'), findsOneWidget);
    expect(find.text('習慣がまだありません'), findsOneWidget);
  });

  testWidgets('統計タブをタップすると統計画面に切り替わる', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('統計'));
    await tester.pumpAndSettle();

    expect(find.text('達成状況'), findsOneWidget);
  });
}
