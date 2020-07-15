import 'package:draggable_flutter_list/draggable_flutter_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';
import '../db/database_provider.dart';
import '../models/employee.dart';
import '../util/string_extension.dart';

class EmployeeList extends StatefulWidget {
  final List<Employee> _empList;
  final Function _removeEmp;
  final Function _setColorState;
  final Function _updateEmpName;
  final Function _rearrange;
  final bool _next;

  EmployeeList(this._empList, this._removeEmp, this._setColorState,
      this._updateEmpName, this._rearrange, this._next);

  @override
  _EmployeeListState createState() => _EmployeeListState();
}

class _EmployeeListState extends State<EmployeeList> {
  Color _currentColor = Colors.tealAccent;

  void changeColor(Color color) => _currentColor = color;

  @override
  Widget build(BuildContext context) {
    return DragAndDropList(
      widget._empList.length,
      itemBuilder: (context, index) {
        final _fnCtrl =
            TextEditingController(text: widget._empList[index].firstName);
        final _lnCtrl =
            TextEditingController(text: widget._empList[index].lastName);
        return Card(
          elevation: 3,
          child: ListTile(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return SimpleDialog(
                    elevation: 3,
                    title: Text(
                      "Modify Employee",
                      textAlign: TextAlign.center,
                    ),
                    contentPadding: EdgeInsets.all(8.0),
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          TextField(
                            decoration:
                                InputDecoration(labelText: "First Name"),
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
                            onPressed: () {
                              if (_fnCtrl.text.trim().isNotEmpty &&
                                  _lnCtrl.text.trim().isNotEmpty) {
                                widget._updateEmpName(
                                    index,
                                    _fnCtrl.text.trim().capitalize(),
                                    _lnCtrl.text.trim().capitalize());

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
                },
              );
            },
            leading: GestureDetector(
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
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Color(widget._empList[index].color),
                child: Text(
                  NumberFormat('##0.##', 'en_US').format(
                          widget._empList[index].getWeekHours(widget._next)) +
                      "H",
                  style: TextStyle(
                      color: useWhiteForeground(
                              Color(widget._empList[index].color))
                          ? const Color(0xffffffff)
                          : const Color(0xff000000),
                      fontWeight: FontWeight.bold),
                ),
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
      dragElevation: 8.0,
      canBeDraggedTo: (oldIndex, newIndex) => true,
      onDragFinish: (oldIndex, newIndex) {
        widget._rearrange(oldIndex, newIndex);
      },
    );
  }
}
