bool compareDates(DateTime a, DateTime b) {
  if (a == null || b == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

bool thisWeek(DateTime a) {
  var now = DateTime.now();
  var startWeek = now.subtract(Duration(days: now.weekday - 1));
  var endWeek = now.add(Duration(days: 7 - now.weekday));
  // print("$startWeek - $endWeek / ${a.day}");
  return a.isAfter(startWeek.subtract(Duration(days: 1))) &&
      a.isBefore(endWeek.add(Duration(days: 1)));
}

bool nextWeek(DateTime a) {
  var now = DateTime.now().add(Duration(days: 7));
  var startWeek = now.subtract(Duration(days: now.weekday - 1));
  var endWeek = now.add(Duration(days: 7 - now.weekday));
  // print("$startWeek - $endWeek / ${a.day}");
  return a.isAfter(startWeek.subtract(Duration(days: 1))) &&
      a.isBefore(endWeek.add(Duration(days: 1)));
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

List<DateTime> getNextWeek() {
  List<DateTime> week = [];

  DateTime now = DateTime.now().add(Duration(days: 7));
  DateTime startWeek = now.subtract(Duration(days: now.weekday - 1));

  for (var i = 0; i < 7; ++i) {
    week.add(startWeek.add(Duration(days: i)));
  }

  return week;
}
