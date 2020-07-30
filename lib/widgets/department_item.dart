import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/department.dart';
import '../providers/departments.dart';
import '../providers/employees.dart';

class DepartmentItem extends StatelessWidget {
  final bool _selected;
  final int _index;
  final Function _rebuildCalendar;

  DepartmentItem(this._selected, this._index, this._rebuildCalendar);
  @override
  Widget build(BuildContext context) {
    final dept = Provider.of<Department>(context);
    return Dismissible(
      key: ValueKey(dept.id),
      background: Container(
        padding: const EdgeInsets.only(left: 20),
        margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 4.0),
        color: Colors.blue,
        child: Icon(
          Icons.edit,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: Container(
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 4.0),
        color: Theme.of(context).errorColor,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerRight,
      ),
      // ignore: missing_return
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart &&
            Provider.of<Departments>(context, listen: false).items.length > 1 &&
            !_selected) {
          return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Are you sure ?"),
              content: const Text("Do you want to remove this department?"),
              actions: <Widget>[
                FlatButton(
                  child: const Text("No"),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                FlatButton(
                  child: const Text("Yes"),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            ),
          );
        } else if (direction == DismissDirection.startToEnd) {
          return await showDialog(
              context: context,
              builder: (context) {
                final deptCtrl = TextEditingController(text: dept.name);
                return AlertDialog(
                  title: const Text(
                    "Edit Department",
                    textAlign: TextAlign.center,
                  ),
                  titlePadding: const EdgeInsets.all(15.0),
                  contentPadding: const EdgeInsets.all(15.0),
                  elevation: 5,
                  actions: <Widget>[
                    RaisedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text("Close"),
                      color: Colors.red[900],
                      textColor: Colors.white,
                    ),
                    RaisedButton(
                      child: const Text("Edit Department Name"),
                      color: Colors.amber,
                      textColor: Colors.black,
                      onPressed: () async {
                        if (deptCtrl.text.trim().isNotEmpty) {
                          await dept.updateName(deptCtrl.text);
                          _rebuildCalendar(
                              Provider.of<Employees>(context, listen: false)
                                  .items);
                          Navigator.of(context).pop(false);
                        }
                      },
                    )
                  ],
                  content: TextField(
                      controller: deptCtrl,
                      decoration:
                          InputDecoration(labelText: "Department Name")),
                );
              });
        }
      },
      onDismissed: (direction) async {
        if (direction == DismissDirection.endToStart &&
            Provider.of<Departments>(context, listen: false).items.length > 1 &&
            !_selected) {
          await Provider.of<Departments>(context, listen: false)
              .removeDepartment(dept.id);
        }
      },
      child: Card(
        elevation: 3,
        color: _selected ? Colors.teal[800] : Colors.grey[800],
        child: ListTile(
          leading: Icon(
            Icons.subject,
            color: Colors.amber,
            size: 26,
          ),
          title: Text(
            dept.name,
            style: TextStyle(
                color: Colors.amber, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          onTap: () async {
            Provider.of<Departments>(context, listen: false)
                .setCurrentIndex(_index);
            await Provider.of<Employees>(context, listen: false).loadEmployees(
                Provider.of<Departments>(context, listen: false).current.id);
            _rebuildCalendar(
                Provider.of<Employees>(context, listen: false).items);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
