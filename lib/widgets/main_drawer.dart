import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../db/database_provider.dart';
import '../providers/department.dart';
import '../providers/departments.dart';
import '../util/string_extension.dart';
import 'department_item.dart';

class MainDrawer extends StatelessWidget {
  final Function _rebuild;

  MainDrawer(this._rebuild);
  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 2.0,
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text("Work Schedule"),
            automaticallyImplyLeading: false,
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () async => await showDialog(
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
                                var lastindex =
                                    await DatabaseProvider.db.countDepts();
                                await Provider.of<Departments>(context,
                                        listen: false)
                                    .addDepartment(Department(lastindex + 1,
                                        deptCtrl.text.capitalize()));
                                Navigator.of(context).pop();
                              }
                            },
                          )
                        ],
                        content: TextField(
                            controller: deptCtrl,
                            decoration:
                                InputDecoration(labelText: "Department Name")),
                      );
                    }),
              )
            ],
          ),
          Consumer<Departments>(
            builder: (_, depts, __) => Container(
              height: MediaQuery.of(context).size.height - 200,
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                  itemCount: depts.items.length,
                  itemBuilder: (context, index) => ChangeNotifierProvider.value(
                        value: depts.items[index],
                        child: DepartmentItem(
                            depts.items[index].id == depts.current.id,
                            index,
                            _rebuild),
                      )),
            ),
          ),
        ],
      ),
    );
  }
}
