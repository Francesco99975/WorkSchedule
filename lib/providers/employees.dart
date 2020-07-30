import 'package:flutter/foundation.dart';
import '../db/database_provider.dart';
import 'employee.dart';

class Employees with ChangeNotifier {
  List<Employee> _items = [];
  bool _nextWeekHours = true;

  List<Employee> get items {
    return [..._items];
  }

  Future<void> loadEmployees(int filterId) async {
    try {
      final empList = await DatabaseProvider.db.getEmployees();
      List<Employee> loadedEmps = [];
      empList.forEach((emp) {
        if (emp.deptId == null) {
          emp = Employee(
              id: emp.id,
              deptId: 1,
              firstName: emp.firstName,
              lastName: emp.lastName,
              color: emp.color,
              priority: emp.priority,
              shifts: emp.shifts);
        }
        loadedEmps.add(emp);
      });
      _items = loadedEmps.where((emp) => emp.deptId == filterId).toList();
      print("Employees Loaded!");
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  Employee findbyId(int id) {
    return _items.firstWhere((itm) => itm.id == id);
  }

  Future<void> addEmployee(Employee emp) async {
    await DatabaseProvider.db.insertEmployee(emp);
    _items.add(emp);
    notifyListeners();
  }

  Future<void> removeEmployee(int id) async {
    final index = _items.indexWhere((itm) => itm.id == id);
    if (index >= 0) {
      print("hell0");
      await DatabaseProvider.db.deleteEmployee(id);
      _items.removeAt(index);
      notifyListeners();
    }
  }

  void rearrangeEmps(int oldIndex, int newIndex) {
    Employee tmp = _items[oldIndex];
    _items.removeAt(oldIndex);
    _items.insert(newIndex, tmp);

    if (newIndex > oldIndex) {
      for (var i = newIndex; i >= 0; --i) {
        _items[i].priority = i.toDouble();
      }
    } else if (newIndex < oldIndex) {
      for (var i = newIndex; i < _items.length; ++i) {
        _items[i].priority = i.toDouble();
      }
    }

    _items.forEach(
        (emp) async => await DatabaseProvider.db.updateEmployee(emp.id, emp));
    notifyListeners();
  }

  bool get hours {
    return _nextWeekHours;
  }

  void toggleHours() {
    _nextWeekHours = !_nextWeekHours;
    notifyListeners();
  }

  double get totWeekHours {
    return _items.fold(
        0.0, (prev, emp) => prev + emp.getWeekHours(_nextWeekHours));
  }
}
