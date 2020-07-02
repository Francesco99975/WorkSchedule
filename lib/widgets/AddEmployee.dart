import 'package:flutter/material.dart';
import 'package:work_schedule/models/employee.dart';
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
                onPressed: () {
                  if (_fnCtrl.text.isNotEmpty && _lnCtrl.text.isNotEmpty) {
                    widget._addEmp(Employee(
                        _fnCtrl.text.capitalize(), _lnCtrl.text.capitalize()));
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
