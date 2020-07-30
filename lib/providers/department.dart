import 'package:flutter/foundation.dart';
import '../db/database_provider.dart';

class Department with ChangeNotifier {
  int id;
  String name;

  Department(this.id, this.name);

  Department.fromMap(Map<String, dynamic> map) {
    id = map[DatabaseProvider.COLUMN_DEPT_ID];
    name = map[DatabaseProvider.COLUMN_DEPT_NAME];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{DatabaseProvider.COLUMN_DEPT_NAME: name};

    if (id != null) map[DatabaseProvider.COLUMN_DEPT_ID] = id;

    return map;
  }

  Future<void> updateName(String newName) async {
    name = newName;
    await DatabaseProvider.db.updateDept(id, this);
    notifyListeners();
  }
}
