import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/departments.dart';
import '../widgets/add_department_item.dart';
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
          ),
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Consumer<Departments>(
                  builder: (_, depts, __) => Container(
                    height:
                        depts.items.length * 100.0 - (depts.items.length * 10),
                    padding: const EdgeInsets.all(3.0),
                    child: ListView.builder(
                        itemCount: depts.items.length,
                        itemBuilder: (context, index) =>
                            ChangeNotifierProvider.value(
                              value: depts.items[index],
                              child: DepartmentItem(
                                  depts.items[index].id == depts.current.id,
                                  index,
                                  _rebuild),
                            )),
                  ),
                ),
                Divider(),
                AddDepartmentItem()
              ],
            ),
          ),
        ],
      ),
    );
  }
}
