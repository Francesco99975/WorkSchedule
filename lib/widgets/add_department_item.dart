import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../db/database_provider.dart';
import '../providers/department.dart';
import '../providers/departments.dart';

class AddDepartmentItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: Theme.of(context).primaryColor,
      child: ListTile(
        leading: Icon(
          Icons.add,
          color: Colors.grey[800],
          size: 26,
        ),
        title: Text(
          "Add new department",
          style: TextStyle(color: Colors.grey[800], fontSize: 18),
        ),
        onTap: () async => await showDialog(
            context: context,
            builder: (context) {
              final deptCtrl = TextEditingController();
              return AlertDialog(
                title: const Text(
                  "Add Department",
                  textAlign: TextAlign.center,
                ),
                titlePadding: const EdgeInsets.all(15.0),
                contentPadding: const EdgeInsets.all(15.0),
                elevation: 5,
                actions: <Widget>[
                  RaisedButton(
                    child: const Text("Add Department"),
                    color: Colors.amber,
                    textColor: Colors.black,
                    onPressed: () async {
                      if (deptCtrl.text.trim().isNotEmpty) {
                        var lastindex = await DatabaseProvider.db.countDepts();
                        await Provider.of<Departments>(context, listen: false)
                            .addDepartment(
                                Department(lastindex + 1, deptCtrl.text));
                        Navigator.of(context).pop();
                      }
                    },
                  )
                ],
                content: TextField(
                    controller: deptCtrl,
                    decoration: InputDecoration(labelText: "Department Name")),
              );
            }),
      ),
    );
  }
}
