import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/employee.dart';
import '../providers/employees.dart';
import '../util/string_extension.dart';

class EmployeeItem extends StatefulWidget {
  final Function _rebuildCalendar;

  EmployeeItem(this._rebuildCalendar);
  @override
  _EmployeeItemState createState() => _EmployeeItemState();
}

class _EmployeeItemState extends State<EmployeeItem> {
  Color _currentColor = Colors.tealAccent;

  void changeColor(Color color) => _currentColor = color;

  @override
  Widget build(BuildContext context) {
    final emp = Provider.of<Employee>(context);
    return Card(
      elevation: 3,
      child: ListTile(
        onTap: () {
          showDialog(
            context: context,
            builder: (_) =>
                _buildUpdateDialog(context, widget._rebuildCalendar),
          );
        },
        leading: GestureDetector(
          onLongPress: () async {
            _currentColor = Color(emp.color);
            await showDialog(
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
            );
            await emp.setColorEmp(_currentColor);
            widget._rebuildCalendar(
                Provider.of<Employees>(context, listen: false).items);
          },
          child: CircleAvatar(
            radius: 30,
            backgroundColor: Color(emp.color),
            child: Text(
              NumberFormat('##0.##', 'en_US').format(emp.getWeekHours(
                      Provider.of<Employees>(context, listen: false).hours)) +
                  "H",
              style: TextStyle(
                  color: useWhiteForeground(Color(emp.color))
                      ? const Color(0xffffffff)
                      : const Color(0xff000000),
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        title: Text(emp.firstName),
        subtitle: Text(emp.lastName),
        trailing: IconButton(
          icon: Icon(
            Icons.delete,
            color: Colors.red,
          ),
          onPressed: () async {
            await Provider.of<Employees>(context, listen: false)
                .removeEmployee(emp.id);
            widget._rebuildCalendar(
                Provider.of<Employees>(context, listen: false).items);
          },
        ),
      ),
    );
  }
}

Widget _buildUpdateDialog(BuildContext context, Function rebuild) {
  final emp = Provider.of<Employee>(context);
  final _fnCtrl = TextEditingController(text: emp.firstName);
  final _lnCtrl = TextEditingController(text: emp.lastName);
  return SimpleDialog(
    elevation: 3,
    title: Text(
      "Modify Employee",
      textAlign: TextAlign.center,
    ),
    contentPadding: const EdgeInsets.all(8.0),
    children: <Widget>[
      Column(
        children: <Widget>[
          TextField(
            decoration: InputDecoration(labelText: "First Name"),
            controller: _fnCtrl,
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
            decoration: InputDecoration(labelText: "Last Name"),
            controller: _lnCtrl,
          ),
          SizedBox(
            height: 20,
          ),
          RaisedButton(
            onPressed: () async {
              if (_fnCtrl.text.trim().isNotEmpty &&
                  _lnCtrl.text.trim().isNotEmpty) {
                await emp.updateEmpName(_fnCtrl.text.trim().capitalize(),
                    _lnCtrl.text.trim().capitalize());
                rebuild(Provider.of<Employees>(context, listen: false).items);

                Navigator.of(context).pop();
              }
            },
            child: Text("Modify Employee"),
            color: Colors.amber,
            textColor: Colors.black,
          )
        ],
      )
    ],
  );
}
