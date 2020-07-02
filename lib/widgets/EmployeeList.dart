import 'package:flutter/material.dart';
import '../models/employee.dart';

class EmployeeList extends StatelessWidget {
  final List<Employee> _empList;
  final Function _removeEmp;

  EmployeeList(this._empList, this._removeEmp);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _empList.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 3,
          child: ListTile(
            title: Text(_empList[index].firstName),
            subtitle: Text(_empList[index].lastName),
            trailing: IconButton(
              icon: Icon(
                Icons.delete,
                color: Colors.red,
              ),
              onPressed: () {
                _removeEmp(index);
              },
            ),
          ),
        );
      },
    );
  }
}
