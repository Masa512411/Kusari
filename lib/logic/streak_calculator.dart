import 'package:kusari/models/date.dart';

int currentStreak(Set<Date> completions, Date today) {
  final valid = completions.where((d) => d <= today).toSet();
  var cursor = valid.contains(today) ? today : today.previous;

  var count = 0;
  while (valid.contains(cursor)) {
    count++;
    cursor = cursor.previous;
  }
  return count;
}

int longestStreak(Set<Date> completions, Date today) {
  final valid = completions.where((d) => d <= today).toList()..sort();

  if (valid.isEmpty) {
    return 0;
  }

  var longest = 1;
  var run = 1;

  for (var i = 1; i < valid.length; i++) {
    if (valid[i].epochDay - valid[i - 1].epochDay == 1) {
      run++;
    } else {
      longest = run > longest ? run : longest;
      run = 1;
    }
  }

  return run > longest ? run : longest;
}

int totalCompletions(Set<Date> completions, Date today) =>
    completions.where((d) => d <= today).length;
