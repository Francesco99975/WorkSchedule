import 'package:flutter/foundation.dart';
import 'package:work_schedule/db/database_provider.dart';
import 'package:work_schedule/providers/department.dart';

class Departments with ChangeNotifier {
  List<Department> _items = [];
  int _currentIndex = 0;

  List<Department> get items {
    return [..._items];
  }

  Department get current {
    return _items[_currentIndex];
  }

  void setCurrentIndex(int index) {
    _currentIndex = index;
  }

  Future<void> loadDepartments() async {
    try {
      final deptList = await DatabaseProvider.db.getDepartments();
      List<Department> loadedDepts = [];
      deptList.forEach((emp) {
        loadedDepts.add(emp);
      });
      _items = loadedDepts;
      print(_items);
      print("Departments Loaded!");
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> addDepartment(Department dept) async {
    await DatabaseProvider.db.insertDept(dept);
    _items.add(dept);
    notifyListeners();
  }

  Future<void> removeDepartment(int id) async {
    await DatabaseProvider.db.deleteDept(id);
    final index = _items.indexWhere((dept) => dept.id == id);
    _items.removeAt(index);
  }
}
