import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kusari/providers/database_provider.dart';
import 'package:kusari/repositories/habit_repository.dart';

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return HabitRepository(ref.watch(appDatabaseProvider));
});
