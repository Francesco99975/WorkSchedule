import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../db/database_provider.dart';
import '../models/shift.dart';

List<Shift> parseShifts(String enc) {
  var parsedData = jsonDecode(enc) as List;
  return parsedData.map((el) {
    return Shift.fromJson(el);
  }).toList();
}

class Employee {
  int id;
  String firstName;
  String lastName;
  int color;
  double hours;
  List<Shift> shifts;

  Employee(
      {this.id,
      @required this.firstName,
      @required this.lastName,
      @required this.color,
      @required this.hours}) {
    this.shifts = [];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      DatabaseProvider.COLUMN_FIRST_NAME: firstName,
      DatabaseProvider.COLUMN_LAST_NAME: lastName,
      DatabaseProvider.COLUMN_COLOR: color,
      DatabaseProvider.COLUMN_HOURS: hours,
      DatabaseProvider.COLUMN_SHIFTS: jsonEncode(shifts)
    };

    if (id != null) map[DatabaseProvider.COLUMN_ID] = id;

    return map;
  }

  Employee.fromMap(Map<String, dynamic> map) {
    id = map[DatabaseProvider.COLUMN_ID];
    firstName = map[DatabaseProvider.COLUMN_FIRST_NAME];
    lastName = map[DatabaseProvider.COLUMN_LAST_NAME];
    color = map[DatabaseProvider.COLUMN_COLOR];
    hours = map[DatabaseProvider.COLUMN_HOURS];
    shifts = parseShifts(map[DatabaseProvider.COLUMN_SHIFTS]);
  }
}
