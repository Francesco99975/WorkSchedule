import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../db/database_provider.dart';
import '../models/employee.dart';
import '../util/string_extension.dart';

class AddEmployee extends StatefulWidget {
  final Function _addEmp;

  AddEmployee(this._addEmp);

  @override
  _AddEmployeeState createState() => _AddEmployeeState();
}

class _AddEmployeeState extends State<AddEmployee> {
  final _fnCtrl = TextEditingController();
  final _lnCtrl = TextEditingController();
  Color _currentColor = Colors.tealAccent;

  void changeColor(Color color) => setState(() => _currentColor = color);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        elevation: 5,
        child: Padding(
          padding: EdgeInsets.only(
              left: 10,
              top: 10,
              right: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom + 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              TextField(
                decoration: InputDecoration(labelText: "First Name"),
                controller: _fnCtrl,
              ),
              TextField(
                decoration: InputDecoration(labelText: "Last Name"),
                controller: _lnCtrl,
              ),
              RaisedButton(
                elevation: 3.0,
                onPressed: () {
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
                  );
                },
                child: const Text('Color'),
                color: _currentColor,
                textColor: useWhiteForeground(_currentColor)
                    ? const Color(0xffffffff)
                    : const Color(0xff000000),
              ),
              RaisedButton(
                onPressed: () async {
                  var lastIndex = await DatabaseProvider.db.count();
                  if (_fnCtrl.text.trim().isNotEmpty &&
                      _lnCtrl.text.trim().isNotEmpty) {
                    Employee newEmp = Employee(
                        firstName: _fnCtrl.text.trim().capitalize(),
                        lastName: _lnCtrl.text.trim().capitalize(),
                        color: _currentColor.value,
                        hours: lastIndex.toDouble());

                    await DatabaseProvider.db
                        .insertEmployee(newEmp)
                        .then((emp) => widget._addEmp(emp));

                    Navigator.of(context).pop();
                  }
                },
                child: Text("Add Employee"),
                color: Colors.amber,
                textColor: Colors.black,
              )
            ],
          ),
        ),
      ),
    );
  }
}
