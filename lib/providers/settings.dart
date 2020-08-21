import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../db/database_provider.dart';
import '../util/date_functions.dart';

class Settings with ChangeNotifier {
  Map<String, dynamic> _options = {DatabaseProvider.COLUMN_H24: false};
  DateTime _selectedDate = getNextWeek()[0];

  Future<void> loadSettings() async {
    final map = await DatabaseProvider.db.getSettings();
    _options[DatabaseProvider.COLUMN_H24] =
        map[DatabaseProvider.COLUMN_H24] == 1 ? true : false;
    print("Settings Loaded!");
  }

  Future<void> toggleTimeFormat(bool val) async {
    _options['H24'] = val;
    await DatabaseProvider.db.updateSettings(_options);
    notifyListeners();
  }

  void setCurrentDate(DateTime newDate) {
    _selectedDate = newDate;
    notifyListeners();
  }

  void decreaseDay() {
    _selectedDate = _selectedDate.subtract(Duration(days: 1));
    notifyListeners();
  }

  void increaseDay() {
    _selectedDate = _selectedDate.add(Duration(days: 1));
    notifyListeners();
  }

  bool get timeFormat {
    return _options['H24'];
  }

  DateTime get date => _selectedDate;
}
