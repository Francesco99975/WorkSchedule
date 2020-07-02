import 'package:flutter/foundation.dart';
import 'package:work_schedule/db/database_provider.dart';

class Employee {
  int id;
  String firstName;
  String lastName;

  Employee({this.id, @required this.firstName, @required this.lastName});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      DatabaseProvider.COLUMN_FIRST_NAME: firstName,
      DatabaseProvider.COLUMN_LAST_NAME: lastName
    };

    if (id != null) map[DatabaseProvider.COLUMN_ID] = id;

    return map;
  }

  Employee.fromMap(Map<String, dynamic> map) {
    id = map[DatabaseProvider.COLUMN_ID];
    firstName = map[DatabaseProvider.COLUMN_FIRST_NAME];
    lastName = map[DatabaseProvider.COLUMN_LAST_NAME];
  }
}
