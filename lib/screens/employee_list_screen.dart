import 'package:draggable_flutter_list/draggable_flutter_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/employees.dart';
import '../widgets/employee_item.dart';

class EmployeeListScreen extends StatelessWidget {
  static const ROUTE_NAME = '/emp-list';

  final Function _rebuild;

  EmployeeListScreen(this._rebuild);

  @override
  Widget build(BuildContext context) {
    final emps = Provider.of<Employees>(context);
    return DragAndDropList(
      emps.items.length,
      itemBuilder: (context, index) => ChangeNotifierProvider.value(
        value: emps.items[index],
        child: EmployeeItem(_rebuild),
      ),
      dragElevation: 8.0,
      canBeDraggedTo: (oldIndex, newIndex) => true,
      onDragFinish: (oldIndex, newIndex) {
        emps.rearrangeEmps(oldIndex, newIndex);
      },
    );
  }
}
