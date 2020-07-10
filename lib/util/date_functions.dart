bool compareDates(DateTime a, DateTime b) {
  if (a == null || b == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

bool thisWeek(DateTime a) {
  var now = DateTime.now();
  int startWeek = now.subtract(Duration(days: now.weekday - 1)).day;
  int endWeek = now.add(Duration(days: 7 - now.weekday)).day;
  // print("$startWeek - $endWeek / ${a.day}");
  return now.year == a.year &&
      now.month == a.month &&
      a.day >= startWeek &&
      a.day <= endWeek;
}

List<DateTime> getCurrentWeek() {
  List<DateTime> week = [];

  DateTime now = DateTime.now();
  DateTime startWeek = now.subtract(Duration(days: now.weekday - 1));

  for (var i = 0; i < 7; ++i) {
    week.add(startWeek.add(Duration(days: i)));
  }

  return week;
}
