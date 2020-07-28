import 'package:flutter/cupertino.dart';

import 'package:flutter/foundation.dart';

class Settings with ChangeNotifier {
  Map<String, dynamic> _options = {'H24': false};

  void toggleTimeFormat() {
    _options['H24'] = !_options['H24'];
  }

  bool get timeFormat {
    return _options['H24'];
  }
}
