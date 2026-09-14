class Date implements Comparable<Date> {
  final int epochDay;

  const Date(this.epochDay);

  factory Date.fromLocal(DateTime dt) => Date(
    DateTime.utc(dt.year, dt.month, dt.day).millisecondsSinceEpoch ~/
        Duration.millisecondsPerDay,
  );

  factory Date.today() => Date.fromLocal(DateTime.now());

  Date get previous => Date(epochDay - 1);
  Date get next => Date(epochDay + 1);

  bool operator <=(Date other) => epochDay <= other.epochDay;

  @override
  int compareTo(Date other) => epochDay.compareTo(other.epochDay);

  @override
  bool operator ==(Object other) => other is Date && other.epochDay == epochDay;

  @override
  int get hashCode => epochDay.hashCode;
}
