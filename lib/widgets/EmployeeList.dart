import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';
import '../db/database_provider.dart';
import '../models/employee.dart';

class EmployeeList extends StatefulWidget {
  final List<Employee> _empList;
  final Function _removeEmp;
  final Function _setColorState;

  EmployeeList(this._empList, this._removeEmp, this._setColorState);

  @override
  _EmployeeListState createState() => _EmployeeListState();
}

class _EmployeeListState extends State<EmployeeList> {
  Color _currentColor = Colors.tealAccent;

  void changeColor(Color color) => setState(() => _currentColor = color);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget._empList.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 3,
          child: ListTile(
            onLongPress: () {
              _currentColor = Color(widget._empList[index].color);
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Select a color'),
                    content: SingleChildScrollView(
                      child: BlockPicker(
                        pickerColor: _currentColor,
                        onColorChanged: changeColor,
                      ),
                    ),
                  );
                },
              ).then((_) {
                widget._setColorState(index, _currentColor);
              });
            },
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: Color(widget._empList[index].color),
              child: Text(
                NumberFormat('##0.##', 'en_US')
                        .format(widget._empList[index].getWeekHours()) +
                    "H",
                style: TextStyle(
                    color:
                        useWhiteForeground(Color(widget._empList[index].color))
                            ? const Color(0xffffffff)
                            : const Color(0xff000000),
                    fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(widget._empList[index].firstName),
            subtitle: Text(widget._empList[index].lastName),
            trailing: IconButton(
              icon: Icon(
                Icons.delete,
                color: Colors.red,
              ),
              onPressed: () {
                DatabaseProvider.db
                    .deleteEmployee(widget._empList[index].id)
                    .then((value) {
                  print("Removed $value rows");
                  widget._removeEmp(index);
                });
              },
            ),
          ),
        );
      },
    );
  }
}
