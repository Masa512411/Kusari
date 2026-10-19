import 'package:drift/drift.dart';
import 'package:kusari/database/database.dart' as d;
import 'package:kusari/logic/edit_window.dart';
import 'package:kusari/models/date.dart';
import 'package:kusari/models/habit.dart';

class EditWindowViolation implements Exception {
  final String message;
  const EditWindowViolation(this.message);

  @override
  String toString() => 'EditWindowViolation: $message';
}

class DeletedHabit {
  final Habit habit;
  final Set<Date> completions;
  const DeletedHabit(this.habit, this.completions);
}

class HabitRepository {
  final d.AppDatabase _db;

  HabitRepository(this._db);

  Future<void> addHabit(String name) async {
    final rows = await _db.select(_db.habits).get();
    final nextSortOrder = rows.isEmpty
        ? 0
        : rows.map((r) => r.sortOrder).reduce((a, b) => a > b ? a : b) + 1;

    await _db
        .into(_db.habits)
        .insert(
          d.HabitsCompanion.insert(
            id: _generateId(),
            name: name,
            createdAt: Date.today().epochDay,
            sortOrder: nextSortOrder,
          ),
        );
  }

  Future<List<Habit>> getHabits({bool includeArchived = false}) async {
    final query = _db.select(_db.habits)
      ..orderBy([(h) => OrderingTerm.asc(h.sortOrder)]);
    if (!includeArchived) {
      query.where((h) => h.archived.equals(false));
    }
    final rows = await query.get();
    return rows.map(_toDomain).toList();
  }

  Future<void> renameHabit(String habitId, String name) async {
    await (_db.update(_db.habits)..where((h) => h.id.equals(habitId))).write(
      d.HabitsCompanion(name: Value(name)),
    );
  }

  Future<void> setArchived(String habitId, bool archived) async {
    await (_db.update(_db.habits)..where((h) => h.id.equals(habitId))).write(
      d.HabitsCompanion(archived: Value(archived)),
    );
  }

  Future<void> reorderHabits(List<String> orderedHabitIds) async {
    await _db.transaction(() async {
      for (var i = 0; i < orderedHabitIds.length; i++) {
        await (_db.update(_db.habits)..where((h) => h.id.equals(orderedHabitIds[i])))
            .write(d.HabitsCompanion(sortOrder: Value(i)));
      }
    });
  }

  Future<DeletedHabit> deleteHabit(String habitId) async {
    final habit = (await getHabits(
      includeArchived: true,
    )).firstWhere((h) => h.id == habitId);
    final completions = await getCompletions(habitId);

    await (_db.delete(_db.habits)..where((h) => h.id.equals(habitId))).go();

    return DeletedHabit(habit, completions);
  }

  Future<void> undoDelete(DeletedHabit deleted) async {
    await _db
        .into(_db.habits)
        .insert(
          d.HabitsCompanion.insert(
            id: deleted.habit.id,
            name: deleted.habit.name,
            createdAt: deleted.habit.createdAt.epochDay,
            sortOrder: deleted.habit.sortOrder,
            archived: Value(deleted.habit.archived),
          ),
        );

    for (final date in deleted.completions) {
      await _db
          .into(_db.completions)
          .insert(
            d.CompletionsCompanion.insert(
              habitId: deleted.habit.id,
              date: date.epochDay,
            ),
          );
    }
  }

  Future<void> toggleCompletion(String habitId, Date date, Date today) async {
    if (!isEditable(date, today)) {
      throw EditWindowViolation(
        '$date is outside the editable window for $today',
      );
    }

    final existing = await (_db.select(_db.completions)..where(
          (c) => c.habitId.equals(habitId) & c.date.equals(date.epochDay),
        ))
        .getSingleOrNull();

    if (existing != null) {
      await (_db.delete(_db.completions)..where(
            (c) => c.habitId.equals(habitId) & c.date.equals(date.epochDay),
          ))
          .go();
    } else {
      await _db
          .into(_db.completions)
          .insert(
            d.CompletionsCompanion.insert(habitId: habitId, date: date.epochDay),
          );
    }
  }

  Future<Set<Date>> getCompletions(String habitId) async {
    final rows = await (_db.select(
      _db.completions,
    )..where((c) => c.habitId.equals(habitId))).get();
    return rows.map((r) => Date(r.date)).toSet();
  }

  Habit _toDomain(d.Habit row) => Habit(
    id: row.id,
    name: row.name,
    createdAt: Date(row.createdAt),
    archived: row.archived,
    sortOrder: row.sortOrder,
  );

  String _generateId() => DateTime.now().microsecondsSinceEpoch.toString();
}
