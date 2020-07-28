import 'package:draggable_flutter_list/draggable_flutter_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:work_schedule/providers/employees.dart';
import 'package:work_schedule/widgets/employee_item.dart';

class EmployeeListScreen extends StatelessWidget {
  static const ROUTE_NAME = '/emp-list';

  @override
  Widget build(BuildContext context) {
    final emps = Provider.of<Employees>(context);
    return DragAndDropList(
      emps.items.length,
      itemBuilder: (context, index) => ChangeNotifierProvider.value(
        value: emps.items[index],
        child: EmployeeItem(),
      ),
      dragElevation: 8.0,
      canBeDraggedTo: (oldIndex, newIndex) => true,
      onDragFinish: (oldIndex, newIndex) {
        emps.rearrangeEmps(oldIndex, newIndex);
      },
    );
  }
}
