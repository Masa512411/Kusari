Set<DateTime> _toDateSet(List<DateTime> dates) =>
    dates.map((d) => DateTime(d.year, d.month, d.day)).toSet();

int currentStreak(List<DateTime> completionDates, DateTime today) {
  final todayDate = DateTime(today.year, today.month, today.day);
  final dates = _toDateSet(completionDates)
      .where((d) => !d.isAfter(todayDate))
      .toSet();

  // 猶予ルール: 今日が未達成でも昨日が達成なら昨日を起点にする
  final DateTime cursor;
  if (dates.contains(todayDate)) {
    cursor = todayDate;
  } else {
    final yesterday = todayDate.subtract(const Duration(days: 1));
    if (dates.contains(yesterday)) {
      cursor = yesterday;
    } else {
      return 0;
    }
  }

  var current = cursor;
  var count = 0;
  while (dates.contains(current)) {
    count++;
    current = current.subtract(const Duration(days: 1));
  }
  return count;
}

int longestStreak(List<DateTime> completionDates) {
  final dates = _toDateSet(completionDates);

  if (dates.isEmpty) {
    return 0;
  }

  final sortedDates = dates.toList()..sort();
  var longest = 1;
  var currentStreak = 1;

  for (var i = 1; i < sortedDates.length; i++) {
    final previousDate = sortedDates[i - 1];
    final currentDate = sortedDates[i];

    if (currentDate.difference(previousDate).inDays == 1) {
      currentStreak++;
    } else {
      longest = currentStreak > longest ? currentStreak : longest;
      currentStreak = 1;
    }
  }

  return currentStreak > longest ? currentStreak : longest;
}

int totalCompletions(List<DateTime> completionDates) =>
    _toDateSet(completionDates).length;
