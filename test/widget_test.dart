import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kusari/database/database.dart';
import 'package:kusari/main.dart';
import 'package:kusari/providers/database_provider.dart';

void main() {
  testWidgets('アプリを起動するとホーム画面が表示される', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(
            AppDatabase(NativeDatabase.memory()),
          ),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('kusari'), findsOneWidget);
    expect(find.text('習慣がまだありません'), findsOneWidget);
  });
}
