import 'package:kusari/models/date.dart';

class Habit {
  final String id;
  final String name;
  final Date createdAt;
  final bool archived;
  final int sortOrder;

  Habit({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.archived,
    required this.sortOrder,
  });
}
