import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../db/database_provider.dart';
import '../models/shift.dart';
import '../util/date_functions.dart';

List<Shift> parseShifts(String enc) {
  var parsedData = jsonDecode(enc) as List;
  return parsedData.map((el) {
    return Shift.fromJson(el);
  }).toList();
}

class Employee with ChangeNotifier {
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

  Future<void> updateEmpName(String fn, String ln) async {
    firstName = fn;
    lastName = ln;
    await DatabaseProvider.db.updateEmployee(id, this);
    notifyListeners();
    //Rebuild Calendar
  }

  Future<void> update(value) async {
    if (value != null && value is Shift) {
      Shift newShift = value;
      bool isDayOccupied =
          shifts.any((sh) => compareDates(sh.start, newShift.start));
      if (!isDayOccupied) {
        shifts.add(newShift);
      } else {
        int oldIndex =
            shifts.indexWhere((sh) => compareDates(sh.start, newShift.start));
        shifts.replaceRange(oldIndex, oldIndex + 1, [newShift]);
      }
    } else {
      if (value is DateTime)
        shifts.removeWhere((sh) => compareDates(sh.start, value));
    }

    await DatabaseProvider.db.updateEmployee(id, this);
    notifyListeners();
  }

  Future<void> setColorEmp(Color newColor) async {
    color = newColor.value;
    await DatabaseProvider.db.updateEmployee(id, this);
    notifyListeners();
    //Rebuild Calendar
  }

  double getWeekHours(bool next) {
    if (next) {
      return this.shifts.where((sh) => nextWeek(sh.start)).fold(
          0.0,
          (prev, sh) =>
              prev + (sh.end.difference(sh.start).inMinutes.toDouble() / 60));
    } else {
      return this.shifts.where((sh) => thisWeek(sh.start)).fold(
          0.0,
          (prev, sh) =>
              prev + (sh.end.difference(sh.start).inMinutes.toDouble() / 60));
    }
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
