bool compareDates(DateTime a, DateTime b) {
  if (a == null || b == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

bool thisWeek(DateTime a) {
  var now = DateTime.now();
  var moment = DateTime(now.year, now.month, now.day, 1, 0, 0);
  var startWeek = moment.subtract(Duration(days: moment.weekday - 1));
  var endWeek =
      moment.add(Duration(days: 7 - moment.weekday, hours: 22, minutes: 59));
  // print("$startWeek - $endWeek / ${a.day}");
  return a.isAfter(startWeek) && a.isBefore(endWeek);
}

bool nextWeek(DateTime a) {
  var now = DateTime.now().add(Duration(days: 7));
  var moment = DateTime(now.year, now.month, now.day, 1, 0, 0);
  var startWeek = moment.subtract(Duration(days: moment.weekday - 1));
  var endWeek =
      moment.add(Duration(days: 7 - moment.weekday, hours: 22, minutes: 59));
  // print("$startWeek - $endWeek / ${a.day}");
  return a.isAfter(startWeek) && a.isBefore(endWeek);
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
