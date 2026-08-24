int currentStreak(List<DateTime> completionDates, DateTime today) {
  final todayDate = DateTime(today.year, today.month, today.day);

  final dates = completionDates
      .map((d) => DateTime(d.year, d.month, d.day))
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
