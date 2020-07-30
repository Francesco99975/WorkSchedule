import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../db/database_provider.dart';

class Settings with ChangeNotifier {
  Map<String, dynamic> _options = {DatabaseProvider.COLUMN_H24: false};

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

  bool get timeFormat {
    return _options['H24'];
  }
}
